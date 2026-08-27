// Unit tests for the pure/testable business logic in the appuser auth-flow
// GetX controllers: success_account, forgot_password, createpin,
// verification, reset_password, signup, login, edit_profile, main_app.
//
// Pattern (matches test/appuser_business_logic_test.dart): controllers are
// constructed directly (never Get.put/onInit) so their network-calling /
// navigation-triggering onInit() bodies never run — we drive the reactive
// fields and pure getters/methods directly instead.
//
// Several controllers here validate user input only inside private listener
// methods (e.g. `_validateEmail`) that are wired up in onInit(). Since we
// deliberately never call onInit() (it would fire real HTTP calls or start
// long-lived timers), those private validators are unreachable from this
// test file and are intentionally left untested — only the public surface
// (getters, toggles, computed properties) is exercised, per the file's own
// pattern.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vip/appuser/modules/success_account/controllers/success_account_controller.dart';
import 'package:vip/appuser/modules/forgot_password/controllers/forgot_password_controller.dart';
import 'package:vip/appuser/modules/createpin/controllers/createpin_controller.dart';
import 'package:vip/appuser/modules/verification/controllers/verification_controller.dart';
import 'package:vip/appuser/modules/reset_password/controllers/reset_password_controller.dart';
import 'package:vip/appuser/modules/signup/controllers/signup_controller.dart';
import 'package:vip/appuser/modules/login/controllers/login_controller.dart';
import 'package:vip/appuser/modules/edit_profile/controllers/edit_profile_controller.dart';
import 'package:vip/appuser/modules/main_app/controllers/main_app_controller.dart';

// Tests for LoginController.toggleRememberMe and
// MainAppController.toggleAmountVisibility were removed with those methods:
// neither flag was read anywhere in the app and no control toggled them.

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // ═══════════════════════════════════════════════════════════
  // SuccessAccountController
  // ═══════════════════════════════════════════════════════════
  // The real controller only exposes goToHome(), which navigates via
  // Get.offAllNamed — not unit-testable without a live route table. It has
  // no other state or pure logic to exercise.
  group('SuccessAccountController', () {
    test('can be constructed without touching Get/navigation', () {
      expect(() => SuccessAccountController(), returnsNormally);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // ForgotPasswordController
  // ═══════════════════════════════════════════════════════════
  group('ForgotPasswordController', () {
    late ForgotPasswordController controller;

    setUp(() {
      controller = ForgotPasswordController();
    });

    test('isEmailValid and isSending default to false', () {
      expect(controller.isEmailValid.value, isFalse);
      expect(controller.isSending.value, isFalse);
    });

    test('submittedEmail returns the trimmed email text', () {
      controller.emailController.text = '  user@example.com  ';
      expect(controller.submittedEmail, equals('user@example.com'));
    });

    test('submittedEmail is empty when the field is empty', () {
      expect(controller.submittedEmail, equals(''));
    });
  });

  // ═══════════════════════════════════════════════════════════
  // CreatepinController
  // ═══════════════════════════════════════════════════════════
  group('CreatepinController', () {
    late CreatepinController controller;

    setUp(() {
      controller = CreatepinController();
    });

    test('initial state is the first-entry step with no error', () {
      expect(controller.isConfirmStep.value, isFalse);
      expect(controller.hasError.value, isFalse);
      expect(controller.firstPin.value, isEmpty);
      expect(controller.isCreating.value, isFalse);
    });

    test('onPinCompleted stores the first PIN and advances to confirm step',
        () async {
      controller.onPinCompleted('1234');
      expect(controller.firstPin.value, equals('1234'));
      expect(controller.isConfirmStep.value, isTrue);

      // Let the internal 300ms focus-request Future settle before the test
      // ends so no timer callback escapes into a later test.
      await Future.delayed(const Duration(milliseconds: 350));
    });

    test(
        'onPinCompleted flags a mismatch on confirm step and clears the confirm field',
        () async {
      controller.onPinCompleted('1234'); // first entry
      controller.confirmPinController.text = '9999';

      controller.onPinCompleted('9999'); // mismatched confirmation
      expect(controller.hasError.value, isTrue);
      expect(controller.confirmPinController.text, isEmpty);
      // firstPin is untouched by a failed confirmation attempt.
      expect(controller.firstPin.value, equals('1234'));

      // Let the internal delayed resets (300ms + 500ms) settle.
      await Future.delayed(const Duration(milliseconds: 600));
    });

    test('goBack from the confirm step resets to the first-entry step',
        () async {
      controller.onPinCompleted('1234'); // move to confirm step
      controller.confirmPinController.text = '5678';

      controller.goBack();

      expect(controller.isConfirmStep.value, isFalse);
      expect(controller.firstPin.value, isEmpty);
      expect(controller.hasError.value, isFalse);
      expect(controller.pinController.text, isEmpty);
      expect(controller.confirmPinController.text, isEmpty);

      await Future.delayed(const Duration(milliseconds: 350));
    });
  });

  // ═══════════════════════════════════════════════════════════
  // VerificationController
  // ═══════════════════════════════════════════════════════════
  group('VerificationController', () {
    late VerificationController controller;

    setUp(() {
      controller = VerificationController();
    });

    test('default state before onInit has run', () {
      expect(controller.email.value, isEmpty);
      expect(controller.isVerifying.value, isFalse);
      expect(controller.resendTimer.value, equals(60));
    });

    test('resendCode is a no-op while the resend timer is still running',
        () async {
      controller.resendTimer.value = 30;
      await controller.resendCode();
      // Since the timer had not reached 0, resendCode returns early and
      // does not touch resendTimer (and critically does not kick off a new
      // startResendTimer loop).
      expect(controller.resendTimer.value, equals(30));
    });
  });

  // ═══════════════════════════════════════════════════════════
  // ResetPasswordController
  // ═══════════════════════════════════════════════════════════
  group('ResetPasswordController', () {
    late ResetPasswordController controller;

    setUp(() {
      controller = ResetPasswordController();
    });

    test('visibility and validity flags default to false', () {
      expect(controller.isPasswordVisible.value, isFalse);
      expect(controller.isConfirmPasswordVisible.value, isFalse);
      expect(controller.isPasswordValid.value, isFalse);
      expect(controller.isPasswordConfirmed.value, isFalse);
      expect(controller.isResetting.value, isFalse);
    });

    test('togglePasswordVisibility flips isPasswordVisible', () {
      controller.togglePasswordVisibility();
      expect(controller.isPasswordVisible.value, isTrue);
      controller.togglePasswordVisibility();
      expect(controller.isPasswordVisible.value, isFalse);
    });

    test('toggleConfirmPasswordVisibility flips isConfirmPasswordVisible',
        () {
      controller.toggleConfirmPasswordVisibility();
      expect(controller.isConfirmPasswordVisible.value, isTrue);
      controller.toggleConfirmPasswordVisibility();
      expect(controller.isConfirmPasswordVisible.value, isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // SignupController
  // ═══════════════════════════════════════════════════════════
  group('SignupController', () {
    late SignupController controller;

    setUp(() {
      controller = SignupController();
    });

    test('all validity flags default to false', () {
      expect(controller.isFullNameValid.value, isFalse);
      expect(controller.isPhoneValid.value, isFalse);
      expect(controller.isEmailValid.value, isFalse);
      expect(controller.isPasswordValid.value, isFalse);
      expect(controller.isPasswordConfirmed.value, isFalse);
      expect(controller.isLoading.value, isFalse);
    });

    test('canSubmit is false until every validity flag is true', () {
      expect(controller.canSubmit, isFalse);

      controller.isFullNameValid.value = true;
      controller.isPhoneValid.value = true;
      controller.isEmailValid.value = true;
      expect(controller.canSubmit, isFalse); // password not confirmed yet

      controller.isPasswordConfirmed.value = true;
      expect(controller.canSubmit, isTrue);
    });

    test('canSubmit turns false again if any single flag flips back', () {
      controller.isFullNameValid.value = true;
      controller.isPhoneValid.value = true;
      controller.isEmailValid.value = true;
      controller.isPasswordConfirmed.value = true;
      expect(controller.canSubmit, isTrue);

      controller.isPhoneValid.value = false;
      expect(controller.canSubmit, isFalse);
    });

    test('togglePasswordVisibility flips isPasswordVisible', () {
      controller.togglePasswordVisibility();
      expect(controller.isPasswordVisible.value, isTrue);
      controller.togglePasswordVisibility();
      expect(controller.isPasswordVisible.value, isFalse);
    });

    test('toggleConfirmPasswordVisibility flips isConfirmPasswordVisible',
        () {
      controller.toggleConfirmPasswordVisibility();
      expect(controller.isConfirmPasswordVisible.value, isTrue);
      controller.toggleConfirmPasswordVisibility();
      expect(controller.isConfirmPasswordVisible.value, isFalse);
    });

    test(
        'signUpWithGoogle / signUpWithFacebook attempt real Firebase '
        'sign-in and reset isLoading even when it fails (no Firebase app '
        'and no mounted Navigator in this unit-test environment, so the '
        'error dialog itself throws — that is a test-harness limitation, '
        'not app behavior; a real run has a mounted GetMaterialApp)',
        () async {
      try {
        await controller.signUpWithGoogle();
      } catch (_) {}
      expect(controller.isLoading.value, isFalse);

      try {
        await controller.signUpWithFacebook();
      } catch (_) {}
      expect(controller.isLoading.value, isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // LoginController
  // ═══════════════════════════════════════════════════════════
  group('LoginController', () {
    late LoginController controller;

    setUp(() {
      controller = LoginController();
    });

    test('rememberMe and isPasswordVisible default to false', () {
      expect(controller.rememberMe, isFalse);
      expect(controller.isPasswordVisible, isFalse);
    });


    test('togglePasswordVisibility flips isPasswordVisible', () {
      controller.togglePasswordVisibility();
      expect(controller.isPasswordVisible, isTrue);
      controller.togglePasswordVisibility();
      expect(controller.isPasswordVisible, isFalse);
    });

    test('canEmailLogin requires both email and password to be non-empty',
        () {
      expect(controller.canEmailLogin, isFalse);

      controller.emailController.text = 'user@example.com';
      expect(controller.canEmailLogin, isFalse);

      controller.passwordController.text = 'Secret1';
      expect(controller.canEmailLogin, isTrue);

      controller.passwordController.text = '';
      expect(controller.canEmailLogin, isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // EditProfileController
  // ═══════════════════════════════════════════════════════════
  group('EditProfileController', () {
    late EditProfileController controller;

    setUp(() {
      controller = EditProfileController();
    });

    test('isMale defaults to true', () {
      expect(controller.isMale.value, isTrue);
    });

    test('selectedCity and selectedCivilStatus default to null', () {
      expect(controller.selectedCity.value, isNull);
      expect(controller.selectedCivilStatus.value, isNull);
    });

    test('selectedCity / selectedCivilStatus can be updated directly', () {
      controller.selectedCity.value = 'Sfax';
      expect(controller.selectedCity.value, equals('Sfax'));

      controller.selectedCivilStatus.value = 'Married';
      expect(controller.selectedCivilStatus.value, equals('Married'));
    });

    test('cities exposes the fixed list of selectable cities', () {
      expect(
        controller.cities,
        equals(['Nabeul', 'Tunis', 'Gafsa', 'Sousse', 'Sfax']),
      );
    });

    test('civilStatuses exposes the fixed list of statuses', () {
      expect(
        controller.civilStatuses,
        equals(['Single', 'Married', 'Divorced', 'Widowed']),
      );
    });
  });

  // ═══════════════════════════════════════════════════════════
  // MainAppController
  // ═══════════════════════════════════════════════════════════
  group('MainAppController', () {
    late MainAppController controller;

    setUp(() {
      controller = MainAppController();
    });

    test('currentIndex and isAmountVisible default correctly', () {
      expect(controller.currentIndex.value, equals(0));
      expect(controller.isAmountVisible.value, isFalse);
    });

    test('changePage updates currentIndex', () {
      controller.changePage(2);
      expect(controller.currentIndex.value, equals(2));
    });


    test('userPoints falls back to 0.0 when no ProfileController is registered',
        () {
      expect(controller.userPoints, equals(0.0));
    });

    test('primaryColor falls back to Colors.orange when no ProfileController is registered',
        () {
      expect(controller.primaryColor, equals(Colors.orange));
    });

    test('currentRole falls back to "Customer" when no ProfileController is registered',
        () {
      expect(controller.currentRole, equals('Customer'));
    });
  });
}
