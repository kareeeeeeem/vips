import 'package:flutter/material.dart' show DateTimeRange;
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

import '../../../core/admin_list_controller.dart';

/// Till receipt history, with the refund action.
class PosInvoicesController extends AdminListController {
  static const List<String> statuses = ['completed', 'refunded', 'cancelled'];

  final RxString statusFilter = ''.obs;
  final Rxn<DateTimeRange> dateRange = Rxn<DateTimeRange>();

  /// `totals` from the response: takings and refunds for the current filter.
  final RxNum salesTotal = RxNum(0);
  final RxNum refundedTotal = RxNum(0);

  @override
  Future<ApiResponse> fetch() => api.posInvoices(
        page: page.value,
        limit: 20,
        search: search.value,
        status: statusFilter.value,
        from: dateRange.value?.start.toIso8601String().substring(0, 10),
        to: dateRange.value?.end.toIso8601String().substring(0, 10),
      );

  @override
  void parse(Map<String, dynamic> data) {
    final totals = data['totals'];
    if (totals is Map) {
      salesTotal.value = totals['sales'] is num ? totals['sales'] as num : 0;
      refundedTotal.value = totals['refunded'] is num ? totals['refunded'] as num : 0;
    }
  }

  void setStatusFilter(String value) {
    if (statusFilter.value == value) return;
    statusFilter.value = value;
    load(resetPage: true);
  }

  void setDateRange(DateTimeRange? range) {
    dateRange.value = range;
    load(resetPage: true);
  }

  bool get hasAnyFilter =>
      search.value.isNotEmpty ||
      statusFilter.value.isNotEmpty ||
      dateRange.value != null;

  Future<bool> refund(String invoiceId, String reason) => mutate(
        () => api.posRefundInvoice(invoiceId, reason),
        successTitle: 'Refunded',
        // The server refuses a double refund or a cancelled invoice with a
        // specific message worth showing rather than a generic failure.
        failureTitle: 'Cannot refund',
      );

  /// Only a completed sale can be refunded; the button is disabled otherwise
  /// rather than failing after the tap.
  static bool isRefundable(String status) => status == 'completed';
}
