import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../design_system/atoms/app_colors.dart';

class ExpenseToRewardController extends GetxController {
  // Controllers
  final amountController = TextEditingController();
  final userIdController = TextEditingController();

  // Observables
  final RxString billAmount = ''.obs;
  final RxString userId = ''.obs;
  final RxInt timerSeconds = 21.obs;
  final RxBool isTimerRunning = false.obs;
  final RxBool isAmountValid = false.obs;
  final RxBool isUserIdValid = false.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    startTimer();

    // Listeners pour validation
    amountController.addListener(() {
      billAmount.value = amountController.text;
      validateAmount();
    });

    userIdController.addListener(() {
      userId.value = userIdController.text;
      validateUserId();
    });
  }

  // Validation du montant
  void validateAmount() {
    final amount = double.tryParse(amountController.text);
    isAmountValid.value = amount != null && amount > 0;
  }

  // Validation de l'ID utilisateur
  void validateUserId() {
    isUserIdValid.value = userIdController.text.isNotEmpty;
  }

  // Vérifier si le formulaire est valide
  bool get isFormValid => isAmountValid.value && isUserIdValid.value;

  // Démarrer le timer
  void startTimer() {
    isTimerRunning.value = true;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timerSeconds.value > 0) {
        timerSeconds.value--;
      } else {
        stopTimer();
        showTimeoutDialog();
      }
    });
  }

  // Arrêter le timer
  void stopTimer() {
    _timer?.cancel();
    isTimerRunning.value = false;
  }

  // Réinitialiser le timer
  void resetTimer() {
    timerSeconds.value = 21;
    startTimer();
  }

  // Formater le temps
  String get formattedTime {
    final minutes = timerSeconds.value ~/ 60;
    final seconds = timerSeconds.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Scanner QR Code
  void scanQRCode() {
    // TODO: Implémenter le scan QR
  }

  // Afficher dialogue timeout
  void showTimeoutDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon avec animation
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.timer_off_rounded,
                  size: 48.sp,
                  color: Colors.red.shade400,
                ),
              ),

              SizedBox(height: 20.h),

              // Titre
              Text(
                'Session Expired',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 12.h),

              // Description
              Text(
                'Your session has timed out. Would you like to restart and try again?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),

              SizedBox(height: 24.h),

              // Boutons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                        Get.back();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          'Cancel',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                        resetTimer();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.AppPrimaryColor,
                              AppColors.AppPrimaryColor.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.AppPrimaryColor.withOpacity(0.3),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          'Restart',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Procéder au paiement
  void proceedToReward() {
    if (!isFormValid) {
      return;
    }

    stopTimer();
    Get.toNamed(
      '/invoice-reward',
      arguments: {'amount': billAmount.value, 'userId': userId.value},
    );
  }

  @override
  void onClose() {
    stopTimer();
    amountController.dispose();
    userIdController.dispose();
    super.onClose();
  }
}
