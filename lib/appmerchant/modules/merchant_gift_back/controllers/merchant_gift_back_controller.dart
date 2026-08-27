import 'package:flutter/material.dart';
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
  final dailyLimit = 0.0.obs;
  final remainingDailyLimit = 0.0.obs;
  final monthlyLimit = 0.0.obs;
  final remainingMonthlyLimit = 0.0.obs;
  final txMin = 0.0.obs;
  final txMax = 0.0.obs;
  final limitsLoaded = false.obs;

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

  Future<void> _loadLimits() async {
    try {
      final response = await ApiService().get('/merchant/gift-back/limits');
      if (response.success && response.data is Map) {
        final d = Map<String, dynamic>.from(response.data as Map);
        currency.value = (d['currency'] ?? 'D').toString();
        dailyLimit.value = _num(d['dailyLimit']);
        remainingDailyLimit.value = _num(d['remainingDailyLimit']);
        monthlyLimit.value = _num(d['monthlyLimit']);
        remainingMonthlyLimit.value = _num(d['remainingMonthlyLimit']);
        txMin.value = _num(d['txMin']);
        txMax.value = _num(d['txMax']);
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
    }

    final phoneOk = phoneController.text.trim().isNotEmpty;
    final raw = amountController.text.trim();
    if (!phoneOk || raw.isEmpty) {
      formError.value = '';
      isFormValid.value = false;
      return;
    }

    final amt = double.tryParse(raw);
    if (amt == null) {
      formError.value = 'Enter a valid amount';
      isFormValid.value = false;
      return;
    }

    // Mirror the server's caps (routes/merchant.js GIFT_BACK_LIMITS) so the
    // merchant is told before the inquiry + PIN steps, not after.
    if (limitsLoaded.value) {
      if (amt < txMin.value) {
        formError.value = 'Minimum gift back is ${_fmt(txMin.value)}';
        isFormValid.value = false;
        return;
      }
      if (amt > txMax.value) {
        formError.value = 'Maximum per transaction is ${_fmt(txMax.value)}';
        isFormValid.value = false;
        return;
      }
      if (amt > remainingDailyLimit.value) {
        formError.value =
            'Daily limit: only ${_fmt(remainingDailyLimit.value)} left today';
        isFormValid.value = false;
        return;
      }
      if (amt > remainingMonthlyLimit.value) {
        formError.value =
            'Monthly limit: only ${_fmt(remainingMonthlyLimit.value)} left this month';
        isFormValid.value = false;
        return;
      }
    } else if (amt <= 0) {
      formError.value = 'Amount must be greater than 0';
      isFormValid.value = false;
      return;
    }

    formError.value = '';
    isFormValid.value = true;
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
          await ApiService().get('/merchant/gift-back/lookup', queryParams: query);
      if (response.success && response.data is Map) {
        final d = Map<String, dynamic>.from(response.data as Map);
        recipientName.value = (d['fullName'] ?? '').toString();
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

  void onProceedToPin() {
    pinCode.value = '';
    pinError.value = '';
    Get.toNamed(MerchantRoutes.GIFT_BACK_PIN);
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
      final amount = enteredAmount;
      final response = await ApiService().post('/merchant/gift-back', {
        if (scannedUserId.value.isNotEmpty)
          'userId': scannedUserId.value
        else
          'phone': phoneController.text.trim(),
        'amount': amount,
        'message': messageController.text.trim().isNotEmpty
            ? messageController.text.trim()
            : 'Gift back from merchant',
      });

      if (response.success) {
        // Set the label before navigating — the status screen reads it on
        // build, and it used to be assigned only after the push.
        statusLabel.value = 'Successful';
        if (response.data is Map) {
          final d = Map<String, dynamic>.from(response.data as Map);
          lastTransaction.value = d;
          if (d['remainingDailyLimit'] != null) {
            remainingDailyLimit.value = _num(d['remainingDailyLimit']);
          }
          if (d['remainingMonthlyLimit'] != null) {
            remainingMonthlyLimit.value = _num(d['remainingMonthlyLimit']);
          }
          if (d['recipientName'] != null) {
            recipientName.value = d['recipientName'].toString();
          }
        }
        Get.toNamed(MerchantRoutes.GIFT_BACK_STATUS);
        safeSnackbar('Success', 'Gift back sent successfully!',
            backgroundColor: Colors.green, colorText: Colors.white);
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
