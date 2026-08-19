import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appuser/routes/app_pages.dart';
import 'package:vip/core/services/api_service.dart';

class SearchController extends GetxController {
  final TextEditingController searchTextController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  var recentSearches = <String>[].obs;
  var popularSearches = <String>['Fast Food', 'Pizza', 'Burgers', 'Shopping', 'Entertainment'].obs;

  final _searchData = Rx<Map<String, dynamic>>({});
  var isSearching = false.obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;

  // Combined, type-tagged search results (deals/merchants/outings/products)
  // so tapping a result can navigate to the right details screen.
  var combinedResults = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    searchTextController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchFocusNode.requestFocus();
    });
  }

  @override
  void onClose() {
    searchTextController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    final query = searchTextController.text.trim();
    searchQuery.value = query;

    if (query.isEmpty) {
      isSearching.value = false;
      combinedResults.clear();
      _searchData.value = {};
    } else {
      isSearching.value = true;
      _debounceSearch(query);
    }
  }

  DateTime? _lastSearch;
  void _debounceSearch(String query) {
    _lastSearch = DateTime.now();
    final captured = _lastSearch;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_lastSearch == captured) {
        performSearch(query);
      }
    });
  }

  Future<void> performSearch(String query) async {
    if (query.isEmpty) return;
    isLoading.value = true;
    try {
      final params = <String, dynamic>{'q': query};
      if (selectedCategory.value != 'All') params['category'] = selectedCategory.value;
      if (selectedSort.value != 'Relevance') params['sort'] = selectedSort.value;
      final response = await ApiService().get('/content/search', queryParams: params);
      if (response.success && response.data != null) {
        _searchData.value = Map<String, dynamic>.from(response.data);
        // Combine all result types, tagged so the UI can show the right
        // label/icon and navigate to the right details screen on tap.
        final combined = <Map<String, dynamic>>[];
        for (var deal in dealResults) {
          combined.add({...deal, 'type': 'deal'});
        }
        for (var merchant in merchantResults) {
          combined.add({...merchant, 'type': 'merchant'});
        }
        for (var outing in outingResults) {
          combined.add({...outing, 'type': 'outing'});
        }
        for (var product in productResults) {
          combined.add({...product, 'type': 'product'});
        }
        combinedResults.value = combined;
      }
    } catch (_) {}
    isLoading.value = false;
  }

  List<Map<String, dynamic>> get dealResults =>
      List<Map<String, dynamic>>.from(_searchData.value['deals'] ?? []);

  List<Map<String, dynamic>> get outingResults =>
      List<Map<String, dynamic>>.from(_searchData.value['outings'] ?? []);

  List<Map<String, dynamic>> get merchantResults =>
      List<Map<String, dynamic>>.from(_searchData.value['merchants'] ?? []);

  List<Map<String, dynamic>> get productResults =>
      List<Map<String, dynamic>>.from(_searchData.value['products'] ?? []);

  void removeRecentSearch(int index) => recentSearches.removeAt(index);
  void clearAllRecent() => recentSearches.clear();

  void addToRecent(String query) {
    recentSearches.remove(query);
    recentSearches.insert(0, query);
    if (recentSearches.length > 10) recentSearches.removeRange(10, recentSearches.length);
  }

  void clearSearch() {
    searchTextController.clear();
    searchFocusNode.requestFocus();
  }

  void selectSearch(String searchTerm) {
    searchTextController.text = searchTerm;
    addToRecent(searchTerm);
    performSearch(searchTerm);
  }

  void onSearchSubmitted(String query) {
    if (query.isNotEmpty) addToRecent(query);
  }

  // Opens the right details screen for a tapped search result based on
  // its type, and records the search term in recents.
  void openSearchResult(Map<String, dynamic> item) {
    final title = (item['title'] ?? item['storeName'] ?? '').toString();
    if (title.isNotEmpty) addToRecent(title);

    if (item['type'] == 'merchant') {
      Get.toNamed(Routes.MERCHANT_DETAILS, arguments: item);
    } else {
      Get.toNamed(Routes.DEAL_DETAILS, arguments: item);
    }
  }

  final selectedCategory = 'All'.obs;
  final selectedSort = 'Relevance'.obs;
  final priceMin = 0.0.obs;
  final priceMax = 1000.0.obs;

  final _categories = ['All', 'Food', 'Shopping', 'Entertainment', 'Services', 'Outings'];
  final _sortOptions = ['Relevance', 'Price: Low to High', 'Price: High to Low', 'Newest', 'Rating'];

  List<String> get categories => _categories;
  List<String> get sortOptions => _sortOptions;

  void openFilter() {
    Get.bottomSheet(
      _SearchFilterSheet(controller: this),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void applyFilter() {
    if (searchQuery.value.isNotEmpty) {
      performSearch(searchQuery.value);
    }
    Get.back();
  }

  void resetFilter() {
    selectedCategory.value = 'All';
    selectedSort.value = 'Relevance';
    priceMin.value = 0.0;
    priceMax.value = 1000.0;
  }

  void goBack() => Get.back();
}

class _SearchFilterSheet extends StatelessWidget {
  final SearchController controller;
  const _SearchFilterSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filter Results', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: controller.resetFilter, child: const Text('Reset', style: TextStyle(color: Color(0xFFFF6B35)))),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Category', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
                    SizedBox(height: 12.h),
                    Obx(() => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.categories.map((cat) {
                        final selected = controller.selectedCategory.value == cat;
                        return GestureDetector(
                          onTap: () => controller.selectedCategory.value = cat,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: selected ? const Color(0xFFFF6B35) : Colors.grey[100],
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(color: selected ? const Color(0xFFFF6B35) : Colors.grey[300]!),
                            ),
                            child: Text(cat, style: TextStyle(fontSize: 13.sp, color: selected ? Colors.white : Colors.black87, fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
                          ),
                        );
                      }).toList(),
                    )),
                    SizedBox(height: 24.h),
                    Text('Sort By', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
                    SizedBox(height: 8.h),
                    Obx(() => Column(
                      children: controller.sortOptions.map((opt) {
                        return RadioListTile<String>(
                          dense: true,
                          title: Text(opt, style: TextStyle(fontSize: 14.sp)),
                          value: opt,
                          groupValue: controller.selectedSort.value,
                          onChanged: (v) { if (v != null) controller.selectedSort.value = v; },
                          fillColor: WidgetStateProperty.resolveWith((states) =>
                            states.contains(WidgetState.selected) ? const Color(0xFFFF6B35) : null),
                          selected: controller.selectedSort.value == opt,
                        );
                      }).toList(),
                    )),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
              child: ElevatedButton(
                onPressed: controller.applyFilter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 52.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  elevation: 0,
                ),
                child: Text('Apply Filter', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
