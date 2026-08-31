import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:vip/core/chat/chat_service.dart';
import 'package:vip/core/services/api_service.dart';

/// Where one order has got to.
///
/// The timeline comes from the order's recorded history, not from guessing:
/// the backend writes an entry every time the status changes, wherever the
/// change came from, so this shows what actually happened rather than a
/// standard set of steps drawn as though they had.
class OrderTrackingController extends GetxController {
  OrderTrackingController(this.orderId);

  final String orderId;
  final ApiService _api = ApiService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxMap<String, dynamic> data = <String, dynamic>{}.obs;

  StreamSubscription<dynamic>? _live;

  /// The stages an order moves through, in order. Kept separate from the
  /// history so the screen can show what is still ahead as well as what has
  /// happened — a timeline of only the past cannot say what comes next.
  static const List<String> flow = [
    'pending',
    'confirmed',
    'processing',
    'ready',
    'handover',
    'delivered',
  ];

  static String label(String status) => switch (status) {
        'pending' => 'Order placed',
        'confirmed' => 'Confirmed',
        'processing' => 'Being prepared',
        'ready' => 'Ready',
        'handover' => 'On the way',
        'picked_up' => 'Picked up',
        'delivered' => 'Delivered',
        'canceled' || 'cancelled' => 'Cancelled',
        'refund_requested' => 'Refund requested',
        'refunded' => 'Refunded',
        _ => status,
      };

  String get status => '${data['status'] ?? 'pending'}';
  String get orderNumber => '${data['orderNumber'] ?? ''}';
  String get merchantName => '${data['merchantName'] ?? ''}';
  String get merchantPhone => '${data['merchantPhone'] ?? ''}';

  /// False for orders placed before the history existed. The screen says so
  /// rather than drawing an empty timeline, which would read as nothing
  /// having happened to the order.
  bool get historyRecorded => data['historyRecorded'] == true;

  /// True once the order has left the normal flow — cancelled or refunded.
  /// The step list is meaningless then and the screen stops drawing it.
  bool get isStopped => const {
        'canceled',
        'cancelled',
        'refund_requested',
        'refunded',
      }.contains(status);

  List<Map<String, dynamic>> get history {
    final raw = data['history'];
    if (raw is! List) return const [];
    return raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// The recorded entry for a stage, or null if it has not happened.
  Map<String, dynamic>? entryFor(String stage) {
    for (final h in history) {
      if (h['status'] == stage) return h;
    }
    return null;
  }

  DateTime? get estimatedDeliveryAt =>
      DateTime.tryParse('${data['estimatedDeliveryAt'] ?? ''}');

  /// Null unless somebody is actually reporting a position. The screen hides
  /// the section entirely rather than showing an empty map, which would imply
  /// tracking that is not happening.
  Map<String, dynamic>? get liveLocation {
    final raw = data['liveLocation'];
    return raw is Map ? Map<String, dynamic>.from(raw) : null;
  }

  @override
  void onInit() {
    super.onInit();
    load();
    _listenForUpdates();
  }

  @override
  void onClose() {
    _live?.cancel();
    super.onClose();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await _api.get('/order/$orderId/tracking');
      if (response.success && response.data is Map) {
        data.value = Map<String, dynamic>.from(response.data as Map);
      } else {
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Could not load tracking for this order.';
      }
    } catch (e) {
      debugPrint('[TRACKING] load failed: $e');
      errorMessage.value = 'Could not load tracking. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Rides the connection the chat already holds open rather than opening a
  /// second socket for one more kind of message.
  void _listenForUpdates() {
    final chat = ChatService();
    chat.connect();
    _live = chat.onOrderUpdate.listen((update) {
      if ('${update['orderId']}' != orderId) return;
      // Refetched rather than patched from the event: the event carries the
      // change, the endpoint carries the whole picture, and one source is
      // easier to trust than two that could disagree.
      load();
    });
  }
}
