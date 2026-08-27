import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FormWidgets {
  static Widget buildTextField(
    String label, {
    String? hint,
    Widget? suffixIcon,
    int maxLines = 1,
    TextEditingController? controller,
    TextInputType? keyboardType,
    Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13.sp, color: const Color(0xFF374151)),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          validator: validator,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint ?? label,
            hintStyle: TextStyle(
              color: const Color(0xFF9CA3AF),
              fontSize: 13.sp,
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  /// A real dropdown. This used to be a decorative `Container` with a chevron
  /// icon and no gesture handler at all — every "Select ..." control in the
  /// coupon and voucher forms looked interactive but could never be changed.
  static Widget buildDropdown(
    String label,
    String value, {
    bool isHalf = false,
    List<String> items = const [],
    ValueChanged<String>? onChanged,
    String? placeholder,
  }) {
    final bool enabled = onChanged != null && items.isNotEmpty;
    final bool isPlaceholder = value.isEmpty;

    Widget field = Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              isPlaceholder ? (placeholder ?? 'Select') : value,
              style: TextStyle(
                fontSize: 13.sp,
                color: isPlaceholder
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF1F2937),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down,
            color: const Color(0xFF6B7280),
            size: 18.sp,
          ),
        ],
      ),
    );

    if (enabled) {
      field = PopupMenuButton<String>(
        tooltip: label,
        padding: EdgeInsets.zero,
        position: PopupMenuPosition.under,
        onSelected: onChanged,
        itemBuilder: (context) => [
          for (final item in items)
            PopupMenuItem<String>(value: item, child: Text(item)),
        ],
        child: field,
      );
    }

    Widget dropdown = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13.sp, color: const Color(0xFF374151)),
        ),
        SizedBox(height: 6.h),
        field,
      ],
    );

    return isHalf ? Expanded(child: dropdown) : dropdown;
  }

  /// A real date picker. Same story as [buildDropdown]: this was a static box
  /// with a calendar icon and no tap handler, so the coupon/voucher validity
  /// dates could never actually be set and were always left to the backend's
  /// 30-day default.
  static Widget buildDatePicker(
    String label, {
    bool isHalf = false,
    DateTime? value,
    ValueChanged<DateTime>? onPicked,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    Widget field = Builder(
      builder: (context) => GestureDetector(
        onTap: onPicked == null
            ? null
            : () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: value ?? now,
                  firstDate: firstDate ?? DateTime(now.year - 1),
                  lastDate: lastDate ?? DateTime(now.year + 5),
                );
                if (picked != null) onPicked(picked);
              },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  value == null ? label : formatDate(value),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: value == null
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF1F2937),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.calendar_today_outlined,
                color: const Color(0xFF10B981),
                size: 18.sp,
              ),
            ],
          ),
        ),
      ),
    );

    Widget picker = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13.sp, color: const Color(0xFF374151)),
        ),
        SizedBox(height: 6.h),
        field,
      ],
    );
    return isHalf ? Expanded(child: picker) : picker;
  }

  static String formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
