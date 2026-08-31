import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/routes/admin_routes.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_scaffold.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../controllers/pos_customers_controller.dart';

/// Customers the till can attach to a sale.
class PosCustomersView extends GetView<PosCustomersController> {
  const PosCustomersView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Till customers',
      route: AdminRoutes.POS_CUSTOMERS,
      onRefresh: () => controller.load(),
      actions: [
        Obx(() {
          final allowed = controller.canCreate;
          return IconButton(
            tooltip: allowed
                ? 'Add a customer'
                : 'Adding needs the users.create permission',
            onPressed: allowed ? () => _showAddSheet() : null,
            icon: Icon(Icons.person_add_alt_rounded,
                size: 20.sp,
                color: allowed ? AdminColors.primary : AdminColors.border),
          );
        }),
      ],
      body: Column(
        children: [
          Container(
            color: AdminColors.background,
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
            child: Obx(() {
              controller.search.value;
              return AdminSearchField(
                controller: controller.searchController,
                hint: 'Search by name or phone',
                onChanged: controller.onSearchChanged,
                onClear: controller.clearSearch,
              );
            }),
          ),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildList() {
    return Obx(() {
      if (controller.isLoading.value && controller.items.isEmpty) {
        return const AdminLoading();
      }
      if (controller.errorMessage.isNotEmpty && controller.items.isEmpty) {
        return AdminErrorState(
          message: controller.errorMessage.value,
          onRetry: () => controller.load(),
        );
      }
      if (controller.items.isEmpty) {
        return AdminEmptyState(
          icon: Icons.contact_page_outlined,
          title: controller.search.value.isEmpty
              ? 'No till customers yet'
              : 'No match',
          message: controller.search.value.isEmpty
              // Naming the difference: a walk-in is a real sale with nobody
              // attached, which is why this list is shorter than Users.
              ? 'A counter sale needs no customer. Add one here when somebody '
                  'wants their purchases on an account.'
              : 'No customer matches that name or phone.',
        );
      }

      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
        children: [for (final c in controller.items) _buildCard(c)],
      );
    });
  }

  Widget _buildCard(Map<String, dynamic> customer) {
    final name = adminString(customer['fullName'], 'Unnamed');
    final phone = adminString(customer['phone'], 'No phone');
    final email = adminString(customer['email']);
    final id = adminString(customer['_id']);

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        // Opens the full account, which is where their orders and wallet are.
        onTap: id.isEmpty ? null : () => Get.toNamed(AdminRoutes.userDetails(id)),
        child: Container(
          padding: EdgeInsets.all(13.w),
          decoration: BoxDecoration(
            color: AdminColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AdminColors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 19.r,
                backgroundColor: AdminColors.primary.withValues(alpha: 0.1),
                child: Text(
                  name.isEmpty ? '?' : name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: AdminColors.primary,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                        color: AdminColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      email.isEmpty ? phone : '$phone · $email',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 11.sp, color: AdminColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 19.sp, color: AdminColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddSheet() {
    final name = TextEditingController();
    final phone = TextEditingController();
    final email = TextEditingController();
    final error = RxnString();

    adminSheet(
      title: 'Add a till customer',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'This creates a real customer account. They set their own '
            'password through "forgot password".',
            style: TextStyle(
                fontSize: 11.5.sp, height: 1.35, color: AdminColors.textMuted),
          ),
          SizedBox(height: 14.h),
          _field(name, 'Full name'),
          _field(phone, 'Phone', keyboard: TextInputType.phone),
          _field(email, 'Email (optional)', keyboard: TextInputType.emailAddress),
          Obx(() => error.value == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: Text(error.value!,
                      style:
                          TextStyle(fontSize: 12.sp, color: AdminColors.danger)),
                )),
          Obx(() => AdminButton(
                label: 'Add customer',
                isLoading: controller.isMutating.value,
                onPressed: () async {
                  if (name.text.trim().isEmpty || phone.text.trim().isEmpty) {
                    error.value = 'A name and a phone number are required.';
                    return;
                  }
                  error.value = null;
                  final ok = await controller.createCustomer(
                    fullName: name.text.trim(),
                    phone: phone.text.trim(),
                    email:
                        email.text.trim().isEmpty ? null : email.text.trim(),
                  );
                  if (ok) Get.back();
                },
              )),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType keyboard = TextInputType.text,
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        ),
      ),
    );
  }
}
