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

  // Missions
  var weeklyStreak = 3.obs;
  var weeklyStreakTotal = 7.obs;
  var dailyCheckIn = 4.obs;
  var dailyCheckInTotal = 7.obs;

  // History
  var transactionHistory = <Map<String, dynamic>>[].obs;

  // Spin wheel remaining spins
  var remainingSpins = 3.obs;
  var isSpinning = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchClubData();
    loadReferralCode();
  }

  Future<void> fetchClubData() async {
    try {
      final response = await ApiService().get('/user/vips-club');
      if (response.success && response.data != null) {
        final data = response.data;
        convertibleDiamonds.value =
            ((data['points'] ?? data['convertibleDiamonds'] ?? 0) as num).toInt();
        pendingDiamonds.value =
            ((data['pendingDiamonds'] ?? data['pending'] ?? 0) as num).toInt();
        suspendedDiamonds.value =
            ((data['suspendedDiamonds'] ?? data['suspended'] ?? 0) as num).toInt();
        superBonus.value = ((data['superBonus'] ?? data['bonus'] ?? 0) as num).toInt();
        referrals.value =
            ((data['referrals'] ?? data['referralCount'] ?? 0) as num).toInt();
        currentRank.value = ((data['rank'] ?? data['currentRank'] ?? 0) as num).toInt();
        todayCoins.value = ((data['todayCoins'] ?? data['dailyCoins'] ?? 0) as num).toInt();
        hasCheckedInToday.value = data['checkedInToday'] ?? false;
        canClaimReward.value = !hasCheckedInToday.value;
        checkInStreak.value = ((data['checkInStreak'] ?? 0) as num).toInt();

        final List<dynamic> days = data['checkInDays'] ?? [];
        if (days.isNotEmpty) {
          checkInDays.value = days.map((d) => Map<String, dynamic>.from(d)).toList();
          currentProgress.value = '${checkInStreak.value}/7';
        }
      }

      final walletResponse = await ApiService().get('/user/wallet');
      if (walletResponse.success && walletResponse.data != null) {
        final List<dynamic> txList = walletResponse.data['recentTransactions'] ?? [];
        if (txList.isNotEmpty) {
          transactionHistory.value = txList.map((tx) => {
            'amount': tx['amount'],
            'type': tx['type'],
            'description': tx['description'] ?? 'Transaction',
            'date': tx['createdAt'] != null
                ? DateTime.parse(tx['createdAt']).toString()
                : DateTime.now().toString(),
            'isDebit': tx['type'] == 'debit',
          }).toList();
        }
      }
    } catch (_) {
    }
  }

  Future<void> claimDailyReward() async {
    if (hasCheckedInToday.value || !canClaimReward.value) return;
    try {
      final response = await ApiService().post('/user/vips-club/checkin', {});
      if (response.success && response.data != null) {
        final earned = response.data['pointsEarned'] ?? 0;
        convertibleDiamonds.value = response.data['newPoints'] ?? convertibleDiamonds.value;
        checkInStreak.value = response.data['streak'] ?? checkInStreak.value;
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

  void updateBannerIndex(int index) {
    currentBannerIndex.value = index;
  }

  void navigateToHistory() {
    Get.toNamed('/vips-club-history');
  }

  void navigateToSpinWheel() {
    Get.toNamed('/spin-wheel');
  }

  void spinWheel() async {
    if (remainingSpins.value <= 0 || isSpinning.value) return;

    isSpinning.value = true;

    try {
      final response = await ApiService().post('/rewards/spin-wheel', {});
      
      if (response.success && response.data != null) {
        remainingSpins.value--;
        final wonPrize = response.data['amount'] ?? 0;
        
        // Wait for UI animation (assuming 3 seconds spinner)
        await Future.delayed(Duration(seconds: 3));

        todayCoins.value += (wonPrize as num).toInt();
        
        // Show prize dialog
        safeSnackbar(
          'Congratulations!',
          'You won $wonPrize coins!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      } else {
        safeSnackbar('Oops', response.message, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      safeSnackbar('Error', 'Failed to spin the wheel: $e');
    } finally {
      isSpinning.value = false;
    }
  }

  final RxString referralCode = ''.obs;

  Future<void> loadReferralCode() async {
    try {
      final res = await ApiService().get('/user/referral');
      if (res.success && res.data != null) {
        referralCode.value = (res.data['referralCode'] ?? res.data['code'] ?? '').toString();
        // /user/vips-club never returns a referral count, so the "Referrals"
        // stat would otherwise always show 0 — pull it from here instead.
        final joined = res.data['totalJoined'] ?? res.data['totalInvited'];
        if (joined != null) referrals.value = (joined as num).toInt();
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
                          if (response.success && response.data != null) {
                            convertibleDiamonds.value = response.data['newPoints'] ?? 0;
                            transactionHistory.insert(0, {
                              'amount': -(response.data['walletAmount'] ?? 0),
                              'type': 'diamant',
                              'description': 'Diamonds converted to VIPs Wallet',
                              'date': DateTime.now().toString(),
                              'isDebit': true,
                            });
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

  void joinMission(String missionType) {
    safeSnackbar(
      'Mission',
      'Joining $missionType mission...',
      backgroundColor: Colors.purple,
      colorText: Colors.white,
    );
  }
}
