import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appuser/modules/home/controllers/home_controller.dart';
import 'package:vip/appuser/modules/home/views/widgets/build_offer_card.dart';

class BuildBundle extends GetView<HomeController> {
  const BuildBundle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFFB8804A).withOpacity(0.2),
        borderRadius: BorderRadius.circular(0),
      ),
      child: Column(
        children: [
          // Header avec titre et bouton "voir plus"
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                // Icône fire + titre
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB8804A).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.local_fire_department,
                        size: 20.sp,
                        color: const Color(0xFFB8804A),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Bundles are Here'.tr,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                        fontFamily: 'SF Pro Text',
                      ),
                    ),
                  ],
                ),

                Spacer(),

                // Bouton voir plus
                GestureDetector(
                  onTap: () => controller.navigateToAllHotDeals(),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB8804A),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'view_all'.tr,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily: 'SF Pro Text',
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.arrow_forward,
                          size: 14.sp,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Check out Waffarha's new bundles more savings, extra discounts on top! more offers,",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),

          // Liste horizontale des deals
          SizedBox(
            height: 233.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: controller.hotDeals.length,
              itemBuilder: (context, index) {
                final deal = controller.hotDeals[index];
                return Container(
                  width: 180.w,
                  margin: EdgeInsets.only(right: 12.w),
                  child: BuildOfferCard(
                    deal: deal,
                    onTap: () => controller.navigateToHotDeal(deal),
                    onAddToBasket: () {},
                    isFavorite: true,
                    onToggleFavorite: () {},
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
