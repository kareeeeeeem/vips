// lib/app/modules/profile/controllers/profile_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

import '../../../design_system/atoms/app_colors.dart';
import '../../../design_system/organisms/pin/pin.dart';
import '../../edit_profile/views/edit_profile_view.dart';
import '../views/widgets/vips_id_view.dart';
import '../views/widgets/wallet_points_view.dart';

class ProfileController extends GetxController {
  final RxString selectedRole = 'Customer'.obs;
  final RxBool isUserSelected = true.obs;
  final RxBool isAdminSelected = false.obs;
  var temporaryRole = 'Customer'.obs;
  // Simuler des données utilisateur
  final RxString userName = 'Full Name'.obs;
  final RxString userEmail = 'user@email.com'.obs;
  final RxDouble profileCompletion = 0.31.obs;
  final RxInt totalCredits = 1250.obs;
  final RxInt totalExpenses = 850.obs;
  final RxBool isStoresExpanded = false.obs;

  final RxString selectedStore = 'Store 1'.obs; // Store sélectionné par défaut

  // Gestion des filtres de commandes
  final RxString selectedOrderFilter = 'Active'.obs;
  final RxString selectedTypeFilter = 'All'.obs;

  // Gestion des dates
  final Rx<DateTime> fromDate = DateTime.now().subtract(Duration(days: 30)).obs;
  final Rx<DateTime> toDate = DateTime.now().obs;

  // Liste simulée de commandes
  final RxList<Map<String, dynamic>> ordersList =
      <Map<String, dynamic>>[
        {
          'id': '0023900',
          'store': 'McDonald\'s',
          'amount': '25.20',
          'items': 2,
          'date': '10 Mar',
          'time': '04:13 PM',
          'status': 'Reserved',
          'type': 'In Store',
          'statusColor': 'purple',
        },
        {
          'id': '0023901',
          'store': 'KFC',
          'amount': '32.50',
          'items': 3,
          'date': '10 Mar',
          'time': '02:30 PM',
          'status': 'Pending',
          'type': 'Delivery',
          'statusColor': 'blue',
        },
        {
          'id': '0023902',
          'store': 'Pizza Hut',
          'amount': '18.90',
          'items': 1,
          'date': '10 Mar',
          'time': '06:45 PM',
          'status': 'Ready For Pickup',
          'type': 'In Store',
          'statusColor': 'blue',
        },
        {
          'id': '0023903',
          'store': 'Burger King',
          'amount': '45.20',
          'items': 4,
          'date': '11 Mar',
          'time': '12:15 PM',
          'status': 'Delivered',
          'type': 'Delivery',
          'statusColor': 'green',
        },
        {
          'id': '0023904',
          'store': 'Subway',
          'amount': '28.75',
          'items': 2,
          'date': '11 Mar',
          'time': '07:20 PM',
          'status': 'Reserved',
          'type': 'In Store',
          'statusColor': 'purple',
        },
        {
          'id': '0023905',
          'store': 'Domino\'s Pizza',
          'amount': '56.80',
          'items': 5,
          'date': '11 Mar',
          'time': '08:30 PM',
          'status': 'Pending',
          'type': 'Delivery',
          'statusColor': 'blue',
        },
        {
          'id': '0023906',
          'store': 'Starbucks',
          'amount': '15.50',
          'items': 2,
          'date': '12 Mar',
          'time': '09:00 AM',
          'status': 'Delivered',
          'type': 'Delivery',
          'statusColor': 'green',
        },
        {
          'id': '0023907',
          'store': 'McDonald\'s',
          'amount': '22.40',
          'items': 3,
          'date': '12 Mar',
          'time': '01:45 PM',
          'status': 'Ready For Pickup',
          'type': 'In Store',
          'statusColor': 'blue',
        },
        {
          'id': '0023908',
          'store': 'KFC',
          'amount': '38.90',
          'items': 4,
          'date': '12 Mar',
          'time': '05:20 PM',
          'status': 'Reserved',
          'type': 'In Store',
          'statusColor': 'purple',
        },
        {
          'id': '0023909',
          'store': 'Taco Bell',
          'amount': '19.75',
          'items': 2,
          'date': '13 Mar',
          'time': '11:30 AM',
          'status': 'Delivered',
          'type': 'Delivery',
          'statusColor': 'green',
        },
        {
          'id': '0023910',
          'store': 'Pizza Hut',
          'amount': '67.50',
          'items': 6,
          'date': '13 Mar',
          'time': '07:15 PM',
          'status': 'Pending',
          'type': 'Delivery',
          'statusColor': 'blue',
        },
        {
          'id': '0023911',
          'store': 'Burger King',
          'amount': '29.30',
          'items': 3,
          'date': '13 Mar',
          'time': '02:40 PM',
          'status': 'Reserved',
          'type': 'In Store',
          'statusColor': 'purple',
        },
        {
          'id': '0023912',
          'store': 'Subway',
          'amount': '16.80',
          'items': 1,
          'date': '14 Mar',
          'time': '12:00 PM',
          'status': 'Delivered',
          'type': 'Delivery',
          'statusColor': 'green',
        },
        {
          'id': '0023913',
          'store': 'McDonald\'s',
          'amount': '41.20',
          'items': 5,
          'date': '14 Mar',
          'time': '06:30 PM',
          'status': 'Ready For Pickup',
          'type': 'In Store',
          'statusColor': 'blue',
        },
        {
          'id': '0023914',
          'store': 'Starbucks',
          'amount': '23.50',
          'items': 3,
          'date': '14 Mar',
          'time': '08:45 AM',
          'status': 'Pending',
          'type': 'Delivery',
          'statusColor': 'blue',
        },
        {
          'id': '0023915',
          'store': 'Domino\'s Pizza',
          'amount': '52.90',
          'items': 4,
          'date': '15 Mar',
          'time': '08:00 PM',
          'status': 'Reserved',
          'type': 'In Store',
          'statusColor': 'purple',
        },
        {
          'id': '0023916',
          'store': 'KFC',
          'amount': '34.60',
          'items': 3,
          'date': '15 Mar',
          'time': '01:20 PM',
          'status': 'Delivered',
          'type': 'Delivery',
          'statusColor': 'green',
        },
        {
          'id': '0023917',
          'store': 'Taco Bell',
          'amount': '27.40',
          'items': 4,
          'date': '15 Mar',
          'time': '05:50 PM',
          'status': 'Ready For Pickup',
          'type': 'In Store',
          'statusColor': 'blue',
        },
        {
          'id': '0023918',
          'store': 'Pizza Hut',
          'amount': '44.80',
          'items': 3,
          'date': '16 Mar',
          'time': '07:30 PM',
          'status': 'Pending',
          'type': 'Delivery',
          'statusColor': 'blue',
        },
        {
          'id': '0023919',
          'store': 'Burger King',
          'amount': '31.50',
          'items': 2,
          'date': '16 Mar',
          'time': '12:45 PM',
          'status': 'Delivered',
          'type': 'Delivery',
          'statusColor': 'green',
        },
        {
          'id': '0023920',
          'store': 'McDonald\'s',
          'amount': '26.90',
          'items': 3,
          'date': '16 Mar',
          'time': '03:15 PM',
          'status': 'Reserved',
          'type': 'In Store',
          'statusColor': 'purple',
        },
        {
          'id': '0023921',
          'store': 'Subway',
          'amount': '19.20',
          'items': 2,
          'date': '17 Mar',
          'time': '11:00 AM',
          'status': 'Ready For Pickup',
          'type': 'In Store',
          'statusColor': 'blue',
        },
        {
          'id': '0023922',
          'store': 'Starbucks',
          'amount': '17.80',
          'items': 2,
          'date': '17 Mar',
          'time': '09:30 AM',
          'status': 'Delivered',
          'type': 'Delivery',
          'statusColor': 'green',
        },
        {
          'id': '0023923',
          'store': 'Domino\'s Pizza',
          'amount': '59.70',
          'items': 5,
          'date': '17 Mar',
          'time': '08:45 PM',
          'status': 'Pending',
          'type': 'Delivery',
          'statusColor': 'blue',
        },
        {
          'id': '0023924',
          'store': 'KFC',
          'amount': '36.40',
          'items': 4,
          'date': '18 Mar',
          'time': '02:00 PM',
          'status': 'Reserved',
          'type': 'In Store',
          'statusColor': 'purple',
        },
        {
          'id': '0023925',
          'store': 'Taco Bell',
          'amount': '24.60',
          'items': 3,
          'date': '18 Mar',
          'time': '06:15 PM',
          'status': 'Delivered',
          'type': 'Delivery',
          'statusColor': 'green',
        },
        {
          'id': '0023926',
          'store': 'Pizza Hut',
          'amount': '48.90',
          'items': 4,
          'date': '18 Mar',
          'time': '07:50 PM',
          'status': 'Ready For Pickup',
          'type': 'In Store',
          'statusColor': 'blue',
        },
        {
          'id': '0023927',
          'store': 'Burger King',
          'amount': '33.20',
          'items': 3,
          'date': '19 Mar',
          'time': '01:30 PM',
          'status': 'Pending',
          'type': 'Delivery',
          'statusColor': 'blue',
        },
        {
          'id': '0023928',
          'store': 'McDonald\'s',
          'amount': '28.50',
          'items': 2,
          'date': '19 Mar',
          'time': '04:45 PM',
          'status': 'Reserved',
          'type': 'In Store',
          'statusColor': 'purple',
        },
        {
          'id': '0023929',
          'store': 'Subway',
          'amount': '21.30',
          'items': 2,
          'date': '19 Mar',
          'time': '12:30 PM',
          'status': 'Delivered',
          'type': 'Delivery',
          'statusColor': 'green',
        },
      ].obs;

  final RxList<Map<String, dynamic>> storesList =
      <Map<String, dynamic>>[
        {'name': 'Store 1', 'products': '25 Products'},
        {'name': 'Store 2', 'products': '18 Products'},
      ].obs;

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
            dialogBackgroundColor: Colors.white,
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
          return pin == '1234';
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

  // Nouvelle méthode pour les sous-options
  Widget _buildSubRoleOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? Colors.blue.withOpacity(0.15)
                        : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.blue : Colors.grey.shade600,
                size: 24.sp,
              ),
            ),

            SizedBox(width: 12.w),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.blue : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2.h),
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

            // Checkmark
            if (isSelected)
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: Colors.white, size: 16.sp),
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
              isSelected ? primaryColor.withOpacity(0.08) : Colors.grey.shade50,
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
                    isSelected ? primaryColor.withOpacity(0.15) : Colors.white,
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

  Widget _buildRoleOption(String role, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.AppPrimaryColor.withOpacity(0.1)
                  : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color:
                isSelected ? AppColors.AppPrimaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20.w,
              height: 20.h,
              decoration: BoxDecoration(
                color:
                    isSelected ? AppColors.AppPrimaryColor : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected
                          ? AppColors.AppPrimaryColor
                          : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child:
                  isSelected
                      ? Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 12.sp,
                      )
                      : null,
            ),
            SizedBox(width: 12.w),
            Text(
              role,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.AppPrimaryColor : Colors.black87,
              ),
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
          return pin == '1234';
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
          Get.snackbar(
            'Store Changed',
            'You are now managing $tempStore',
            backgroundColor: primaryColor.withOpacity(0.1),
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
      userId: '12345678',
      userName: 'John Doe',
    );
  }

  void navigateToWallet() {
    Get.to(
      () => PinValidator(
        pinLength: 4,
        primaryColor: primaryColor,
        validatePin: (pin) {
          return pin == '1234';
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
