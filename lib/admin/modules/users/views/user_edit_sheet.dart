import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_scaffold.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../controllers/users_controller.dart';

/// Add or edit a customer's own details.
///
/// [user] null means "add". Roles, bans and deletion are deliberately not
/// here: each is its own decision with its own permission, and folding them
/// into a general edit form would let one save do four different things.
Future<void> showUserEditSheet({
  required AdminUsersController controller,
  Map<String, dynamic>? user,
}) {
  final isEdit = user != null;

  final fullName = TextEditingController(text: adminString(user?['fullName']));
  final phone = TextEditingController(text: adminString(user?['phone']));
  final email = TextEditingController(text: adminString(user?['email']));
  final city = TextEditingController(text: adminString(user?['city']));

  final error = RxnString();
  final isSaving = false.obs;

  Future<void> submit() async {
    if (isSaving.value) return;
    error.value = null;

    if (fullName.text.trim().isEmpty) {
      error.value = 'A name is required.';
      return;
    }
    if (phone.text.trim().isEmpty) {
      error.value = 'A phone number is required.';
      return;
    }

    isSaving.value = true;
    try {
      bool ok;
      if (isEdit) {
        final changes = <String, dynamic>{};
        void diff(String key, String current, String next) {
          if (current != next) changes[key] = next;
        }

        diff('fullName', adminString(user['fullName']), fullName.text.trim());
        diff('phone', adminString(user['phone']), phone.text.trim());
        diff('email', adminString(user['email']), email.text.trim());
        diff('city', adminString(user['city']), city.text.trim());

        if (changes.isEmpty) {
          error.value = 'Nothing has changed.';
          isSaving.value = false;
          return;
        }
        // Email and phone are sign-in identifiers, so the server refuses a
        // value another account already holds and says which one.
        ok = await controller.updateUser(adminString(user['_id']), changes);
      } else {
        ok = await controller.createUser(
          fullName: fullName.text.trim(),
          phone: phone.text.trim(),
          email: email.text.trim().isEmpty ? null : email.text.trim(),
          city: city.text.trim().isEmpty ? null : city.text.trim(),
        );
      }
      if (ok) Get.back();
    } finally {
      isSaving.value = false;
    }
  }

  return adminSheet(
    title: isEdit
        ? adminString(user['fullName'], 'Edit customer')
        : 'Add a customer',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isEdit)
          Padding(
            padding: EdgeInsets.only(bottom: 14.h),
            child: Text(
              // No password is set here: one is generated and discarded, and
              // the customer claims the account through "forgot password".
              'The customer sets their own password through "forgot password". '
              'Leave the email blank for a walk-in with no address.',
              style: TextStyle(
                fontSize: 11.5.sp,
                height: 1.35,
                color: AdminColors.textMuted,
              ),
            ),
          ),
        _field(fullName, 'Full name'),
        _field(phone, 'Phone', keyboard: TextInputType.phone),
        _field(email, 'Email',
            keyboard: TextInputType.emailAddress,
            helper: isEdit ? 'Used to sign in' : 'Optional'),
        _field(city, 'City (optional)'),
        Obx(() {
          if (error.value == null) return const SizedBox.shrink();
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Text(
              error.value!,
              style: TextStyle(fontSize: 12.sp, color: AdminColors.danger),
            ),
          );
        }),
        SizedBox(height: 4.h),
        Obx(() => AdminButton(
              label: isEdit ? 'Save changes' : 'Add customer',
              isLoading: isSaving.value || controller.isMutating.value,
              onPressed: submit,
            )),
      ],
    ),
  );
}

Widget _field(
  TextEditingController controller,
  String label, {
  TextInputType keyboard = TextInputType.text,
  String? helper,
}) {
  return Padding(
    padding: EdgeInsets.only(bottom: 12.h),
    child: TextField(
      controller: controller,
      keyboardType: keyboard,
      style: TextStyle(fontSize: 13.5.sp),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13.sp),
        helperText: helper,
        helperStyle: TextStyle(fontSize: 10.5.sp, color: AdminColors.textMuted),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      ),
    ),
  );
}
