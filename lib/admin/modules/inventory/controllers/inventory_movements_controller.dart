import 'package:flutter/material.dart' show DateTimeRange;
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

import '../../../core/admin_list_controller.dart';
import '../../../services/admin_api_service.dart';

/// The stock ledger — every recorded change to a Stock line, from the merchant
/// app as well as the console. Read-only by design: a correction is a new
/// movement, never an edit to an old one.
class InventoryMovementsController extends AdminListController {
  /// The full `StockMovement.type` enum, kept in step with the model rather
  /// than whichever subset one test session happened to produce.
  static const List<String> types = [
    'initial',
    'in',
    'out',
    'adjustment',
    'transfer_in',
    'transfer_out',
    'removed',
  ];

  final RxString typeFilter = ''.obs;
  final RxString merchantFilter = ''.obs;
  final RxString stockFilter = ''.obs;
  final Rxn<DateTimeRange> dateRange = Rxn<DateTimeRange>();

  /// `byType` from the response, used for the tab badges.
  final RxMap<String, int> typeCounts = <String, int>{}.obs;

  @override
  void onInit() {
    // Opening the ledger from a single stock line or merchant scopes it.
    final args = Get.arguments;
    if (args is Map) {
      if (args['stockId'] is String) stockFilter.value = args['stockId'] as String;
      if (args['merchantId'] is String) merchantFilter.value = args['merchantId'] as String;
      if (args['type'] is String) typeFilter.value = args['type'] as String;
    }
    super.onInit();
  }

  @override
  Future<ApiResponse> fetch() => api.inventoryMovements(
        page: page.value,
        limit: 20,
        search: search.value,
        type: typeFilter.value,
        merchantId: merchantFilter.value,
        stockId: stockFilter.value,
        from: _iso(dateRange.value?.start),
        to: _iso(dateRange.value?.end),
      );

  @override
  void parse(Map<String, dynamic> data) {
    final byType = data['byType'];
    if (byType is Map) {
      typeCounts.value = byType.map((key, value) {
        final entry = value is Map ? adminInt(value['count']) : adminInt(value);
        return MapEntry(key.toString(), entry);
      });
    }
  }

  String? _iso(DateTime? date) => date?.toIso8601String().substring(0, 10);

  int countFor(String type) {
    if (type.isEmpty) {
      return typeCounts.values.fold(0, (sum, value) => sum + value);
    }
    return typeCounts[type] ?? 0;
  }

  void setTypeFilter(String value) {
    if (typeFilter.value == value) return;
    typeFilter.value = value;
    load(resetPage: true);
  }

  void setDateRange(DateTimeRange? range) {
    dateRange.value = range;
    load(resetPage: true);
  }

  void clearScope() {
    merchantFilter.value = '';
    stockFilter.value = '';
    load(resetPage: true);
  }

  bool get hasScope =>
      merchantFilter.value.isNotEmpty || stockFilter.value.isNotEmpty;

  bool get hasAnyFilter =>
      hasScope ||
      search.value.isNotEmpty ||
      typeFilter.value.isNotEmpty ||
      dateRange.value != null;

  /// True when the movement increased the balance — drives the arrow and
  /// colour on every row.
  static bool isInbound(String type) =>
      const ['in', 'initial', 'transfer_in'].contains(type);
}
