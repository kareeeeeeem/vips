import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum TransactionType { vipsIn, vipsOut, recovery, reward, credit }

class TransactionItem {
  final TransactionType type;
  final String displayId;
  final String location;
  final String dateStr;
  final String subDetails;
  final String user;
  final double amount;
  final String? transId;
  final String? transTypeDetails;
  final double? walletPointsTotal;
  final double? serviceCharge;
  final String? fullDateStr;
  final String? statusLabel;
  final RxBool isExpanded;

  TransactionItem({
    required this.type,
    required this.displayId,
    required this.location,
    required this.dateStr,
    required this.subDetails,
    required this.user,
    required this.amount,
    this.transId,
    this.transTypeDetails,
    this.walletPointsTotal,
    this.serviceCharge,
    this.fullDateStr,
    this.statusLabel,
    bool isExpanded = false,
  }) : isExpanded = isExpanded.obs;
}

class MerchantWalletController extends GetxController {
  final RxDouble walletPoints = 0.0.obs;
  final RxDouble pendingPoints = 0.0.obs;
  final RxDouble approvedPoints = 0.0.obs;
  final RxDouble suspendedPoints = 0.0.obs;
  final RxDouble dormantPoints = 0.0.obs;

  // New Summary Stats for the "Performance" style view
  final RxDouble totalVipsIn = 0.0.obs;
  final RxDouble totalVipsOut = 0.0.obs;
  final RxDouble totalVipsRecovery = 0.0.obs;

  final RxString selectedTab = 'Activity'.obs;
  final List<String> tabs = ['Activity', 'Vips In', 'Vips Out', 'Recovery'];

  final RxList<TransactionItem> transactions = <TransactionItem>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadWalletData();
  }

  void _loadWalletData() async {
    isLoading.value = true;

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 600));

    walletPoints.value = 112.00;
    pendingPoints.value = 600.00;
    approvedPoints.value = 600.00;
    suspendedPoints.value = 600.00;
    dormantPoints.value = 861.00;

    totalVipsIn.value = 2500.00;
    totalVipsOut.value = 1200.00;
    totalVipsRecovery.value = 450.00;

    transactions.value = [
      TransactionItem(
        type: TransactionType.vipsOut,
        displayId: '1123908',
        location: 'On Store',
        dateStr: '10\nMar',
        subDetails: '4 item(s) D 5,000',
        user: 'Admin | Mr Ali (0023900)',
        amount: -80,
        transId: '0023900',
        transTypeDetails: 'Discount on Purchase',
        walletPointsTotal: 18100,
        serviceCharge: 0,
        fullDateStr: '25 Oct 2025  16:13',
        isExpanded: true,
      ),
      TransactionItem(
        type: TransactionType.vipsIn,
        displayId: '1123908',
        location: 'Online',
        dateStr: '10\nMar',
        subDetails: 'Invoice D 215120',
        user: 'Employee X | VIPs App',
        amount: 2000,
      ),
      TransactionItem(
        type: TransactionType.recovery,
        displayId: '1123908',
        location: 'Online',
        dateStr: '10\nMar',
        subDetails: 'Invoice D 215120',
        user: '',
        amount: -580,
        statusLabel: 'Pending',
      ),
      TransactionItem(
        type: TransactionType.vipsOut,
        displayId: '1123908',
        location: 'On Store',
        dateStr: '10\nMar',
        subDetails: '2 item(s) D 1,000',
        user: 'Admin | Mr Ali',
        amount: -110,
      ),
    ];

    isLoading.value = false;
  }

  void selectTab(String tab) {
    selectedTab.value = tab;
    // Here you would filter transactions based on tab
  }

  void toggleExpand(TransactionItem item) {
    item.isExpanded.value = !item.isExpanded.value;
  }
}
