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

  // The delivery / takeaway / dine-in / prep-time state that used to live
  // here backed a ShippingOptions block on the coupon and item forms. Nothing
  // ever read it: fulfilment is a per-ORDER choice (Order.orderType) and no
  // product or coupon field stores it, so the toggles could not affect
  // anything. Removed along with the widget rather than left as a mockup.

  // Item specific
  final isFeatureProduct = false.obs;
  final hasMultiVariants = false.obs;
  final hasPromotionalPrice = false.obs;
  final isPublished = true.obs;

  // Item form fields
  /// Promotional price, sent as Product.discountPrice. The "Add Promotional
  /// Price" checkbox previously toggled nothing — there was no field behind
  /// it and no value was ever sent.
  final itemPromoPriceCtrl = TextEditingController();
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

  // ── Coupon form ───────────────────────────────────────────
  // Every one of these is a field the backend's POST /merchant/coupons
  // actually reads. The form previously exposed a set of decorative
  // dropdowns/date boxes with no state behind them, so the only thing a
  // merchant could really vary was the code: discount was pinned at the
  // hardcoded 25 below and the expiry always fell back to the server's
  // 30-day default.
  final couponCodeCtrl = TextEditingController();
  final couponDescriptionCtrl = TextEditingController();
  final couponDiscountCtrl = TextEditingController(text: '25');
  final couponMaxDiscountCtrl = TextEditingController();
  final couponMinOrderCtrl = TextEditingController();
  final couponMaxUsageCtrl = TextEditingController();
  final couponEndDate = Rxn<DateTime>();
  final isPublishedCoupon = true.obs;

  /// Coupon.type enum, minus 'voucher' (that is the separate voucher form).
  static const List<String> couponTypes = ['percentage', 'fixed', 'shipping'];
  static const Map<String, String> couponTypeLabels = {
    'percentage': 'Percent off',
    'fixed': 'Fixed amount off',
    'shipping': 'Free shipping',
  };
  final couponType = 'percentage'.obs;

  // ── Voucher form ──────────────────────────────────────────
  final voucherCodeCtrl = TextEditingController();
  final voucherDescriptionCtrl = TextEditingController();
  final voucherMaxUsageCtrl = TextEditingController();
  final voucherEndDate = Rxn<DateTime>();
  final voucherPercent = 25.obs;
  final isPublishedVoucher = true.obs;

  /// Preset percentages offered in the voucher form's grid. The grid used to
  /// be inert — none of the boxes had a tap handler and 25 was drawn as
  /// permanently selected, so every voucher was created at 25%.
  static const List<int> voucherPercentPresets = [5, 10, 15, 20, 25, 30, 40, 50];

  // ── Plan limits (drives the "Remaining uploads" banner) ───
  /// -1 means unlimited, per the backend's plan catalogue.
  final maxProducts = 0.obs;
  final planName = ''.obs;
  final RxBool hasPlanInfo = false.obs;
  int get productsUsed => items.length;
  int get productsRemaining =>
      maxProducts.value < 0 ? -1 : (maxProducts.value - productsUsed);

  @override
  void onInit() {
    super.onInit();
    loadItems();
    loadCouponsAndVouchers();
    loadPlanLimits();
  }

  /// Real per-plan product allowance from GET /merchant/subscription/current.
  /// The "Remaining uploads" banner rendered the literal string '8/2' with a
  /// "Matches mock" comment; its own `remaining`/`total` parameters were never
  /// read.
  Future<void> loadPlanLimits() async {
    try {
      final response = await _api.get('/merchant/subscription/current');
      if (response.success && response.data is Map) {
        final features = response.data['features'];
        if (features is Map) {
          maxProducts.value = (features['maxProducts'] as num?)?.toInt() ?? 0;
        }
        planName.value = (response.data['planName'] ?? '').toString();
        hasPlanInfo.value = true;
      }
    } catch (e) {
      debugPrint('loadPlanLimits error: $e');
    }
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

  /// Flip a coupon/voucher active without deleting it. The card already
  /// showed an Active/Off badge but there was no way to change it, even
  /// though PUT /merchant/coupons/:id has always accepted `isActive`.
  Future<void> updateCouponStatus(String id, bool isActive) async {
    try {
      final response =
          await _api.put('/merchant/coupons/$id', {'isActive': isActive});
      if (!response.success) {
        safeSnackbar('Error', response.message);
      }
    } catch (e) {
      debugPrint('updateCouponStatus failed: $e');
      safeSnackbar('Error', 'Could not update that code. Please try again.');
    } finally {
      await loadCouponsAndVouchers();
    }
  }

  /// Label for a coupon/voucher's discount, honouring `Coupon.type`
  /// (percentage / fixed / voucher / shipping). The cards used to render
  /// every one of them as "N% OFF", so a fixed 50 TND coupon read as
  /// "50% OFF" and a free-shipping coupon read as "0% OFF".
  static String discountLabel(Map<String, dynamic> c) {
    final type = (c['type'] ?? 'percentage').toString();
    final raw = c['discount'] ?? c['discountPercentage'] ?? 0;
    final value = raw is num ? raw.toDouble() : (double.tryParse('$raw') ?? 0);
    final amount = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
    switch (type) {
      case 'shipping':
        return 'Free shipping';
      case 'fixed':
      case 'voucher':
        return 'D $amount OFF';
      default:
        return '$amount% OFF';
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

  /// Returns whether the product was actually created, so the caller can stop
  /// navigating away on failure — the form used to jump to the catalog even
  /// after a rejected save, which reads as success to the merchant.
  Future<bool> createItem(Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      final response = await _api.post('/merchant/products', data);
      if (response.success) {
        await loadItems();
        // Clear the form so the next "Create Item" doesn't open pre-filled
        // with the item that was just saved.
        resetItemForm();
        return true;
      }
      safeSnackbar('Error', response.message.isNotEmpty ? response.message : 'Failed to create item',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } catch (e) {
      debugPrint('createItem error: $e');
      safeSnackbar('Error', 'Could not create the item. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateItem(String id, Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      final response = await _api.put('/merchant/products/$id', data);
      if (response.success) {
        await loadItems();
        return true;
      }
      safeSnackbar('Error', response.message.isNotEmpty ? response.message : 'Failed to update item',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } catch (e) {
      debugPrint('updateItem error: $e');
      safeSnackbar('Error', 'Could not update the item. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
      return false;
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

  Future<bool> createItemFromForm() async {
    final name  = itemNameCtrl.text.trim();
    final price = double.tryParse(itemPriceCtrl.text.trim()) ?? 0.0;

    if (name.isEmpty) {
      safeSnackbar('Error', 'Product name is required', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    if (price <= 0) {
      safeSnackbar('Error', 'Please enter a valid selling price', snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    final promo = hasPromotionalPrice.value
        ? double.tryParse(itemPromoPriceCtrl.text.trim())
        : null;
    if (hasPromotionalPrice.value) {
      if (promo == null || promo <= 0) {
        safeSnackbar('Error', 'Enter the promotional price',
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }
      if (promo >= price) {
        safeSnackbar('Error', 'The promotional price must be lower than the selling price',
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    }

    return createItem(buildItemPayload(name: name, price: price, promo: promo));
  }

  /// Shared by create and edit so both paths send the exact same field set —
  /// the edit path used to omit fields the create path sent, and both dropped
  /// productType / alertQty / discountPrice entirely.
  Map<String, dynamic> buildItemPayload({
    required String name,
    required double price,
    double? promo,
  }) {
    return {
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
      'productType': selectedItemType.value,
      'alertQty':    double.tryParse(itemAlertQtyCtrl.text.trim()) ?? 0,
      'discountPrice': promo,
    };
  }

  Future<void> createCouponFromForm() async {
    final code = couponCodeCtrl.text.trim();
    if (code.isEmpty) {
      safeSnackbar('Error', 'Coupon code is required', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    // 'shipping' coupons are free-shipping — the discount figure is not what
    // makes them work, so they are the one type that does not need a value.
    final isShipping = couponType.value == 'shipping';
    final discount = double.tryParse(couponDiscountCtrl.text.trim());
    if (!isShipping && (discount == null || discount <= 0)) {
      safeSnackbar(
        'Error',
        couponType.value == 'fixed'
            ? 'Enter the discount amount'
            : 'Enter a discount percentage between 1 and 100',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (couponType.value == 'percentage' && discount != null && discount > 100) {
      safeSnackbar('Error', 'A percentage discount cannot exceed 100%',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (couponEndDate.value != null &&
        couponEndDate.value!.isBefore(DateTime.now())) {
      safeSnackbar('Error', 'The expiry date is in the past',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      final maxDiscount = double.tryParse(couponMaxDiscountCtrl.text.trim());
      final minOrder = double.tryParse(couponMinOrderCtrl.text.trim());
      final maxUsage = int.tryParse(couponMaxUsageCtrl.text.trim());
      final description = couponDescriptionCtrl.text.trim();

      final response = await _api.post('/merchant/coupons', {
        'code': code,
        'discount': isShipping ? 0 : discount,
        'type': couponType.value,
        if (maxDiscount != null && maxDiscount > 0) 'maxDiscountAmount': maxDiscount,
        if (minOrder != null && minOrder > 0) 'minOrderAmount': minOrder,
        if (maxUsage != null && maxUsage > 0) 'maxUsage': maxUsage,
        if (description.isNotEmpty) 'description': description,
        if (couponEndDate.value != null) 'expiryDate': couponEndDate.value!.toIso8601String(),
        'isActive': isPublishedCoupon.value,
        'tags': tags.toList(),
      });
      if (response.success) {
        await loadCouponsAndVouchers();
        Get.back();
        safeSnackbar('Success', 'Coupon published', snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF10B981), colorText: const Color(0xFFFFFFFF));
        _resetCouponForm();
      } else {
        safeSnackbar('Error', response.message.isNotEmpty ? response.message : 'Failed to create coupon',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      debugPrint('createCouponFromForm error: $e');
      safeSnackbar('Error', 'Could not publish the coupon. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    }
    isLoading.value = false;
  }

  void _resetCouponForm() {
    couponCodeCtrl.clear();
    couponDescriptionCtrl.clear();
    couponDiscountCtrl.text = '25';
    couponMaxDiscountCtrl.clear();
    couponMinOrderCtrl.clear();
    couponMaxUsageCtrl.clear();
    couponEndDate.value = null;
    couponType.value = 'percentage';
    isPublishedCoupon.value = true;
    tags.clear();
  }

  Future<void> createVoucherFromForm() async {
    final code = voucherCodeCtrl.text.trim();
    if (code.isEmpty) {
      safeSnackbar('Error', 'Voucher code is required', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (voucherPercent.value <= 0 || voucherPercent.value > 100) {
      safeSnackbar('Error', 'Pick a discount between 1% and 100%',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (voucherEndDate.value != null &&
        voucherEndDate.value!.isBefore(DateTime.now())) {
      safeSnackbar('Error', 'The expiry date is in the past',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      final maxUsage = int.tryParse(voucherMaxUsageCtrl.text.trim());
      final description = voucherDescriptionCtrl.text.trim();
      final response = await _api.post('/merchant/coupons', {
        'code': code,
        'discount': voucherPercent.value,
        if (maxUsage != null && maxUsage > 0) 'maxUsage': maxUsage,
        if (description.isNotEmpty) 'description': description,
        if (voucherEndDate.value != null) 'expiryDate': voucherEndDate.value!.toIso8601String(),
        'isActive': isPublishedVoucher.value,
        'type': 'voucher',
        'tags': tags.toList(),
      });
      if (response.success) {
        await loadCouponsAndVouchers();
        Get.back();
        safeSnackbar('Success', 'Voucher published', snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF10B981), colorText: const Color(0xFFFFFFFF));
        _resetVoucherForm();
      } else {
        safeSnackbar('Error', response.message.isNotEmpty ? response.message : 'Failed to create voucher',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      debugPrint('createVoucherFromForm error: $e');
      safeSnackbar('Error', 'Could not publish the voucher. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    }
    isLoading.value = false;
  }

  void _resetVoucherForm() {
    voucherCodeCtrl.clear();
    voucherDescriptionCtrl.clear();
    voucherMaxUsageCtrl.clear();
    voucherEndDate.value = null;
    voucherPercent.value = 25;
    isPublishedVoucher.value = true;
    tags.clear();
  }

  /// Adds a percentage the presets do not cover.
  void setCustomVoucherPercent(int value) {
    if (value <= 0 || value > 100) {
      safeSnackbar('Error', 'Pick a discount between 1% and 100%',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    voucherPercent.value = value;
  }

  @override
  void onClose() {
    tagController.dispose();
    itemNameCtrl.dispose();
    itemCodeCtrl.dispose();
    itemPriceCtrl.dispose();
    itemAlertQtyCtrl.dispose();
    itemVatCtrl.dispose();
    itemPromoPriceCtrl.dispose();
    couponCodeCtrl.dispose();
    couponDescriptionCtrl.dispose();
    couponDiscountCtrl.dispose();
    couponMaxDiscountCtrl.dispose();
    couponMinOrderCtrl.dispose();
    couponMaxUsageCtrl.dispose();
    voucherCodeCtrl.dispose();
    voucherDescriptionCtrl.dispose();
    voucherMaxUsageCtrl.dispose();
    super.onClose();
  }
}
