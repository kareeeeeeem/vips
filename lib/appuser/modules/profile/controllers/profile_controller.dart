// lib/app/modules/profile/controllers/profile_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vip/core/services/api_service.dart';

import '../../../design_system/organisms/pin/pin.dart';
import '../../edit_profile/views/edit_profile_view.dart';
import '../views/widgets/vips_id_view.dart';
import '../views/widgets/wallet_points_view.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class ProfileController extends GetxController {
  final RxString selectedRole = 'Customer'.obs;
  final RxBool isUserSelected = true.obs;
  final RxBool isAdminSelected = false.obs;
  var temporaryRole = 'Customer'.obs;
  final RxString userName = 'Full Name'.obs;
  final RxString userEmail = 'user@email.com'.obs;
  final RxDouble profileCompletion = 0.31.obs;
  final RxInt totalCredits = 0.obs;
  final RxInt totalExpenses = 0.obs;
  final RxBool isStoresExpanded = false.obs;
  final RxBool isLoading = true.obs;

  // Dynamic profile fields
  final RxString packageName = '--'.obs;
  final RxString lastLogin = '--'.obs;
  // Vendor stats
  final RxString vendorProducts = '0'.obs;
  final RxString vendorSales = '0'.obs;
  final RxString vendorRevenue = '0'.obs;
  // Agent stats
  final RxString agentTotal = '0'.obs;
  final RxString agentCompleted = '0'.obs;
  final RxString agentPending = '0'.obs;
  // Business stats
  final RxString businessStores = '0'.obs;
  final RxString businessDrivers = '0'.obs;
  final RxString businessCustomers = '0'.obs;

  final RxString selectedStore = 'Store 1'.obs;
  final RxString userId = ''.obs;
  final RxDouble vipProgress = 0.0.obs;
  final RxInt vipPoints = 0.obs;
  final RxInt unreadNotificationsCount = 0.obs;

  String _userPin = '0000';

  @override
  void onInit() {
    super.onInit();
    _loadPin();
    fetchUserProfile();
  }

  Future<void> _loadPin() async {
    final prefs = await SharedPreferences.getInstance();
    _userPin = prefs.getString('user_pin') ?? '0000';
  }

  Future<void> fetchUserProfile() async {
    isLoading.value = true;
    try {
      final userResponse = await ApiService().get('/auth/me');
      if (userResponse.success && userResponse.data != null) {
        final user = userResponse.data['user'] ?? userResponse.data;
        userId.value = (user['_id'] ?? user['id'] ?? '').toString();
        userName.value = user['fullName'] ?? user['name'] ?? 'User';
        userEmail.value = user['email'] ?? '';
        packageName.value =
            user['package'] ?? user['packageName'] ?? user['plan'] ?? '--';
        if (user['lastLogin'] != null || user['lastConnection'] != null) {
          final raw = user['lastLogin'] ?? user['lastConnection'];
          try {
            final dt = DateTime.parse(raw.toString());
            lastLogin.value =
                '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
          } catch (_) {
            lastLogin.value = raw.toString();
          }
        }

        final stats = user['stats'] ?? {};
        vendorProducts.value =
            (stats['products'] ?? stats['productCount'] ?? 0).toString();
        vendorSales.value =
            (stats['sales'] ?? stats['salesCount'] ?? 0).toString();
        vendorRevenue.value = (stats['revenue'] ?? 0).toString();
        agentTotal.value =
            (stats['totalDeliveries'] ?? stats['total'] ?? 0).toString();
        agentCompleted.value =
            (stats['completedDeliveries'] ?? stats['completed'] ?? 0)
                .toString();
        agentPending.value =
            (stats['pendingDeliveries'] ?? stats['pending'] ?? 0).toString();
        businessStores.value =
            (stats['stores'] ?? stats['storeCount'] ?? 0).toString();
        businessDrivers.value =
            (stats['drivers'] ?? stats['driverCount'] ?? 0).toString();
        businessCustomers.value =
            (stats['customers'] ?? stats['customerCount'] ?? 0).toString();
      }

      final walletResponse = await ApiService().get('/user/wallet');
      if (walletResponse.success && walletResponse.data != null) {
        totalCredits.value =
            (walletResponse.data['balance'] as num?)?.toInt() ?? 0;
        totalExpenses.value =
            (walletResponse.data['points'] as num?)?.toInt() ?? 0;
      }

      final clubResponse = await ApiService().get('/user/vips-club');
      if (clubResponse.success && clubResponse.data != null) {
        final pts =
            (clubResponse.data['points'] ??
                    clubResponse.data['convertibleDiamonds'] ??
                    0)
                as num;
        vipPoints.value = pts.toInt();
        const vipThreshold = 1000;
        vipProgress.value = (pts / vipThreshold).clamp(0.0, 1.0).toDouble();
      }

      final notifResponse = await ApiService().get(
        '/user/notifications',
        queryParams: {'unread': 'true', 'limit': '1'},
      );
      if (notifResponse.success && notifResponse.data != null) {
        unreadNotificationsCount.value =
            (notifResponse.data['unreadCount'] ??
                    notifResponse.data['count'] ??
                    0)
                as int;
      }

      await _loadOrdersFromApi();
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadOrdersFromApi() async {
    try {
      final response = await ApiService().get('/order/my-orders');
      if (response.success && response.data != null) {
        final List<dynamic> raw = response.data;
        ordersList.value =
            raw
                .map(
                  (o) => {
                    'id':
                        o['_id']?.toString().substring(
                          o['_id'].toString().length - 7,
                        ) ??
                        '',
                    'store': o['merchantId']?['storeName'] ?? 'VIPs Store',
                    'amount': (o['totalAmount'] ?? 0).toString(),
                    'items': (o['items'] as List?)?.length ?? 1,
                    'date':
                        o['createdAt'] != null
                            ? DateTime.parse(
                              o['createdAt'],
                            ).toString().substring(0, 10)
                            : '',
                    'time': '',
                    'status': _capitalize(o['status'] ?? 'pending'),
                    'type': o['deliveryType'] ?? 'Delivery',
                    'statusColor': _statusColor(o['status']),
                  },
                )
                .toList();
      }
    } catch (_) {}
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
  String _statusColor(String? s) {
    switch (s) {
      case 'delivered':
        return 'green';
      case 'cancelled':
        return 'red';
      case 'pending':
        return 'blue';
      default:
        return 'purple';
    }
  }

  // Gestion des filtres de commandes
  final RxString selectedOrderFilter = 'Active'.obs;
  final RxString selectedTypeFilter = 'All'.obs;

  // Gestion des dates
  final Rx<DateTime> fromDate = DateTime.now().subtract(Duration(days: 30)).obs;
  final Rx<DateTime> toDate = DateTime.now().obs;

  final RxList<Map<String, dynamic>> ordersList = <Map<String, dynamic>>[].obs;

  final RxList<Map<String, dynamic>> storesList = <Map<String, dynamic>>[].obs;

  // Filtrer les commandes selon les critères sélectionnés
  List<Map<String, dynamic>> get filteredOrders {
    return ordersList.where((order) {
      // Filtre par statut
      bool matchesStatus = true;
      if (selectedOrderFilter.value == 'Active') {
        matchesStatus =
            order['status'] != 'Delivered' && order['status'] != 'Cancelled';
      } else if (selectedOrderFilter.value == 'Done') {
        matchesStatus = order['status'] == 'Delivered';
      } else if (selectedOrderFilter.value == 'Refunded') {
        matchesStatus = order['status'] == 'Refunded';
      }

      // Filtre par type
      bool matchesType = true;
      if (selectedTypeFilter.value != 'All') {
        matchesType = order['type'] == selectedTypeFilter.value;
      }

      return matchesStatus && matchesType;
    }).toList();
  }

  int get activeOrdersCount {
    return ordersList
        .where(
          (order) =>
              order['status'] != 'Delivered' && order['status'] != 'Cancelled',
        )
        .length;
  }

  int get doneOrdersCount {
    return ordersList.where((order) => order['status'] == 'Delivered').length;
  }

  int get refundedOrdersCount {
    return ordersList.where((order) => order['status'] == 'Refunded').length;
  }

  void changeOrderFilter(String filter) {
    selectedOrderFilter.value = filter;
  }

  void changeTypeFilter(String filter) {
    selectedTypeFilter.value = filter;
  }

  final RxString orderSortMode = 'newest'.obs;

  void showSortDialog() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sort Orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            for (final option in [
              ('newest', 'Newest First'),
              ('oldest', 'Oldest First'),
              ('highest', 'Highest Amount'),
              ('lowest', 'Lowest Amount'),
            ])
              ListTile(
                title: Text(option.$2),
                trailing: Obx(
                  () =>
                      orderSortMode.value == option.$1
                          ? const Icon(Icons.check, color: Colors.blue)
                          : const SizedBox.shrink(),
                ),
                onTap: () {
                  orderSortMode.value = option.$1;
                  _applySortToOrders(option.$1);
                  Get.back();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _applySortToOrders(String mode) {
    final list = ordersList.toList();
    switch (mode) {
      case 'oldest':
        list.sort((a, b) => (a['date'] ?? '').compareTo(b['date'] ?? ''));
        break;
      case 'highest':
        list.sort(
          (a, b) => (double.tryParse(b['amount']?.toString() ?? '0') ?? 0)
              .compareTo(double.tryParse(a['amount']?.toString() ?? '0') ?? 0),
        );
        break;
      case 'lowest':
        list.sort(
          (a, b) => (double.tryParse(a['amount']?.toString() ?? '0') ?? 0)
              .compareTo(double.tryParse(b['amount']?.toString() ?? '0') ?? 0),
        );
        break;
      default: // newest
        list.sort((a, b) => (b['date'] ?? '').compareTo(a['date'] ?? ''));
    }
    ordersList.assignAll(list);
  }

  // Méthode pour sélectionner la plage de dates
  Future<void> selectDateRange() async {
    final picked = await showDateRangePicker(
      context: Get.context!,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: fromDate.value, end: toDate.value),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: primaryColor,
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: primaryColor),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      fromDate.value = picked.start;
      toDate.value = picked.end;
    }
  }

  // Formater la date pour l'affichage
  String formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  // Méthode pour toggle l'état
  void toggleStoresExpanded() {
    isStoresExpanded.value = !isStoresExpanded.value;
  }

  // Getter pour la couleur primaire
  Color get primaryColor {
    switch (selectedRole.value) {
      case 'Vendor':
        return Color(0xFFFFC107);

      case 'Agent':
        return Color(0xFF2196F3);

      case 'Business':
        return Colors.blue;
      case 'Customer':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  List<Map<String, dynamic>> get servicesList {
    if (selectedRole.value == 'Admin') {
      return [
        {'icon': Icons.credit_card, 'title': 'Credit', 'route': '/credit'},
        {'icon': Icons.card_giftcard, 'title': 'Gifted', 'route': '/gift'},
        {'icon': Icons.payment, 'title': 'Pay Bill', 'route': 'pay-bills'},
        {'icon': Icons.refresh, 'title': 'Recovery', 'route': '/recovery'},
        {'icon': Icons.local_offer, 'title': 'Offers', 'route': '/coupon'},
        {'icon': Icons.assessment, 'title': 'Report', 'route': '/report'},
        {
          'icon': Icons.volunteer_activism,
          'title': 'Donation',
          'route': '/donation',
        },
        {'icon': Icons.group, 'title': 'Team', 'route': '/teams'},
      ];
    } else if (selectedRole.value == 'Vendor') {
      return [
        {'icon': Icons.store, 'title': 'My Store', 'route': '/store'},
        {'icon': Icons.inventory, 'title': 'Products', 'route': '/products'},
        {'icon': Icons.shopping_cart, 'title': 'Orders', 'route': '/orders'},
        {'icon': Icons.analytics, 'title': 'Analytics', 'route': '/analytics'},
        {
          'icon': Icons.local_offer,
          'title': 'Promotions',
          'route': '/promotions',
        },
        {'icon': Icons.reviews, 'title': 'Reviews', 'route': '/reviews'},
        {'icon': Icons.settings, 'title': 'Settings', 'route': '/settings'},
      ];
    } else {
      return [
        {
          'icon': Icons.phone_android,
          'title': 'Mob credit',
          'route': '/mobile',
        },
        {'icon': Icons.card_giftcard, 'title': 'Gifted', 'route': '/gift'},
        {'icon': Icons.payment, 'title': 'Pay Bill', 'route': '/pay-bills'},
        {'icon': Icons.discount, 'title': 'Promotions', 'route': '/promotions'},
        {
          'icon': Icons.emoji_events,
          'title': 'VIPs Club',
          'route': '/v-i-ps-club',
        },
        {'icon': Icons.contacts, 'title': 'Contacts', 'route': '/contact'},
        {
          'icon': Icons.volunteer_activism,
          'title': 'Donation',
          'route': '/donation',
        },
        {
          'icon': Icons.local_shipping,
          'title': 'Shipping',
          'route': '/shipping',
        },
      ];
    }
  }

  void showRoleSwitcher() {
    Get.bottomSheet(
      _buildRoleSwitcherSheet(),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  void validateRoleChange(String newRole) {
    // Sauvegarder temporairement le nouveau rôle
    temporaryRole.value = newRole;

    // Fermer le bottomsheet
    Get.back();

    // Afficher l'écran de validation PIN
    Get.to(
      () => PinValidator(
        pinLength: 4,
        primaryColor: primaryColor,
        validatePin: (pin) {
          return pin == _userPin;
        },
        validateBiometrics: () async {
          final LocalAuthentication localAuth = LocalAuthentication();
          try {
            return await localAuth.authenticate(
              localizedReason: 'Authenticate to switch role',
              options: const AuthenticationOptions(
                stickyAuth: true,
                biometricOnly: true,
              ),
            );
          } catch (e) {
            return false;
          }
        },
        onValidPin: () {
          // Appliquer le changement de rôle
          selectedRole.value = temporaryRole.value;
          Get.back();
        },
        supportedMethods: [ValidationMethod.pin, ValidationMethod.biometrics],
      ),
      transition: Transition.downToUp,
    );
  }

  Widget _buildRoleSwitcherSheet() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),

            // Title with icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.swap_horiz_rounded, color: Colors.blue, size: 24.sp),
                SizedBox(width: 8.w),
                Text(
                  'Switch Role',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // Subtitle
            Text(
              'Choose the role you want to switch to',
              style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
            ),

            SizedBox(height: 24.h),

            // Role options with GetX
            Obx(() {
              final currentRole = selectedRole.value;

              return Column(
                children: [
                  // Customer option
                  _buildEnhancedRoleOption(
                    title: 'Customer',
                    subtitle: 'Access customer features and services',
                    icon: Icons.person_rounded,
                    isSelected: currentRole == 'Customer',
                    onTap: () => validateRoleChange('Customer'),
                  ),

                  SizedBox(height: 12.h),

                  // Vendor option
                  _buildEnhancedRoleOption(
                    title: 'Vendor',
                    subtitle: 'Manage your store and products',
                    icon: Icons.store_rounded,
                    isSelected: currentRole == 'Vendor',
                    onTap: () => validateRoleChange('Vendor'),
                  ),

                  SizedBox(height: 12.h),

                  // Agent option
                  _buildEnhancedRoleOption(
                    title: 'Agent',
                    subtitle: 'Deliver orders to customers',
                    icon: Icons.delivery_dining_rounded,
                    isSelected: currentRole == 'Agent',
                    onTap: () => validateRoleChange('Agent'),
                  ),
                ],
              );
            }),

            SizedBox(height: 24.h),

            // Action buttons
            Row(
              children: [
                // Cancel button
                Expanded(
                  child: SizedBox(
                    height: 52.h,
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 12.w),

                // Save button
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Apply Changes',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedRoleOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? primaryColor.withValues(alpha: 0.08)
                  : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade200,
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            // Icon with background
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? primaryColor.withValues(alpha: 0.15)
                        : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: isSelected ? primaryColor : Colors.grey.shade600,
                size: 28.sp,
              ),
            ),

            SizedBox(width: 16.w),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? primaryColor : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Selection indicator
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? primaryColor : Colors.transparent,
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child:
                  isSelected
                      ? Icon(Icons.check, size: 16.sp, color: Colors.white)
                      : null,
            ),
          ],
        ),
      ),
    );
  }

  void navigateToEditProfile() {
    Get.to(() => EditProfileView());
  }

  void validateStoreChange(String newStore) {
    // Sauvegarder temporairement le nouveau store
    final String tempStore = newStore;

    // Afficher l'écran de validation PIN
    Get.to(
      () => PinValidator(
        pinLength: 4,
        primaryColor: primaryColor,
        validatePin: (pin) {
          return pin == _userPin;
        },
        validateBiometrics: () async {
          final LocalAuthentication localAuth = LocalAuthentication();
          try {
            return await localAuth.authenticate(
              localizedReason: 'Authenticate to switch store',
              options: const AuthenticationOptions(
                stickyAuth: true,
                biometricOnly: true,
              ),
            );
          } catch (e) {
            return false;
          }
        },
        onValidPin: () {
          // Appliquer le changement de store
          selectedStore.value = tempStore;
          Get.back();

          // Fermer la liste des stores
          isStoresExpanded.value = false;

          // Afficher un message de confirmation
          safeSnackbar(
            'Store Changed',
            'You are now managing $tempStore',
            backgroundColor: primaryColor.withValues(alpha: 0.1),
            colorText: primaryColor,
            snackPosition: SnackPosition.BOTTOM,
            margin: EdgeInsets.all(16.w),
            borderRadius: 12.r,
            duration: Duration(seconds: 2),
          );
        },
        supportedMethods: [ValidationMethod.pin, ValidationMethod.biometrics],
      ),
      transition: Transition.downToUp,
    );
  }

  void navigateToVipsId() {
    VipsIdDialog.show(
      primaryColor: primaryColor,
      userId: userId.value.isNotEmpty ? userId.value : '—',
      userName: userName.value,
    );
  }

  void navigateToWallet() {
    Get.to(
      () => PinValidator(
        pinLength: 4,
        primaryColor: primaryColor,
        validatePin: (pin) {
          return pin == _userPin;
        },
        validateBiometrics: () async {
          final LocalAuthentication localAuth = LocalAuthentication();
          try {
            return await localAuth.authenticate(
              localizedReason: 'Authenticate to switch role',
              options: const AuthenticationOptions(
                stickyAuth: true,
                biometricOnly: true,
              ),
            );
          } catch (e) {
            return false;
          }
        },
        onValidPin: () {
          Get.back();
          Get.to(() => WalletPointsView(primaryColor: primaryColor));
        },
        supportedMethods: [ValidationMethod.pin, ValidationMethod.biometrics],
      ),
      transition: Transition.downToUp,
    );
  }
}
