import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/widgets/custom_network_image.dart';
import 'package:vip/appuser/modules/home/controllers/home_controller.dart';
import 'package:vip/appuser/modules/home/views/widgets/build_offer_card.dart';
import 'package:vip/appuser/routes/app_pages.dart';

class MerchantDetailsView extends StatefulWidget {
  const MerchantDetailsView({super.key});

  @override
  State<MerchantDetailsView> createState() => _MerchantDetailsViewState();
}

class _MerchantDetailsViewState extends State<MerchantDetailsView> {
  late final HomeController homeController;
  Map<String, dynamic>? merchant;

  bool isLoading = true;
  List<Map<String, dynamic>> products = [];
  final Set<String> favoriteIds = {};

  @override
  void initState() {
    super.initState();
    homeController = Get.isRegistered<HomeController>() ? Get.find<HomeController>() : Get.put(HomeController());
    merchant = Get.arguments as Map<String, dynamic>?;
    _loadProducts();
    _loadFavoriteIds();
  }

  Future<void> _loadFavoriteIds() async {
    try {
      final response = await ApiService().get('/favorites');
      if (response.success && response.data is List) {
        final ids = (response.data as List)
            .map((f) => f['itemId']?.toString())
            .whereType<String>();
        if (mounted) setState(() => favoriteIds.addAll(ids));
      }
    } catch (_) {}
  }

  Future<void> _toggleFavorite(String id) async {
    await homeController.toggleFavoriteServer(id, itemType: 'Product');
    setState(() {
      if (favoriteIds.contains(id)) {
        favoriteIds.remove(id);
      } else {
        favoriteIds.add(id);
      }
    });
  }

  Future<void> _loadProducts() async {
    final merchantId = merchant?['_id']?.toString() ?? merchant?['id']?.toString();
    if (merchantId == null || merchantId.isEmpty) {
      setState(() => isLoading = false);
      return;
    }
    try {
      final response = await ApiService().get('/content/products?merchantId=$merchantId');
      if (response.success && response.data is List) {
        products = (response.data as List)
            .map((p) => Map<String, dynamic>.from(p as Map))
            .toList();
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Products come back name/price-shaped; BuildOfferCard reads
  // title/currentPrice (deal-shaped), same mapping deal_details_view.dart
  // uses for cross-type search results.
  Map<String, dynamic> _asDealShaped(Map<String, dynamic> product) {
    return {
      ...product,
      'title': product['name'],
      'currentPrice': product['discountPrice'] ?? product['price'],
      'originalPrice': product['discountPrice'] != null ? product['price'] : null,
      'merchantId': product['merchantId'] ?? merchant?['_id'],
      // DealDetailsView branches its Redeem-vs-Add-to-Cart action on this —
      // without it, tapping a product here showed "Redeem Deal" and POSTed
      // to /content/deals/:id/redeem with a Product id, which always fails.
      'type': 'product',
    };
  }

  @override
  Widget build(BuildContext context) {
    final brandColorValue = merchant?['brandColor'];
    final brandColor = brandColorValue is String && brandColorValue.startsWith('0x')
        ? Color(int.parse(brandColorValue))
        : const Color(0xFF3B82F6);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: merchant == null
          ? Center(child: Text('no_merchant_data'.tr))
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: brandColor,
                  pinned: true,
                  expandedHeight: 180.h,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      merchant!['storeName']?.toString() ?? '',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
                    ),
                    background: (merchant!['logo'] != null && merchant!['logo'].toString().isNotEmpty)
                        ? CustomNetworkImage(
                            imageUrl: merchant!['logo'].toString(),
                            fit: BoxFit.cover,
                          )
                        : Container(color: brandColor),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                    child: Row(
                      children: [
                        if ((merchant!['storeCategory']?.toString() ?? '').isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: brandColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              merchant!['storeCategory'].toString(),
                              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: brandColor),
                            ),
                          ),
                        if ((merchant!['discountPercentage'] ?? 0) > 0) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              '-${merchant!['discountPercentage']}% off',
                              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.green.shade700),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
                    child: Text(
                      'Products',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.black87),
                    ),
                  ),
                ),
                if (isLoading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                else if (products.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32.w),
                      child: Center(
                        child: Text(
                          'No products from this merchant yet',
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12.h,
                        crossAxisSpacing: 12.w,
                        childAspectRatio: 0.72,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = products[index];
                          final dealShaped = _asDealShaped(product);
                          final id = (product['_id'] ?? product['id'])?.toString() ?? '';
                          return BuildOfferCard(
                            deal: dealShaped,
                            isFavorite: favoriteIds.contains(id),
                            onTap: () => Get.toNamed(Routes.DEAL_DETAILS, arguments: dealShaped),
                            onAddToBasket: () => homeController.addToCartServer(
                              itemId: id,
                              itemType: 'Product',
                              name: product['name']?.toString(),
                              price: (dealShaped['currentPrice'] is num)
                                  ? (dealShaped['currentPrice'] as num).toDouble()
                                  : 0,
                              quantity: 1,
                              merchantId: dealShaped['merchantId']?.toString(),
                            ),
                            onToggleFavorite: () => _toggleFavorite(id),
                          );
                        },
                        childCount: products.length,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
