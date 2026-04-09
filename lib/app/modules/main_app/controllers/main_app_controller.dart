import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../profile/controllers/profile_controller.dart';
import '../views/widgets/activate_points_bottom_sheet.dart';

class MainAppController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final RxBool isAmountVisible = false.obs;

  // Points de l'utilisateur (à récupérer depuis votre backend/database)
  final RxDouble userPoints = 285.0.obs;

  // Getter pour récupérer la primaryColor depuis ProfileController
  Color get primaryColor {
    try {
      final profileController = Get.find<ProfileController>();
      return profileController.primaryColor;
    } catch (e) {
      return Colors.orange; // Couleur par défaut
    }
  }

  // Getter pour récupérer le rôle depuis ProfileController
  String get currentRole {
    try {
      final profileController = Get.find<ProfileController>();
      return profileController.selectedRole.value;
    } catch (e) {
      return 'Customer'; // Rôle par défaut
    }
  }

  // Fonction dynamique pour afficher le wallet
  void onScanTap() {
    WalletPointsBottomSheet.show(
      primaryColor: primaryColor,
      points: userPoints.value,
      role: currentRole,
    );
  }

  // Méthode pour mettre à jour les points (depuis API par exemple)
  void updateUserPoints(double newPoints) {
    userPoints.value = newPoints;
  }

  void changePage(int index) {
    currentIndex.value = index;
  }

  void toggleAmountVisibility() {
    isAmountVisible.value = !isAmountVisible.value;
  }
}
