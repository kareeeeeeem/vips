import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart' as dio;
import 'package:url_launcher/url_launcher.dart';
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
  final RxString description = ''.obs;
  final RxDouble discountPercentage = 0.0.obs;
  /// Whether the storefront discount may be changed yet, and when it opens.
  /// A shop-wide discount is a promise on the storefront, so it stands for a
  /// day between changes.
  final RxBool discountEditable = true.obs;
  final Rxn<DateTime> discountEditableAt = Rxn<DateTime>();
  final RxBool isSavingDiscount = false.obs;

  /// Real contact channels, read from the merchant's BusinessRegistration
  /// (GET /merchant/partnership/status). The header used to draw a website /
  /// mail / facebook icon row that had no tap handlers and no data behind it.
  final RxString website = ''.obs;
  final RxString email = ''.obs;
  final RxString facebook = ''.obs;
  final RxString instagram = ''.obs;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isUploadingLogo = false.obs;
  final RxBool isUploadingBanner = false.obs;

  /// Content shown under the Coupon / Voucher / Items tabs. These tabs used to
  /// switch nothing but their own highlight colour — no list was ever rendered.
  final RxBool isLoadingContent = false.obs;
  final coupons = <Map<String, dynamic>>[].obs;
  final vouchers = <Map<String, dynamic>>[].obs;
  final items = <Map<String, dynamic>>[].obs;

  final RxInt selectedMainTab = 0.obs;
  final RxInt selectedContentTab = 0.obs;

  // Edit-form controllers, populated from the live profile when the sheet opens.
  final nameCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    categoryCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    descriptionCtrl.dispose();
    super.onClose();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    try {
      await Future.wait([_loadProfile(), _loadRegistration(), loadContent()]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadProfile() async {
    try {
      final response = await ApiService().get('/merchant/profile');
      if (response.success && response.data != null) {
        final data = response.data;
        storeName.value = data['storeName'] ?? data['fullName'] ?? '';
        category.value = data['storeCategory'] ?? '';
        logoImage.value = data['logo'] ?? data['profileImage'] ?? '';
        bannerImage.value = data['coverImage'] ?? '';
        phone.value = data['phone'] ?? '';
        // The User schema stores this as `storeAddress`. Reading `address`
        // (which does not exist on the document) left the address permanently
        // blank, so the header's location button silently did nothing.
        address.value = data['storeAddress'] ?? data['address'] ?? '';
        description.value = data['storeDescription'] ?? '';
        discountPercentage.value =
            (data['discountPercentage'] as num?)?.toDouble() ?? 0.0;
        unawaited(_loadDiscountLock());
        email.value = data['email'] ?? '';
      }
    } catch (_) {}
  }

  /// Website / social handles live on the BusinessRegistration document, which
  /// the registration flow already writes. Absent (merchant never registered a
  /// partnership) simply means those icons stay hidden.
  Future<void> _loadRegistration() async {
    try {
      final response = await ApiService().get('/merchant/partnership/status');
      final data = response.data;
      if (response.success && data is Map) {
        website.value = (data['website'] ?? '').toString();
        final social = data['socialMedia'];
        if (social is Map) {
          facebook.value = (social['facebook'] ?? '').toString();
          instagram.value = (social['instagram'] ?? '').toString();
        }
        final regDesc = (data['description'] ?? '').toString();
        if (description.value.isEmpty && regDesc.isNotEmpty) {
          description.value = regDesc;
        }
        final regAddress = (data['address'] ?? '').toString();
        if (address.value.isEmpty && regAddress.isNotEmpty) {
          address.value = regAddress;
        }
      }
    } catch (_) {}
  }

  Future<void> loadContent() async {
    isLoadingContent.value = true;
    try {
      final results = await Future.wait([
        ApiService().get('/merchant/coupons'),
        ApiService().get('/merchant/products'),
      ]);

      final couponRes = results[0];
      if (couponRes.success && couponRes.data is List) {
        final all = (couponRes.data as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        coupons.assignAll(
          all.where((c) => (c['type'] ?? 'percentage') != 'voucher').toList(),
        );
        vouchers.assignAll(all.where((c) => c['type'] == 'voucher').toList());
      }

      final itemRes = results[1];
      if (itemRes.success && itemRes.data is List) {
        items.assignAll(
          (itemRes.data as List)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList(),
        );
      }
    } catch (_) {
      // Leave the lists as they are; the tab renders its empty state.
    } finally {
      isLoadingContent.value = false;
    }
  }

  Future<void> pickAndUploadLogo() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
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
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
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

  Future<void> _loadDiscountLock() async {
    try {
      final response = await ApiService().get('/merchant/storefront-discount');
      if (response.success && response.data is Map) {
        final d = Map<String, dynamic>.from(response.data as Map);
        discountPercentage.value =
            (d['discountPercentage'] as num?)?.toDouble() ?? discountPercentage.value;
        discountEditable.value = d['editable'] != false;
        discountEditableAt.value =
            DateTime.tryParse((d['editableAt'] ?? '').toString());
      }
    } catch (e) {
      debugPrint('storefront discount lock unavailable: $e');
    }
  }

  /// Saves a new storefront discount.
  ///
  /// The server holds the same cooldown, so a refusal here carries its
  /// wording rather than a generic failure — the merchant needs to know it
  /// is a wait, not a fault.
  Future<bool> saveStorefrontDiscount(double percent) async {
    if (percent < 0 || percent > 100) {
      safeSnackbar('Error', 'Enter a discount between 0 and 100',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    isSavingDiscount.value = true;
    try {
      final response = await ApiService()
          .put('/merchant/storefront-discount', {'discountPercentage': percent});
      if (response.success) {
        if (response.data is Map) {
          final d = Map<String, dynamic>.from(response.data as Map);
          discountPercentage.value =
              (d['discountPercentage'] as num?)?.toDouble() ?? percent;
          discountEditable.value = d['editable'] != false;
          discountEditableAt.value =
              DateTime.tryParse((d['editableAt'] ?? '').toString());
        }
        safeSnackbar('Saved', response.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF10B981),
            colorText: const Color(0xFFFFFFFF));
        return true;
      }
      safeSnackbar('Not changed', response.message,
          snackPosition: SnackPosition.BOTTOM);
      await _loadDiscountLock();
      return false;
    } catch (e) {
      debugPrint('saveStorefrontDiscount failed: $e');
      safeSnackbar('Error', 'Could not save that. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isSavingDiscount.value = false;
    }
  }

  /// How long until the discount can be changed again, in whole hours.
  int get discountHoursRemaining {
    final at = discountEditableAt.value;
    if (at == null) return 0;
    final left = at.difference(DateTime.now());
    return left.isNegative ? 0 : left.inHours + 1;
  }

  /// Seeds the edit form with what is currently on the server so the merchant
  /// edits real values rather than blank fields.
  void prepareEditForm() {
    nameCtrl.text = storeName.value;
    categoryCtrl.text = category.value;
    phoneCtrl.text = phone.value;
    addressCtrl.text = address.value;
    descriptionCtrl.text = description.value;
  }

  /// PUT /merchant/profile. Until now there was no way anywhere in the
  /// merchant app to edit the store name, category, phone or address — the
  /// "Edit" tab only changed its own highlight.
  Future<void> saveStoreProfile() async {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      safeSnackbar('Error', 'Store name is required',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final newPhone = phoneCtrl.text.trim();
    if (newPhone.isEmpty) {
      safeSnackbar('Error', 'Phone number is required',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isSaving.value = true;
    try {
      final response = await ApiService().put('/merchant/profile', {
        'storeName': name,
        'storeCategory': categoryCtrl.text.trim(),
        'phone': newPhone,
        'address': addressCtrl.text.trim(),
        'description': descriptionCtrl.text.trim(),
      });
      if (response.success) {
        await _loadProfile();
        Get.back();
        safeSnackbar('Saved', 'Store profile updated',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        safeSnackbar(
          'Error',
          response.message.isNotEmpty
              ? response.message
              : 'Could not save the store profile. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('saveStoreProfile failed: $e');
      safeSnackbar('Error', 'Could not save the store profile. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving.value = false;
    }
  }

  void changeMainTab(int index) => selectedMainTab.value = index;
  void changeContentTab(int index) => selectedContentTab.value = index;

  void goToSwitchBusiness() => Get.toNamed(MerchantRoutes.SWITCH_BUSINESS);
  void goToAddBusiness() => Get.toNamed(MerchantRoutes.BUSINESS_REGISTRATION);

  /// The single call-to-action under the content tabs now follows the selected
  /// tab. It used to always create a Coupon, even with Voucher or Items
  /// selected, while createVoucher/createItem were never reachable at all.
  Future<void> createForSelectedTab() async {
    final route = switch (selectedContentTab.value) {
      1 => MerchantRoutes.CREATE_VOUCHER,
      2 => MerchantRoutes.CREATE_ITEM,
      _ => MerchantRoutes.CREATE_COUPON,
    };
    await Get.toNamed(route);
    // Whatever was just published should appear in the list behind it.
    await loadContent();
  }

  String get createButtonLabel => switch (selectedContentTab.value) {
        1 => 'Create Voucher',
        2 => 'Create Item',
        _ => 'Create Coupon',
      };

  Future<void> openWebsite() => _launch(_asUrl(website.value));
  Future<void> openFacebook() => _launch(_asUrl(facebook.value));
  Future<void> openInstagram() => _launch(_asUrl(instagram.value));
  Future<void> openEmail() => _launch('mailto:${email.value}');
  Future<void> callStore() => _launch('tel:${phone.value}');

  /// Opens the store's saved address in the device's maps app. The location
  /// pin next to the call button only popped the address into a toast.
  Future<void> openStoreLocation() async {
    final addr = address.value.trim();
    if (addr.isEmpty) {
      safeSnackbar(
        'No address saved',
        'Add your store address from Edit so customers can find you.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    await _launch('https://maps.google.com/?q=${Uri.encodeComponent(addr)}');
  }

  /// Registration stores handles as typed — bare domains and bare handles are
  /// both common, so normalise before handing them to the OS.
  String _asUrl(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return '';
    if (value.startsWith('http://') || value.startsWith('https://')) return value;
    return 'https://$value';
  }

  Future<void> _launch(String url) async {
    if (url.isEmpty || url == 'mailto:' || url == 'tel:') return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (e) {
      debugPrint('launch failed for $url: $e');
    }
    safeSnackbar('Unavailable', 'Could not open $url',
        snackPosition: SnackPosition.BOTTOM);
  }
}
