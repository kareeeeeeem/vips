import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vip/core/utils/safe_snackbar.dart';
import 'package:get/get.dart';
import 'package:vip/core/widgets/custom_network_image.dart';
import '../controllers/merchant_store_profile_controller.dart';

class MerchantStoreProfileView extends GetView<MerchantStoreProfileController> {
  const MerchantStoreProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: _buildTopTabs(),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildStoreBanner(),
            SizedBox(height: 20.h),
            _buildStoreHeader(),
            SizedBox(height: 12.h),
            _buildDescription(),
            SizedBox(height: 16.h),
            _buildSocialLinks(),
            SizedBox(height: 24.h),
            _buildDiscountBanner(),
            SizedBox(height: 24.h),
            _buildContentTabs(),
            SizedBox(height: 16.h),
            _buildTabContent(),
            SizedBox(height: 24.h),
            _buildCreateButton(),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTopTabs() {
    return Container(
      height: 40.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Obx(
        () => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _topTabItem("Edit", 0),
            _topTabItem("Switch", 1),
            _topTabItem("Add New", 2),
          ],
        ),
      ),
    );
  }

  /// "Edit" / "Switch" / "Add New" were a segmented control that changed only
  /// its own highlight colour — none of the three did anything. They now run
  /// the action they name.
  Widget _topTabItem(String label, int index) {
    final bool isSelected = controller.selectedMainTab.value == index;
    return GestureDetector(
      onTap: () {
        controller.changeMainTab(index);
        switch (index) {
          case 0:
            _openEditSheet();
            break;
          case 1:
            controller.goToSwitchBusiness();
            break;
          case 2:
            controller.goToAddBusiness();
            break;
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color:
                isSelected ? const Color(0xFFF97316) : const Color(0xFF6B7280),
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildStoreBanner() {
    return Obx(
      () => Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: controller.pickAndUploadBanner,
            child: Container(
              width: double.infinity,
              height: 200.h,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                image:
                    controller.bannerImage.value.isNotEmpty
                        ? DecorationImage(
                          image: NetworkImage(controller.bannerImage.value),
                          fit: BoxFit.cover,
                        )
                        : null,
              ),
              child: controller.isUploadingBanner.value
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
                  : controller.bannerImage.value.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.store, size: 48.sp, color: Colors.grey.shade400),
                            SizedBox(height: 8.h),
                            Text('Tap to upload banner', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500)),
                          ],
                        )
                      : Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: EdgeInsets.all(8.w),
                            child: Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              child: Icon(Icons.edit, color: Colors.white, size: 16.sp),
                            ),
                          ),
                        ),
            ),
          ),
          Positioned(
            bottom: -40.h,
            left: 20.w,
            child: GestureDetector(
              onTap: controller.pickAndUploadLogo,
              child: Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: controller.isUploadingLogo.value
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981), strokeWidth: 2))
                      : controller.logoImage.value.isNotEmpty
                          ? CustomNetworkImage(
                            imageUrl: controller.logoImage.value,
                            fit: BoxFit.cover,
                          )
                          : Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(Icons.storefront, size: 36.sp, color: Colors.grey.shade400),
                                Positioned(
                                  bottom: 4,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                                    child: const Icon(Icons.add, color: Colors.white, size: 10),
                                  ),
                                ),
                              ],
                            ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(width: 90.w), // Space for logo
          Expanded(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.storeName.value.isNotEmpty
                        ? controller.storeName.value
                        : 'My Store',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      controller.category.value.isNotEmpty
                          ? controller.category.value
                          : 'General',
                      style: TextStyle(
                        color: const Color(0xFF059669),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              _actionButton(
                Icons.location_on_outlined,
                onTap: controller.openStoreLocation,
              ),
              SizedBox(width: 12.w),
              _actionButton(
                Icons.phone_enabled_rounded,
                onTap: controller.callStore,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.w,
        height: 44.w,
        decoration: const BoxDecoration(
          color: Color(0xFFF3F4F6),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF4B5563), size: 20.sp),
      ),
    );
  }

  Widget _buildDescription() {
    return Obx(() {
      final text = controller.description.value;
      if (text.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Text(
          text,
          style: TextStyle(fontSize: 13.sp, color: const Color(0xFF6B7280), height: 1.5),
        ),
      );
    });
  }

  /// These three icons were plain, tapless `Icon` widgets with no data source.
  /// They now show only the channels the merchant actually has on file and
  /// open them.
  Widget _buildSocialLinks() {
    return Obx(() {
      final links = <Widget>[
        if (controller.website.value.trim().isNotEmpty)
          _socialIcon(Icons.language_rounded, controller.openWebsite),
        if (controller.email.value.trim().isNotEmpty)
          _socialIcon(Icons.mail_outline_rounded, controller.openEmail),
        if (controller.facebook.value.trim().isNotEmpty)
          _socialIcon(Icons.facebook_rounded, controller.openFacebook),
        if (controller.instagram.value.trim().isNotEmpty)
          _socialIcon(Icons.camera_alt_outlined, controller.openInstagram),
      ];
      if (links.isEmpty) return const SizedBox.shrink();
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < links.length; i++) ...[
            if (i > 0) SizedBox(width: 24.w),
            links[i],
          ],
        ],
      );
    });
  }

  Widget _socialIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Icon(icon, color: const Color(0xFF111827), size: 22.sp),
      ),
    );
  }

  /// The storefront discount. Tapping it changes it — the figure is the
  /// merchant's own choice, and until now the only screen that showed it
  /// offered no way to set it.
  Widget _buildDiscountBanner() {
    return Obx(() {
      final locked = !controller.discountEditable.value;
      return InkWell(
        onTap: locked ? _explainDiscountLock : _editDiscount,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            children: [
              Text(
                // Reflects the store's real `discountPercentage` instead of
                // promising "exclusive offers" that may not exist.
                controller.discountPercentage.value > 0
                    ? '${controller.discountPercentage.value.toStringAsFixed(0)}% off across the store — customers earn VIPs points on every purchase.'
                    : 'Customers earn VIPs points on every purchase at this store.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    locked ? Icons.lock_clock_outlined : Icons.edit_outlined,
                    size: 13.sp,
                    color: Colors.white70,
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    locked
                        ? 'Changeable in ${controller.discountHoursRemaining}h'
                        : 'Tap to change',
                    style: TextStyle(fontSize: 11.sp, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  void _explainDiscountLock() {
    safeSnackbar(
      'Not yet',
      'You changed your storefront discount recently. You can change it again '
      'in ${controller.discountHoursRemaining} hour(s) — customers see a '
      'settled offer rather than one that moves under them.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _editDiscount() {
    final input = TextEditingController(
      text: controller.discountPercentage.value.toStringAsFixed(0),
    );
    Get.dialog(
      AlertDialog(
        title: const Text('Store discount'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: input,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                suffixText: '%',
                hintText: '0 - 100',
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Once you set this it stays for 24 hours before it can be '
              'changed again.',
              style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          Obx(() => TextButton(
                onPressed: controller.isSavingDiscount.value
                    ? null
                    : () async {
                        final parsed = double.tryParse(input.text.trim());
                        if (parsed == null) return;
                        if (await controller.saveStorefrontDiscount(parsed)) {
                          Get.back<void>();
                        }
                      },
                child: Text(
                  controller.isSavingDiscount.value ? 'Saving…' : 'Confirm',
                ),
              )),
        ],
      ),
    ).then((_) => input.dispose());
  }

  Widget _buildContentTabs() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Obx(
        () => Row(
          children: [
            _contentTabItem("Coupon", 0),
            _contentTabItem("Voucher", 1),
            _contentTabItem("Items", 2),
          ],
        ),
      ),
    );
  }

  Widget _contentTabItem(String label, int index) {
    final bool isSelected = controller.selectedContentTab.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeContentTab(index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color:
                    isSelected
                        ? const Color(0xFFF97316)
                        : const Color(0xFF9CA3AF),
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Renders whichever of the three real lists the selected tab names. Before,
  /// the tabs rendered nothing at all — a merchant could publish coupons,
  /// vouchers and items and never see any of them on their own store page.
  Widget _buildTabContent() {
    return Obx(() {
      if (controller.isLoadingContent.value) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 32.h),
          child: const Center(
            child: CircularProgressIndicator(color: Color(0xFF10B981)),
          ),
        );
      }

      final tab = controller.selectedContentTab.value;
      final rows = switch (tab) {
        1 => controller.vouchers,
        2 => controller.items,
        _ => controller.coupons,
      };

      if (rows.isEmpty) {
        final what = switch (tab) {
          1 => 'vouchers',
          2 => 'items',
          _ => 'coupons',
        };
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
          child: Column(
            children: [
              Icon(Icons.inbox_outlined, size: 40.sp, color: const Color(0xFFD1D5DB)),
              SizedBox(height: 8.h),
              Text(
                'No $what published yet',
                style: TextStyle(fontSize: 13.sp, color: const Color(0xFF9CA3AF)),
              ),
            ],
          ),
        );
      }

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            for (final row in rows)
              tab == 2 ? _itemRow(row) : _couponRow(row),
          ],
        ),
      );
    });
  }

  Widget _couponRow(Map<String, dynamic> row) {
    final code = (row['code'] ?? '').toString();
    final discount = (row['discount'] ?? row['discountPercentage'] ?? 0);
    final isActive = row['isActive'] == true;
    final expiry = _formatDate(row['expiryDate']);
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.confirmation_number_outlined,
                size: 20.sp, color: const Color(0xFF10B981)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2.h),
                Text(
                  expiry.isEmpty ? '$discount% off' : '$discount% off · expires $expiry',
                  style: TextStyle(fontSize: 11.sp, color: const Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          _statusPill(isActive),
        ],
      ),
    );
  }

  Widget _itemRow(Map<String, dynamic> row) {
    final name = (row['name'] ?? '').toString();
    final price = (row['price'] ?? 0);
    final isActive = row['isActive'] == true;
    final image = (row['image'] ?? '').toString();
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: SizedBox(
              width: 44.w,
              height: 44.w,
              child: image.isNotEmpty
                  ? CustomNetworkImage(imageUrl: image, fit: BoxFit.cover)
                  : Container(
                      color: const Color(0xFFF3F4F6),
                      child: Icon(Icons.inventory_2_outlined,
                          size: 20.sp, color: const Color(0xFF9CA3AF)),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2.h),
                Text(
                  'D ${(price as num).toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 11.sp, color: const Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          _statusPill(isActive),
        ],
      ),
    );
  }

  Widget _statusPill(bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFD1FAE5) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          color: isActive ? const Color(0xFF059669) : const Color(0xFF9CA3AF),
        ),
      ),
    );
  }

  String _formatDate(dynamic raw) {
    if (raw == null) return '';
    final parsed = DateTime.tryParse(raw.toString());
    if (parsed == null) return '';
    final d = parsed.toLocal();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Widget _buildCreateButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: GestureDetector(
        onTap: controller.createForSelectedTab,
        child: Container(
          width: double.infinity,
          height: 54.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: const Color(0xFF10B981),
              width: 1.5,
              style:
                  BorderStyle
                      .solid, // Flutter doesn't support dashed borders natively without a library, but I can simulate it or use a custom painter if needed.
            ),
          ),
          child: Stack(
            children: [
              // Simulate dashed border using CustomPaint
              CustomPaint(
                size: Size(double.infinity, 54.h),
                painter: DashedRectPainter(color: const Color(0xFF10B981)),
              ),
              Center(
                child: Obx(
                  () => Text(
                    controller.createButtonLabel,
                    style: TextStyle(
                      color: const Color(0xFF10B981),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The merchant app had no way at all to edit the store's own details —
  /// MerchantProfileController.updateProfile() existed but no screen ever
  /// called it. This sheet is the missing surface for PUT /merchant/profile.
  void _openEditSheet() {
    controller.prepareEditForm();
    Get.bottomSheet(
      isScrollControlled: true,
      // Builder + MediaQuery so the sheet lifts with the keyboard as fields
      // gain focus; a one-off Get.mediaQuery read would be captured at build
      // time and leave the lower fields hidden behind the keyboard.
      Builder(
        builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 28.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'Edit Store Profile',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20.h),
                _editField('Store name', controller.nameCtrl),
                _editField('Category', controller.categoryCtrl),
                _editField(
                  'Phone',
                  controller.phoneCtrl,
                  keyboardType: TextInputType.phone,
                ),
                _editField('Address', controller.addressCtrl),
                _editField('Description', controller.descriptionCtrl, maxLines: 3),
                SizedBox(height: 8.h),
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: controller.isSaving.value
                          ? null
                          : controller.saveStoreProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        disabledBackgroundColor: const Color(0xFF9CA3AF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: controller.isSaving.value
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Save Changes',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _editField(
    String label,
    TextEditingController ctrl, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 6.h),
          TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 12.h,
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Color(0xFF10B981)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  DashedRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 5, dashSpace = 3;
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

    RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(16),
    );

    Path path = Path()..addRRect(rrect);

    Path dashedPath = Path();
    for (var metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        dashedPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
