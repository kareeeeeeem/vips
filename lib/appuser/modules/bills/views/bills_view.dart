import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appuser/modules/bills/views/widgets/filter.dart';
import 'package:vip/appuser/modules/bills/views/widgets/history_list_widget.dart';
import 'package:vip/appuser/modules/bills/views/widgets/product_detail_page.dart';
import 'package:vip/appuser/modules/bills/views/widgets/product_list_page.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

import '../../home/views/widgets/build_appbar.dart';
import '../../home/views/widgets/build_drawer_menu.dart';
import '../controllers/bills_controller.dart';

class BillsView extends GetView<BillsController> {
  BillsView({super.key});
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // main_app_view.dart instantiates BillsView directly (not via
    // Get.toNamed), so BillsBinding never runs for the real "Digital"
    // bottom-nav tab — this Get.put is the only thing that ever
    // registers BillsController there, and removing it outright breaks
    // that tab. But calling Get.put unconditionally replaced the
    // controller (discarding loaded products, filter selection,
    // expanded-order state, then re-fetching from scratch) on every
    // rebuild of this widget, not just the first. Guard it instead.
    if (!Get.isRegistered<BillsController>()) {
      Get.put(BillsController());
    }
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.grey[50],
      drawer: DrawerMenu(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: BuildAppbar(() {
                scaffoldKey.currentState?.openDrawer();
              }, false),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              child: BillsFilterWidget(
                selectedFilter: controller.selectedFilter,
                onFilterChanged: controller.onFilterChanged,
              ),
            ),

            // Conditional content based on selected filter
            Expanded(
              child: Obx(() {
                if (controller.selectedFilter.value == 'History') {
                  // Show History content
                  return const HistoryListWidget();
                } else if (controller.selectedFilter.value == 'Products') {
                  if (controller.isLoading.value && controller.allProducts.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B35)));
                  }
                  if (controller.hasLoadError.value) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cloud_off, size: 48, color: Colors.grey.shade400),
                            SizedBox(height: 12.h),
                            Text(
                              'Could not load products. Check your connection and try again.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            SizedBox(height: 12.h),
                            TextButton(
                              onPressed: controller.fetchProducts,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  // Show Products content
                  return _buildProductsView();
                } else {
                  // Show Services content (original content)
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 5),
                          _buildCarousel(),
                          const SizedBox(height: 14),
                          _buildServicesGrid(),
                        ],
                      ),
                    ),
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  // NEW: Products View
  Widget _buildProductsView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories with blue banner - SCROLL HORIZONTAL
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Blue vertical banner with "Category" text
                  Container(
                    width: 35,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4285F4),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Center(
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: const Text(
                          'Category',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Categories - SCROLL HORIZONTAL (mainAxisAlignment retiré)
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.categories.length,
                      itemBuilder: (context, index) {
                        return _buildCategoryItem(controller.categories[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Best Selling Theme Section - 6 PRODUITS
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Best Selling Theme',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Get.to(
                      () => ProductListPage(
                        title: 'Best Selling Theme',
                        products: controller.bestSellingProducts,
                      ),
                    );
                  },
                  child: const Text(
                    'See All',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Best Selling Products - HORIZONTAL SCROLL (6 produits)
          SizedBox(
            height: 260,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              scrollDirection: Axis.horizontal,
              itemCount: controller.bestSellingProducts.length,
              itemBuilder: (context, index) {
                return _buildProductCard(controller.bestSellingProducts[index]);
              },
            ),
          ),

          const SizedBox(height: 16),

          // Promotional Banner
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.w),
            child: Container(
              width: Get.width,
              height: 170,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0066FF),
                borderRadius: BorderRadius.circular(0),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Browse our full digital product catalog',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => Get.to(
                        () => ProductListPage(
                          title: 'All Products',
                          products: controller.allProducts,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0066FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Browse All Products',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Trending Theme Section - 9 PRODUITS
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Trending Theme',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () => Get.to(
                    () => ProductListPage(
                      title: 'Trending Theme',
                      products: controller.trendingProducts,
                    ),
                  ),
                  child: const Text(
                    'See All',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Trending Products - MAINTENANT EN HORIZONTAL SCROLL (9 produits)
          SizedBox(
            height: 260,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              scrollDirection: Axis.horizontal,
              itemCount: controller.trendingProducts.length,
              itemBuilder: (context, index) {
                return _buildProductCard(controller.trendingProducts[index]);
              },
            ),
          ),

          const SizedBox(height: 24),

          // Feature Themes Section - 6 PRODUITS
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Feature Themes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () => Get.to(
                    () => ProductListPage(
                      title: 'Feature Themes',
                      products: controller.featureProducts,
                    ),
                  ),
                  child: const Text(
                    'See All',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Feature Products - HORIZONTAL SCROLL (6 produits)
          SizedBox(
            height: 260,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              scrollDirection: Axis.horizontal,
              itemCount: controller.featureProducts.length,
              itemBuilder: (context, index) {
                return _buildProductCard(controller.featureProducts[index]);
              },
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Category Item Widget - AVEC MARGIN A DROITE
  Widget _buildCategoryItem(CategoryItem category) {
    return GestureDetector(
      onTap: () => controller.onCategoryTap(category.title),
      child: Container(
        margin: EdgeInsets.only(right: 16.w), // MARGIN ICI POUR ESPACER
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFF6B35), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    category.icon,
                    color: const Color(0xFFFF6B35),
                    size: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Product Card Widget (for horizontal scrolling)
  Widget _buildProductCard(ProductItem product) {
    return GestureDetector(
      onTap: () => Get.to(() => ProductDetailPage(product: product)),
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with favorite and price
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.network(
                    product.imageUrl,
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 130,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 50),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: GestureDetector(
                    onTap: () async {
                      final res = await ApiService().post('/favorites/toggle', {
                        'itemId': product.id,
                        'itemType': 'Product',
                      });
                      safeSnackbar(
                        res.success ? 'Favorites' : 'Error',
                        res.success ? 'Updated your favorites' : res.message,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        color: Color(0xFF0066FF),
                        size: 18,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0066FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      // TND ('D') is the only currency this app supports
                      // anywhere — this used to show '$' on a TND-priced
                      // product, same currency label bug fixed across
                      // product_list_page.dart / product_detail_page.dart.
                      '${product.price.toStringAsFixed(1)} D',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Product Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  Text(
                    product.category,
                    style: const TextStyle(
                      color: Color(0xFF0066FF),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Title
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Sell count and rating — both real (aggregated
                  // server-side from actual Orders), not a decoration
                  // that always showed 5 gold stars for every product.
                  Row(
                    children: [
                      const Icon(Icons.download, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${product.sellCount} Sell',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      if (product.reviewCount > 0) ...[
                        const Icon(Icons.star, size: 12, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          '${product.avgRating.toStringAsFixed(1)} (${product.reviewCount})',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarousel() {
    return Column(
      children: [
        Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: PageView.builder(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              itemCount: controller.carouselImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      controller.carouselImages[index],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error, size: 50),
                        );
                      },
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue.withValues(alpha: 0.7),
                            Colors.purple.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Special Offer ${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Get amazing deals on your bills',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildCarouselIndicators(),
      ],
    );
  }

  Widget _buildCarouselIndicators() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          controller.carouselImages.length,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: controller.currentIndex.value == index ? 24 : 8,
            decoration: BoxDecoration(
              color:
                  controller.currentIndex.value == index
                      ? Colors.black87
                      : Colors.grey,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServicesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.9,
        crossAxisSpacing: 12,
        mainAxisSpacing: 1,
      ),
      itemCount: controller.services.length,
      itemBuilder: (context, index) {
        final service = controller.services[index];
        return GestureDetector(
          onTap: () => controller.onServiceTap(service.title),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image/Icon container
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    service.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(service.icon, size: 40, color: service.color);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Title
              SizedBox(
                height: 35,
                child: Text(
                  service.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
