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
        if (controller.isFavoritesLoading.value && controller.favoriteDealItems.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final favoriteDeals = controller.favoriteDealItems;
        if (favoriteDeals.isEmpty) {
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
          itemCount: favoriteDeals.length,
          itemBuilder: (context, index) {
            final deal = favoriteDeals[index];
            final id = (deal['_id'] ?? deal['id'])?.toString() ?? '';

            return BuildOfferCard(
              deal: deal,
              isFavorite: true,
              onTap: () => Get.toNamed(Routes.DEAL_DETAILS, arguments: deal),
              onAddToBasket: () => controller.addToCartServer(
                itemId: id,
                itemType: 'Deal',
                name: deal['title']?.toString(),
                price: (deal['currentPrice'] is num)
                    ? (deal['currentPrice'] as num).toDouble()
                    : 0,
                quantity: 1,
                merchantId: deal['merchantId']?.toString(),
              ),
              onToggleFavorite: () async {
                await controller.toggleFavoriteServer(id, itemType: 'Deal');
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
