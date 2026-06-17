import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class TagsInput extends StatelessWidget {
  final RxList<String> tags;
  final TextEditingController controller;
  final Function(String) onAdd;
  final Function(String) onRemove;

  const TagsInput({
    Key? key,
    required this.tags,
    required this.controller,
    required this.onAdd,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tag',
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500, color: const Color(0xFF374151)),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Add a tag',
                  hintStyle: TextStyle(color: const Color(0xFF9CA3AF), fontSize: 13.sp),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
                onFieldSubmitted: (val) {
                  onAdd(val);
                },
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () => onAdd(controller.text),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13.sp)),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Obx(() => Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: tags.map((tag) => _buildTagChip(tag)).toList(),
        )),
      ],
    );
  }

  Widget _buildTagChip(String tag) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.5)),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(tag, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF10B981), fontWeight: FontWeight.w600)),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: () => onRemove(tag),
            child: Icon(Icons.close, size: 14.sp, color: const Color(0xFF10B981)),
          ),
        ],
      ),
    );
  }
}
