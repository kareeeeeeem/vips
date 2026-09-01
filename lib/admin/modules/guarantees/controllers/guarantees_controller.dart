import 'package:get/get.dart';

import '../../../core/admin_toast.dart';
import '../../../services/admin_api_service.dart';

/// Guarantees held across the merchant network (§5.1, §5.2).
///
/// This money is not the platform's. Merchants deposit it to cover the points
/// their own offers hand out, it is refundable in full, and §5.3 rules out
/// the platform earning anything on it — so this screen reports it apart
/// from revenue and never rolls the two into one figure.
class GuaranteesController extends GetxController {
  final AdminApiService api = AdminApiService();

  final RxList<Map<String, dynamic>> merchants = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isMutating = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString search = ''.obs;

  final RxDouble totalHeldTnd = 0.0.obs;
  final RxDouble totalDepositedTnd = 0.0.obs;
  final RxDouble totalRefundedTnd = 0.0.obs;
  final RxInt withoutGuarantee = 0.obs;
  final RxInt suspended = 0.obs;

  static const List<String> plans = ['basic', 'professional', 'advanced'];

  static String planLabel(String key) => switch (key) {
        'basic' => 'Basic — 3% commission',
        'professional' => 'Professional — 49 TND, 2%',
        'advanced' => 'Advanced — 149 TND, 1%',
        _ => key,
      };

  /// Merchants matching the search box, newest exposure first.
  List<Map<String, dynamic>> get visible {
    final q = search.value.trim().toLowerCase();
    if (q.isEmpty) return merchants;
    return merchants
        .where((m) => '${m['name']}'.toLowerCase().contains(q))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await api.guarantees();
      if (response.success && response.data is Map) {
        final data = Map<String, dynamic>.from(response.data as Map);
        merchants.value = adminItems(data);
        totalHeldTnd.value = adminDouble(data['totalHeldTnd']);
        totalDepositedTnd.value = adminDouble(data['totalDepositedTnd']);
        totalRefundedTnd.value = adminDouble(data['totalRefundedTnd']);
        withoutGuarantee.value = adminInt(data['merchantsWithoutGuarantee']);
        suspended.value = adminInt(data['suspendedMerchants']);
      } else {
        // Keep whatever is on screen rather than blanking the table under an
        // error — a stale figure the operator can see beats no figure.
        errorMessage.value =
            response.message.isNotEmpty ? response.message : 'Could not load guarantees.';
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Records cash received from a merchant. Converts at 100 points = 1 TND
  /// and lands unallocated — the merchant decides the split themselves.
  Future<bool> deposit(String merchantId, num amount, {String note = ''}) async {
    if (amount <= 0) {
      adminToast('Amount missing', 'Enter the amount received, in dinars.', isError: true);
      return false;
    }
    isMutating.value = true;
    try {
      final response = await api.depositGuarantee(merchantId, amount, note: note);
      if (response.success) {
        adminToast('Recorded', '$amount TND added to the guarantee.', isError: false);
        await load();
        return true;
      }
      adminToast('Could not save', response.message, isError: true);
      return false;
    } finally {
      isMutating.value = false;
    }
  }

  Future<bool> setPlan(String merchantId, {String? plan, num? earnRate}) async {
    isMutating.value = true;
    try {
      final response = await api.setMerchantPlan(merchantId, plan: plan, earnRate: earnRate);
      if (response.success) {
        adminToast('Saved', 'Merchant plan updated.', isError: false);
        await load();
        return true;
      }
      adminToast('Could not save', response.message, isError: true);
      return false;
    } finally {
      isMutating.value = false;
    }
  }

  Future<Map<String, dynamic>?> detail(String merchantId) async {
    final response = await api.merchantGuarantee(merchantId);
    if (response.success && response.data is Map) {
      return Map<String, dynamic>.from(response.data as Map);
    }
    adminToast('Could not save', response.message, isError: true);
    return null;
  }
}
