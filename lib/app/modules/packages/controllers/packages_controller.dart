import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum PackageTier { basic, silver, gold, platinum }

class PackageBenefit {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;

  PackageBenefit({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
  });
}

class Package {
  final String id;
  final PackageTier tier;
  final String name;
  final double price;
  final double monthlyPrice;
  final int redeemPoints;
  final int giftPoints;
  final Color primaryColor;
  final Color accentColor;
  final List<PackageBenefit> benefits;
  final bool isCurrent;
  final bool isPopular;
  final String badge;

  Package({
    required this.id,
    required this.tier,
    required this.name,
    required this.price,
    required this.monthlyPrice,
    required this.redeemPoints,
    required this.giftPoints,
    required this.primaryColor,
    required this.accentColor,
    required this.benefits,
    this.isCurrent = false,
    this.isPopular = false,
    this.badge = '',
  });
}

class PackagesController extends GetxController {
  var packages = <Package>[].obs;
  var selectedPackage = Rx<Package?>(null);
  var quantity = 1.obs;
  var showDetails = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPackages();
  }

  void _loadPackages() {
    packages.value = [
      Package(
        id: 'basic',
        tier: PackageTier.basic,
        name: 'Basic',
        price: 0,
        monthlyPrice: 0,
        redeemPoints: 1000,
        giftPoints: 800,
        primaryColor: const Color(0xFF8B7355),
        accentColor: const Color(0xFFBFA084),
        isCurrent: true,
        badge: 'Current',
        benefits: [
          PackageBenefit(
            title: 'Standard Support',
            description: 'Email support within 48 hours',
            icon: Icons.support_agent_outlined,
            iconColor: const Color(0xFF8B7355),
          ),
          PackageBenefit(
            title: 'Basic Rewards',
            description: '1x points on purchases',
            icon: Icons.stars_outlined,
            iconColor: const Color(0xFF8B7355),
          ),
          PackageBenefit(
            title: 'Monthly Newsletter',
            description: 'Exclusive deals & updates',
            icon: Icons.mail_outline,
            iconColor: const Color(0xFF8B7355),
          ),
        ],
      ),
      Package(
        id: 'silver',
        tier: PackageTier.silver,
        name: 'Silver',
        price: 15,
        monthlyPrice: 1.25,
        redeemPoints: 1500,
        giftPoints: 1200,
        primaryColor: const Color(0xFFC0C0C0),
        accentColor: const Color(0xFFD1D5DB),
        badge: '',
        benefits: [
          PackageBenefit(
            title: 'Priority Support',
            description: 'Email support within 24 hours',
            icon: Icons.headset_mic_outlined,
            iconColor: const Color(0xFFC0C0C0),
          ),
          PackageBenefit(
            title: 'Enhanced Rewards',
            description: '1.5x points on all purchases',
            icon: Icons.auto_awesome_outlined,
            iconColor: const Color(0xFFC0C0C0),
          ),
          PackageBenefit(
            title: 'Monthly Bonus',
            description: 'Exclusive monthly offers',
            icon: Icons.card_giftcard_outlined,
            iconColor: const Color(0xFFC0C0C0),
          ),
        ],
      ),
      Package(
        id: 'gold',
        tier: PackageTier.gold,
        name: 'Gold',
        price: 25,
        monthlyPrice: 2.08,
        redeemPoints: 2500,
        giftPoints: 2200,
        primaryColor: const Color(0xFFFFB800),
        accentColor: const Color(0xFFFFD700),
        isPopular: true,
        badge: 'Most Popular',
        benefits: [
          PackageBenefit(
            title: 'Birthday Treat',
            description:
                'Receive a personalized 15% discount code or a free gift during your birthday month.',
            icon: Icons.card_giftcard,
            iconColor: const Color(0xFFFFB800),
          ),
          PackageBenefit(
            title: 'Increased Earning Rate',
            description:
                'Unlock bonus diamants challenges for additional earning opportunities.',
            icon: Icons.add_circle,
            iconColor: const Color(0xFFFFB800),
          ),
          PackageBenefit(
            title: 'Tier Upgrade Bonus',
            description:
                'Enjoy priority email support with a guaranteed response within 24 hours.',
            icon: Icons.card_giftcard_outlined,
            iconColor: const Color(0xFFFFB800),
          ),
        ],
      ),
      Package(
        id: 'platinum',
        tier: PackageTier.platinum,
        name: 'Platinum',
        price: 50,
        monthlyPrice: 4.17,
        redeemPoints: 5000,
        giftPoints: 4500,
        primaryColor: const Color(0xFF4A5568),
        accentColor: const Color(0xFF6B7280),
        badge: 'Elite',
        benefits: [
          PackageBenefit(
            title: 'Concierge Service',
            description: 'Dedicated personal assistant',
            icon: Icons.person_pin_outlined,
            iconColor: const Color(0xFF4A5568),
          ),
          PackageBenefit(
            title: 'Maximum Rewards',
            description: '3x points on all purchases',
            icon: Icons.auto_graph_outlined,
            iconColor: const Color(0xFF4A5568),
          ),
          PackageBenefit(
            title: 'Platinum Perks',
            description: 'Exclusive platinum-only deals',
            icon: Icons.military_tech_outlined,
            iconColor: const Color(0xFF4A5568),
          ),
        ],
      ),
    ];

    // Auto-select Gold package by default
    selectedPackage.value = packages.firstWhere(
      (pkg) => pkg.tier == PackageTier.gold,
      orElse: () => packages[2],
    );
  }

  Package get currentPackage {
    return packages.firstWhere(
      (pkg) => pkg.isCurrent,
      orElse: () => packages.first,
    );
  }

  void selectPackage(Package package) {
    selectedPackage.value = package;
    showDetails.value = true;
  }

  void changeTab(int index) {
    // Update selected package based on tab
    switch (index) {
      case 0:
        selectedPackage.value = packages.firstWhere(
          (pkg) => pkg.tier == PackageTier.silver,
        );
        break;
      case 1:
        selectedPackage.value = packages.firstWhere(
          (pkg) => pkg.tier == PackageTier.gold,
        );
        break;
      case 2:
        selectedPackage.value = packages.firstWhere(
          (pkg) => pkg.tier == PackageTier.platinum,
        );
        break;
    }
  }

  void incrementQuantity() {
    if (quantity.value < 10) {
      quantity.value++;
    }
  }

  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  double get totalPrice {
    return (selectedPackage.value?.price ?? 0) * quantity.value;
  }

  void buyPackage() {
    if (selectedPackage.value == null) return;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF22C55E), const Color(0xFF16A34A)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Successfully Upgraded!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'SF Pro Display',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Welcome to ${selectedPackage.value!.name}! Enjoy all the premium benefits.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: const Color(0xFF6B7280),
                  fontFamily: 'SF Pro Text',
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F2937),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Start Enjoying',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void goBack() {
    if (showDetails.value) {
      showDetails.value = false;
    } else {
      Get.back();
    }
  }
}
