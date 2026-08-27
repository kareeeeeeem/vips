import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

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

  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPackages();
  }

  // Purely decorative per-tier styling — real price/points/benefits come
  // from GET /services/packages below, and which tier is "Current" comes
  // from GET /services/packages/current (previously hardcoded to Basic
  // client-side, so it never reflected an actual purchase).
  static const _tierStyle = {
    'basic': (color: Color(0xFF8B7355), accent: Color(0xFFBFA084), icon: Icons.support_agent_outlined),
    'silver': (color: Color(0xFFC0C0C0), accent: Color(0xFFD1D5DB), icon: Icons.headset_mic_outlined),
    'gold': (color: Color(0xFFFFB800), accent: Color(0xFFFFD700), icon: Icons.card_giftcard),
    'platinum': (color: Color(0xFF4A5568), accent: Color(0xFF6B7280), icon: Icons.military_tech_outlined),
  };

  Future<void> _loadPackages() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        ApiService().get('/services/packages'),
        ApiService().get('/services/packages/current'),
      ]);

      final packagesRes = results[0];
      final currentRes = results[1];
      final currentTier = (currentRes.success && currentRes.data != null)
          ? currentRes.data['tier']?.toString() ?? 'basic'
          : 'basic';

      if (packagesRes.success && packagesRes.data is List) {
        packages.value = (packagesRes.data as List).map((p) {
          final id = p['id']?.toString() ?? 'basic';
          final style = _tierStyle[id] ?? _tierStyle['basic']!;
          final benefitTitles = p['benefits'] is List
              ? (p['benefits'] as List).map((b) => b.toString()).toList()
              : <String>[];
          return Package(
            id: id,
            tier: PackageTier.values.firstWhere((t) => t.name == id, orElse: () => PackageTier.basic),
            name: p['name']?.toString() ?? id,
            price: ((p['price'] ?? 0) as num).toDouble(),
            monthlyPrice: ((p['monthlyPrice'] ?? 0) as num).toDouble(),
            redeemPoints: ((p['redeemPoints'] ?? 0) as num).toInt(),
            giftPoints: ((p['giftPoints'] ?? 0) as num).toInt(),
            primaryColor: style.color,
            accentColor: style.accent,
            isCurrent: id == currentTier,
            isPopular: p['isPopular'] == true,
            badge: id == currentTier ? 'Current' : (p['isPopular'] == true ? 'Most Popular' : ''),
            benefits: benefitTitles.map((title) => PackageBenefit(
              title: title,
              description: title,
              icon: style.icon,
              iconColor: style.color,
            )).toList(),
          );
        }).toList();
      }

      // Select the real current tier by default; fall back to Gold, then
      // whatever loaded first.
      selectedPackage.value = packages.firstWhereOrNull((pkg) => pkg.isCurrent) ??
          packages.firstWhereOrNull((pkg) => pkg.tier == PackageTier.gold) ??
          packages.firstOrNull;
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
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
    // firstWhere with no orElse throws StateError if packages hasn't
    // loaded yet (or the backend ever returns fewer than 3 tiers) — that
    // turned tapping a tier tab into a hard crash. firstWhereOrNull leaves
    // the current selection untouched instead of throwing.
    switch (index) {
      case 0:
        final pkg = packages.firstWhereOrNull((pkg) => pkg.tier == PackageTier.silver);
        if (pkg != null) selectedPackage.value = pkg;
        break;
      case 1:
        final pkg = packages.firstWhereOrNull((pkg) => pkg.tier == PackageTier.gold);
        if (pkg != null) selectedPackage.value = pkg;
        break;
      case 2:
        final pkg = packages.firstWhereOrNull((pkg) => pkg.tier == PackageTier.platinum);
        if (pkg != null) selectedPackage.value = pkg;
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

  final isBuying = false.obs;

  Future<void> buyPackage() async {
    if (selectedPackage.value == null) return;
    final pkg = selectedPackage.value!;
    if (pkg.tier == PackageTier.basic) {
      // Basic is the free/current tier — tapping "Subscribe Now" on it
      // previously did nothing with no feedback, looking like a dead button.
      safeSnackbar('Already Active', 'You\'re already on the Basic plan.');
      return;
    }

    isBuying.value = true;
    try {
      final response = await ApiService().post('/services/packages/subscribe', {
        'tier': pkg.name.toLowerCase(),
      });

      if (response.success) {
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
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Successfully Upgraded!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, fontFamily: 'SF Pro Display'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Welcome to ${pkg.name}! Enjoy all the premium benefits.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, color: Color(0xFF6B7280), fontFamily: 'SF Pro Text', height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () { Get.back(); Get.back(); },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F2937),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: const Text('Start Enjoying', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: 'SF Pro Display')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        safeSnackbar('Error', response.message, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      safeSnackbar('Error', 'Could not process subscription', backgroundColor: Colors.red, colorText: Colors.white);
    }
    isBuying.value = false;
  }

  void goBack() {
    if (showDetails.value) {
      showDetails.value = false;
    } else {
      Get.back();
    }
  }
}
