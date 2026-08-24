import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appuser/modules/home/controllers/home_controller.dart';
import 'package:vip/appuser/modules/home/views/widgets/build_offer_card.dart';
import 'package:vip/appuser/routes/app_pages.dart';

class FavoritesView extends StatefulWidget {
  const FavoritesView({super.key});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  late final HomeController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<HomeController>() ? Get.find<HomeController>() : Get.put(HomeController());
    controller.refreshFavoriteDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('favorites'.tr),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: Obx(() {
        if (controller.isFavoritesLoading.value && controller.favoriteItems.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Only Deal and Product favorites are ever created elsewhere in the
        // app (see home_view/build_hot_deals/merchant_details_view); any
        // other/unrecognized itemType is skipped rather than mis-rendered.
        final favorites = controller.favoriteItems.where((f) {
          final type = (f['itemType']?.toString().toLowerCase() ?? '');
          return type == 'deal' || type == 'product';
        }).toList();
        if (favorites.isEmpty) {
          return _buildEmptyState();
        }

        return GridView.builder(
          padding: EdgeInsets.all(16.w),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            childAspectRatio: 0.72,
          ),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final favorite = favorites[index];
            final isProduct = (favorite['itemType']?.toString().toLowerCase() ?? '') == 'product';
            final itemType = isProduct ? 'Product' : 'Deal';
            final rawItem = Map<String, dynamic>.from(favorite['item'] as Map);
            // Products are name/price-shaped; BuildOfferCard reads
            // title/currentPrice (deal-shaped) — same mapping
            // merchant_details_view.dart uses for the same cross-type case.
            final deal = isProduct
                ? {
                    ...rawItem,
                    'title': rawItem['name'],
                    'currentPrice': rawItem['discountPrice'] ?? rawItem['price'],
                    'originalPrice': rawItem['discountPrice'] != null ? rawItem['price'] : null,
                    // DealDetailsView branches Redeem-vs-Add-to-Cart on this.
                    'type': 'product',
                  }
                : rawItem;
            final id = (deal['_id'] ?? deal['id'])?.toString() ?? '';

            return BuildOfferCard(
              deal: deal,
              isFavorite: true,
              onTap: () => Get.toNamed(Routes.DEAL_DETAILS, arguments: deal),
              onAddToBasket: () => controller.addToCartServer(
                itemId: id,
                itemType: itemType,
                name: deal['title']?.toString(),
                price: (deal['currentPrice'] is num)
                    ? (deal['currentPrice'] as num).toDouble()
                    : 0,
                quantity: 1,
                merchantId: deal['merchantId']?.toString(),
              ),
              onToggleFavorite: () async {
                await controller.toggleFavoriteServer(id, itemType: itemType);
                controller.refreshFavoriteDetails();
              },
            );
          },
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 64.sp,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: 16.h),
            Text(
              'No favorites yet',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Tap the heart icon on any deal to save it here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
