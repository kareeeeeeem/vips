import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appuser/modules/home/views/widgets/Build_ending_soon.dart';
import 'package:vip/appuser/modules/home/views/widgets/build_appbar.dart';
import 'package:vip/appuser/modules/home/views/widgets/build_bill_payments.dart';
import 'package:vip/appuser/modules/home/views/widgets/build_bundle.dart';
import 'package:vip/appuser/modules/home/views/widgets/build_discover_places_card.dart';
import 'package:vip/appuser/modules/home/views/widgets/build_drawer_menu.dart';
import 'package:vip/appuser/modules/home/views/widgets/build_explore_section.dart';
import 'package:vip/appuser/modules/home/views/widgets/build_featured_categories.dart';
import 'package:vip/appuser/modules/home/views/widgets/build_gift_voucher.dart';
import 'package:vip/appuser/modules/home/views/widgets/build_hero_banner.dart';
import 'package:vip/appuser/modules/home/views/widgets/build_hot_deals.dart';
import 'package:vip/appuser/modules/home/views/widgets/build_offre_details.dart';
import 'package:vip/appuser/modules/home/views/widgets/build_promotional_carousel.dart';
import 'package:vip/appuser/modules/home/views/widgets/build_quick_navigation.dart';
import 'package:vip/appuser/modules/home/views/widgets/build_restorant.dart';
import 'package:vip/appuser/modules/home/views/widgets/build_section_header.dart';
import 'package:vip/appuser/modules/home/views/widgets/build_store_alerts_section.dart';
import 'package:vip/appuser/modules/home/views/widgets/build_trending_merchants.dart';

import '../controllers/home_controller.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key, required this.fromOffer});
  final bool fromOffer;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return Scaffold(
          key: scaffoldKey,
          backgroundColor: const Color(0xFFF8FAFC),
          drawer: DrawerMenu(),
          body: Container(
            color: const Color(0xFFF8FAFC),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: BuildAppbar(() {
                      scaffoldKey.currentState?.openDrawer();
                    }, false),
                  ),
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 0.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // SizedBox(height: 15),
                                if (fromOffer)
                                  BuildFeaturedCategories(fromHome: !fromOffer),
                                if (fromOffer) SizedBox(height: 15),

                                //if (!fromOffer) BuildCarousel(),
                                //BuildDiscoveryFilters(),
                                // Dans votre vue
                                if (!fromOffer) BuildHeroBanner(),
                                SizedBox(height: 5),
                                BuildQuickNavigation(),
                                BuildPromotionalCarousel(),

                                SizedBox(height: 5),
                                // 2. Navigation rapide
                                //

                                // 3. Carrousel promotionnel

                                // 4. Featured Categories
                                if (!fromOffer)
                                  BuildFeaturedCategories(fromHome: !fromOffer),

                                BuildEndingSoon(
                                  deals: controller.endingSoonDeals,
                                  onDealTap: (deal) {
                                    Get.to(() => OfferDetailPage());
                                  },
                                  onViewAll: () {},
                                  onAddToBasket: (deal) {},
                                  onToggleFavorite: (deal) {},
                                ),
                                BuildHotDeals(),
                                BuildExploreSection(),
                                BuildRestorant(),
                                BuildTrendingMerchants(),
                                BuildBundle(),
                                SizedBox(height: 26.h),
                                BuildBillPayments(),
                                SizedBox(height: 26.h),
                                BuildSectionHeader(
                                  title: 'You May Also Like',
                                  onSeeAll: () {},
                                ),
                                SizedBox(height: 16.h),
                                BuildDiscoverPlacesCard(),
                                SizedBox(height: 16.h),
                                BuildStoreAlertsSection(),
                                SizedBox(height: 16.h),
                                GiftVoucherView(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
