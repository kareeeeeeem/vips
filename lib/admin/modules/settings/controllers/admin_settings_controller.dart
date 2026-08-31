import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../core/admin_toast.dart';
import '../../../services/admin_api_service.dart';

/// Platform settings: the admin roster and the live integration status.
///
/// The integration flags come straight from the running backend process
/// (the same source `/api/health` reads), so this screen reports what is
/// actually configured rather than what someone believes is configured.
class AdminSettingsController extends GetxController {
  final AdminApiService _api = AdminApiService();

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<Map<String, dynamic>> admins = <Map<String, dynamic>>[].obs;

  /// The real number of admin accounts, which can exceed the roster returned.
  /// The endpoint caps the list; showing its length as the total would report
  /// a smaller platform than the one that exists.
  final RxInt adminCount = 0.obs;
  final RxBool adminsTruncated = false.obs;
  final RxMap<String, dynamic> integrations = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> environment = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await _api.settings();
      if (response.success && response.data is Map) {
        final data = Map<String, dynamic>.from(response.data as Map);
        admins.value = adminItems(data, 'admins');
        adminCount.value = adminInt(data['adminCount'], admins.length);
        adminsTruncated.value = adminBool(data['adminsTruncated']);
        integrations.value = data['integrations'] is Map
            ? Map<String, dynamic>.from(data['integrations'] as Map)
            : {};
        environment.value = data['environment'] is Map
            ? Map<String, dynamic>.from(data['environment'] as Map)
            : {};
      } else {
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Could not load platform settings.';
      }
    } catch (e) {
      debugPrint('[ADMIN SETTINGS] load failed: $e');
      errorMessage.value = 'Could not load platform settings. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createAdmin({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    if (isSaving.value) return false;
    isSaving.value = true;
    try {
      final response = await _api.createAdmin(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
      );
      if (response.success) {
        adminToast('Admin created', response.message, isError: false);
        await load();
        return true;
      }
      adminToast('Could not create admin', response.message, isError: true);
      return false;
    } catch (e) {
      debugPrint('[ADMIN SETTINGS] createAdmin failed: $e');
      adminToast('Could not create admin',
          'Could not reach the server. Please try again.', isError: true);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> removeAdmin(String id) async {
    if (isSaving.value) return false;
    isSaving.value = true;
    try {
      final response = await _api.deleteAdmin(id);
      if (response.success) {
        adminToast('Admin removed', response.message, isError: false);
        await load();
        return true;
      }
      // The backend refuses to remove the last admin, or yourself, with a
      // specific message that is more useful than a generic failure.
      adminToast('Could not remove admin', response.message, isError: true);
      return false;
    } catch (e) {
      debugPrint('[ADMIN SETTINGS] removeAdmin failed: $e');
      adminToast('Could not remove admin',
          'Could not reach the server. Please try again.', isError: true);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  bool integrationEnabled(String key) => integrations[key] == true;
}
