import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/app/modules/vIPsClub/views/widgets/invite_friends.dart';
import 'package:vip/app/modules/vIPsClub/views/widgets/vips_rank.dart';

import '../../spin_wheel/views/spin_wheel_view.dart';
import '../../vips_club_history/views/vips_club_history_view.dart';
import '../controllers/v_i_ps_club_controller.dart';

class VIPsClubView extends GetView<VIPsClubController> {
  const VIPsClubView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'VIPs Club',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),

            // Available Diamants Banner
            _buildAvailableDiamantsBanner(),

            SizedBox(height: 16.h),

            // Current Rank Card
            _buildCurrentRankCard(),

            SizedBox(height: 16.h),

            // Daily Check-in Card
            _buildCheckInCard(),

            SizedBox(height: 16.h),

            // Stats Card
            _buildStatsCard(),

            SizedBox(height: 16.h),

            // Join Challenge Banner
            _buildJoinChallengeBanner(),

            SizedBox(height: 16.h),

            // Missions Section
            _buildMissionsSection(),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableDiamantsBanner() {
    return InkWell(
      onTap: () => Get.to(() => VipsClubHistoryView()),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Color(0xFFB8B8B8),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            // Trophy Icon
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.emoji_events_outlined,
                color: Colors.white,
                size: 30.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available diamants!',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Obx(
                    () => Text(
                      '${controller.convertibleDiamonds.value}',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              ),
              child: Text(
                'Details',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentRankCard() {
    return InkWell(
      onTap: () => Get.to(() => VIPsRankView()),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Obx(
                  () => Text(
                    '#${controller.currentRank.value}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Rank',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Keep earning to improve',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckInCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily check-in Progress 1x',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue,
                ),
              ),
              Obx(
                () => Text(
                  controller.currentProgress.value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          // Check-in days with rewards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              var day = controller.checkInDays[index];
              return _buildCheckInDay(
                index + 1,
                day['checked'],
                day['isToday'] ?? false,
                day['reward'],
              );
            }),
          ),
          SizedBox(height: 20.h),
          // Check In Button
          Obx(
            () =>
                !controller.hasCheckedInToday.value
                    ? Container(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: controller.claimDailyReward,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Check In',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                    : Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(
                        color: Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check, size: 18.sp, color: Colors.green),
                          SizedBox(width: 8.w),
                          Text(
                            'Checked in',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInDay(int day, bool checked, bool isToday, int reward) {
    bool showReward = !checked && (isToday || day > 4);

    return Column(
      children: [
        Container(
          width: 42.w,
          height: 42.w,
          decoration: BoxDecoration(
            color:
                checked
                    ? Colors.black
                    : showReward
                    ? Color(0xFFFFB84D)
                    : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color:
                  checked
                      ? Colors.black
                      : showReward
                      ? Color(0xFFFFB84D)
                      : Color(0xFFE0E0E0),
              width: 2,
            ),
          ),
          child:
              checked
                  ? Icon(Icons.check, color: Colors.white, size: 20.sp)
                  : showReward
                  ? Center(
                    child: Text(
                      '$reward',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  )
                  : Center(
                    child: Text(
                      '',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
        ),
        SizedBox(height: 6.h),
        Text(
          isToday ? 'Today' : 'Day $day',
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          _buildStatRow(
            'Approved Diamants',
            controller.convertibleDiamonds.value.toString(),
          ),
          SizedBox(height: 16.h),
          _buildStatRow('Pending', controller.pendingDiamonds.value.toString()),
          SizedBox(height: 16.h),
          _buildStatRow(
            'Suspended',
            controller.suspendedDiamonds.value.toString(),
          ),
          SizedBox(height: 20.h),
          Divider(height: 1, color: Color(0xFFE0E0E0)),
          SizedBox(height: 20.h),
          _buildStatRow('Today Coins', controller.todayCoins.value.toString()),
          SizedBox(height: 16.h),
          _buildStatRow('Referrals', controller.referrals.value.toString()),
          SizedBox(height: 16.h),
          _buildStatRow('Super Bonus', controller.superBonus.value.toString()),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildJoinChallengeBanner() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Color(0xFFFFE8A3),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Text(
            'Join Challenge to Get diamants',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.black87,
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: 'Our rewards are always changing. ',
                  style: TextStyle(
                    color: Color(0xFFFF8C00),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: 'make sure to keep applying to win the best rewards.',
                  style: TextStyle(fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'Complete Missions to Get diamants',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFFB84D),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        InkWell(
          onTap: () => Get.to(() => SpinWheelView()),

          child: _buildMissionItem('Spin the wheel', '+500 diamants', false),
        ),
        _buildMissionItem('Daily Check-in', '+500 diamants', true),
        InkWell(
          onTap: () => Get.to(() => InviteFriendsView()),
          child: _buildMissionItem('Invite Friends', '+25000 diamants', false),
        ),
      ],
    );
  }

  Widget _buildMissionItem(String title, String reward, bool isCompleted) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h, left: 16.w, right: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Reward: $reward',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: isCompleted ? Color(0xFF4CAF50) : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child:
                isCompleted
                    ? Icon(Icons.check, color: Colors.white, size: 16.sp)
                    : null,
          ),
        ],
      ),
    );
  }
}
