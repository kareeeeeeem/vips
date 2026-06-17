import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  Future<void> loadReports() async {
    try {
      _isLoading.value = true;

      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      final now = DateTime.now();
      _allReports.value = [
        Report(
          id: '1',
          title: 'Monthly Sales Report',
          type: ReportType.all,
          date: now.subtract(const Duration(days: 1)),
          amount: 15420.50,
          status: ReportStatus.completed,
          description: 'Complete sales overview for last month',
        ),
        Report(
          id: '2',
          title: 'Quarterly Revenue',
          type: ReportType.all,
          date: now.subtract(const Duration(days: 3)),
          amount: 48920.00,
          status: ReportStatus.completed,
          description: 'Q1 revenue summary and analysis',
        ),
        Report(
          id: '3',
          title: 'Annual Summary',
          type: ReportType.all,
          date: now.subtract(const Duration(days: 7)),
          amount: 125000.00,
          status: ReportStatus.pending,
          description: 'Year-end financial summary',
        ),
      ];

      _couponReports.value = [
        Report(
          id: '4',
          title: 'Summer Discount Coupons',
          type: ReportType.coupon,
          date: now.subtract(const Duration(days: 2)),
          amount: 3240.00,
          status: ReportStatus.completed,
          description: 'Total revenue from summer coupons',
          itemCount: 124,
        ),
        Report(
          id: '5',
          title: 'Welcome Bonus Usage',
          type: ReportType.coupon,
          date: now.subtract(const Duration(days: 5)),
          amount: 1890.50,
          status: ReportStatus.completed,
          description: 'New user welcome coupon statistics',
          itemCount: 89,
        ),
      ];

      _packageReports.value = [
        Report(
          id: '6',
          title: 'Premium Package Sales',
          type: ReportType.package,
          date: now.subtract(const Duration(days: 1)),
          amount: 8450.00,
          status: ReportStatus.completed,
          description: 'Premium tier package purchases',
          itemCount: 45,
        ),
        Report(
          id: '7',
          title: 'Basic Package Revenue',
          type: ReportType.package,
          date: now.subtract(const Duration(days: 4)),
          amount: 4200.00,
          status: ReportStatus.completed,
          description: 'Entry level package sales',
          itemCount: 78,
        ),
      ];
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load reports: $e',
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

      // TODO: Call API with date filter
      await Future.delayed(const Duration(milliseconds: 500));

      // Filter existing data (in real app, this would be an API call)
      _allReports.value =
          _allReports.where((report) {
            return report.date.isAfter(dateRange.start) &&
                report.date.isBefore(
                  dateRange.end.add(const Duration(days: 1)),
                );
          }).toList();

      _couponReports.value =
          _couponReports.where((report) {
            return report.date.isAfter(dateRange.start) &&
                report.date.isBefore(
                  dateRange.end.add(const Duration(days: 1)),
                );
          }).toList();

      _packageReports.value =
          _packageReports.where((report) {
            return report.date.isAfter(dateRange.start) &&
                report.date.isBefore(
                  dateRange.end.add(const Duration(days: 1)),
                );
          }).toList();

      Get.snackbar(
        'Filter Applied',
        'Showing reports from ${_formatDate(dateRange.start)} to ${_formatDate(dateRange.end)}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to filter reports: $e',
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

    Get.snackbar(
      'Filter Cleared',
      'Showing all reports',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Export current reports
  Future<void> exportReports() async {
    try {
      _isLoading.value = true;

      // TODO: Implement actual export logic
      await Future.delayed(const Duration(seconds: 1));

      final reports = currentReports;
      if (reports.isEmpty) {
        Get.snackbar(
          'No Data',
          'No reports to export',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      Get.snackbar(
        'Export Success',
        'Exported ${reports.length} reports',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to export: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// View report details
  void viewReportDetails(Report report) {
    Get.snackbar(
      report.title,
      report.description,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
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
    return '\$${amount.toStringAsFixed(2)}';
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
