import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/bulk_import_controller.dart';

/// Upload a spreadsheet of products instead of typing them in one at a time.
class BulkImportView extends GetView<BulkImportController> {
  const BulkImportView({super.key});

  static const Color _primary = Color(0xFF1B7A43);
  static const Color _muted = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Import products',
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 28.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTemplateCard(),
            SizedBox(height: 12.h),
            _buildFileCard(),
            Obx(() => controller.preview.value == null
                ? const SizedBox.shrink()
                : _buildReport(controller.preview.value!, isPreview: true)),
            Obx(() => controller.result.value == null
                ? const SizedBox.shrink()
                : _buildReport(controller.result.value!, isPreview: false)),
            SizedBox(height: 12.h),
            _buildHistory(),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _border),
        ),
        child: child,
      );

  // ── Template ──────────────────────────────────────────────

  Widget _buildTemplateCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('1. Start from the template',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800)),
          SizedBox(height: 6.h),
          Text(
            'It has the exact column names, with two example rows. Only '
            'name, category and price are required — leave the rest blank if '
            'you do not use them.',
            style: TextStyle(fontSize: 11.5.sp, height: 1.45, color: _muted),
          ),
          SizedBox(height: 12.h),
          Obx(() => OutlinedButton.icon(
                onPressed: controller.isDownloading.value ? null : _showTemplate,
                icon: Icon(Icons.description_outlined, size: 17.sp),
                label: Text(
                  controller.isDownloading.value ? 'Fetching…' : 'Show the template',
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primary,
                  side: const BorderSide(color: _primary),
                  padding: EdgeInsets.symmetric(vertical: 11.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11.r)),
                ),
              )),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 15.sp, color: const Color(0xFF2563EB)),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    // Said up front, because a merchant will reach for .xlsx
                    // first and a rejected upload is a worse way to learn it.
                    'Working in Excel? Choose File → Save As → CSV UTF-8. '
                    'Excel files are not read directly.',
                    style: TextStyle(fontSize: 11.sp, height: 1.4, color: _muted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showTemplate() async {
    final csv = await controller.downloadTemplate();
    if (csv == null) return;
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.all(18.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('vips-product-import-template.csv',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800)),
            SizedBox(height: 6.h),
            Text(
              'Copy this into a spreadsheet, replace the example rows with '
              'your products, and save as CSV.',
              style: TextStyle(fontSize: 11.5.sp, height: 1.4, color: _muted),
            ),
            SizedBox(height: 12.h),
            Flexible(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(11.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: _border),
                  ),
                  child: SelectableText(
                    csv,
                    style: TextStyle(
                        fontSize: 10.5.sp, height: 1.6, fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ── File ──────────────────────────────────────────────────

  Widget _buildFileCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('2. Choose your file',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800)),
          SizedBox(height: 12.h),
          Obx(() => InkWell(
                onTap: controller.pickFile,
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 14.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: controller.hasFile ? _primary : _border,
                      width: controller.hasFile ? 1.4 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        controller.hasFile
                            ? Icons.description_rounded
                            : Icons.upload_file_outlined,
                        size: 30.sp,
                        color: controller.hasFile ? _primary : _muted,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        controller.hasFile
                            ? controller.fileName.value
                            : 'Tap to choose a CSV file',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w600,
                          color: controller.hasFile ? _primary : _muted,
                        ),
                      ),
                      if (controller.hasFile) ...[
                        SizedBox(height: 3.h),
                        Text(
                          '${(controller.fileSize.value / 1024).toStringAsFixed(1)} KB',
                          style: TextStyle(fontSize: 10.5.sp, color: _muted),
                        ),
                      ],
                    ],
                  ),
                ),
              )),
          SizedBox(height: 12.h),
          Obx(() {
            if (!controller.hasFile) return const SizedBox.shrink();
            return Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        controller.isChecking.value ? null : controller.check,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11.r)),
                    ),
                    child: Text(
                      controller.isChecking.value ? 'Checking…' : 'Check the file',
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ElevatedButton(
                    // Only after a check. A bulk write of hundreds of products
                    // has no undo, so the merchant sees what will happen first.
                    onPressed: controller.canImport ? controller.import : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      disabledBackgroundColor: _border,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11.r)),
                    ),
                    child: Text(
                      controller.isImporting.value ? 'Importing…' : 'Import',
                      style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          }),
          Obx(() {
            if (!controller.hasFile || controller.preview.value != null) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                'Check the file first — nothing is saved until you press Import.',
                style: TextStyle(fontSize: 10.5.sp, color: _muted),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Report ────────────────────────────────────────────────

  Widget _buildReport(Map<String, dynamic> report, {required bool isPreview}) {
    int n(String key) {
      final value = report[key];
      return value is num ? value.toInt() : 0;
    }

    final issues = controller.issuesOf(report);
    final total = n('totalIssues');

    return Padding(
      padding: EdgeInsets.only(top: 12.h),
      child: _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isPreview ? Icons.fact_check_outlined : Icons.check_circle_outline,
                  size: 18.sp,
                  color: isPreview ? const Color(0xFF2563EB) : _primary,
                ),
                SizedBox(width: 8.w),
                Text(
                  isPreview ? 'What this file would do' : 'Imported',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                _stat(isPreview ? 'Would add' : 'Added',
                    '${isPreview ? n('wouldCreate') : n('created')}', _primary),
                SizedBox(width: 8.w),
                _stat('Already there', '${n('skipped')}', const Color(0xFFD97706)),
                SizedBox(width: 8.w),
                _stat('Rejected', '${n('failed')}', const Color(0xFFDC2626)),
              ],
            ),
            if (isPreview && n('wouldCreate') == 0) ...[
              SizedBox(height: 10.h),
              Text(
                'Nothing in this file can be imported. Fix the rows below and '
                'choose the file again.',
                style: TextStyle(
                    fontSize: 11.5.sp, height: 1.4, color: const Color(0xFFDC2626)),
              ),
            ],
            if (issues.isNotEmpty) ...[
              SizedBox(height: 14.h),
              Text(
                total > issues.length
                    ? 'First ${issues.length} of $total problems'
                    : 'Problems',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 6.h),
              // Every problem carries the line number in the file the merchant
              // is looking at, so "row 7" means the seventh line they can see.
              for (final issue in issues.take(25)) _issueRow(issue),
            ],
          ],
        ),
      ),
    );
  }

  Widget _issueRow(Map<String, dynamic> issue) {
    final line = issue['line'];
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(5.r),
            ),
            child: Text('Line $line',
                style: TextStyle(
                    fontSize: 9.5.sp,
                    fontWeight: FontWeight.w700,
                    color: _muted)),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              '${issue['message'] ?? ''}',
              style: TextStyle(fontSize: 11.sp, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 11.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 17.sp, fontWeight: FontWeight.w800, color: color)),
            SizedBox(height: 2.h),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10.sp, color: color)),
          ],
        ),
      ),
    );
  }

  // ── History ───────────────────────────────────────────────

  Widget _buildHistory() {
    return Obx(() {
      if (controller.history.isEmpty) return const SizedBox.shrink();
      return _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Past imports',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800)),
            SizedBox(height: 4.h),
            Text(
              'Checks are listed too, so you can see a file was looked at '
              'before it was imported.',
              style: TextStyle(fontSize: 10.5.sp, height: 1.35, color: _muted),
            ),
            SizedBox(height: 10.h),
            for (final entry in controller.history) _historyRow(entry),
          ],
        ),
      );
    });
  }

  Widget _historyRow(Map<String, dynamic> entry) {
    final dryRun = entry['dryRun'] == true;
    int n(String key) {
      final value = entry[key];
      return value is num ? value.toInt() : 0;
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7.h),
      child: Row(
        children: [
          Icon(
            dryRun ? Icons.visibility_outlined : Icons.download_done_rounded,
            size: 16.sp,
            color: dryRun ? _muted : _primary,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry['fileName'] ?? 'Untitled'}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 2.h),
                Text(
                  dryRun
                      ? 'Checked · ${n('rowsRead')} rows'
                      : 'Added ${n('created')} · skipped ${n('skipped')} · '
                          'rejected ${n('failed')}',
                  style: TextStyle(fontSize: 10.5.sp, color: _muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
