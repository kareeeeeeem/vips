import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

import '../../../core/routes/admin_routes.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_scaffold.dart';
import '../../../services/admin_api_service.dart';

/// Session state for the console.
///
/// Registered permanently in `main_admin.dart` so the drawer, top bar and
/// every screen can read the signed-in admin without re-fetching.
class AdminAuthController extends GetxController {
  final AdminApiService _api = AdminApiService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxString adminName = ''.obs;
  final RxString adminEmail = ''.obs;
  final RxString adminId = ''.obs;

  /// The signed-in admin's role and effective permissions, from /admin/me.
  /// Used to hide controls the caller cannot use — presentation only: every
  /// action is gated server-side too, so this is a courtesy, not the
  /// security boundary.
  final RxString adminRole = 'viewer'.obs;
  final RxList<String> permissions = <String>[].obs;

  bool get canSubmit =>
      emailController.text.trim().isNotEmpty && passwordController.text.isNotEmpty;

  void togglePasswordVisibility() => isPasswordVisible.toggle();

  void _adopt(Map<String, dynamic> user, [Map<String, dynamic>? envelope]) {
    adminId.value    = adminString(user['_id']);
    adminName.value  = adminString(user['fullName']);
    adminEmail.value = adminString(user['email']);
    adminRole.value  = adminString(
      envelope?['adminRole'] ?? user['adminRole'],
      'viewer',
    );
    final granted = envelope?['permissions'] ?? user['permissions'];
    if (granted is List) {
      permissions.value = granted.map((p) => p.toString()).toList();
    }
  }

  /// Whether the caller holds a permission. '*' and a module wildcard both
  /// count, matching the server's own check.
  bool can(String permission) {
    if (permissions.contains('*')) return true;
    if (permissions.contains(permission)) return true;
    final module = permission.split('.').first;
    return permissions.contains('$module.*');
  }

  bool get isSuperAdmin => adminRole.value == 'super_admin';

  /// POST /admin/login. The backend refuses any non-admin account, so a
  /// customer's correct password still cannot open the console.
  Future<void> login() async {
    if (isLoading.value) return;

    if (!canSubmit) {
      safeSnackbar(
        'Missing details',
        'Enter both your admin email and password.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AdminColors.danger,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      final response = await _api.login(
        emailController.text.trim(),
        passwordController.text,
      );

      final token = response.data is Map ? response.data['token'] as String? : null;
      if (response.success && token != null && token.isNotEmpty) {
        await ApiService().setToken(token);

        final envelope = response.data is Map
            ? Map<String, dynamic>.from(response.data as Map)
            : null;
        final user = envelope?['user'];
        if (user is Map) _adopt(Map<String, dynamic>.from(user), envelope);

        passwordController.clear();
        Get.offAllNamed(AdminRoutes.DASHBOARD);
      } else {
        safeSnackbar(
          'Sign-in failed',
          response.message.isNotEmpty
              ? response.message
              : 'Invalid credentials or not an admin account.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AdminColors.danger,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // The raw exception goes to the log, never to the operator's screen —
      // the app-wide rule after an earlier sweep found 18 sites leaking
      // DioException text into user-facing toasts.
      debugPrint('[ADMIN AUTH] login failed: $e');
      safeSnackbar(
        'Sign-in failed',
        'Could not reach the server. Check your connection and try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AdminColors.danger,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Confirms the stored token still belongs to a live admin.
  /// Returns false for "not signed in", which routes back to Login.
  Future<bool> restoreSession() async {
    if (!ApiService().isLoggedIn) return false;
    try {
      final response = await _api.me();
      final envelope = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : null;
      final user = envelope?['user'];
      if (response.success && user is Map) {
        _adopt(Map<String, dynamic>.from(user), envelope);
        return true;
      }
      // A 403 here means a real token for a non-admin account (someone
      // signed into the consumer app on this device first, sharing the same
      // token key) — drop it rather than looping the splash screen.
      if (response.statusCode == 401 || response.statusCode == 403) {
        await ApiService().clearToken();
      }
      return false;
    } catch (e) {
      debugPrint('[ADMIN AUTH] restoreSession failed: $e');
      return false;
    }
  }

  Future<void> confirmLogout() async {
    final confirmed = await adminConfirm(
      title: 'Sign out',
      message: 'You will need your admin email and password to sign back in.',
      confirmLabel: 'Sign out',
    );
    if (confirmed) await logout();
  }

  Future<void> logout() async {
    try {
      // Best-effort: JWTs are stateless so this cannot revoke anything, but
      // the local token is cleared either way.
      await _api.logout();
    } catch (e) {
      debugPrint('[ADMIN AUTH] logout call failed (clearing locally anyway): $e');
    }
    await ApiService().clearToken();
    adminId.value = '';
    adminName.value = '';
    adminEmail.value = '';
    adminRole.value = 'viewer';
    permissions.clear();
    emailController.clear();
    passwordController.clear();
    Get.offAllNamed(AdminRoutes.LOGIN);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
