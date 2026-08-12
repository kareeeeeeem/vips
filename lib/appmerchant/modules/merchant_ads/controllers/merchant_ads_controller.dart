import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class MerchantAdsController extends GetxController {
  final _api = ApiService();

  final isLoading = false.obs;
  final ads = <Map<String, dynamic>>[].obs;
  final stats = <String, dynamic>{}.obs;

  final isArabicSelected = false.obs;
  final showReview = false.obs;
  final showRating = false.obs;
  final selectedCategory = 'Auto Promotion'.obs;

  // Form controllers for new ad
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final budgetController = TextEditingController();
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();
  final isCreating = false.obs;
  final uploadedImageUrl = ''.obs;

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    budgetController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    loadAds();
    loadStats();
  }

  Future<void> loadAds({String? status}) async {
    isLoading.value = true;
    try {
      final params = <String, String>{};
      if (status != null) params['status'] = status;
      final response = await _api.get('/merchant/ads', queryParams: params);
      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        ads.value = List<Map<String, dynamic>>.from(data['ads'] ?? []);
      }
    } catch (e) {
      debugPrint('loadAds error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadStats() async {
    try {
      final response = await _api.get('/merchant/ads/stats');
      if (response.success && response.data != null) {
        stats.value = Map<String, dynamic>.from(response.data as Map);
      }
    } catch (e) {
      debugPrint('loadStats error: $e');
    }
  }

  Future<void> createAd({
    required String title,
    String? description,
    String? imageUrl,
    double budget = 0,
    required String startDate,
    required String endDate,
    String adType = 'banner',
    String targetAudience = 'all',
  }) async {
    try {
      final response = await _api.post('/merchant/ads', {
        'title': title,
        'description': description ?? '',
        'imageUrl': imageUrl ?? '',
        'budget': budget,
        'startDate': startDate,
        'endDate': endDate,
        'adType': adType,
        'targetAudience': targetAudience,
      });
      if (response.success) {
        safeSnackbar('Success', 'Ad campaign created', snackPosition: SnackPosition.BOTTOM);
        await loadAds();
      } else {
        safeSnackbar('Error', response.message.isNotEmpty ? response.message : 'Failed to create ad',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      safeSnackbar('Error', 'Network error', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> pauseAd(String id) async {
    try {
      await _api.put('/merchant/ads/$id/pause', {});
      await loadAds();
    } catch (e) {
      debugPrint('pauseAd error: $e');
    }
  }

  Future<void> resumeAd(String id) async {
    try {
      await _api.put('/merchant/ads/$id/resume', {});
      await loadAds();
    } catch (e) {
      debugPrint('resumeAd error: $e');
    }
  }

  Future<void> deleteAd(String id) async {
    try {
      await _api.delete('/merchant/ads/$id');
      ads.removeWhere((a) => a['_id'] == id);
      safeSnackbar('Deleted', 'Ad removed', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      debugPrint('deleteAd error: $e');
    }
  }

  Future<void> boostAd(String id, double boostBudget) async {
    try {
      final response = await _api.post('/merchant/ads/$id/boost', {'boostBudget': boostBudget});
      if (response.success) {
        safeSnackbar('Boosted', 'Ad boosted successfully', snackPosition: SnackPosition.BOTTOM);
        await loadAds();
      } else {
        safeSnackbar('Error', response.message.isNotEmpty ? response.message : 'Failed to boost ad',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      debugPrint('boostAd error: $e');
    }
  }

  void toggleLanguage(bool isArabic) {
    isArabicSelected.value = isArabic;
  }

  Future<void> submitAdForm() async {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      safeSnackbar('Validation', 'Ad title is required', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (startDate.value == null || endDate.value == null) {
      safeSnackbar('Validation', 'Please select start and end dates', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (endDate.value!.isBefore(startDate.value!)) {
      safeSnackbar('Validation', 'End date must be after start date', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isCreating.value = true;
    try {
      final budget = double.tryParse(budgetController.text.trim()) ?? 0.0;
      await createAd(
        title: title,
        description: descriptionController.text.trim(),
        imageUrl: uploadedImageUrl.value,
        budget: budget,
        startDate: startDate.value!.toIso8601String(),
        endDate: endDate.value!.toIso8601String(),
        adType: selectedCategory.value.toLowerCase().replaceAll(' ', '_'),
      );
      resetForm();
      Get.back();
    } finally {
      isCreating.value = false;
    }
  }

  void pickStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) startDate.value = picked;
  }

  void pickEndDate(BuildContext context) async {
    final first = startDate.value ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: first.add(const Duration(days: 1)),
      firstDate: first,
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) endDate.value = picked;
  }

  void resetForm() {
    titleController.clear();
    descriptionController.clear();
    budgetController.clear();
    startDate.value = null;
    endDate.value = null;
    uploadedImageUrl.value = '';
    isArabicSelected.value = false;
    showReview.value = false;
    showRating.value = false;
    selectedCategory.value = 'Auto Promotion';
  }
}
