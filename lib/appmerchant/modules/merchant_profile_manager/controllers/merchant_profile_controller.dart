import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vip/core/services/api_service.dart';
import '../models/business_profile_model.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class MerchantProfileController extends GetxController {
  final profiles = <BusinessProfile>[].obs;
  final currentProfile = Rxn<BusinessProfile>();
  final isLoading = false.obs;

  final RxString enteredPin = ''.obs;
  final RxBool isVerifying = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPin = prefs.getString('merchant_pin') ?? '0000';

      final response = await ApiService().get('/merchant/profile');
      if (response.success && response.data != null) {
        final data = response.data;
        final profile = BusinessProfile(
          id: data['_id'] ?? '',
          name: data['storeName'] ?? data['fullName'] ?? 'My Store',
          type: data['storeCategory'] ?? 'Business',
          logoUrl: data['logo'] ?? data['profileImage'] ?? '',
          pin: savedPin,
          isActive: true,
        );
        profiles.value = [profile];
        currentProfile.value = profile;
      }
    } catch (e) {
      // Fallback to empty state
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePin(String newPin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('merchant_pin', newPin);
    await _loadProfiles();
  }

  Future<bool> verifyPin(BusinessProfile profile, String pin) async {
    isVerifying.value = true;
    try {
      // Verify against locally stored PIN (persisted to SharedPreferences on changePin())
      // Server-side PIN re-auth would require a dedicated /auth/verify-pin endpoint.
      final prefs = await SharedPreferences.getInstance();
      final storedPin = prefs.getString('merchant_pin') ?? '0000';
      if (pin == storedPin) {
        _switchProfile(profile);
        return true;
      }
      return false;
    } finally {
      isVerifying.value = false;
    }
  }

  void _switchProfile(BusinessProfile profile) {
    for (var i = 0; i < profiles.length; i++) {
      profiles[i] = BusinessProfile(
        id: profiles[i].id,
        name: profiles[i].name,
        type: profiles[i].type,
        logoUrl: profiles[i].logoUrl,
        pin: profiles[i].pin,
        isActive: profiles[i].id == profile.id,
      );
    }
    currentProfile.value = profile;
    Get.back();
    safeSnackbar('Success', 'Switched to ${profile.name}');
  }

  Future<void> updateProfile({
    String? storeName,
    String? storeCategory,
    String? phone,
    String? address,
    String? description,
  }) async {
    try {
      final response = await ApiService().put('/merchant/profile', {
        if (storeName != null) 'storeName': storeName,
        if (storeCategory != null) 'storeCategory': storeCategory,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
        if (description != null) 'description': description,
      });
      if (response.success) {
        await _loadProfiles();
        safeSnackbar('Success', 'Profile updated');
      }
    } catch (e) {
      safeSnackbar('Error', 'Failed to update profile: $e');
    }
  }
}
