import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../design_system/atoms/app_colors.dart';
import '../controllers/mobile_controller.dart';

class MobilesView extends GetView<MobilesController> {
  const MobilesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(MobilesController());
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 55.h,
                bottom: 20.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: 20.h),

                  // OPERATORS SECTION (FIRST)
                  _buildOperatorsSection(),

                  SizedBox(height: 24.h),

                  // CREDIT OPTIONS SECTION (SECOND)
                  _buildCreditOptionsSection(),

                  SizedBox(height: 24.h),
                  _buildSelectedCard(),
                  SizedBox(height: 20.h),
                  _buildExpandableSection(
                    'How it works',
                    'Welcome to resort paradise we ensure the best service during your stay in bali with an emphasis on customer comfort. Enjoy Balinese specialities, dance and music every Saturday for free at competitive prices.',
                  ),
                  SizedBox(height: 16.h),
                  _buildExpandableSection(
                    'Required conditions',
                    'Welcome to resort paradise we ensure the best service during your stay in bali with an emphasis on customer comfort. Enjoy Balinese specialities, dance and music every Saturday for free at competitive prices.',
                  ),
                  SizedBox(height: 100.h), // Space for fixed buttons
                ],
              ),
            ),
          ),

          // Fixed buttons at bottom
          _buildFixedButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Get.back(),
            padding: EdgeInsets.all(8.w),
            constraints: BoxConstraints(),
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          'Mobile Card',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // OPERATORS SECTION - Liste horizontale des opérateurs
  Widget _buildOperatorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Operator',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade400,
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 100.h,
          child: Obx(() {
            final selectedOperatorIndex =
                controller.selectedOperatorIndex.value;

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              itemCount: controller.operators.length,
              itemBuilder: (context, index) {
                final isSelected = selectedOperatorIndex == index;
                final operator = controller.operators[index];

                return Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: GestureDetector(
                    onTap: () => controller.selectOperator(index),
                    child: Container(
                      width: 110.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color:
                              isSelected
                                  ? AppColors.AppPrimaryColor
                                  : Colors.grey.shade200,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Operator logo
                          Container(
                            width: 50.w,
                            height: 50.h,
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? AppColors.AppPrimaryColor.withOpacity(
                                        0.1,
                                      )
                                      : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Center(
                              child: Image.network(operator['logoUrl']),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          // Operator name
                          Text(
                            operator['name'],
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color:
                                  isSelected
                                      ? AppColors.AppPrimaryColor
                                      : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  // CREDIT OPTIONS SECTION - Liste horizontale des options de crédit
  Widget _buildCreditOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Credit Amount',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade400,
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 70.w,
          child: Obx(() {
            final selectedIndex = controller.selectedCreditOption.value;

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              itemCount: controller.creditOptions.length,
              itemBuilder: (context, index) {
                final isSelected = selectedIndex == index;
                final option = controller.creditOptions[index];

                return Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: GestureDetector(
                    onTap: () => controller.selectCreditOption(index),
                    child: Container(
                      width: 110.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color:
                              isSelected
                                  ? AppColors.AppPrimaryColor
                                  : Colors.grey.shade200,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? AppColors.AppPrimaryColor
                                      : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              option['label'],
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSelectedCard() {
    return Obx(() {
      final selectedOperatorIndex = controller.selectedOperatorIndex.value;
      final selectedCreditIndex = controller.selectedCreditOption.value;

      if (selectedOperatorIndex == null) {
        return SizedBox();
      }

      final operator = controller.operators[selectedOperatorIndex];
      final option = controller.creditOptions[selectedCreditIndex];

      return Stack(
        children: [
          Container(
            margin: EdgeInsets.only(top: 30.h),
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(height: 40.h), // Space for logo
                // Operator name
                Text(
                  operator['name'],
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),

                SizedBox(height: 8.h),

                // Credit badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        operator['color'] ?? AppColors.AppPrimaryColor,
                        (operator['color'] ?? AppColors.AppPrimaryColor)
                            .withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    option['label'],
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // Dashed divider
                CustomPaint(
                  size: Size(double.infinity, 1),
                  painter: DashedLinePainter(),
                ),

                SizedBox(height: 24.h),

                // Quantity
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Quantity',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    _buildQuantitySelector(selectedCreditIndex),
                  ],
                ),
              ],
            ),
          ),

          // Logo flottant en haut
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 70.w,
                height: 70.h,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: operator['color'] ?? AppColors.AppPrimaryColor,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Image.network(operator['logoUrl']),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector(int optionIndex) {
    return GetBuilder<MobilesController>(
      builder: (controller) {
        final quantity = controller.creditOptions[optionIndex]['quantity'];
        final textController = TextEditingController(text: '$quantity');

        textController.selection = TextSelection.fromPosition(
          TextPosition(offset: textController.text.length),
        );

        return Row(
          children: [
            // Minus button
            GestureDetector(
              onTap: () => controller.decrementQuantity(optionIndex),
              child: Container(
                width: 32.w,
                height: 32.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.remove, color: Colors.black87, size: 18.sp),
              ),
            ),

            // TextField for quantity
            Container(
              width: 80.w,
              height: 40.h,
              margin: EdgeInsets.symmetric(horizontal: 12.w),
              child: TextField(
                controller: textController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(
                      color: AppColors.AppPrimaryColor,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (value) {
                  final int? newQuantity = int.tryParse(value);
                  if (newQuantity != null && newQuantity > 0) {
                    controller.updateQuantity(optionIndex, newQuantity);
                  }
                },
              ),
            ),

            // Plus button
            GestureDetector(
              onTap: () => controller.incrementQuantity(optionIndex),
              child: Container(
                width: 32.w,
                height: 32.h,
                decoration: BoxDecoration(
                  color: AppColors.AppPrimaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.AppPrimaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(Icons.add, color: Colors.white, size: 18.sp),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExpandableSection(String title, String content) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          collapsedIconColor: Colors.grey.shade400,
          iconColor: Colors.grey.shade600,
          title: Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          children: [
            Text(
              content,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedButtons() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Proceed button
            // Cancel button
            SizedBox(
              height: 56.h,
              width: 120.w,
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: AppColors.AppPrimaryColor,
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.AppPrimaryColor,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: SizedBox(
                height: 56.h,
                child: ElevatedButton(
                  onPressed: controller.proceed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.AppPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Proceed',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey.shade300
          ..strokeWidth = 1.5;

    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
