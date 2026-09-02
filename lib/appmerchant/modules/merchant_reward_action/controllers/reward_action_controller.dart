import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

/// Targeted offers to customer segments (§6.2).
///
/// The shop's customers are grouped by what they actually did — bought once,
/// stopped coming, spend the most — and the merchant sends each group an
/// offer written for them.
class RewardActionController extends GetxController {
  final isLoading = false.obs;
  final isMutating = false.obs;
  final error = ''.obs;

  final reachedToday = 0.obs;
  final reachedWeek = 0.obs;
  final reachedMonth = 0.obs;

  final segments = <Map<String, dynamic>>[].obs;
  final actions = <Map<String, dynamic>>[].obs;

  /// Which segment the list is filtered to. Empty means all of them.
  final segmentFilter = ''.obs;

  static int _int(dynamic v) => (v as num?)?.toInt() ?? 0;
  static double _num(dynamic v) =>
      v is num ? v.toDouble() : (double.tryParse('${v ?? ''}') ?? 0);

  List<Map<String, dynamic>> get visibleActions {
    if (segmentFilter.value.isEmpty) return actions;
    return actions.where((a) => a['segment'] == segmentFilter.value).toList();
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = '';
    try {
      final results = await Future.wait([
        ApiService().get('/merchant/rewards/overview'),
        ApiService().get('/merchant/rewards/segments'),
        ApiService().get('/merchant/rewards/actions'),
      ]);

      final overview = results[0];
      if (overview.success && overview.data is Map) {
        final d = Map<String, dynamic>.from(overview.data as Map);
        reachedToday.value = _int(d['today']);
        reachedWeek.value = _int(d['thisWeek']);
        reachedMonth.value = _int(d['thisMonth']);
      }

      final segs = results[1];
      if (segs.success && segs.data is Map) {
        final d = Map<String, dynamic>.from(segs.data as Map);
        segments.value = ((d['segments'] as List?) ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }

      final acts = results[2];
      if (acts.success && acts.data is Map) {
        final d = Map<String, dynamic>.from(acts.data as Map);
        actions.value = ((d['items'] as List?) ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      } else {
        error.value = acts.message;
      }
    } catch (e) {
      debugPrint('reward actions load failed: $e');
      error.value = 'Could not reach the server.';
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic>? segmentByKey(String key) {
    for (final s in segments) {
      if (s['key'] == key) return s;
    }
    return null;
  }

  int customersIn(String key) => _int(segmentByKey(key)?['customers']);
  double spendIn(String key) => _num(segmentByKey(key)?['spend']);

  Future<bool> createAction({
    required String segment,
    required String discountType,
    required double discountValue,
    double? maxDiscountTnd,
    required int availabilityDays,
    String? message,
  }) async {
    isMutating.value = true;
    try {
      final response = await ApiService().post('/merchant/rewards/actions', {
        'segment': segment,
        'discountType': discountType,
        'discountValue': discountValue,
        if (maxDiscountTnd != null) 'maxDiscountTnd': maxDiscountTnd,
        'availabilityDays': availabilityDays,
        if (message != null && message.trim().isNotEmpty) 'message': message.trim(),
      });
      if (response.success) {
        await load();
        return true;
      }
      safeSnackbar('Not created', response.message);
      return false;
    } catch (e) {
      debugPrint('createAction failed: $e');
      safeSnackbar('Error', 'Could not reach the server. Try again.');
      return false;
    } finally {
      isMutating.value = false;
    }
  }

  Future<bool> updateAction(String id, Map<String, dynamic> changes) async {
    isMutating.value = true;
    try {
      final response =
          await ApiService().put('/merchant/rewards/actions/$id', changes);
      if (response.success) {
        await load();
        return true;
      }
      safeSnackbar('Not saved', response.message);
      return false;
    } catch (e) {
      debugPrint('updateAction failed: $e');
      safeSnackbar('Error', 'Could not reach the server. Try again.');
      return false;
    } finally {
      isMutating.value = false;
    }
  }

  /// Sends the offer. The audience is worked out at this moment, so the
  /// count the merchant sees on the confirmation is the real one.
  Future<bool> sendAction(String id) async {
    isMutating.value = true;
    try {
      final response =
          await ApiService().post('/merchant/rewards/actions/$id/send', {});
      if (response.success) {
        safeSnackbar('Sent', response.message,
            backgroundColor: const Color(0xFF10B981), colorText: Colors.white);
        await load();
        return true;
      }
      safeSnackbar('Not sent', response.message);
      return false;
    } catch (e) {
      debugPrint('sendAction failed: $e');
      safeSnackbar('Error', 'Could not reach the server. Try again.');
      return false;
    } finally {
      isMutating.value = false;
    }
  }

  static String discountLabel(Map<String, dynamic> a) {
    final value = _num(a['discountValue']);
    final amount = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
    return a['discountType'] == 'tnd' ? 'D $amount off' : '$amount% off';
  }
}
