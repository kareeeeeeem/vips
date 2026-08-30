import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

import '../../../core/admin_list_controller.dart';
import '../../../services/admin_api_service.dart';

class AdminMerchantsController extends AdminListController {
  /// '' | 'active' | 'inactive'
  final RxString statusFilter = ''.obs;

  /// '' | pending | under_review | approved | rejected | none
  final RxString approvalFilter = ''.obs;

  final RxBool isLoadingDetails = false.obs;
  final Rxn<Map<String, dynamic>> details = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    final args = Get.arguments;
    if (args is Map) {
      if (args['approval'] is String) approvalFilter.value = args['approval'] as String;
      if (args['status'] is String) statusFilter.value = args['status'] as String;
    }
    super.onInit();
  }

  @override
  Future<ApiResponse> fetch() => api.merchants(
        page: page.value,
        limit: 20,
        search: search.value,
        status: statusFilter.value,
        approval: approvalFilter.value,
      );

  void setStatusFilter(String value) {
    if (statusFilter.value == value) return;
    statusFilter.value = value;
    load(resetPage: true);
  }

  void setApprovalFilter(String value) {
    if (approvalFilter.value == value) return;
    approvalFilter.value = value;
    load(resetPage: true);
  }

  Future<void> loadDetails(String id) async {
    isLoadingDetails.value = true;
    details.value = null;
    try {
      final response = await api.merchantDetails(id);
      if (response.success && response.data is Map) {
        details.value = Map<String, dynamic>.from(response.data as Map);
      }
    } catch (e) {
      debugPrint('[ADMIN MERCHANTS] loadDetails failed: $e');
    } finally {
      isLoadingDetails.value = false;
    }
  }

  Future<bool> approve(String id, {String reason = ''}) => mutate(
        () => api.approveMerchant(id, true, reason: reason),
        successTitle: 'Merchant approved',
      );

  Future<bool> reject(String id, String reason) => mutate(
        () => api.approveMerchant(id, false, reason: reason),
        successTitle: 'Merchant rejected',
      );

  Future<bool> setActive(String id, bool active) => mutate(
        () => api.activateMerchant(id, active),
        successTitle: active ? 'Merchant activated' : 'Merchant deactivated',
      );

  Future<bool> deleteMerchant(String id) => mutate(
        () => api.deleteMerchant(id),
        successTitle: 'Merchant deleted',
        // A merchant with live orders is refused by the backend with a 409
        // and a specific message — surfaced verbatim rather than as a
        // generic failure, since it tells the operator what to do instead.
        failureTitle: 'Cannot delete',
      );

  /// A merchant with no BusinessRegistration document reads as 'none'.
  String approvalOf(Map<String, dynamic> merchant) =>
      adminString(merchant['approvalStatus'], 'none');

  bool isPending(Map<String, dynamic> merchant) {
    final status = approvalOf(merchant);
    return status == 'pending' || status == 'under_review';
  }

  String displayName(Map<String, dynamic> merchant) {
    final store = adminString(merchant['storeName']);
    if (store.isNotEmpty) return store;
    final business = adminString(merchant['businessName']);
    if (business.isNotEmpty) return business;
    return adminString(merchant['fullName'], 'Unnamed merchant');
  }
}
