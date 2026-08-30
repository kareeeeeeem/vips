import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/admin_toast.dart';
import '../../../services/admin_api_service.dart';

/// Moves units between two stock lines and shows the resulting ledger entries.
///
/// The form only ever offers destinations the backend will accept: real
/// locations derived from live data, plus a free-text one for opening a new
/// warehouse. That keeps it from presenting a choice that then 400s.
class InventoryTransfersController extends GetxController {
  final AdminApiService _api = AdminApiService();

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;

  /// Every stock line, used as the source picker.
  final RxList<Map<String, dynamic>> sources = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> locations = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> recentTransfers = <Map<String, dynamic>>[].obs;

  final Rxn<Map<String, dynamic>> selectedSource = Rxn<Map<String, dynamic>>();
  final RxString selectedLocation = ''.obs;

  final TextEditingController quantityController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController newLocationController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final results = await Future.wait([
        _api.inventory(limit: 100),
        _api.inventoryLocations(),
        _api.inventoryMovements(limit: 20, type: 'transfer_out'),
      ]);

      if (results[0].success && results[0].data is Map) {
        sources.value = adminItems(results[0].data);
      }
      if (results[1].success && results[1].data is Map) {
        locations.value = adminItems(results[1].data);
      }
      if (results[2].success && results[2].data is Map) {
        recentTransfers.value = adminItems(results[2].data);
      }

      if (sources.isEmpty) {
        errorMessage.value = 'There are no stock lines to transfer between yet.';
      }
    } catch (e) {
      debugPrint('[ADMIN TRANSFERS] load failed: $e');
      errorMessage.value = 'Could not load stock lines. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void selectSource(Map<String, dynamic> stock) {
    selectedSource.value = stock;
    // A destination equal to the source location would be rejected server
    // side, so drop the selection instead of carrying an invalid pair.
    if (selectedLocation.value == adminString(stock['location'], 'Main')) {
      selectedLocation.value = '';
    }
  }

  void selectLocation(String location) {
    selectedLocation.value = location;
    if (location.isNotEmpty) newLocationController.clear();
  }

  /// Locations other than the source's own — the only valid destinations.
  List<String> get destinationOptions {
    final sourceLocation = adminString(selectedSource.value?['location'], 'Main');
    return locations
        .map((l) => adminString(l['location']))
        .where((l) => l.isNotEmpty && l != sourceLocation)
        .toList();
  }

  int get availableQuantity => adminInt(selectedSource.value?['currentStock']);

  Future<bool> submit() async {
    if (isSubmitting.value) return false;

    final source = selectedSource.value;
    if (source == null) {
      adminToast('Pick a source', 'Choose the stock line to move units from.', isError: true);
      return false;
    }

    final quantity = int.tryParse(quantityController.text.trim());
    if (quantity == null || quantity <= 0) {
      adminToast('Check the quantity', 'Enter a whole number greater than 0.', isError: true);
      return false;
    }
    // Checked here as well as server-side so the operator is told before the
    // round trip, with the real figure in front of them.
    if (quantity > availableQuantity) {
      adminToast('Not enough stock',
          'Only $availableQuantity unit(s) are on hand at ${adminString(source['location'], 'Main')}.',
          isError: true);
      return false;
    }

    final typed = newLocationController.text.trim();
    final destination = typed.isNotEmpty ? typed : selectedLocation.value;
    if (destination.isEmpty) {
      adminToast('Pick a destination',
          'Choose an existing location or type a new one.', isError: true);
      return false;
    }
    if (destination == adminString(source['location'], 'Main')) {
      adminToast('Same location',
          'The destination must differ from the source location.', isError: true);
      return false;
    }

    isSubmitting.value = true;
    try {
      final response = await _api.transferStock(
        fromStockId: adminString(source['_id']),
        quantity: quantity,
        toLocation: destination,
        reason: reasonController.text.trim(),
      );
      if (response.success) {
        adminToast('Transfer complete', response.message, isError: false);
        quantityController.clear();
        reasonController.clear();
        newLocationController.clear();
        selectedSource.value = null;
        selectedLocation.value = '';
        await load();
        return true;
      }
      adminToast('Transfer failed', response.message, isError: true);
      return false;
    } catch (e) {
      debugPrint('[ADMIN TRANSFERS] submit failed: $e');
      adminToast('Transfer failed',
          'Could not reach the server. Please try again.', isError: true);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    quantityController.dispose();
    reasonController.dispose();
    newLocationController.dispose();
    super.onClose();
  }
}
