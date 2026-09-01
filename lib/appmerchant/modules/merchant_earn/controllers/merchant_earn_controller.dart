import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

/// Recording a sale at the till (§4.1).
///
/// The customer pays as normal, shows their VIPs QR, and the merchant enters
/// the invoice. This is the flow the document describes, and the reason it
/// puts the merchant here is that they are the one who saw the money — the
/// app previously let the customer type their own spending and be credited
/// for it, with no invoice and nobody to check it.
class MerchantEarnController extends GetxController {
  final invoiceController = TextEditingController();
  final phoneController = TextEditingController();
  final changeController = TextEditingController();

  final customerId = ''.obs;
  final customerName = ''.obs;
  final isLookingUp = false.obs;
  final isSubmitting = false.obs;
  final error = ''.obs;

  /// Points this merchant awards per dinar. Null until their profile loads;
  /// zero or null means they have no policy set and cannot award anything.
  final earnRate = Rxn<double>();
  final rateLoaded = false.obs;

  /// What the discount budget can still cover (§5.1). A sale that would
  /// exceed it is refused by the server, so it is shown here first.
  final discountBudget = 0.obs;
  final guaranteeSuspended = false.obs;

  // Giftback rides along on the same sale, which is where change arises.
  final offerGiftback = false.obs;
  final giftbackConsent = false.obs;
  final maxChangeTnd = 5.0.obs;
  final remainingAllowanceTnd = 0.0.obs;
  final allowanceKnown = false.obs;
  final activationDelayHours = 12.obs;

  final lastResult = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    invoiceController.addListener(update);
    changeController.addListener(update);
    loadContext();
  }

  @override
  void onClose() {
    invoiceController.dispose();
    phoneController.dispose();
    changeController.dispose();
    super.onClose();
  }

  static double _num(dynamic v) =>
      v is num ? v.toDouble() : (double.tryParse('${v ?? ''}') ?? 0);

  /// The merchant's own rate and budget, so the screen can say up front when
  /// a sale cannot be recorded rather than failing at the end.
  Future<void> loadContext() async {
    try {
      final profile = await ApiService().get('/merchant/profile');
      if (profile.success && profile.data is Map) {
        final d = Map<String, dynamic>.from(profile.data as Map);
        final rate = d['earnRate'];
        earnRate.value = rate == null ? null : _num(rate);
      }
      final g = await ApiService().get('/merchant/guarantee');
      if (g.success && g.data is Map) {
        final d = Map<String, dynamic>.from(g.data as Map);
        final budgets = Map<String, dynamic>.from(d['budgets'] as Map? ?? {});
        discountBudget.value = (budgets['discount'] as num?)?.toInt() ?? 0;
        guaranteeSuspended.value = d['suspended'] == true;
      }
    } catch (e) {
      debugPrint('earn context failed: $e');
    } finally {
      rateLoaded.value = true;
    }
  }

  /// Points this invoice would award, at the merchant's own rate.
  int get pointsPreview {
    final invoice = double.tryParse(invoiceController.text.trim()) ?? 0;
    final rate = earnRate.value ?? 0;
    if (invoice <= 0 || rate <= 0) return 0;
    return (invoice * rate).floor();
  }

  /// Points the forgone change is worth, at 100 to the dinar (§5.1).
  int get giftbackPointsPreview {
    final change = double.tryParse(changeController.text.trim()) ?? 0;
    return change <= 0 ? 0 : (change * 100).floor();
  }

  bool get canSubmit =>
      customerId.isNotEmpty &&
      (double.tryParse(invoiceController.text.trim()) ?? 0) > 0 &&
      (earnRate.value ?? 0) > 0 &&
      !isSubmitting.value;

  /// Resolves a scanned QR or typed number to a real customer, and reads
  /// their Giftback allowance while it is there.
  Future<bool> lookup({String? qr}) async {
    final phone = phoneController.text.trim();
    if ((qr == null || qr.isEmpty) && phone.isEmpty) {
      error.value = 'Scan the customer\'s QR or enter their number.';
      return false;
    }
    isLookingUp.value = true;
    error.value = '';
    try {
      final response = await ApiService().get(
        '/merchant/customers/lookup',
        queryParams: qr != null && qr.isNotEmpty ? {'qr': qr} : {'phone': phone},
      );
      if (response.success && response.data is Map) {
        final d = Map<String, dynamic>.from(response.data as Map);
        customerId.value = '${d['userId']}';
        customerName.value = '${d['fullName'] ?? ''}';
        if (d['phone'] != null) phoneController.text = '${d['phone']}';
        if (d['giftbackAllowance'] is Map) {
          final a = Map<String, dynamic>.from(d['giftbackAllowance'] as Map);
          remainingAllowanceTnd.value = _num(a['remainingTnd']);
          allowanceKnown.value = true;
        }
        return true;
      }
      customerId.value = '';
      customerName.value = '';
      error.value = response.message.isNotEmpty
          ? response.message
          : 'No VIPs customer matches that.';
      return false;
    } catch (e) {
      debugPrint('customer lookup failed: $e');
      error.value = 'Could not reach the server. Try again.';
      return false;
    } finally {
      isLookingUp.value = false;
    }
  }

  Future<bool> submit() async {
    if (!canSubmit) return false;
    final invoice = double.parse(invoiceController.text.trim());

    // Refuse locally what the server would refuse anyway, so the customer is
    // not told they earned points that are then taken back.
    if (offerGiftback.value) {
      final change = double.tryParse(changeController.text.trim()) ?? 0;
      if (change >= maxChangeTnd.value) {
        error.value = 'Giftback covers change under ${maxChangeTnd.value} TND.';
        return false;
      }
      if (change > 0 && !giftbackConsent.value) {
        error.value = 'The customer has to agree before their change becomes points.';
        return false;
      }
    }

    isSubmitting.value = true;
    error.value = '';
    try {
      final change =
          offerGiftback.value ? double.tryParse(changeController.text.trim()) : null;

      final response = await ApiService().post('/merchant/earn', {
        'userId': customerId.value,
        'invoiceAmount': invoice,
        if (change != null && change > 0) 'giftbackChange': change,
        if (change != null && change > 0) 'giftbackConsent': giftbackConsent.value,
      });

      if (response.success && response.data is Map) {
        final d = Map<String, dynamic>.from(response.data as Map);
        lastResult.value = d;
        if (d['guarantee'] is Map) {
          final g = Map<String, dynamic>.from(d['guarantee'] as Map);
          final budgets = Map<String, dynamic>.from(g['budgets'] as Map? ?? {});
          discountBudget.value = (budgets['discount'] as num?)?.toInt() ?? 0;
          guaranteeSuspended.value = g['suspended'] == true;
        }
        safeSnackbar(
          'Recorded',
          '${d['pointsAwarded']} points for ${d['customer']?['fullName'] ?? 'the customer'}.',
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
        );
        reset();
        return true;
      }
      error.value = response.message;
      return false;
    } catch (e) {
      debugPrint('earn failed: $e');
      error.value = 'Could not record the sale. Try again.';
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  void reset() {
    invoiceController.clear();
    changeController.clear();
    phoneController.clear();
    customerId.value = '';
    customerName.value = '';
    offerGiftback.value = false;
    giftbackConsent.value = false;
    allowanceKnown.value = false;
  }
}
