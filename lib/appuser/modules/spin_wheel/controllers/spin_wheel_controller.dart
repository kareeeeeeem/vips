import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:vip/core/services/api_service.dart';
import '../views/widgets/WinDialogWidget.dart';

class SpinWheelController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // Animation controller
  late AnimationController animationController;
  late Animation<double> animation;

  // Observable variables
  var isSpinning = false.obs;
  var remainingSpins = 3.obs;
  var rotation = 0.0.obs;
  var canSpin = true.obs;

  // Prizes (8 sections)
  final List<WheelPrize> prizes = [
    WheelPrize(
      name: 'Money Bag',
      value: 100,
      color: Colors.purple.shade700,
      icon: Icons.money,
    ),
    WheelPrize(
      name: 'Trending Up',
      value: 200,
      color: Colors.red.shade600,
      icon: Icons.trending_up,
    ),
    WheelPrize(
      name: 'Offer',
      value: 50,
      color: Colors.orange.shade600,
      icon: Icons.local_offer,
    ),
    WheelPrize(
      name: 'Gold Coin',
      value: 500,
      color: Colors.yellow.shade700,
      icon: Icons.monetization_on,
    ),
    WheelPrize(
      name: 'Cash',
      value: 150,
      color: Colors.green.shade600,
      icon: Icons.attach_money,
    ),
    WheelPrize(
      name: 'Bank',
      value: 300,
      color: Colors.teal.shade600,
      icon: Icons.account_balance,
    ),
    WheelPrize(
      name: 'Payment',
      value: 75,
      color: Colors.blue.shade700,
      icon: Icons.payment,
    ),
    WheelPrize(
      name: 'Gift',
      value: 1000,
      color: Colors.pink.shade600,
      icon: Icons.redeem,
    ),
  ];

  var wonPrize = Rx<WheelPrize?>(null);

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    );

    animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutCubic,
    );

    animation.addListener(() {
      rotation.value = animation.value;
    });

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        isSpinning.value = false;
        canSpin.value = true;
        _showWinDialog();
      }
    });
  }

  void spinWheel() async {
    if (isSpinning.value || remainingSpins.value <= 0 || !canSpin.value) {
      return;
    }

    isSpinning.value = true;
    canSpin.value = false;

    try {
      final response = await ApiService().post('/rewards/spin-wheel', {});
      if (response.success && response.data != null) {
        remainingSpins.value--;
        final amountWon = response.data['amount'];

        // Find the index of the prize we won
        int winningIndex = prizes.indexWhere((p) => p.value == amountWon);
        if (winningIndex == -1) {
          winningIndex = 0; // fallback
        }
        wonPrize.value = prizes[winningIndex];

        // Random number of full rotations (5-8)
        final random = Random();
        final extraRotations = 5 + random.nextInt(4);

        // Calculate the exact angle to land on winningIndex
        final sectionAngle = (2 * pi) / prizes.length;
        // We want finalAngle such that: floor((2*pi - finalAngle) / sectionAngle) % length == winningIndex
        // finalAngle = 2*pi - (winningIndex * sectionAngle) - (random offset inside section)
        final randomOffset = random.nextDouble() * sectionAngle;
        final targetFinalAngle =
            (2 * pi) - (winningIndex * sectionAngle) - randomOffset;

        final totalRotation = extraRotations * 2 * pi + targetFinalAngle;

        // Start animation
        animation = Tween<double>(
          begin: rotation.value,
          end:
              rotation.value +
              (totalRotation / (2 * pi)), // animation value is in rotations
        ).animate(
          CurvedAnimation(
            parent: animationController,
            curve: Curves.easeOutCubic,
          ),
        );

        animationController.forward(from: 0);
      } else {
        Get.snackbar('Error', 'Failed to spin. Try again.');
        isSpinning.value = false;
        canSpin.value = true;
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred.');
      isSpinning.value = false;
      canSpin.value = true;
    }
  }

  void _showWinDialog() {
    if (wonPrize.value == null) return;

    // Navigation vers le widget de victoire en plein écran
    Get.to(
      () => WinDialogWidget(
        wonAmount: wonPrize.value!.value,
        onClaim: () {
          Navigator.pop(Get.context!);
          Navigator.pop(Get.context!);
          wonPrize.value = null;
        },
      ),
      transition: Transition.fadeIn,
      duration: Duration(milliseconds: 300),
    );
  }

  void resetSpins() {
    remainingSpins.value = 3;
    canSpin.value = true;
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}

// Prize model
class WheelPrize {
  final String name;
  final int value;
  final Color color;
  final IconData icon;

  WheelPrize({
    required this.name,
    required this.value,
    required this.color,
    required this.icon,
  });
}
