import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

/// The customer's Giftback section (§6.1).
///
/// Points from change they chose to give up, which become spendable twelve
/// hours later. Pending and active are kept apart on purpose: a total that
/// includes points the customer cannot spend yet is a number that will be
/// wrong the moment they try.
class GiftbackController extends GetxController {
  final isLoading = false.obs;
  final error = ''.obs;

  final grants = <Map<String, dynamic>>[].obs;
  final pendingPoints = 0.obs;
  final pendingTnd = 0.0.obs;

  final capTnd = 50.0.obs;
  final usedTnd = 0.0.obs;
  final remainingTnd = 0.0.obs;
  final activationDelayHours = 12.obs;
  final maxChangeTnd = 5.0.obs;

  static double _num(dynamic v) =>
      v is num ? v.toDouble() : (double.tryParse('${v ?? ''}') ?? 0);

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = '';
    try {
      final response = await ApiService().get('/user/giftback');
      if (response.success && response.data is Map) {
        final d = Map<String, dynamic>.from(response.data as Map);
        pendingPoints.value = (d['pendingPoints'] as num?)?.toInt() ?? 0;
        pendingTnd.value = _num(d['pendingTnd']);
        activationDelayHours.value =
            (d['activationDelayHours'] as num?)?.toInt() ?? 12;
        maxChangeTnd.value = _num(d['maxChangeTnd']);

        if (d['allowance'] is Map) {
          final a = Map<String, dynamic>.from(d['allowance'] as Map);
          capTnd.value = _num(a['capTnd']);
          usedTnd.value = _num(a['usedTnd']);
          remainingTnd.value = _num(a['remainingTnd']);
        }
        grants.value = ((d['grants'] as List?) ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      } else {
        error.value = response.message.isNotEmpty
            ? response.message
            : 'Could not load your Giftback.';
      }
    } catch (e) {
      debugPrint('giftback load failed: $e');
      error.value = 'Could not reach the server.';
    } finally {
      isLoading.value = false;
    }
  }

  /// How long until a pending grant can be spent, in the customer's terms.
  String countdown(Map<String, dynamic> grant) {
    final at = DateTime.tryParse('${grant['activatesAt']}')?.toLocal();
    if (at == null) return '';
    final left = at.difference(DateTime.now());
    if (left.isNegative) return 'Ready now';
    if (left.inHours >= 1) return 'In ${left.inHours}h';
    return 'In ${left.inMinutes} min';
  }

  double get usedFraction =>
      capTnd.value <= 0 ? 0 : (usedTnd.value / capTnd.value).clamp(0, 1);
}
