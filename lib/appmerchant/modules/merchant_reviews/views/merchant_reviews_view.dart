import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

class MerchantReviewsView extends StatefulWidget {
  const MerchantReviewsView({super.key});

  @override
  State<MerchantReviewsView> createState() => _MerchantReviewsViewState();
}

class _MerchantReviewsViewState extends State<MerchantReviewsView> {
  late final _ReviewsController ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = Get.put(_ReviewsController());
  }

  @override
  void dispose() {
    Get.delete<_ReviewsController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Get.back(),
        ),
        title: Text('Reviews & Ratings',
            style: TextStyle(color: const Color(0xFF1F2937), fontSize: 18.sp, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded, color: Color(0xFF6B7280)), onPressed: ctrl.load),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFF59E0B)));
        }
        return RefreshIndicator(
          onRefresh: ctrl.load,
          color: const Color(0xFFF59E0B),
          child: ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              _buildRatingSummary(ctrl),
              SizedBox(height: 20.h),
              _buildFilterBar(ctrl),
              SizedBox(height: 16.h),
              if (ctrl.reviews.isEmpty)
                _buildEmptyState()
              else
                ...ctrl.filteredReviews.map((r) => _buildReviewCard(r)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildRatingSummary(_ReviewsController ctrl) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Obx(() => Row(
        children: [
          Column(
            children: [
              Text(ctrl.averageRating.toStringAsFixed(1),
                  style: TextStyle(fontSize: 48.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1F2937))),
              Row(children: List.generate(5, (i) => Icon(
                i < ctrl.averageRating.floor() ? Icons.star_rounded : Icons.star_outline_rounded,
                color: const Color(0xFFF59E0B), size: 18.sp,
              ))),
              SizedBox(height: 4.h),
              Text('${ctrl.reviews.length} reviews', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))),
            ],
          ),
          SizedBox(width: 24.w),
          Expanded(
            child: Column(
              children: [5, 4, 3, 2, 1].map((star) {
                final count = ctrl.reviews.where((r) => (r['rating'] as num?) == star).length;
                final pct = ctrl.reviews.isEmpty ? 0.0 : count / ctrl.reviews.length;
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 3.h),
                  child: Row(children: [
                    Text('$star', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))),
                    SizedBox(width: 4.w),
                    const Icon(Icons.star_rounded, size: 12, color: Color(0xFFF59E0B)),
                    SizedBox(width: 8.w),
                    Expanded(child: ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: const Color(0xFFF3F4F6),
                        color: const Color(0xFFF59E0B),
                        minHeight: 6.h,
                      ),
                    )),
                    SizedBox(width: 8.w),
                    Text('$count', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))),
                  ]),
                );
              }).toList(),
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildFilterBar(_ReviewsController ctrl) {
    return Obx(() => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['All', '5★', '4★', '3★', '2★', '1★'].map((f) {
          final active = ctrl.filter.value == f;
          return GestureDetector(
            onTap: () => ctrl.filter.value = f,
            child: Container(
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: active ? const Color(0xFFF59E0B) : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: active ? const Color(0xFFF59E0B) : const Color(0xFFE5E7EB)),
              ),
              child: Text(f, style: TextStyle(
                fontSize: 13.sp,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                color: active ? Colors.white : const Color(0xFF6B7280),
              )),
            ),
          );
        }).toList(),
      ),
    ));
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.only(top: 60.h),
      child: Column(
        children: [
          Container(
            width: 100.w, height: 100.w,
            decoration: BoxDecoration(color: const Color(0xFFF59E0B).withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.star_border_outlined, size: 48.sp, color: const Color(0xFFF59E0B)),
          ),
          SizedBox(height: 24.h),
          Text('No Reviews Yet', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937))),
          SizedBox(height: 8.h),
          Text('Customer reviews will appear here\nonce they start rating your store.',
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF9CA3AF)), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final rating = (review['rating'] as num?)?.toInt() ?? 5;
    final name = review['customerName']?.toString() ?? 'Customer';
    final comment = review['comment']?.toString() ?? '';
    final date = review['createdAt']?.toString() ?? '';
    final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(
              radius: 20.r,
              backgroundColor: const Color(0xFFF59E0B).withValues(alpha: 0.15),
              child: Text(initials, style: TextStyle(color: const Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 14.sp)),
            ),
            SizedBox(width: 12.w),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                Text(date.isNotEmpty ? _formatDate(date) : 'Recently',
                    style: TextStyle(fontSize: 11.sp, color: const Color(0xFF9CA3AF))),
              ],
            )),
            Row(children: List.generate(5, (i) => Icon(
              i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 14.sp, color: const Color(0xFFF59E0B),
            ))),
          ]),
          if (comment.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(comment, style: TextStyle(fontSize: 13.sp, color: const Color(0xFF4B5563), height: 1.5)),
          ],
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) { return iso; }
  }
}

class _ReviewsController extends GetxController {
  final RxList<Map<String, dynamic>> reviews = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString filter = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final response = await ApiService().get('/merchant/reviews');
      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final list = data['reviews'] as List<dynamic>? ?? [];
        reviews.value = list.map((r) => Map<String, dynamic>.from(r)).toList();
      }
    } catch (_) {}
    finally {
      isLoading.value = false;
    }
  }

  double get averageRating {
    if (reviews.isEmpty) return 0;
    final sum = reviews.fold<double>(0, (acc, r) => acc + ((r['rating'] as num?) ?? 0));
    return sum / reviews.length;
  }

  List<Map<String, dynamic>> get filteredReviews {
    if (filter.value == 'All') return reviews;
    final star = int.tryParse(filter.value.replaceAll('★', '')) ?? 0;
    return reviews.where((r) => (r['rating'] as num?)?.toInt() == star).toList();
  }
}
