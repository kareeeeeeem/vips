import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

/// Controller for Report Screen using GetX
class ReportController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // Observable variables
  final _tabIndex = 0.obs;
  final _isLoading = false.obs;
  final _selectedDateRange = Rxn<DateTimeRange>();
  final _allReports = <Report>[].obs;
  final _couponReports = <Report>[].obs;
  final _packageReports = <Report>[].obs;

  // Getters
  int get tabIndex => _tabIndex.value;
  bool get isLoading => _isLoading.value;
  DateTimeRange? get selectedDateRange => _selectedDateRange.value;
  List<Report> get allReports => _allReports;
  List<Report> get couponReports => _couponReports;
  List<Report> get packageReports => _packageReports;

  // Get current tab reports
  List<Report> get currentReports {
    switch (_tabIndex.value) {
      case 0:
        return _allReports;
      case 1:
        return _couponReports;
      case 2:
        return _packageReports;
      default:
        return [];
    }
  }

  // Tab controller
  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(_onTabChanged);
    loadReports();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  /// Handle tab changes
  void _onTabChanged() {
    _tabIndex.value = tabController.index;
  }

  /// Change tab programmatically
  void changeTab(int index) {
    tabController.animateTo(index);
  }

  /// Load all reports
  Future<void> loadReports({DateTime? startDate, DateTime? endDate}) async {
    try {
      _isLoading.value = true;

      String url = '/user/reports';
      if (startDate != null && endDate != null) {
        url += '?startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}';
      }

      final response = await ApiService().get(url);
      
      if (response.success && response.data != null) {
        final data = response.data;

        // Handle array response (current backend returns array of all reports)
        if (data is List) {
          final allReportsList = data
              .whereType<Map>()
              .map((e) => Report.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          // "All" means every report, not just the ones that aren't
          // coupon/package — a user with only coupon/package activity was
          // previously seeing an empty All tab despite having real reports.
          _allReports.value = allReportsList;
          _couponReports.value = allReportsList.where((r) => r.type == ReportType.coupon).toList();
          _packageReports.value = allReportsList.where((r) => r.type == ReportType.package).toList();
        } else if (data is Map) {
          final all = data['all'];
          if (all is List) {
            _allReports.value = all
                .whereType<Map>()
                .map((e) => Report.fromJson(Map<String, dynamic>.from(e)))
                .toList();
          }
          final coupon = data['coupon'];
          if (coupon is List) {
            _couponReports.value = coupon
                .whereType<Map>()
                .map((e) => Report.fromJson(Map<String, dynamic>.from(e)))
                .toList();
          }
          final package = data['package'];
          if (package is List) {
            _packageReports.value = package
                .whereType<Map>()
                .map((e) => Report.fromJson(Map<String, dynamic>.from(e)))
                .toList();
          }
        }
      }
    } catch (e) {
      debugPrint('Load reports error: $e');
      safeSnackbar(
        'Error',
        'Could not load reports. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Filter reports by date range
  Future<void> filterByDateRange(DateTimeRange? dateRange) async {
    _selectedDateRange.value = dateRange;

    if (dateRange == null) {
      // Reset filters
      await loadReports();
      return;
    }

    try {
      _isLoading.value = true;

      // Call API with date filter
      await loadReports(startDate: dateRange.start, endDate: dateRange.end);

      safeSnackbar(
        'Filter Applied',
        'Showing reports from ${_formatDate(dateRange.start)} to ${_formatDate(dateRange.end)}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('Filter reports error: $e');
      safeSnackbar(
        'Error',
        'Could not filter reports. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Show date picker
  Future<void> showDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1);
    final lastDate = DateTime(now.year, now.month, now.day);

    final picked = await Get.dialog<DateTimeRange>(
      DateRangePickerDialog(
        firstDate: firstDate,
        lastDate: lastDate,
        initialDateRange: _selectedDateRange.value,
      ),
    );

    if (picked != null) {
      await filterByDateRange(picked);
    }
  }

  /// Clear date filter
  Future<void> clearDateFilter() async {
    _selectedDateRange.value = null;
    await loadReports();

    safeSnackbar(
      'Filter Cleared',
      'Showing all reports',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Export current reports via OS share sheet
  Future<void> exportReports() async {
    final reports = currentReports;
    if (reports.isEmpty) {
      safeSnackbar('No Data', 'No reports to export', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final buffer = StringBuffer();
    buffer.writeln('VIPs Report Export');
    buffer.writeln('Generated: ${_formatDate(DateTime.now())}');
    buffer.writeln('─' * 40);
    for (final r in reports) {
      buffer.writeln('${r.title}  |  ${_formatDate(r.date)}');
      buffer.writeln('Amount: D ${r.amount.toStringAsFixed(3)}  |  Status: ${r.status.name}');
      if (r.description.isNotEmpty) buffer.writeln(r.description);
      buffer.writeln('─' * 40);
    }
    buffer.writeln('Total: D ${totalAmount.toStringAsFixed(3)}  (${reports.length} records)');
    await SharePlus.instance.share(ShareParams(
      text: buffer.toString(),
      subject: 'VIPs Report — ${_formatDate(DateTime.now())}',
    ));
  }

  /// View report details in a dialog
  void viewReportDetails(Report report) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(report.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Date', _formatDate(report.date)),
            _detailRow('Amount', 'D ${report.amount.toStringAsFixed(3)}'),
            _detailRow('Status', report.status.name.toUpperCase()),
            if (report.itemCount != null) _detailRow('Items', '${report.itemCount}'),
            if (report.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(report.description, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
          TextButton(
            onPressed: () {
              Get.back();
              SharePlus.instance.share(ShareParams(
                text: '${report.title}\nD ${report.amount.toStringAsFixed(3)} — ${_formatDate(report.date)}\n${report.description}',
                subject: report.title,
              ));
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  /// Get total amount for current tab
  double get totalAmount {
    return currentReports.fold(0.0, (sum, report) => sum + report.amount);
  }

  /// Get report count for current tab
  int get reportCount => currentReports.length;

  /// Format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Report model
class Report {
  final String id;
  final String title;
  final ReportType type;
  final DateTime date;
  final double amount;
  final ReportStatus status;
  final String description;
  final int? itemCount;

  Report({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
    required this.amount,
    required this.status,
    required this.description,
    this.itemCount,
  });

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String get formattedAmount {
    return 'D ${amount.toStringAsFixed(3)}';
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    ReportType typeEnum = ReportType.all;
    if (json['type'] == 'coupon') typeEnum = ReportType.coupon;
    if (json['type'] == 'package') typeEnum = ReportType.package;

    // Real Transaction.status enum is pending/completed/failed/cancelled —
    // 'cancelled' fell through to the 'pending' default, misleadingly
    // implying a cancelled transaction was still processing.
    ReportStatus statusEnum = ReportStatus.pending;
    if (json['status'] == 'completed') statusEnum = ReportStatus.completed;
    if (json['status'] == 'failed' || json['status'] == 'cancelled') {
      statusEnum = ReportStatus.failed;
    }

    final amount = json['amount'];
    final itemCount = json['itemCount'];

    return Report(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      type: typeEnum,
      date: json['date'] != null
          ? (DateTime.tryParse(json['date'].toString()) ?? DateTime.now())
          : DateTime.now(),
      amount: amount is num ? amount.toDouble() : 0.0,
      status: statusEnum,
      description: (json['description'] ?? '').toString(),
      itemCount: itemCount is num ? itemCount.toInt() : null,
    );
  }
}

/// Report type enum
enum ReportType { all, coupon, package }

extension ReportTypeExtension on ReportType {
  String get displayName {
    switch (this) {
      case ReportType.all:
        return 'All Reports';
      case ReportType.coupon:
        return 'Coupon Report';
      case ReportType.package:
        return 'Package Report';
    }
  }

  IconData get icon {
    switch (this) {
      case ReportType.all:
        return Icons.description_outlined;
      case ReportType.coupon:
        return Icons.local_offer_outlined;
      case ReportType.package:
        return Icons.card_giftcard_outlined;
    }
  }
}

/// Report status enum
enum ReportStatus { completed, pending, failed }

extension ReportStatusExtension on ReportStatus {
  String get displayName {
    switch (this) {
      case ReportStatus.completed:
        return 'Completed';
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.failed:
        return 'Failed';
    }
  }

  Color get color {
    switch (this) {
      case ReportStatus.completed:
        return const Color(0xff4CAF50);
      case ReportStatus.pending:
        return const Color(0xffFF9800);
      case ReportStatus.failed:
        return const Color(0xffF44336);
    }
  }
}
