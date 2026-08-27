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

  bool isFollowing = false;
  int followerCount = 0;
  bool followLoading = false;
  List<Map<String, dynamic>> reviews = [];
  double avgRating = 0;
  int reviewCount = 0;

  @override
  void initState() {
    super.initState();
    homeController = Get.isRegistered<HomeController>() ? Get.find<HomeController>() : Get.put(HomeController());
    merchant = Get.arguments as Map<String, dynamic>?;
    _loadProducts();
    _loadFavoriteIds();
    _loadFollowStatus();
    _loadReviews();
  }

  String? get _merchantId => (merchant?['_id'] ?? merchant?['id'])?.toString();

  Future<void> _loadFollowStatus() async {
    final id = _merchantId;
    if (id == null || id.isEmpty) return;
    try {
      final response = await ApiService().get('/content/merchants/$id/follow-status');
      if (response.success && response.data is Map) {
        final data = response.data as Map;
        if (mounted) {
          setState(() {
            isFollowing = data['following'] == true;
            followerCount = (data['followerCount'] as num?)?.toInt() ?? 0;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _toggleFollow() async {
    final id = _merchantId;
    if (id == null || id.isEmpty || followLoading) return;
    setState(() => followLoading = true);
    try {
      final response = await ApiService().post('/content/merchants/$id/follow', {});
      if (response.success && response.data is Map) {
        final data = response.data as Map;
        setState(() {
          isFollowing = data['following'] == true;
          followerCount = (data['followerCount'] as num?)?.toInt() ?? followerCount;
        });
      }
    } finally {
      if (mounted) setState(() => followLoading = false);
    }
  }

  Future<void> _loadReviews() async {
    final id = _merchantId;
    if (id == null || id.isEmpty) return;
    try {
      final response = await ApiService().get('/content/merchants/$id/reviews');
      if (response.success && response.data is Map) {
        final data = response.data as Map;
        if (mounted) {
          setState(() {
            reviews = (data['reviews'] as List? ?? [])
                .map((r) => Map<String, dynamic>.from(r as Map))
                .toList();
            avgRating = (data['avgRating'] as num?)?.toDouble() ?? 0;
            reviewCount = (data['reviewCount'] as num?)?.toInt() ?? 0;
          });
        }
      }
    } catch (_) {}
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
    final parsedBrandColor = brandColorValue is String && brandColorValue.startsWith('0x')
        ? int.tryParse(brandColorValue)
        : null;
    final brandColor = parsedBrandColor != null ? Color(parsedBrandColor) : const Color(0xFF3B82F6);

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
                  actions: [
                    // shareMerchant() was real (share_plus) and unreachable.
                    IconButton(
                      icon: const Icon(Icons.share_rounded),
                      tooltip: 'Share',
                      onPressed: () {
                        final home = Get.isRegistered<HomeController>()
                            ? Get.find<HomeController>()
                            : Get.put(HomeController());
                        home.shareMerchant(merchant!);
                      },
                    ),
                  ],
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
                        SizedBox(
                          height: 34.h,
                          child: OutlinedButton.icon(
                            onPressed: followLoading ? null : _toggleFollow,
                            icon: Icon(
                              isFollowing ? Icons.check : Icons.add,
                              size: 16.sp,
                              color: isFollowing ? Colors.grey.shade700 : brandColor,
                            ),
                            label: Text(
                              isFollowing ? 'following'.tr : 'follow'.tr,
                              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isFollowing ? Colors.grey.shade700 : brandColor,
                              side: BorderSide(color: isFollowing ? Colors.grey.shade400 : brandColor),
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '$followerCount ${'followers'.tr}',
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                        ),
                        SizedBox(width: 12.w),
                        if (reviewCount > 0) ...[
                          Icon(Icons.star, size: 14.sp, color: Colors.amber),
                          SizedBox(width: 2.w),
                          Text(
                            '$avgRating ($reviewCount)',
                            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
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
                if (reviews.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
                      child: Text(
                        '${'reviews'.tr} ($reviewCount)',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.black87),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final review = reviews[index];
                          final rating = (review['rating'] as num?)?.toInt() ?? 0;
                          return Container(
                            margin: EdgeInsets.only(bottom: 10.h),
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      review['reviewerName']?.toString() ?? 'VIPs Customer',
                                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: List.generate(
                                        5,
                                        (i) => Icon(
                                          i < rating ? Icons.star : Icons.star_border,
                                          size: 14.sp,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if ((review['review']?.toString() ?? '').isNotEmpty) ...[
                                  SizedBox(height: 6.h),
                                  Text(
                                    review['review'].toString(),
                                    style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                        childCount: reviews.length,
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
