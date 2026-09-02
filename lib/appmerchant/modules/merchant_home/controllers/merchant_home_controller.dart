import 'package:get/get.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class MerchantHomeController extends GetxController {
  // --- Dashboard Statistics ---
  final RxDouble totalSales = 0.0.obs;
  final RxDouble totalExpenses = 0.0.obs;
  final RxDouble totalPurchases = 0.0.obs;
  final RxDouble totalSaleDue = 0.0.obs;
  final RxDouble totalDueCollect = 0.0.obs;

  // VIPs Stats — all three are PTS (points), never dinars.
  final RxDouble vipsIn = 0.0.obs;
  final RxDouble vipsOut = 0.0.obs;
  /// Total VIPs points issued to customers in the selected period
  /// (rewards + gift backs). Reads the backend's `totalVipsIssued`.
  /// This slot used to read `netProfit`, which is a *dinar* figure — it was
  /// rendered with a "VIP" prefix under a "VIPs Recovery" label that has no
  /// backing concept anywhere in the backend.
  /// §5.2: guarantee points this merchant has taken back out as a bank
  /// transfer. This was `vipsIssued`, rewards and gift-backs added together
  /// — two different outflows summed into a figure that answered no
  /// question, sitting next to both of its own parts.
  final RxDouble vipsRecovery = 0.0.obs;
  final RxDouble vipsRecoveryTnd = 0.0.obs;

  /// The merchant's own spendable VIPs points balance (`User.walletPoints`,
  /// served by GET /merchant/profile). Distinct from [vipsIn]/[vipsOut],
  /// which are period totals of points *issued to customers*. The Quick
  /// Actions sheet labels its figure "Available VIPs Points" and used to
  /// read [vipsIn] — lifetime rewards handed out, not a balance.
  final RxDouble availablePoints = 0.0.obs;

  /// Unread merchant notifications — drives the AppBar bell badge, which
  /// used to be a hardcoded red dot that showed even with zero notifications.
  final RxInt unreadNotifications = 0.obs;

  /// Period filter for the Performance card. Matches the backend's
  /// `?period=` values on GET /merchant/dashboard.
  static const List<String> periods = ['today', 'week', 'month', 'all'];
  static const Map<String, String> periodLabels = {
    'today': 'Today',
    'week': 'This Week',
    'month': 'This Month',
    'all': 'All Time',
  };
  final RxString selectedPeriod = 'today'.obs;
  String get selectedPeriodLabel => periodLabels[selectedPeriod.value] ?? 'Today';

  // --- Merchant Profile ---
  final RxString storeName = ''.obs;
  /// The shop's category, shown under its name in the header. The header
  /// carried the words "Merchant Dashboard" there instead — the same on
  /// every merchant's screen, and so telling them nothing.
  final RxString storeCategory = ''.obs;

  /// The merchant's own live campaigns, shown on the home screen. They had
  /// to open Advertisements to see whether anything was running at all.
  final RxList<Map<String, dynamic>> activeAds = <Map<String, dynamic>>[].obs;
  final RxString storePhone = ''.obs;
  final RxString storeAddress = ''.obs;
  final RxString storeImageUrl = ''.obs;
  final RxString merchantId = ''.obs;

  /// The account's real verification state and whether a security PIN has
  /// been set (both from GET /merchant/profile). The Settings header used to
  /// paint a "Verified" badge on every merchant unconditionally.
  final RxBool isVerified = false.obs;
  final RxBool hasPin = false.obs;

  final RxBool isLoading = true.obs;
  final RxInt currentIndex = 0.obs;

  /// Every tab pushes a screen on top of the dashboard rather than swapping a
  /// body, so the highlight must be reset once that screen is popped —
  /// otherwise the bar keeps showing e.g. "Wallet" as active while the user is
  /// looking at the dashboard again. `Get.toNamed` completes on pop, so the
  /// reset is awaited here instead of being left stale.
  Future<void> changePage(int index) async {
    final route = switch (index) {
      0 => MerchantRoutes.STORE_PROFILE,
      // The tab is called Rapport and led to the transactions list. The
      // report is the shop's position; the transactions list is reachable
      // from inside Finance, where it belongs.
      1 => MerchantRoutes.REPORT,
      2 => MerchantRoutes.QR_RECEIVE,
      // The wallet tab and the drawer's "Wallet & Finance" entry led to two
      // different screens, so the same word took the merchant to two places
      // depending on where they tapped it. Both open Finance, which is the
      // screen that holds the balances; the wallet screen is reachable from
      // inside it rather than competing with it.
      3 => MerchantRoutes.FINANCE_DASHBOARD,
      4 => MerchantRoutes.BUSINESS_PLAN,
      _ => null,
    };
    if (route == null) return;
    currentIndex.value = index;
    await Get.toNamed(route);
    currentIndex.value = 0;
    // Figures may have moved while the merchant was on the other screen
    // (a sale, a gift back, a due collection) — pull them fresh on return.
    await refreshStats();
  }

  @override
  void onInit() {
    super.onInit();
    _loadAll();
  }

  Future<void> _loadAll() async {
    isLoading.value = true;
    try {
      await Future.wait([
        _loadDashboardStats(),
        _loadMerchantProfile(),
        _loadUnreadNotifications(),
        _loadActiveAds(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadDashboardStats() async {
    try {
      final response = await ApiService().get(
        '/merchant/dashboard',
        queryParams: {'period': selectedPeriod.value},
      );
      if (response.success && response.data != null) {
        final data = response.data;
        totalSales.value = (data['totalSales'] ?? 0).toDouble();
        totalExpenses.value = (data['totalExpenses'] ?? 0).toDouble();
        totalPurchases.value = (data['totalPurchases'] ?? 0).toDouble();
        totalSaleDue.value = (data['totalSaleDue'] ?? data['totalDue'] ?? 0).toDouble();
        totalDueCollect.value = (data['totalDueCollect'] ?? data['totalCollected'] ?? 0).toDouble();
        vipsIn.value = (data['totalRewards'] ?? 0).toDouble();
        vipsOut.value = (data['totalGiftBack'] ?? 0).toDouble();
        vipsRecovery.value = (data['vipsRecoveryPoints'] ?? 0).toDouble();
        vipsRecoveryTnd.value = (data['vipsRecoveryTnd'] ?? 0).toDouble();
      }
    } catch (_) {}
  }

  Future<void> _loadUnreadNotifications() async {
    try {
      final response = await ApiService().get('/merchant/notifications');
      if (response.success && response.data is Map) {
        unreadNotifications.value =
            (response.data['unreadCount'] as num?)?.toInt() ?? 0;
      }
    } catch (_) {}
  }

  /// Re-reads just the unread badge — used after returning from the
  /// notifications screen, where items may have been marked read.
  Future<void> refreshUnreadNotifications() => _loadUnreadNotifications();

  /// Re-queries the dashboard for a different window. Only the Performance
  /// card's figures change; nothing else needs reloading.
  Future<void> changePeriod(String period) async {
    if (!periods.contains(period) || period == selectedPeriod.value) return;
    selectedPeriod.value = period;
    isLoading.value = true;
    try {
      await _loadDashboardStats();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadActiveAds() async {
    try {
      final response = await ApiService()
          .get('/merchant/ads', queryParams: {'status': 'active', 'limit': '10'});
      if (response.success && response.data is Map) {
        final data = Map<String, dynamic>.from(response.data as Map);
        activeAds.value = ((data['ads'] as List?) ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
    } catch (_) {
      // A home screen that fails to load because an advert list did is
      // worse than a home screen with no advert strip.
    }
  }

  Future<void> _loadMerchantProfile() async {
    try {
      final response = await ApiService().get('/merchant/profile');
      if (response.success && response.data != null) {
        final data = response.data;
        storeName.value = data['storeName'] ?? data['fullName'] ?? '';
        storePhone.value = data['phone'] ?? '';
        storeAddress.value = data['storeAddress'] ?? '';
        storeCategory.value = data['storeCategory'] ?? '';
        storeImageUrl.value = data['logo'] ?? data['profileImage'] ?? '';
        merchantId.value = data['_id']?.toString() ?? '';
        availablePoints.value = (data['walletPoints'] is num)
            ? (data['walletPoints'] as num).toDouble()
            : 0.0;
        isVerified.value = data['isVerified'] == true;
        hasPin.value = data['hasPin'] == true;
      }
    } catch (_) {}
  }

  Future<void> refreshStats() async {
    await _loadAll();
  }

  /// Sets or changes this account's security PIN (POST /auth/pin) — the PIN
  /// that gates bill approval and Gift Back. The merchant app gated screens
  /// behind a PIN but had no screen anywhere to actually set one, so a
  /// merchant who never set a PIN was told "Set a PIN for this account"
  /// with nowhere to go.
  Future<bool> setSecurityPin(String pin) async {
    final response = await ApiService().post('/auth/pin', {'pin': pin});
    if (response.success) {
      hasPin.value = true;
      return true;
    }
    safeSnackbar(
      'Error',
      response.message.isNotEmpty ? response.message : 'Could not save your PIN',
      snackPosition: SnackPosition.BOTTOM,
    );
    return false;
  }
}

