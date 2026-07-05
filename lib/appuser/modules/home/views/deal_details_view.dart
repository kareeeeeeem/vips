import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class DealDetailsView extends StatelessWidget {
  const DealDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deal = Get.arguments as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(
        title: Text(deal?['title']?.toString() ?? 'deal_details'.tr),
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
                        child: Image.network(
                          deal['image'].toString(),
                          fit: BoxFit.cover,
                        ),
                      ),
                    SizedBox(height: 16.h),
                    Text(
                      deal['title']?.toString() ?? '',
                      style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      deal['description']?.toString() ?? '',
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${deal['currentPrice']?.toString() ?? '-'} ${deal['currency'] ?? 'TN'}',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFF6B35),
                          ),
                        ),
                        if (deal['discount'] != null)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B35).withOpacity(0.12),
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
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 52.h),
                        backgroundColor: const Color(0xFFFF6B35),
                      ),
                      onPressed: () {
                        Get.back();
                      },
                      child: Text(
                        'back'.tr,
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
