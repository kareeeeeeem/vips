import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';
import '../models/business_profile_model.dart';

/// Backs the "Switch Business" screen.
///
/// A merchant account maps to exactly one business: the backend's
/// POST /merchant/partnership/register answers 409 if a registration with
/// status pending/under_review/approved already exists for the account. So
/// this screen lists the one real business, shows its real registration
/// state, and is honest about the fact that a second one cannot be added
/// from the same login — it used to show a fabricated switcher whose rows
/// were never tappable and whose PIN gate compared against a SharedPreferences
/// value that nothing in the app ever wrote (so it was permanently '0000').
class MerchantProfileController extends GetxController {
  final profiles = <BusinessProfile>[].obs;
  final currentProfile = Rxn<BusinessProfile>();
  final isLoading = false.obs;

  /// Whether the account has a server-side PIN. Drives whether the PIN gate
  /// can be enforced at all; there is no local fallback any more.
  final RxBool hasPin = false.obs;
  final RxBool isVerifying = false.obs;

  /// Registration status of the single business, '' when never registered.
  final RxString registrationStatus = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfiles();
  }

  Future<void> loadProfiles() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        ApiService().get('/merchant/profile'),
        ApiService().get('/merchant/partnership/status'),
      ]);

      final registration = results[1];
      if (registration.success && registration.data is Map) {
        registrationStatus.value =
            (registration.data['status'] ?? '').toString();
      } else {
        registrationStatus.value = '';
      }

      final profileRes = results[0];
      if (profileRes.success && profileRes.data != null) {
        final data = profileRes.data;
        hasPin.value = data['hasPin'] == true;
        final profile = BusinessProfile(
          id: data['_id']?.toString() ?? '',
          name: data['storeName'] ?? data['fullName'] ?? 'My Store',
          type: data['storeCategory'] ?? 'Business',
          logoUrl: data['logo'] ?? data['profileImage'] ?? '',
          status: registrationStatus.value,
          isActive: true,
        );
        profiles.value = [profile];
        currentProfile.value = profile;
      }
    } catch (e) {
      debugPrint('loadProfiles failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Verifies against the account's real server-side PIN
  /// (POST /auth/pin/verify) — the same check the rest of the platform uses.
  Future<bool> verifyPin(String pin) async {
    isVerifying.value = true;
    try {
      final response = await ApiService().post('/auth/pin/verify', {'pin': pin});
      return response.success;
    } catch (e) {
      debugPrint('verifyPin failed: $e');
      return false;
    } finally {
      isVerifying.value = false;
    }
  }

  /// A second business cannot be registered from this account — the backend
  /// rejects it. Say so up front instead of walking the merchant through a
  /// multi-step form that ends in a 409.
  void addNewBusiness() {
    const blocking = {'pending', 'under_review', 'approved'};
    if (blocking.contains(registrationStatus.value)) {
      safeSnackbar(
        'Already registered',
        'This account already has a business registration '
            '(${currentProfile.value?.statusLabel ?? registrationStatus.value}). '
            'Each merchant login manages one business.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
      return;
    }
    Get.toNamed(MerchantRoutes.BUSINESS_REGISTRATION);
  }
}
