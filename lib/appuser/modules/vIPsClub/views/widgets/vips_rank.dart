import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class VIPsRankController extends GetxController {
  // Observable variables
  var currentUserRank = 218.obs;
  var currentUserScore = 103.0.obs;

  // Top 3 users
  var topUsers =
      <Map<String, dynamic>>[
        {
          'rank': 1,
          'username': 'Username',
          'score': 144.0,
          'diamonds': 25000,
          'avatar': 'assets/avatar1.png',
        },
        {
          'rank': 2,
          'username': 'Username',
          'score': 144.0,
          'diamonds': 15000,
          'avatar': 'assets/avatar2.png',
        },
        {
          'rank': 3,
          'username': 'Username',
          'score': 144.0,
          'diamonds': 10000,
          'avatar': 'assets/avatar3.png',
        },
      ].obs;

  // Other ranked users
  var rankedUsers =
      <Map<String, dynamic>>[
        {
          'rank': 4,
          'username': 'Username',
          'score': 143.0,
          'avatar': 'assets/avatar4.png',
        },
        {
          'rank': 5,
          'username': 'Username',
          'score': 143.0,
          'avatar': 'assets/avatar5.png',
        },
        {
          'rank': 6,
          'username': 'Username',
          'score': 143.0,
          'avatar': 'assets/avatar6.png',
        },
        {
          'rank': 7,
          'username': 'Username',
          'score': 143.0,
          'avatar': 'assets/avatar7.png',
        },
        {
          'rank': 8,
          'username': 'Username',
          'score': 143.0,
          'avatar': 'assets/avatar8.png',
        },
      ].obs;

  @override
  void onInit() {
    super.onInit();
    fetchRankings();
  }

  void fetchRankings() {
    // Simulate API call to fetch rankings
    // In a real app, this would make an HTTP request
  }

  void refreshRankings() {
    // Refresh rankings data
    fetchRankings();
  }
}

class VIPsRankView extends GetView<VIPsRankController> {
  const VIPsRankView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'VIPs Club Rank',
          style: TextStyle(
            color: Colors.black,
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 20.h),

            // Top 3 Podium - Clean & Minimal
            _buildMinimalPodium(),

            SizedBox(height: 32.h),

            // Your Current Rank Card - Subtle elevation
            _buildCurrentRankCard(),

            SizedBox(height: 24.h),

            // Rankings List - Clean cards
            _buildRankingsList(),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // STYLE 1: PODIUM HORIZONTAL (Style Olympique)
  // Les 3 positions côte à côte avec hauteurs différentes
  // ════════════════════════════════════════════════════════════════

  Widget _buildMinimalPodium() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Position 2 - Left (Silver)
          Expanded(
            child: _buildPodiumPosition(
              rank: 2,
              username: 'Username',
              score: '144₀₀',
              diamonds: '15000',
              avatarUrl: 'https://i.pravatar.cc/150?img=2',
              height: 160.h,
              medalColor: Color(0xFFC0C0C0),
            ),
          ),
          SizedBox(width: 12.w),

          // Position 1 - Center (Gold) - Le plus haut
          Expanded(
            child: _buildPodiumPosition(
              rank: 1,
              username: 'Username',
              score: '144₀₀',
              diamonds: '25000',
              avatarUrl: 'https://i.pravatar.cc/150?img=1',
              height: 200.h,
              medalColor: Color(0xFFFFD700),
              isWinner: true,
            ),
          ),
          SizedBox(width: 12.w),

          // Position 3 - Right (Bronze)
          Expanded(
            child: _buildPodiumPosition(
              rank: 3,
              username: 'Username',
              score: '144₀₀',
              diamonds: '10000',
              avatarUrl: 'https://i.pravatar.cc/150?img=3',
              height: 140.h,
              medalColor: Color(0xFFCD7F32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumPosition({
    required int rank,
    required String username,
    required String score,
    required String diamonds,
    required String avatarUrl,
    required double height,
    required Color medalColor,
    bool isWinner = false,
  }) {
    return Column(
      children: [
        // Avatar avec médaille
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: isWinner ? 80.w : 70.w,
              height: isWinner ? 80.w : 70.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Color(0xFFE8E8E8), width: 2),
              ),
              child: ClipOval(
                child: Image.network(
                  avatarUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Color(0xFFF5F5F5),
                      child: Center(
                        child: SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.black),
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Color(0xFFF5F5F5),
                      child: Icon(
                        Icons.person,
                        size: 30.sp,
                        color: Colors.grey.shade400,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Médaille en haut
            if (isWinner)
              Positioned(
                top: -8.h,
                child: Icon(Icons.emoji_events, color: medalColor, size: 24.sp),
              ),
          ],
        ),

        SizedBox(height: 12.h),

        // Podium block
        Container(
          height: height,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            border: Border.all(color: Color(0xFFE8E8E8), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Rank badge
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 4.h),

              // Username
              Text(
                username,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 4.h),

              // Score
              Text(
                score,
                style: TextStyle(
                  fontSize: isWinner ? 20.sp : 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  letterSpacing: -0.8,
                ),
              ),

              SizedBox(height: 8.h),

              // Diamonds
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.diamond_outlined,
                      size: 12.sp,
                      color: Colors.black87,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      diamonds,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRunnerUpCard({
    required int rank,
    required String username,
    required String score,
    required String diamonds,
    required String avatarUrl,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Color(0xFFF0F0F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar with rank badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Color(0xFFE8E8E8), width: 2),
                ),
                child: ClipOval(
                  child: Image.network(
                    avatarUrl,
                    width: 70.w,
                    height: 70.w,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 70.w,
                        height: 70.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFF5F5F5),
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 16.w,
                            height: 16.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.black),
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 70.w,
                        height: 70.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFF5F5F5),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 35.sp,
                          color: Colors.grey.shade400,
                        ),
                      );
                    },
                  ),
                ),
              ),

              Positioned(
                top: -4.h,
                right: -4.w,
                child: Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    color: rank == 2 ? Color(0xFF6B6B6B) : Color(0xFF9B9B9B),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$rank',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          Text(
            username,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: 4.h),

          Text(
            score,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: -0.8,
            ),
          ),

          SizedBox(height: 8.h),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              diamonds,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentRankCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Color(0xFFE8E8E8), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank number - minimal style
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Center(
              child: Text(
                '218',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
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
                  'Your Current Rank',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Keep earning to improve',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Score
          Text(
            '103₀₀',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: -0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      itemCount: 5,
      itemBuilder: (context, index) {
        int rank = index + 4;
        return _buildRankItem(
          rank: rank,
          username: 'Username',
          score: '143₀₀',
          avatarUrl: 'https://i.pravatar.cc/150?img=$rank',
        );
      },
    );
  }

  Widget _buildRankItem({
    required int rank,
    required String username,
    required String score,
    required String avatarUrl,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Color(0xFFF0F0F0), width: 1),
      ),
      child: Row(
        children: [
          // Rank number - simple
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // Avatar - clean
          Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Color(0xFFE8E8E8), width: 1.5),
            ),
            child: ClipOval(
              child: Image.network(
                avatarUrl,
                width: 44.w,
                height: 44.w,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFF5F5F5),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.black),
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFF5F5F5),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 22.sp,
                      color: Colors.grey.shade400,
                    ),
                  );
                },
              ),
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Text(
              username,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                letterSpacing: -0.3,
              ),
            ),
          ),

          // Score
          Text(
            score,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
