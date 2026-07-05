import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

// =====================================================
// CONTROLLER
// Fichier: vips_club_history_controller.dart
// =====================================================

class VipsClubHistoryController extends GetxController {
  // Convertible diamonds balance
  final RxInt convertibleDiamants = 90.obs;

  // Transaction history
  final RxList<DiamantTransaction> transactions =
      <DiamantTransaction>[
        DiamantTransaction(
          amount: -5800,
          type: 'debit',
          description: 'diamant to VIPs Wallet',
          date: DateTime(2025, 10, 27, 16, 13),
          orderNumber: null,
        ),
        DiamantTransaction(
          amount: 80,
          type: 'credit',
          description: null,
          date: DateTime(2025, 10, 27, 16, 13),
          orderNumber: '118047',
        ),
        DiamantTransaction(
          amount: 10,
          type: 'credit',
          description: null,
          date: DateTime(2025, 10, 27, 16, 13),
          orderNumber: '118047',
        ),
      ].obs;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      final response = await ApiService().get('/user/transactions');
      if (response.success && response.data != null) {
        final List<dynamic> txList = response.data['transactions'] ?? [];
        transactions.value =
            txList.map((tx) {
              return DiamantTransaction(
                amount: (tx['amount'] as num).toInt(),
                type: tx['type'] ?? 'credit',
                description: tx['description'],
                date:
                    tx['createdAt'] != null
                        ? DateTime.parse(tx['createdAt'])
                        : DateTime.now(),
                orderNumber: tx['reference'],
              );
            }).toList();
      }
    } catch (e) {
      print('Error loading history: $e');
    }
  }

  void onConvertNow() {
    // TODO: Navigate to conversion page or show conversion dialog
    print('Convert Now tapped');
    Get.snackbar(
      'Convert Diamants',
      'Converting ${convertibleDiamants.value} diamants...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day $month $year $hour:$minute';
  }

  @override
  void onClose() {
    super.onClose();
  }
}

// =====================================================
// MODEL
// =====================================================

class DiamantTransaction {
  final int amount;
  final String type; // 'credit' or 'debit'
  final String? description;
  final DateTime date;
  final String? orderNumber;

  DiamantTransaction({
    required this.amount,
    required this.type,
    this.description,
    required this.date,
    this.orderNumber,
  });
}
