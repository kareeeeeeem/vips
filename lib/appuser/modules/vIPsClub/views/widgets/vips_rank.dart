import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

class VIPsRankController extends GetxController {
  var currentUserRank = 0.obs;
  var currentUserScore = 0.0.obs;
  var topUsers = <Map<String, dynamic>>[].obs;
  var rankedUsers = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRankings();
  }

  Future<void> fetchRankings() async {
    isLoading.value = true;
    try {
      final res = await ApiService().get('/user/leaderboard', queryParams: {'limit': '20'});
      if (res.success && res.data != null) {
        final data = res.data as Map<String, dynamic>;
        final List<dynamic> board = data['leaderboard'] ?? [];
        currentUserRank.value = (data['currentUserRank'] ?? 0).toInt();
        currentUserScore.value = (data['currentUserScore'] ?? 0).toDouble();
        final all = board.map((e) => Map<String, dynamic>.from(e)).toList();
        topUsers.value = all.take(3).toList();
        rankedUsers.value = all.skip(3).toList();
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  void refreshRankings() => fetchRankings();
}

class VIPsRankView extends GetView<VIPsRankController> {
  const VIPsRankView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<VIPsRankController>()) {
      Get.put(VIPsRankController());
    }
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
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              _buildMinimalPodium(),
              SizedBox(height: 32.h),
              _buildCurrentRankCard(),
              SizedBox(height: 24.h),
              _buildRankingsList(),
              SizedBox(height: 40.h),
            ],
          ),
        );
      }),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // STYLE 1: PODIUM HORIZONTAL (Style Olympique)
  // Les 3 positions côte à côte avec hauteurs différentes
  // ════════════════════════════════════════════════════════════════

  Widget _buildMinimalPodium() {
    final top = controller.topUsers;
    if (top.isEmpty) return SizedBox(height: 20.h);
    final first = top.isNotEmpty ? top[0] : <String, dynamic>{};
    final second = top.length > 1 ? top[1] : <String, dynamic>{};
    final third = top.length > 2 ? top[2] : <String, dynamic>{};
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: _buildPodiumPosition(
              rank: second['rank'] ?? 2,
              username: second['username'] ?? '-',
              score: '${(second['score'] ?? 0).toInt()}',
              diamonds: '${(second['score'] ?? 0).toInt()}',
              avatarUrl: second['avatar'] ?? 'https://i.pravatar.cc/150?img=2',
              height: 160.h,
              medalColor: const Color(0xFFC0C0C0),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildPodiumPosition(
              rank: first['rank'] ?? 1,
              username: first['username'] ?? '-',
              score: '${(first['score'] ?? 0).toInt()}',
              diamonds: '${(first['score'] ?? 0).toInt()}',
              avatarUrl: first['avatar'] ?? 'https://i.pravatar.cc/150?img=1',
              height: 200.h,
              medalColor: const Color(0xFFFFD700),
              isWinner: true,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildPodiumPosition(
              rank: third['rank'] ?? 3,
              username: third['username'] ?? '-',
              score: '${(third['score'] ?? 0).toInt()}',
              diamonds: '${(third['score'] ?? 0).toInt()}',
              avatarUrl: third['avatar'] ?? 'https://i.pravatar.cc/150?img=3',
              height: 140.h,
              medalColor: const Color(0xFFCD7F32),
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
                color: Colors.black.withValues(alpha: 0.04),
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
            color: Colors.black.withValues(alpha: 0.04),
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
              child: Obx(() => Text(
                '${controller.currentUserRank.value}',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              )),
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
          Obx(() => Text(
            '${controller.currentUserScore.value.toInt()}',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: -0.8,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildRankingsList() {
    return Obx(() {
      final users = controller.rankedUsers;
      if (users.isEmpty) return const SizedBox.shrink();
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final u = users[index];
          return _buildRankItem(
            rank: (u['rank'] ?? index + 4) as int,
            username: u['username'] ?? '-',
            score: '${(u['score'] ?? 0).toInt()}',
            avatarUrl: u['avatar'] ?? 'https://i.pravatar.cc/150?img=${index + 4}',
          );
        },
      );
    });
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
