import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';

/// Reports anonymous screen views so the console can count visits.
///
/// The admin console reported conversion as "not tracked" because orders had
/// no denominator — nothing counted the people who looked and did not buy.
/// This is that denominator.
///
/// What it sends: a session id generated on this device, the route name, and
/// the platform. What it does not send: any device identifier, any name,
/// email or phone, and any route that still has a record id in it — the
/// backend rejects those, and [_isSafeScreen] stops them being sent at all.
///
/// Events are batched and flushed on a timer. A screen view is not worth a
/// round trip of its own on a phone connection, and analytics must never be
/// the reason the app feels slow.
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final ApiService _api = ApiService();

  /// Which app this build is. The console splits sessions by it.
  String app = 'consumer';

  String? _sessionId;
  final List<String> _pending = [];
  Timer? _timer;
  bool _enabled = true;
  bool _sending = false;

  static const Duration _flushEvery = Duration(seconds: 20);
  static const int _maxPending = 50;

  /// A session is one app launch. Held in memory only — writing it to disk
  /// would turn it into a device identifier that survives restarts, which is
  /// exactly what this is designed not to collect.
  String get sessionId => _sessionId ??= _newSessionId();

  String _newSessionId() {
    final random = Random();
    final chars = List.generate(
      24,
      (_) => 'abcdefghijklmnopqrstuvwxyz0123456789'[random.nextInt(36)],
    ).join();
    return 's$chars';
  }

  /// Read from `defaultTargetPlatform`, not `dart:io`. This file is compiled
  /// into the admin console too, which runs on the web — and importing
  /// `dart:io` there breaks the build outright.
  String get _platform {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.linux:
        return 'linux';
      default:
        return 'unknown';
    }
  }

  /// Reads the opt-out and starts the flush timer.
  ///
  /// Called once at startup. Failing here must never stop the app booting, so
  /// everything is inside the try.
  Future<void> init({String app = 'consumer'}) async {
    this.app = app;
    try {
      final prefs = await SharedPreferences.getInstance();
      _enabled = prefs.getBool('analytics_enabled') ?? true;
      _timer?.cancel();
      _timer = Timer.periodic(_flushEvery, (_) => flush());
    } catch (e) {
      debugPrint('[ANALYTICS] init failed, tracking stays off: $e');
      _enabled = false;
    }
  }

  /// Turns reporting off for this device and drops anything not yet sent.
  Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;
    if (!enabled) _pending.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('analytics_enabled', enabled);
    } catch (e) {
      debugPrint('[ANALYTICS] could not persist the preference: $e');
    }
  }

  bool get isEnabled => _enabled;

  /// A route is safe to report only if no segment of it is a record id.
  ///
  /// GetX hands over the resolved path, so a details screen arrives as
  /// '/product/68f3…'. Sending that would put a browsing history in a
  /// collection that promises not to hold one, so the id is replaced with
  /// ':id' rather than the whole event being dropped — the screen is still
  /// worth counting.
  static String normaliseScreen(String route) {
    final cleaned = route.split('?').first;
    final segments = cleaned.split('/');
    final out = segments.map((segment) {
      if (segment.isEmpty) return segment;
      final isObjectId = RegExp(r'^[0-9a-f]{24}$', caseSensitive: false).hasMatch(segment);
      final isNumber = RegExp(r'^\d{5,}$').hasMatch(segment);
      final isUuid = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        caseSensitive: false,
      ).hasMatch(segment);
      final isHash = RegExp(r'^[0-9a-f]{32,}$', caseSensitive: false).hasMatch(segment);
      return (isObjectId || isNumber || isUuid || isHash) ? ':id' : segment;
    }).join('/');
    return out.length > 80 ? out.substring(0, 80) : out;
  }

  /// Records one screen view.
  void screen(String route) {
    if (!_enabled || route.isEmpty) return;
    final normalised = normaliseScreen(route);
    if (normalised.isEmpty) return;
    _pending.add(normalised);
    // Flush early rather than grow without bound if the timer is starved.
    if (_pending.length >= _maxPending) flush();
  }

  /// Sends what has accumulated. Safe to call at any time.
  Future<void> flush() async {
    if (!_enabled || _sending || _pending.isEmpty) return;
    _sending = true;
    final batch = List<String>.from(_pending);
    _pending.clear();
    try {
      await _api.post('/analytics/track', {
        'sessionId': sessionId,
        'app': app,
        'platform': _platform,
        'events': batch.map((s) => {'screen': s}).toList(),
      });
    } catch (e) {
      // Dropped on purpose rather than retried forever: a screen view is not
      // worth keeping across a failure, and a growing retry queue is a memory
      // leak in something that must never affect the app.
      debugPrint('[ANALYTICS] flush failed, ${batch.length} event(s) dropped: $e');
    } finally {
      _sending = false;
    }
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

/// Reports every route change to [AnalyticsService].
///
/// A navigator observer rather than a call in each screen's `onInit`: a
/// tracker every screen has to remember to call is a tracker that misses
/// exactly the screens somebody forgot.
class AnalyticsRouteObserver extends NavigatorObserver {
  void _record(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name != null && name.isNotEmpty) AnalyticsService().screen(name);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _record(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _record(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    // The screen being returned to is the one now in view.
    _record(previousRoute);
  }
}
