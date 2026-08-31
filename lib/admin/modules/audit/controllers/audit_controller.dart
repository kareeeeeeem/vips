import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

import '../../../core/admin_list_controller.dart';
import '../../../services/admin_api_service.dart';

/// What operators have done in the console.
///
/// The platform recorded who a receipt or a stock movement belonged to, but
/// nothing recorded who banned a customer, approved a merchant or granted a
/// permission. This reads that history.
class AuditController extends AdminListController {
  final RxString actorFilter = ''.obs;
  final RxString targetFilter = ''.obs;
  final RxString outcomeFilter = ''.obs;

  /// Operators who appear in the log, with how many entries each has. Sent by
  /// the backend so the filter cannot offer someone with nothing to show.
  final RxList<Map<String, dynamic>> actors = <Map<String, dynamic>>[].obs;
  final RxList<String> targetTypes = <String>[].obs;

  static const List<String> outcomes = ['success', 'denied'];

  static String outcomeLabel(String value) => switch (value) {
        'success' => 'Went through',
        // The lines this screen exists for: an operator repeatedly hitting a
        // refusal is exactly what an audit log should surface.
        'denied' => 'Refused',
        _ => 'All outcomes',
      };

  static String targetLabel(String value) => switch (value) {
        'user' => 'Customers',
        'merchant' => 'Merchants',
        'order' => 'Orders',
        'product' => 'Products',
        'stock' => 'Stock',
        'pos' => 'Till',
        'staff' => 'Operators',
        'role' => 'Roles',
        _ => value,
      };

  @override
  Future<ApiResponse> fetch() => api.auditLogs(
        page: page.value,
        limit: 20,
        search: search.value.isEmpty ? null : search.value,
        actorId: actorFilter.value.isEmpty ? null : actorFilter.value,
        targetType: targetFilter.value.isEmpty ? null : targetFilter.value,
        outcome: outcomeFilter.value.isEmpty ? null : outcomeFilter.value,
      );

  @override
  void parse(Map<String, dynamic> data) {
    actors.value = adminItems(data, 'actors');
    final types = data['targetTypes'];
    if (types is List) {
      targetTypes.value = types.map((t) => t.toString()).toList();
    }
  }

  void setActor(String value) {
    if (actorFilter.value == value) return;
    actorFilter.value = value;
    load(resetPage: true);
  }

  void setTarget(String value) {
    if (targetFilter.value == value) return;
    targetFilter.value = value;
    load(resetPage: true);
  }

  void setOutcome(String value) {
    if (outcomeFilter.value == value) return;
    outcomeFilter.value = value;
    load(resetPage: true);
  }

  /// Refused attempts in the current page. Surfaced as a count so a run of
  /// them is visible without reading every row.
  int get refusedCount =>
      items.where((e) => !adminBool(e['success'], true)).length;
}
