import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import '../../../routes/merchant_routes.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class MerchantGiftBackController extends GetxController {
  // --- Step 1: Form ---
  final phoneController = TextEditingController();
  final amountController = TextEditingController();
  final messageController = TextEditingController();

  // Reactive states
  final isFormValid = false.obs;
  final isSending = false.obs;

  /// Why the form is not submittable, shown under the amount field. Empty
  /// when the entry is valid. The form used to only check "both fields are
  /// non-empty", so an over-limit amount was only rejected by the server —
  /// after the merchant had already gone through inquiry and PIN.
  final formError = ''.obs;

  // --- Step 2: PIN ---
  final pinCode = ''.obs;
  final isBiometricTab = false.obs;
  final isVerifyingPin = false.obs;
  final pinError = ''.obs;

  /// Whether this merchant account has a PIN set at all
  /// (`hasPin` on GET /merchant/profile).
  final hasPin = true.obs;

  // --- Step 3: Status ---
  final statusLabel = 'Pending'.obs;

  /// The transaction actually created by POST /merchant/gift-back, kept so
  /// the receipt shows real values. The invoice used to hardcode its
  /// Trans ID, phone and address.
  final lastTransaction = Rxn<Map<String, dynamic>>();

  // --- Recipient (resolved via GET /merchant/gift-back/lookup) ---
  final recipientName = ''.obs;
  final isLookingUp = false.obs;

  // Set only by a successful QR scan (see GiftBackScanMeView) — takes
  // priority over phoneController for the send, since it's an exact
  // customer match rather than a typed-in phone number. Cleared whenever
  // phoneController's text changes to anything other than what the scan
  // itself just populated, so an edited phone number can't be sent under a
  // stale scanned identity.
  final scannedUserId = ''.obs;
  String _lastScannedPhone = '';

  // --- Limits (from API) ---
  final currency = 'D'.obs;

  // §4.2. The cap is the customer's, not this merchant's: 50 TND a month per
  // person, across every shop they visit. The old per-merchant daily and
  // monthly ceilings measured the wrong thing entirely.
  final maxChangeTnd = 5.0.obs;
  final monthlyCapTnd = 50.0.obs;
  final activationDelayHours = 12.obs;
  /// How much of *this customer's* monthly allowance is left. Only knowable
  /// once a customer has been resolved.
  final remainingAllowanceTnd = 0.0.obs;
  final allowanceKnown = false.obs;
  final limitsLoaded = false.obs;

  /// The customer has to say yes before their change becomes points. Never
  /// defaulted to true — an opt-in that starts on is not an opt-in, and §7
  /// rests the platform's exemption on this being the customer's choice.
  final customerConsented = false.obs;

  /// The invoice the change came off, for the approval log (§6.2).
  final invoiceController = TextEditingController();

  double get enteredAmount => double.tryParse(amountController.text.trim()) ?? 0;

  @override
  void onInit() {
    super.onInit();
    // A caller (the Customers list) can hand us the customer to pay.
    final args = Get.arguments;
    if (args is Map && (args['phone']?.toString().isNotEmpty ?? false)) {
      phoneController.text = args['phone'].toString();
    }
    phoneController.addListener(_validateForm);
    amountController.addListener(_validateForm);
    _validateForm();
    _loadLimits();
    _loadPinStatus();
  }

  /// The platform-wide rules. The per-customer allowance comes later, with
  /// [lookupRecipient], because it belongs to a specific person.
  Future<void> _loadLimits({String? userId, String? phone}) async {
    try {
      final response = await ApiService().get(
        '/merchant/gift-back/limits',
        queryParams: {
          if (userId != null && userId.isNotEmpty) 'userId': userId,
          if (userId == null && phone != null && phone.isNotEmpty) 'phone': phone,
        },
      );
      if (response.success && response.data is Map) {
        final d = Map<String, dynamic>.from(response.data as Map);
        maxChangeTnd.value = _num(d['maxChangeTnd']);
        monthlyCapTnd.value = _num(d['monthlyCapTnd']);
        activationDelayHours.value =
            (d['activationDelayHours'] as num?)?.toInt() ?? 12;
        if (d['allowance'] is Map) {
          final a = Map<String, dynamic>.from(d['allowance'] as Map);
          remainingAllowanceTnd.value = _num(a['remainingTnd']);
          allowanceKnown.value = true;
        }
        limitsLoaded.value = true;
        _validateForm();
      }
    } catch (e) {
      debugPrint('gift-back limits failed: $e');
    }
  }

  Future<void> _loadPinStatus() async {
    try {
      final response = await ApiService().get('/merchant/profile');
      if (response.success && response.data is Map) {
        hasPin.value = (response.data as Map)['hasPin'] == true;
      }
    } catch (e) {
      debugPrint('gift-back hasPin check failed: $e');
    }
  }

  static double _num(dynamic v) => v is num ? v.toDouble() : (double.tryParse('${v ?? ''}') ?? 0);

  void _validateForm() {
    if (phoneController.text != _lastScannedPhone) {
      scannedUserId.value = '';
      recipientName.value = '';
      // A different customer has a different allowance; the old one is no
      // longer something this form knows.
      allowanceKnown.value = false;
    }

    final phoneOk = phoneController.text.trim().isNotEmpty;
    final raw = amountController.text.trim();
    if (!phoneOk || raw.isEmpty) {
      formError.value = '';
      isFormValid.value = false;
      return;
    }

    final change = double.tryParse(raw);
    if (change == null || change <= 0) {
      formError.value = 'Enter the change amount';
      isFormValid.value = false;
      return;
    }

    // §4.2: this is change, not a payment. Checked here so the merchant is
    // told at the keypad rather than after the PIN step.
    if (limitsLoaded.value && change >= maxChangeTnd.value) {
      formError.value =
          'Giftback covers change under ${_fmt(maxChangeTnd.value)}. '
          'Hand ${_fmt(change)} back to the customer.';
      isFormValid.value = false;
      return;
    }

    if (allowanceKnown.value && change > remainingAllowanceTnd.value) {
      formError.value = remainingAllowanceTnd.value <= 0
          ? 'This customer has used their ${_fmt(monthlyCapTnd.value)} allowance this month.'
          : 'Only ${_fmt(remainingAllowanceTnd.value)} left of this customer\'s monthly allowance.';
      isFormValid.value = false;
      return;
    }

    if (!customerConsented.value) {
      formError.value = 'The customer has to agree before their change becomes points.';
      isFormValid.value = false;
      return;
    }

    formError.value = '';
    isFormValid.value = true;
  }

  /// Points the customer will receive, at 100 points to the dinar (§5.1).
  int get pointsForChange {
    final change = double.tryParse(amountController.text.trim()) ?? 0;
    return (change * 100).floor();
  }

  void setConsent(bool value) {
    customerConsented.value = value;
    _validateForm();
  }

  String _fmt(double v) =>
      '${currency.value} ${v.toStringAsFixed(v == v.roundToDouble() ? 0 : 2)}';

  void onScanQR() {
    Get.toNamed(MerchantRoutes.GIFT_BACK_SCAN_ME);
  }

  // Called by GiftBackScanMeView after it resolves a scanned QR to a real
  // customer via GET /merchant/gift-back/lookup.
  void applyScannedCustomer({
    required String userId,
    required String phone,
    String? fullName,
  }) {
    _lastScannedPhone = phone;
    scannedUserId.value = userId;
    phoneController.text = phone;
    if (fullName != null) recipientName.value = fullName;
  }

  /// Resolves the typed phone (or scanned id) to a real customer before the
  /// merchant confirms. `/merchant/gift-back/lookup` already existed for
  /// this; nothing called it for a typed number, so the inquiry screen
  /// confirmed a send to a bare phone string and a wrong/unknown number only
  /// failed after the PIN step.
  Future<bool> lookupRecipient() async {
    isLookingUp.value = true;
    try {
      final query = scannedUserId.value.isNotEmpty
          ? {'userId': scannedUserId.value}
          : {'phone': phoneController.text.trim()};
      final response =
          await ApiService().get('/merchant/customers/lookup', queryParams: query);
      if (response.success && response.data is Map) {
        final d = Map<String, dynamic>.from(response.data as Map);
        recipientName.value = (d['fullName'] ?? '').toString();
        if (d['userId'] != null) scannedUserId.value = d['userId'].toString();
        // The allowance travels with the customer, so read it here rather
        // than making the merchant discover it when the send is refused.
        if (d['giftbackAllowance'] is Map) {
          final a = Map<String, dynamic>.from(d['giftbackAllowance'] as Map);
          remainingAllowanceTnd.value = _num(a['remainingTnd']);
          monthlyCapTnd.value = _num(a['capTnd']);
          allowanceKnown.value = true;
        }
        _validateForm();
        return true;
      }
      recipientName.value = '';
      safeSnackbar('Not found', response.message.isNotEmpty
          ? response.message
          : 'No customer found with that phone number');
      return false;
    } catch (e) {
      debugPrint('gift-back lookup failed: $e');
      recipientName.value = '';
      safeSnackbar('Error', 'Could not look up that customer. Please try again.');
      return false;
    } finally {
      isLookingUp.value = false;
    }
  }

  /// Form → Inquiry. Blocks on an unresolvable recipient rather than letting
  /// the merchant walk into the PIN step for a phone number that isn't real.
  Future<void> onProceedToInquiry() async {
    if (!isFormValid.value) return;
    final ok = await lookupRecipient();
    if (!ok) return;
    Get.toNamed(MerchantRoutes.GIFT_BACK_INQUIRY);
  }

  /// Consent, then PIN.
  ///
  /// §7 rests the platform's position on the customer having chosen this,
  /// so the merchant confirms it in front of them as its own deliberate
  /// step rather than a checkbox they passed on the way through. The PIN
  /// that follows authorises the merchant; this authorises the customer,
  /// and one cannot stand in for the other.
  void onProceedToPin() {
    final change = enteredAmount;
    final points = pointsForChange;

    Get.dialog<void>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
        titlePadding: EdgeInsets.fromLTRB(22.w, 22.h, 22.w, 8.h),
        contentPadding: EdgeInsets.fromLTRB(22.w, 0, 22.w, 8.h),
        title: Row(
          children: [
            Icon(Icons.volunteer_activism_outlined,
                color: const Color(0xFF10B981), size: 22.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'Ask the customer',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recipientName.value.isNotEmpty
                  ? '${recipientName.value} gives up '
                      '${_fmt(change)} in change and receives $points points.'
                  : 'The customer gives up ${_fmt(change)} in change '
                      'and receives $points points.',
              style: TextStyle(
                  fontSize: 14.sp, color: const Color(0xFF374151), height: 1.6),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.schedule, size: 16.sp, color: const Color(0xFF059669)),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'They can spend the points in '
                      '${activationDelayHours.value} hours, not right away. '
                      'Say so before they agree.',
                      style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF065F46),
                          height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsPadding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 12.h),
        actions: [
          TextButton(
            onPressed: () {
              // Declining clears consent: the next attempt has to ask again.
              customerConsented.value = false;
              _validateForm();
              Get.back<void>();
            },
            child: Text('They said no', style: TextStyle(fontSize: 13.sp)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            onPressed: () {
              customerConsented.value = true;
              _validateForm();
              Get.back<void>();
              pinCode.value = '';
              pinError.value = '';
              Get.toNamed(MerchantRoutes.GIFT_BACK_PIN);
            },
            child: Text('They agreed', style: TextStyle(fontSize: 13.sp)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Real server-side PIN check (POST /auth/pin/verify) — the same gate the
  /// billing flow uses. This screen used to fire the send as soon as four
  /// digits were entered, without comparing them to anything at all.
  Future<bool> verifyPin(String pin) async {
    isVerifyingPin.value = true;
    try {
      final response = await ApiService().post('/auth/pin/verify', {'pin': pin});
      return response.success;
    } catch (e) {
      debugPrint('gift-back verifyPin failed: $e');
      return false;
    } finally {
      isVerifyingPin.value = false;
    }
  }

  Future<void> onAcceptRequest() async {
    if (isSending.value) return;
    isSending.value = true;
    try {
      final change = enteredAmount;
      final invoice = double.tryParse(invoiceController.text.trim());
      final response = await ApiService().post('/merchant/gift-back', {
        if (scannedUserId.value.isNotEmpty)
          'userId': scannedUserId.value
        else
          'phone': phoneController.text.trim(),
        'changeTnd': change,
        if (invoice != null) 'invoiceTnd': invoice,
        // Sent explicitly rather than implied by the request existing: the
        // server refuses without it, which is what makes the opt-in real.
        'consent': customerConsented.value,
      });

      if (response.success) {
        // Set the label before navigating — the status screen reads it on
        // build, and it used to be assigned only after the push.
        statusLabel.value = 'Successful';
        customerConsented.value = false;
        if (response.data is Map) {
          final d = Map<String, dynamic>.from(response.data as Map);
          lastTransaction.value = d;
          if (d['allowance'] is Map) {
            final a = Map<String, dynamic>.from(d['allowance'] as Map);
            remainingAllowanceTnd.value = _num(a['remainingTnd']);
            allowanceKnown.value = true;
          }
          if (d['recipientName'] != null) {
            recipientName.value = d['recipientName'].toString();
          }
        }
        Get.toNamed(MerchantRoutes.GIFT_BACK_STATUS);
        // Said plainly: the customer will not see these points for twelve
        // hours, and a merchant who does not know that will be asked why.
        safeSnackbar(
          'Recorded',
          'Points become spendable in ${activationDelayHours.value} hours.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        statusLabel.value = 'Failed';
        // Stay on the PIN screen so the merchant can correct and retry
        // instead of being stranded with a filled-in PIN and no feedback.
        pinCode.value = '';
        pinError.value = response.message;
        safeSnackbar('Error', response.message);
        // A rejected send usually means a limit moved — re-read them.
        await _loadLimits();
      }
    } catch (e) {
      statusLabel.value = 'Failed';
      pinCode.value = '';
      pinError.value = 'Could not send the gift back.';
      debugPrint('sendGiftBack failed: $e');
      safeSnackbar('Error', 'Could not send the gift back. Please try again.');
    } finally {
      isSending.value = false;
    }
  }

  Future<void> updatePin(String digit) async {
    if (isVerifyingPin.value || isSending.value) return;
    if (pinCode.value.length >= 4) return;

    pinError.value = '';
    pinCode.value += digit;
    if (pinCode.value.length < 4) return;

    if (!hasPin.value) {
      pinCode.value = '';
      pinError.value = 'No PIN set on this account. Set one in Settings first.';
      safeSnackbar('No PIN set',
          'Set a PIN for this account before sending a gift back.');
      return;
    }

    final entered = pinCode.value;
    final ok = await verifyPin(entered);
    if (!ok) {
      pinCode.value = '';
      pinError.value = 'Incorrect PIN. Please try again.';
      return;
    }
    await onAcceptRequest();
  }

  void clearPin() {
    pinError.value = '';
    if (pinCode.value.isNotEmpty) {
      pinCode.value = pinCode.value.substring(0, pinCode.value.length - 1);
    }
  }

  /// Clears the whole flow so a second gift back doesn't inherit the previous
  /// recipient/amount.
  void resetFlow() {
    phoneController.clear();
    amountController.clear();
    messageController.clear();
    scannedUserId.value = '';
    recipientName.value = '';
    _lastScannedPhone = '';
    pinCode.value = '';
    pinError.value = '';
    statusLabel.value = 'Pending';
    lastTransaction.value = null;
    _loadLimits();
  }

  @override
  void onClose() {
    phoneController.dispose();
    amountController.dispose();
    messageController.dispose();
    super.onClose();
  }
}
