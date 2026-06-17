import 'package:get/get.dart';
import '../models/business_profile_model.dart';

class MerchantProfileController extends GetxController {
  final profiles = <BusinessProfile>[].obs;
  final currentProfile = Rxn<BusinessProfile>();
  
  final RxString enteredPin = ''.obs;
  final RxBool isVerifying = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProfiles();
  }

  void _loadProfiles() {
    // Mock data
    profiles.assignAll([
      BusinessProfile(
        id: '1',
        name: "McDonald's",
        type: 'Restaurant',
        logoUrl: 'https://logo.com/mcd',
        pin: '1234',
        isActive: true,
      ),
      BusinessProfile(
        id: '2',
        name: 'Zara Fashion',
        type: 'Clothing Store',
        logoUrl: 'https://logo.com/zara',
        pin: '0000',
        isActive: false,
      ),
    ]);
    currentProfile.value = profiles.firstWhere((p) => p.isActive);
  }

  Future<bool> verifyPin(BusinessProfile profile, String pin) async {
    isVerifying.value = true;
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate check
    isVerifying.value = false;
    
    if (profile.pin == pin) {
      _switchProfile(profile);
      return true;
    }
    return false;
  }

  void _switchProfile(BusinessProfile profile) {
    // Update active status locally
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
    Get.back(); // Close switcher
    Get.snackbar('Success', 'Switched to ${profile.name}');
  }
}
