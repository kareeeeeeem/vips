import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MerchantDetailsView extends StatelessWidget {
  const MerchantDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final merchant = Get.arguments as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(
        title: Text(merchant?['storeName']?.toString() ?? 'merchant_details'.tr),
        backgroundColor: const Color(0xFF3B82F6),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: merchant == null
            ? Center(child: Text('no_merchant_data'.tr))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    merchant['storeName']?.toString() ?? '',
                    style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    merchant['storeCategory']?.toString() ?? '',
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 16.h),
                  if (merchant['logo'] != null && merchant['logo'].toString().isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      height: 180.h,
                      child: Image.network(
                        merchant['logo'].toString(),
                        fit: BoxFit.contain,
                      ),
                    ),
                  SizedBox(height: 16.h),
                  Text(
                    'merchant_details_description'.tr,
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                  ),
                ],
              ),
      ),
    );
  }
}
