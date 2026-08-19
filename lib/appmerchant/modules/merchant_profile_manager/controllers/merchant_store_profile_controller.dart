import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart' as dio;
import 'package:vip/appmerchant/routes/merchant_routes.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class MerchantStoreProfileController extends GetxController {
  final RxString storeName = ''.obs;
  final RxString category = ''.obs;
  final RxString bannerImage = ''.obs;
  final RxString logoImage = ''.obs;
  final RxString phone = ''.obs;
  final RxString address = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isUploadingLogo = false.obs;
  final RxBool isUploadingBanner = false.obs;

  final RxInt selectedMainTab = 0.obs;
  final RxInt selectedContentTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    isLoading.value = true;
    try {
      final response = await ApiService().get('/merchant/profile');
      if (response.success && response.data != null) {
        final data = response.data;
        storeName.value = data['storeName'] ?? data['fullName'] ?? '';
        category.value = data['storeCategory'] ?? '';
        logoImage.value = data['logo'] ?? data['profileImage'] ?? '';
        bannerImage.value = data['coverImage'] ?? '';
        phone.value = data['phone'] ?? '';
        address.value = data['address'] ?? '';
      }
    } catch (_) {}
    finally {
      isLoading.value = false;
    }
  }

  Future<void> pickAndUploadLogo() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    isUploadingLogo.value = true;
    try {
      final url = await _uploadImage(picked);
      if (url != null) {
        logoImage.value = url;
        await ApiService().put('/merchant/profile', {'logo': url});
      }
    } finally {
      isUploadingLogo.value = false;
    }
  }

  Future<void> pickAndUploadBanner() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    isUploadingBanner.value = true;
    try {
      final url = await _uploadImage(picked);
      if (url != null) {
        bannerImage.value = url;
        await ApiService().put('/merchant/profile', {'coverImage': url});
      }
    } finally {
      isUploadingBanner.value = false;
    }
  }

  Future<String?> _uploadImage(XFile picked) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final dioClient = dio.Dio(dio.BaseOptions(
        baseUrl: ApiService.baseUrl,
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      ));
      final formData = dio.FormData.fromMap({
        'image': await dio.MultipartFile.fromFile(picked.path, filename: picked.name),
      });
      final res = await dioClient.post('/upload', data: formData);
      if (res.data['success'] == true) {
        return res.data['data']['url'] as String;
      }
      safeSnackbar('Error', 'Image upload failed', snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      safeSnackbar('Error', 'Could not upload image', snackPosition: SnackPosition.BOTTOM);
    }
    return null;
  }

  void changeMainTab(int index) => selectedMainTab.value = index;
  void changeContentTab(int index) => selectedContentTab.value = index;
  void createCoupon() => Get.toNamed(MerchantRoutes.CREATE_COUPON);
  void createVoucher() => Get.toNamed(MerchantRoutes.CREATE_VOUCHER);
  void createItem() => Get.toNamed(MerchantRoutes.CREATE_ITEM);
}
