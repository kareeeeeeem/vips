import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../design_system/atoms/app_colors.dart';
import '../controllers/search_controller.dart' as search;

class SearchView extends GetView<search.SearchController> {
  const SearchView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(search.SearchController());
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 16.h, left: 20.w, right: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec recherche et filtre
              _buildSearchHeader(),

              SizedBox(height: 20.h),

              // Contenu principal
              Expanded(
                child: Obx(
                  () =>
                      controller.isSearching.value
                          ? _buildSearchResults()
                          : _buildDefaultContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Row(
      children: [
        // Bouton retour
        GestureDetector(
          onTap: controller.goBack,
          child: Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.arrow_back_ios_new, size: 20.r),
          ),
        ),

        SizedBox(width: 12.w),

        // Champ de recherche
        Expanded(
          child: Container(
            height: 44.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller.searchTextController,
              focusNode: controller.searchFocusNode,
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Search restaurants, food...',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14.sp,
                  fontFamily: 'Poppins',
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[400],
                  size: 20.r,
                ),
                suffixIcon: Obx(
                  () =>
                      controller.searchQuery.value.isNotEmpty
                          ? GestureDetector(
                            onTap: controller.clearSearch,
                            child: Icon(
                              Icons.close,
                              color: Colors.grey[400],
                              size: 20.r,
                            ),
                          )
                          : SizedBox.shrink(),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
              onSubmitted: controller.onSearchSubmitted,
            ),
          ),
        ),

        SizedBox(width: 12.w),

        // Bouton filtre
        GestureDetector(
          onTap: controller.openFilter,
          child: Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: AppColors.AppPrimaryColor,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.AppPrimaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.tune, color: Colors.white, size: 20.r),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section recherches récentes
          Obx(() {
            if (controller.recentSearches.isEmpty) return SizedBox.shrink();

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Searches',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    GestureDetector(
                      onTap: controller.clearAllRecent,
                      child: Text(
                        'Clear All',
                        style: TextStyle(
                          color: AppColors.AppPrimaryColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                ...controller.recentSearches.asMap().entries.map((entry) {
                  int index = entry.key;
                  String search = entry.value;
                  return _buildRecentSearchItem(search, index);
                }).toList(),
                SizedBox(height: 32.h),
              ],
            );
          }),

          // Section recherches populaires
          Text(
            'Popular Searches',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),

          SizedBox(height: 16.h),

          Obx(
            () => Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children:
                  controller.popularSearches
                      .map((search) => _buildPopularChip(search))
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearchItem(String search, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.history, color: Colors.grey[400], size: 20.r),
          SizedBox(width: 12.w),
          Expanded(
            child: GestureDetector(
              onTap: () => controller.selectSearch(search),
              child: Text(
                search,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff3B3B3B),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => controller.removeRecentSearch(index),
            child: Icon(Icons.close, size: 18.r, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularChip(String search) {
    return GestureDetector(
      onTap: () => controller.selectSearch(search),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.AppPrimaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: AppColors.AppPrimaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          search,
          style: TextStyle(
            color: AppColors.AppPrimaryColor,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Obx(() {
      if (controller.filteredResults.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64.r, color: Colors.grey[300]),
              SizedBox(height: 16.h),
              Text(
                'No results found',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Try searching with different keywords',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[400],
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${controller.filteredResults.length} results found',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: ListView.builder(
              itemCount: controller.filteredResults.length,
              itemBuilder: (context, index) {
                return _buildSearchResultItem(
                  controller.filteredResults[index],
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSearchResultItem(String result) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => controller.selectSearchResult(result),
        child: Row(
          children: [
            Icon(
              Icons.restaurant,
              color: AppColors.AppPrimaryColor,
              size: 24.r,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Restaurant • Fast Food',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16.r, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
