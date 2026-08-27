import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class VIPsClubController extends GetxController {
  // Observable variables
  var currentBannerIndex = 0.obs;
  var convertibleDiamonds = 0.obs;
  var pendingDiamonds = 0.obs;
  var suspendedDiamonds = 0.obs;
  var todayCoins = 0.obs;
  var superBonus = 0.obs;
  var referrals = 0.obs;
  var currentRank = 0.obs;

  // Check-in status (7 days) - Updated rewards to match the image
  var checkInDays =
      <Map<String, dynamic>>[
        {'day': 'Day 1', 'checked': true, 'reward': 100},
        {'day': 'Day 2', 'checked': true, 'reward': 100},
        {'day': 'Day 3', 'checked': true, 'reward': 100},
        {'day': 'Day 4', 'checked': true, 'reward': 100},
        {'day': 'Day 5', 'checked': false, 'reward': 250, 'isToday': true},
        {'day': 'Day 6', 'checked': false, 'reward': 250},
        {'day': 'Day 7', 'checked': false, 'reward': 1000},
      ].obs;

  var currentProgress = '4/7'.obs;
  var hasCheckedInToday = false.obs;
  var canClaimReward = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchClubData();
    loadReferralCode();
  }

  // Safe int coercion for fields coming back from the API — a shape
  // mismatch (wrong type, unexpected null) falls back to 0 instead of
  // throwing a TypeError from a bare `as num`.
  int _asInt(dynamic v) => v is num ? v.toInt() : 0;

  Future<void> fetchClubData() async {
    try {
      final response = await ApiService().get('/user/vips-club');
      if (response.success && response.data is Map) {
        final data = response.data as Map;
        convertibleDiamonds.value = _asInt(data['points'] ?? data['convertibleDiamonds']);
        pendingDiamonds.value = _asInt(data['pendingDiamonds'] ?? data['pending']);
        suspendedDiamonds.value = _asInt(data['suspendedDiamonds'] ?? data['suspended']);
        superBonus.value = _asInt(data['superBonus'] ?? data['bonus']);
        referrals.value = _asInt(data['referrals'] ?? data['referralCount']);
        currentRank.value = _asInt(data['rank'] ?? data['currentRank']);
        todayCoins.value = _asInt(data['todayCoins'] ?? data['dailyCoins']);
        hasCheckedInToday.value = data['checkedInToday'] == true;
        canClaimReward.value = !hasCheckedInToday.value;
        checkInStreak.value = _asInt(data['checkInStreak']);

        final days = data['checkInDays'];
        if (days is List && days.isNotEmpty) {
          checkInDays.value = days
              .whereType<Map>()
              .map((d) => Map<String, dynamic>.from(d))
              .toList();
          if (checkInDays.isNotEmpty) {
            currentProgress.value = '${checkInStreak.value}/7';
          }
        }
      }
    } catch (_) {
    }
  }

  Future<void> claimDailyReward() async {
    if (hasCheckedInToday.value || !canClaimReward.value) return;
    try {
      final response = await ApiService().post('/user/vips-club/checkin', {});
      if (response.success && response.data is Map) {
        final data = response.data as Map;
        final earned = _asInt(data['pointsEarned']);
        final newPoints = data['newPoints'];
        if (newPoints is num) convertibleDiamonds.value = newPoints.toInt();
        final streak = data['streak'];
        if (streak is num) checkInStreak.value = streak.toInt();
        hasCheckedInToday.value = true;
        canClaimReward.value = false;
        _rebuildCheckInDays();
        showSuccessDialog(earned);
      } else {
        safeSnackbar('Notice', response.message);
      }
    } catch (_) {
      safeSnackbar('Error', 'Could not claim reward');
    }
  }

  var checkInStreak = 0.obs;

  void _rebuildCheckInDays() {
    final streak = checkInStreak.value;
    checkInDays.value = [
      {'day': 'Day 1', 'reward': 100},
      {'day': 'Day 2', 'reward': 100},
      {'day': 'Day 3', 'reward': 100},
      {'day': 'Day 4', 'reward': 100},
      {'day': 'Day 5', 'reward': 250},
      {'day': 'Day 6', 'reward': 250},
      {'day': 'Day 7', 'reward': 1000},
    ].asMap().entries.map((e) => {
      'day': e.value['day'],
      'reward': e.value['reward'],
      'checked': e.key < streak,
      'isToday': e.key == streak,
    }).toList();
    currentProgress.value = '$streak/7';
  }

  void showSuccessDialog(int coins) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: Colors.green, size: 40),
              ),
              SizedBox(height: 16),
              Text(
                'SUCCESS',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                'You have claimed $coins coins successfully!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Okay',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }




  final RxString referralCode = ''.obs;

  Future<void> loadReferralCode() async {
    try {
      final res = await ApiService().get('/user/referral');
      if (res.success && res.data is Map) {
        final data = res.data as Map;
        referralCode.value = (data['referralCode'] ?? data['code'] ?? '').toString();
        // /user/vips-club never returns a referral count, so the "Referrals"
        // stat would otherwise always show 0 — pull it from here instead.
        final joined = data['totalJoined'] ?? data['totalInvited'];
        if (joined is num) referrals.value = joined.toInt();
      }
    } catch (_) {}
  }

  void inviteFriends() {
    final code = referralCode.value;
    if (code.isNotEmpty) {
      SharePlus.instance.share(ShareParams(
        text: 'Join VIPs and earn rewards! Use my referral code: $code\nDownload the app and start earning today.',
        subject: 'Join VIPs — Earn 25,000 diamonds!',
      ));
    } else {
      loadReferralCode().then((_) {
        if (referralCode.value.isNotEmpty) {
          inviteFriends();
        } else {
          safeSnackbar('Invite Friends', 'Sign in to get your referral code',
              backgroundColor: Colors.blue, colorText: Colors.white);
        }
      });
    }
  }

  Future<void> convertDiamonds() async {
    if (convertibleDiamonds.value < 100) {
      safeSnackbar('Error', 'Minimum 100 diamonds required', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Convert Diamonds', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text('Convert ${convertibleDiamonds.value} diamonds to wallet?', textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Get.back(), child: const Text('Cancel'))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        try {
                          final response = await ApiService().post('/user/vips-club/convert', {
                            'points': convertibleDiamonds.value,
                          });
                          if (response.success && response.data is Map) {
                            convertibleDiamonds.value = _asInt((response.data as Map)['newPoints']);
                            safeSnackbar('Success', 'Diamonds converted!', backgroundColor: Colors.green, colorText: Colors.white);
                          } else {
                            safeSnackbar('Error', response.message, backgroundColor: Colors.red, colorText: Colors.white);
                          }
                        } catch (_) {
                          safeSnackbar('Error', 'Conversion failed');
                        }
                      },
                      child: const Text('Convert'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}
