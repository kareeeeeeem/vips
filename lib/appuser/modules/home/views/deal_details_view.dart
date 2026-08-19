import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/widgets/custom_network_image.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class DealDetailsView extends StatefulWidget {
  const DealDetailsView({super.key});

  @override
  State<DealDetailsView> createState() => _DealDetailsViewState();
}

class _DealDetailsViewState extends State<DealDetailsView> {
  bool _isLoading = false;

  Future<void> _redeemDeal(String dealId) async {
    if (dealId.isEmpty) {
      safeSnackbar('Error', 'Invalid deal', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await ApiService().post('/content/deals/$dealId/redeem', {});
      if (response.success) {
        safeSnackbar('Success', 'Deal added to your cart!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
        Get.toNamed('/cart');
      } else {
        safeSnackbar(
            'Error',
            response.message.isNotEmpty ? response.message : 'Could not redeem deal',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      safeSnackbar('Error', 'Failed to redeem deal: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // This screen also receives 'product' search results (search_controller.dart
  // has no separate product-details route) — a product has no /deals/:id/redeem
  // endpoint, so it needs its own add-to-cart call instead of "Redeem Deal".
  Future<void> _addProductToCart(Map<String, dynamic> product) async {
    final id = product['_id']?.toString() ?? product['id']?.toString() ?? '';
    if (id.isEmpty) {
      safeSnackbar('Error', 'Invalid product', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await ApiService().post('/cart/add', {
        'itemId': id,
        'itemType': 'product',
        'name': product['name'],
        'price': product['price'],
        'quantity': 1,
        'merchantId': product['merchantId'],
      });
      if (response.success) {
        safeSnackbar('Success', 'Added to your cart!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
        Get.toNamed('/cart');
      } else {
        safeSnackbar(
            'Error',
            response.message.isNotEmpty ? response.message : 'Could not add to cart',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      safeSnackbar('Error', 'Failed to add to cart: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deal = Get.arguments as Map<String, dynamic>?;
    final dealId = deal?['_id']?.toString() ?? deal?['id']?.toString() ?? '';
    final isProduct = deal?['type'] == 'product';
    // Outings (malls, parks, attractions from search/Explore) have no
    // price and no backend purchase/redeem action — showing "Redeem Deal"
    // for one called POST /content/deals/:id/redeem with an Outing's id,
    // which always 404s since that id isn't a Deal document.
    final isOuting = deal?['type'] == 'outing';
    final title = (deal?['title'] ?? deal?['name'])?.toString() ?? '';
    final price = deal?['currentPrice'] ?? deal?['price'];

    return Scaffold(
      appBar: AppBar(
        title: Text(title.isNotEmpty ? title : 'deal_details'.tr),
        backgroundColor: const Color(0xFFFF6B35),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: deal == null
            ? Center(child: Text('no_deal_data'.tr))
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (deal['image'] != null && deal['image'].toString().isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        height: 210.h,
                        child: CustomNetworkImage(
                          imageUrl: deal['image'].toString(),
                          fit: BoxFit.cover,
                        ),
                      ),
                    SizedBox(height: 16.h),
                    Text(
                      title,
                      style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      deal['description']?.toString() ?? '',
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                    ),
                    if (isOuting && deal['location'] != null) ...[
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16.sp, color: Colors.grey[600]),
                          SizedBox(width: 4.w),
                          Text(
                            deal['location'].toString(),
                            style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ],
                    if (!isOuting) ...[
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${price?.toString() ?? '-'} ${deal['currency'] ?? 'TN'}',
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFF6B35),
                            ),
                          ),
                          if (!isProduct && deal['discount'] != null)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B35).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                '-${deal['discount']}%',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFFF6B35),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                    SizedBox(height: 24.h),
                    if (!isOuting)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 52.h),
                          backgroundColor: const Color(0xFFFF6B35),
                          disabledBackgroundColor: const Color(0xFFFF6B35).withValues(alpha: 0.6),
                        ),
                        onPressed: _isLoading
                            ? null
                            : () => isProduct ? _addProductToCart(deal) : _redeemDeal(dealId),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : Text(
                                isProduct ? 'Add to Cart' : 'Redeem Deal',
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
