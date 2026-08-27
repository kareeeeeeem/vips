// lib/app/modules/profile/controllers/profile_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:vip/core/services/api_service.dart';

import '../../../design_system/organisms/pin/pin.dart';
import '../views/widgets/vips_id_view.dart';
import '../views/widgets/wallet_points_view.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class ProfileController extends GetxController {
  final RxString selectedRole = 'Customer'.obs;
  final RxBool isUserSelected = true.obs;
  final RxBool isAdminSelected = false.obs;
  final RxString userName = 'Full Name'.obs;
  final RxString userEmail = 'user@email.com'.obs;
  // Computed for real in fetchUserProfile() from which /auth/update-profile
  // fields are actually filled in — this used to be permanently stuck at
  // 31% regardless of the account's actual state.
  final RxDouble profileCompletion = 0.0.obs;
  final RxInt totalCredits = 0.obs;
  final RxInt totalExpenses = 0.obs;
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

  final RxString userId = ''.obs;
  final RxDouble vipProgress = 0.0.obs;
  final RxInt vipPoints = 0.obs;
  final RxInt unreadNotificationsCount = 0.obs;

  // Real state from /auth/me's hasPin field — the PIN itself is never
  // sent to the client, only whether one has been set.
  final RxBool hasPin = false.obs;

  // Backs the "Premium" requirements card — this used to show both
  // requirements permanently unmet with a red X, with no way to act on
  // either one, regardless of the account's real state.
  final RxBool isVerified = false.obs;
  final RxBool hasPaymentMethod = false.obs;
  final RxBool isSendingVerification = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    isLoading.value = true;
    try {
      final userResponse = await ApiService().get('/auth/me');
      if (userResponse.success && userResponse.data != null) {
        final userRaw = userResponse.data['user'] ?? userResponse.data;
        final user = userRaw is Map ? userRaw : <String, dynamic>{};
        userId.value = (user['_id'] ?? user['id'] ?? '').toString();
        userName.value = user['fullName'] ?? user['name'] ?? 'User';
        userEmail.value = user['email'] ?? '';
        hasPin.value = user['hasPin'] == true;
        isVerified.value = user['isVerified'] == true;
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

        final statsRaw = user['stats'];
        final stats = statsRaw is Map ? statsRaw : {};
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

        // Matches the exact field set PUT /auth/update-profile accepts.
        final fields = [
          user['fullName'],
          user['phone'],
          user['email'],
          user['profileImage'],
          user['city'],
          user['civilStatus'],
          user['postalCode'],
          user['profession'],
          user['gender'],
          user['numberOfChildren'],
        ];
        final filled = fields.where((f) => f != null && f.toString().trim().isNotEmpty).length;
        profileCompletion.value = filled / fields.length;
      }

      final walletResponse = await ApiService().get('/user/wallet');
      if (walletResponse.success && walletResponse.data is Map) {
        final walletData = walletResponse.data as Map;
        totalCredits.value = (walletData['balance'] as num?)?.toInt() ?? 0;
        totalExpenses.value = (walletData['points'] as num?)?.toInt() ?? 0;
      }

      final paymentResponse = await ApiService().get('/user/payment-methods');
      if (paymentResponse.success && paymentResponse.data is Map) {
        final cards = (paymentResponse.data as Map)['cards'];
        hasPaymentMethod.value = cards is List && cards.isNotEmpty;
      }

      final clubResponse = await ApiService().get('/user/vips-club');
      if (clubResponse.success && clubResponse.data is Map) {
        final clubData = clubResponse.data as Map;
        final pts =
            (clubData['points'] ?? clubData['convertibleDiamonds'] ?? 0)
                as num;
        vipPoints.value = pts.toInt();
        const vipThreshold = 1000;
        vipProgress.value = (pts / vipThreshold).clamp(0.0, 1.0).toDouble();
      }

      // /user/notifications always returns `data` as a bare array (its
      // sibling `unreadCount` field lives outside `data` and is dropped by
      // ApiService, which only ever surfaces the `data` key) — reading
      // `response.data as Map` here always failed silently, so this badge
      // was permanently stuck at 0 regardless of real unread notifications.
      final notifResponse = await ApiService().get(
        '/user/notifications',
        queryParams: {'unread': 'true'},
      );
      if (notifResponse.success && notifResponse.data is List) {
        unreadNotificationsCount.value = (notifResponse.data as List)
            .whereType<Map>()
            .where((n) => n['isRead'] != true)
            .length;
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
      if (response.success && response.data is List) {
        final raw = (response.data as List).whereType<Map>();
        ordersList.value =
            raw
                .map(
                  (o) => {
                    'orderId': o['_id']?.toString() ?? '',
                    'id':
                        o['_id']?.toString().substring(
                          o['_id'].toString().length - 7,
                        ) ??
                        '',
                    'store': o['merchantId']?['storeName'] ?? 'VIPs Store',
                    'amount': (o['totalAmount'] ?? 0).toString(),
                    'items': (o['items'] as List?)?.length ?? 1,
                    'rawItems': o['items'] ?? [],
                    'merchantId': o['merchantId']?['_id']?.toString(),
                    'date':
                        o['createdAt'] != null
                            ? DateTime.parse(
                              o['createdAt'],
                            ).toString().substring(0, 10)
                            : '',
                    'time': '',
                    'status': _formatStatusLabel(_normalizeStatus(o['status'] ?? 'pending')),
                    // Backend field is `orderType` (e.g. "delivery"/"pickup"),
                    // not `deliveryType` — that key never existed in the API
                    // response, so this badge always showed "Delivery".
                    'type': _formatTypeLabel(o['orderType'] ?? 'delivery'),
                    'statusColor': _statusColor(_normalizeStatus(o['status'])),
                  },
                )
                .toList();
      }
    } catch (_) {}
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  // models/Order.js's real status enum is pending/confirmed/processing/ready/
  // handover/picked_up/delivered/cancelled/refund_requested/refunded — plain
  // _capitalize() only uppercases the first letter, so multi-word statuses
  // like "refund_requested" rendered as the literal "Refund_requested" and,
  // worse, profile_view.dart's status-color switch was never updated past a
  // handful of statuses from a different domain (reserved/completed/in
  // store), so any of these real statuses fell through to plain grey.
  String _formatStatusLabel(String raw) {
    switch (raw) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'processing':
        return 'Processing';
      case 'ready':
        return 'Ready';
      case 'handover':
        return 'Handover';
      case 'picked_up':
        return 'Picked Up';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
      case 'canceled':
        return 'Cancelled';
      case 'refund_requested':
        return 'Refund Requested';
      case 'refunded':
        return 'Refunded';
      default:
        return raw.isEmpty ? 'Pending' : _capitalize(raw);
    }
  }

  String _formatTypeLabel(String raw) {
    switch (raw) {
      case 'delivery':
        return 'Delivery';
      case 'takeaway':
        return 'Takeaway';
      case 'dine_in':
        return 'Dine In';
      default:
        return raw.isEmpty ? 'Delivery' : _capitalize(raw);
    }
  }

  // Merchants cancel orders with status 'canceled' (see
  // appmerchant/.../order_card.dart), while the user-initiated cancel
  // endpoint (POST /order/:id/cancel) writes 'cancelled' — both spellings
  // are valid per models/Order.js's enum. filteredOrders/_statusColor only
  // ever checked for 'Cancelled', so a merchant-cancelled order silently
  // stayed in the customer's Active tab with the wrong (purple) status
  // color instead of being excluded and shown in red.
  String _normalizeStatus(String? s) => s == 'canceled' ? 'cancelled' : (s ?? 'pending');

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

  final RxBool isOrderActionLoading = false.obs;

  bool orderIsCancelable(Map<String, dynamic> order) {
    final status = (order['status'] as String? ?? '').toLowerCase();
    return status == 'pending' || status == 'confirmed';
  }

  Future<void> cancelOrder(Map<String, dynamic> order) async {
    final orderId = order['orderId'] as String? ?? '';
    if (orderId.isEmpty || isOrderActionLoading.value) return;

    isOrderActionLoading.value = true;
    try {
      final response =
          await ApiService().put('/order/$orderId/cancel', {});
      if (response.success) {
        final index = ordersList.indexWhere((o) => o['orderId'] == orderId);
        if (index != -1) {
          ordersList[index] = {...ordersList[index], 'status': 'Cancelled'};
        }
        safeSnackbar('Order Cancelled', 'Your order has been cancelled.',
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        safeSnackbar('Error', response.message,
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      safeSnackbar('Error', 'Could not cancel order. Please try again.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isOrderActionLoading.value = false;
    }
  }

  // Re-adds every item from a past order to the cart via the same
  // /cart/add endpoint CartController uses, then hands off to the cart
  // screen so the user can review quantities before checking out again.
  Future<void> reorder(Map<String, dynamic> order) async {
    final items = order['rawItems'] as List? ?? [];
    if (items.isEmpty || isOrderActionLoading.value) return;

    isOrderActionLoading.value = true;
    try {
      for (final item in items) {
        if (item is! Map) continue;
        await ApiService().post('/cart/add', {
          'itemId': item['productId']?.toString() ?? '',
          'itemType': 'product',
          'name': item['item_name'] ?? 'Product',
          'price': (item['price'] ?? 0),
          'quantity': item['quantity'] ?? 1,
          'merchantId': order['merchantId'],
        });
      }
      safeSnackbar('Added to Cart', 'Items from this order were added to your cart.',
          backgroundColor: Colors.green, colorText: Colors.white);
      Get.toNamed('/cart');
    } catch (e) {
      safeSnackbar('Error', 'Could not reorder. Please try again.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isOrderActionLoading.value = false;
    }
  }

  // Gestion des filtres de commandes
  final RxString selectedOrderFilter = 'Active'.obs;
  final RxString selectedTypeFilter = 'All'.obs;

  // Gestion des dates
  final Rx<DateTime> fromDate = DateTime.now().subtract(Duration(days: 30)).obs;
  final Rx<DateTime> toDate = DateTime.now().obs;
  // The date range shown in the filter chip was purely cosmetic — picking a
  // range via selectDateRange() updated fromDate/toDate but filteredOrders
  // never checked them. Track whether the user actually picked a range so
  // the default 30-day window doesn't silently hide older orders for
  // everyone before they've touched the filter.
  final RxBool _dateFilterActive = false.obs;

  final RxList<Map<String, dynamic>> ordersList = <Map<String, dynamic>>[].obs;

  // Filtrer les commandes selon les critères sélectionnés
  List<Map<String, dynamic>> get filteredOrders {
    return ordersList.where((order) {
      // Filtre par statut
      bool matchesStatus = true;
      if (selectedOrderFilter.value == 'Active') {
        matchesStatus = !_doneOrRefundedStatuses.contains(order['status']);
      } else if (selectedOrderFilter.value == 'Done') {
        matchesStatus = order['status'] == 'Delivered';
      } else if (selectedOrderFilter.value == 'Refunded') {
        matchesStatus = _refundedStatuses.contains(order['status']);
      }

      // Filtre par type
      bool matchesType = true;
      if (selectedTypeFilter.value != 'All') {
        matchesType = order['type'] == selectedTypeFilter.value;
      }

      // Filtre par date (only once the user has actually picked a range)
      bool matchesDate = true;
      if (_dateFilterActive.value) {
        final rawDate = order['date'] as String? ?? '';
        final orderDate = DateTime.tryParse(rawDate);
        if (orderDate != null) {
          final start = DateTime(fromDate.value.year, fromDate.value.month, fromDate.value.day);
          final end = DateTime(toDate.value.year, toDate.value.month, toDate.value.day, 23, 59, 59);
          matchesDate = !orderDate.isBefore(start) && !orderDate.isAfter(end);
        }
      }

      return matchesStatus && matchesType && matchesDate;
    }).toList();
  }

  static const _refundedStatuses = {'Refunded', 'Refund Requested'};
  static const _doneOrRefundedStatuses = {'Delivered', 'Cancelled', 'Refunded', 'Refund Requested'};

  int get activeOrdersCount {
    return ordersList
        .where((order) => !_doneOrRefundedStatuses.contains(order['status']))
        .length;
  }

  int get doneOrdersCount {
    return ordersList.where((order) => order['status'] == 'Delivered').length;
  }

  int get refundedOrdersCount {
    return ordersList.where((order) => _refundedStatuses.contains(order['status'])).length;
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
        child: SingleChildScrollView(
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
            const Divider(height: 24),
            // filteredOrders already filters on selectedTypeFilter, but nothing
            // in the app could ever change it — the whole dimension was stuck
            // on 'All'. Order.orderType's real enum is delivery/takeaway/dine_in.
            const Text(
              'Order Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (final type in ['All', 'Delivery', 'Takeaway', 'Dine In'])
              ListTile(
                title: Text(type),
                trailing: Obx(
                  () => selectedTypeFilter.value == type
                      ? const Icon(Icons.check, color: Colors.blue)
                      : const SizedBox.shrink(),
                ),
                onTap: () {
                  changeTypeFilter(type);
                  Get.back();
                },
              ),
          ],
        ),
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
      _dateFilterActive.value = true;
    }
  }

  // Formater la date pour l'affichage
  String formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  // No other role is reachable — see selectedRole's declaration.
  Color get primaryColor => Colors.orange;

  List<Map<String, dynamic>> get servicesList {
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

  void navigateToEditProfile() {
    Get.toNamed('/edit-profile');
  }

  void navigateToPaymentMethods() {
    Get.toNamed('/credit');
  }

  // Reuses the same OTP mechanism /auth/forgot-password already sends
  // (email, not password-reset specific) to (re)start email verification
  // for an account that predates the PIN/verification flow, or skipped
  // it at signup — then hands off to the same real Verification screen
  // signup uses.
  Future<void> verifyAccountNow() async {
    if (isSendingVerification.value || userEmail.value.isEmpty) return;
    isSendingVerification.value = true;
    try {
      final response = await ApiService().post('/auth/forgot-password', {'email': userEmail.value});
      if (response.success) {
        Get.toNamed('/verification', arguments: {'email': userEmail.value});
      } else {
        safeSnackbar('Error', response.message, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      safeSnackbar('Error', 'Could not send verification code. Please try again.', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSendingVerification.value = false;
    }
  }

  void navigateToVipsId() {
    VipsIdDialog.show(
      primaryColor: primaryColor,
      userId: userId.value.isNotEmpty ? userId.value : '—',
      userName: userName.value,
    );
  }

  void navigateToWallet() {
    if (!hasPin.value) {
      // Nothing to verify against yet — send them to set one up first
      // instead of showing a PIN prompt that can never succeed.
      safeSnackbar(
        'Set up a PIN first',
        'Create a security PIN to protect access to your Wallet.',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.toNamed('/createpin');
      return;
    }

    Get.to(
      () => PinValidator(
        pinLength: 4,
        primaryColor: primaryColor,
        validatePin: (pin) async {
          final response = await ApiService().post('/auth/pin/verify', {'pin': pin});
          return response.success;
        },
        validateBiometrics: () async {
          final LocalAuthentication localAuth = LocalAuthentication();
          try {
            return await localAuth.authenticate(
              localizedReason: 'Authenticate to access your wallet',
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
