import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VIPsClubController extends GetxController {
  // Observable variables
  var currentBannerIndex = 0.obs;
  var convertibleDiamonds = 90.obs;
  var pendingDiamonds = 600.obs;
  var suspendedDiamonds = 600.obs;
  var todayCoins = 10.obs;
  var superBonus = 120.obs;
  var referrals = 0.obs;
  var currentRank = 218.obs;

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
  var transactionHistory =
      <Map<String, dynamic>>[
        {
          'amount': -5800,
          'type': 'diamant',
          'description': 'diamant to VIPs Wallet',
          'date': '27 Oct 2025 16:13',
          'isDebit': true,
        },
        {
          'amount': 80,
          'type': 'diamant',
          'description': 'Order Place N°: 118047',
          'date': '27 Oct 2025 16:13',
          'isDebit': false,
        },
        {
          'amount': 10,
          'type': 'diamant',
          'description': 'Order Place N°: 118047',
          'date': '27 Oct 2025 16:13',
          'isDebit': false,
        },
      ].obs;

  // Spin wheel remaining spins
  var remainingSpins = 3.obs;
  var isSpinning = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkTodayStatus();
  }

  void checkTodayStatus() {
    // Check if user already checked in today
    var todayIndex = checkInDays.indexWhere((day) => day['isToday'] == true);
    if (todayIndex != -1 && checkInDays[todayIndex]['checked'] == true) {
      hasCheckedInToday.value = true;
      canClaimReward.value = false;
    }
  }

  void claimDailyReward() {}

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
    Get.toNamed('/vips-history');
  }

  void navigateToSpinWheel() {
    Get.toNamed('/spin-wheel');
  }

  void spinWheel() async {
    if (remainingSpins.value <= 0 || isSpinning.value) return;

    isSpinning.value = true;
    remainingSpins.value--;

    // Simulate spinning
    await Future.delayed(Duration(seconds: 3));

    // Award random prize
    var prizes = [100, 200, 500, 1000, 50, 150, 300, 2000];
    var wonPrize = prizes[DateTime.now().millisecond % prizes.length];

    todayCoins.value += wonPrize;
    isSpinning.value = false;

    // Show prize dialog
    Get.snackbar(
      'Congratulations!',
      'You won $wonPrize coins!',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  void inviteFriends() {
    // Handle invite friends logic
    Get.snackbar(
      'Invite Friends',
      'Share your referral code to earn 25000 diamonds!',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  void convertDiamonds() {
    if (convertibleDiamonds.value < 100) {
      Get.snackbar(
        'Error',
        'Minimum 100 diamonds required to convert',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Navigate to conversion page
    Get.dialog(
      Dialog(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Convert Diamonds',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Convert ${convertibleDiamonds.value} diamonds to wallet?',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Process conversion
                        transactionHistory.insert(0, {
                          'amount': -convertibleDiamonds.value,
                          'type': 'diamant',
                          'description': 'diamant to VIPs Wallet',
                          'date': DateTime.now().toString(),
                          'isDebit': true,
                        });
                        convertibleDiamonds.value = 0;
                        Get.back();
                        Get.snackbar(
                          'Success',
                          'Diamonds converted successfully!',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      },
                      child: Text('Convert'),
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
    Get.snackbar(
      'Mission',
      'Joining $missionType mission...',
      backgroundColor: Colors.purple,
      colorText: Colors.white,
    );
  }
}
