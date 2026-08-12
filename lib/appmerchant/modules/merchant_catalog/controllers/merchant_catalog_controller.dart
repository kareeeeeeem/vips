import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:dio/dio.dart' as dio;
import 'package:vip/core/utils/safe_snackbar.dart';

class MerchantCatalogController extends GetxController {
  final _api = ApiService();

  // API-backed catalog items
  final items = <Map<String, dynamic>>[].obs;
  final coupons = <Map<String, dynamic>>[].obs;
  final vouchers = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final isUploadingImage = false.obs;

  // Common states
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();
  final selectedCategory = 'Select'.obs;

  // Shipping states
  final isDelivery = true.obs;
  final isTakeaway = true.obs;
  final isDineIn = false.obs;
  final deliveryTime = '15 Min'.obs;

  // Item specific
  final isFeatureProduct = false.obs;
  final hasMultiVariants = false.obs;
  final hasPromotionalPrice = false.obs;
  final isPublished = true.obs;

  // Item form fields
  final itemNameCtrl     = TextEditingController();
  final itemCodeCtrl     = TextEditingController();
  final itemPriceCtrl    = TextEditingController();
  final itemAlertQtyCtrl = TextEditingController();
  final itemVatCtrl      = TextEditingController();
  final itemImageUrl     = ''.obs;
  final selectedItemType     = 'Product'.obs;
  final selectedTaxMethod    = 'Exclusive'.obs;

  // Coupon / Voucher specific
  final tags = <String>[].obs;
  final tagController = TextEditingController();

  // Coupon form
  final couponCodeCtrl   = TextEditingController();
  final couponStartDate  = Rxn<DateTime>();
  final couponEndDate    = Rxn<DateTime>();
  final couponDiscount   = 25.obs;
  final couponMaxAmount  = Rxn<double>();
  final isPublishedCoupon = true.obs;

  // Voucher form
  final voucherCodeCtrl  = TextEditingController();
  final voucherStartDate = Rxn<DateTime>();
  final voucherEndDate   = Rxn<DateTime>();
  final voucherPercent   = 25.obs;
  final isPublishedVoucher = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadItems();
    loadCouponsAndVouchers();
  }

  Future<void> loadCouponsAndVouchers() async {
    try {
      final response = await _api.get('/merchant/coupons');
      if (response.success && response.data != null) {
        final list = List<Map<String, dynamic>>.from(
          (response.data as List<dynamic>).map((e) => Map<String, dynamic>.from(e as Map)),
        );
        coupons.value = list.where((c) => (c['type'] ?? 'coupon') != 'voucher').toList();
        vouchers.value = list.where((c) => c['type'] == 'voucher').toList();
      }
    } catch (_) {
      debugPrint('loadCouponsAndVouchers error');
    }
  }

  Future<void> deleteCoupon(String id) async {
    try {
      final response = await _api.delete('/merchant/coupons/$id');
      if (response.success) {
        coupons.removeWhere((c) => (c['_id'] ?? c['id'])?.toString() == id);
        vouchers.removeWhere((v) => (v['_id'] ?? v['id'])?.toString() == id);
      }
    } catch (_) {
      safeSnackbar('Error', 'Failed to delete', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> loadItems() async {
    isLoading.value = true;
    try {
      final response = await _api.get('/merchant/products');
      if (response.success && response.data != null) {
        final list = response.data as List<dynamic>;
        items.assignAll(
          list.map((e) => Map<String, dynamic>.from(e as Map)).toList(),
        );
      }
    } catch (_) {
      safeSnackbar('Error', 'Failed to load catalog', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createItem(Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      final response = await _api.post('/merchant/products', data);
      if (response.success) {
        await loadItems();
        return;
      }
      safeSnackbar('Error', response.message.isNotEmpty ? response.message : 'Failed to create item',
          snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      safeSnackbar('Error', 'Network error', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateItem(String id, Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      final response = await _api.put('/merchant/products/$id', data);
      if (response.success) {
        await loadItems();
        return;
      }
      safeSnackbar('Error', response.message.isNotEmpty ? response.message : 'Failed to update item',
          snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      safeSnackbar('Error', 'Network error', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteItem(String id) async {
    isLoading.value = true;
    try {
      final response = await _api.delete('/merchant/products/$id');
      if (response.success) {
        items.removeWhere((item) => (item['_id'] ?? item['id'])?.toString() == id);
      } else {
        safeSnackbar('Error', response.message.isNotEmpty ? response.message : 'Failed to delete item',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      safeSnackbar('Error', 'Network error', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateItemStatus(String id, bool isActive) async {
    try {
      await _api.put('/merchant/products/$id', {'isActive': isActive});
      final index = items.indexWhere((item) => (item['_id'] ?? item['id'])?.toString() == id);
      if (index != -1) {
        items[index] = Map<String, dynamic>.from(items[index])
          ..['isActive'] = isActive;
      }
    } catch (_) {
      safeSnackbar('Error', 'Failed to update status', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> updateItemStock(String id, int stock) async {
    try {
      await _api.put('/merchant/products/$id', {'stock': stock});
      final index = items.indexWhere((item) => (item['_id'] ?? item['id'])?.toString() == id);
      if (index != -1) {
        items[index] = Map<String, dynamic>.from(items[index])
          ..['stock'] = stock;
      }
    } catch (_) {
      safeSnackbar('Error', 'Failed to update stock', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> pickAndUploadImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    isUploadingImage.value = true;
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
        itemImageUrl.value = res.data['data']['url'] as String;
      } else {
        safeSnackbar('Error', 'Image upload failed', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      safeSnackbar('Error', 'Could not upload image', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isUploadingImage.value = false;
    }
  }

  void addTag(String tag) {
    if (tag.isNotEmpty && !tags.contains(tag)) {
      tags.add(tag);
      tagController.clear();
    }
  }

  void removeTag(String tag) {
    tags.remove(tag);
  }

  void resetItemForm() {
    itemNameCtrl.clear();
    itemCodeCtrl.clear();
    itemPriceCtrl.clear();
    itemAlertQtyCtrl.clear();
    itemVatCtrl.clear();
    itemImageUrl.value = '';
    isFeatureProduct.value = false;
    hasMultiVariants.value = false;
    hasPromotionalPrice.value = false;
    isPublished.value = true;
  }

  Future<void> createItemFromForm() async {
    final name  = itemNameCtrl.text.trim();
    final price = double.tryParse(itemPriceCtrl.text.trim()) ?? 0.0;

    if (name.isEmpty) {
      safeSnackbar('Error', 'Product name is required', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (price <= 0) {
      safeSnackbar('Error', 'Please enter a valid selling price', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    await createItem({
      'name':        name,
      'category':    selectedCategory.value == 'Select' ? 'General' : selectedCategory.value,
      'price':       price,
      'image':       itemImageUrl.value,
      'description': '',
      'isFeature':   isFeatureProduct.value,
      'hasVariants': hasMultiVariants.value,
      'isActive':    isPublished.value,
      'vat':         double.tryParse(itemVatCtrl.text.trim()) ?? 0.0,
      'code':        itemCodeCtrl.text.trim(),
      'taxMethod':   selectedTaxMethod.value,
    });
  }

  Future<void> createCouponFromForm() async {
    final code = couponCodeCtrl.text.trim();
    if (code.isEmpty) {
      safeSnackbar('Error', 'Coupon code is required', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    isLoading.value = true;
    try {
      final response = await _api.post('/merchant/coupons', {
        'code': code,
        'discountPercentage': couponDiscount.value,
        if (couponMaxAmount.value != null) 'maxDiscountAmount': couponMaxAmount.value,
        if (couponEndDate.value != null) 'expiryDate': couponEndDate.value!.toIso8601String(),
        'isActive': isPublishedCoupon.value,
        'tags': tags.toList(),
      });
      if (response.success) {
        Get.back();
        safeSnackbar('Success', 'Coupon published', snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF10B981), colorText: const Color(0xFFFFFFFF));
        couponCodeCtrl.clear();
        tags.clear();
      } else {
        safeSnackbar('Error', response.message.isNotEmpty ? response.message : 'Failed to create coupon',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      safeSnackbar('Error', 'Network error', snackPosition: SnackPosition.BOTTOM);
    }
    isLoading.value = false;
  }

  Future<void> createVoucherFromForm() async {
    final code = voucherCodeCtrl.text.trim();
    if (code.isEmpty) {
      safeSnackbar('Error', 'Voucher code is required', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    isLoading.value = true;
    try {
      final response = await _api.post('/merchant/coupons', {
        'code': code,
        'discountPercentage': voucherPercent.value,
        if (voucherEndDate.value != null) 'expiryDate': voucherEndDate.value!.toIso8601String(),
        'isActive': isPublishedVoucher.value,
        'type': 'voucher',
        'tags': tags.toList(),
      });
      if (response.success) {
        Get.back();
        safeSnackbar('Success', 'Voucher published', snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF10B981), colorText: const Color(0xFFFFFFFF));
        voucherCodeCtrl.clear();
        tags.clear();
      } else {
        safeSnackbar('Error', response.message.isNotEmpty ? response.message : 'Failed to create voucher',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      safeSnackbar('Error', 'Network error', snackPosition: SnackPosition.BOTTOM);
    }
    isLoading.value = false;
  }

  @override
  void onClose() {
    tagController.dispose();
    itemNameCtrl.dispose();
    itemCodeCtrl.dispose();
    itemPriceCtrl.dispose();
    itemAlertQtyCtrl.dispose();
    itemVatCtrl.dispose();
    couponCodeCtrl.dispose();
    voucherCodeCtrl.dispose();
    super.onClose();
  }
}
