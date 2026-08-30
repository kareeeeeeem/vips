import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

import '../services/admin_api_service.dart';
import 'admin_toast.dart';

/// Shared behaviour for the four paginated list screens (users, merchants,
/// orders, inventory): debounced search, page state, and a load that keeps
/// the previous rows on screen when a refresh fails instead of blanking the
/// list under an error message.
///
/// Subclasses implement [fetch] and [parse]; everything else is handled here.
abstract class AdminListController extends GetxController {
  final AdminApiService api = AdminApiService();
  final TextEditingController searchController = TextEditingController();

  final RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isMutating = false.obs;
  final RxString errorMessage = ''.obs;

  final RxInt page = 1.obs;
  final RxInt pages = 1.obs;
  final RxInt total = 0.obs;
  final RxString search = ''.obs;

  Timer? _debounce;

  /// Issue the request for the current filter state.
  Future<ApiResponse> fetch();

  /// Hook for a subclass to pull extra fields out of the same response
  /// (order status counts, inventory totals) before [items] is replaced.
  void parse(Map<String, dynamic> data) {}

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load({bool resetPage = false}) async {
    if (resetPage) page.value = 1;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await fetch();
      if (response.success && response.data is Map) {
        final data = Map<String, dynamic>.from(response.data as Map);
        items.value = adminItems(data);
        page.value  = adminInt(data['page'], page.value);
        pages.value = adminInt(data['pages'], 1);
        total.value = adminInt(data['total']);
        parse(data);
      } else {
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Could not load this list.';
      }
    } catch (e) {
      debugPrint('[$runtimeType] load failed: $e');
      errorMessage.value = 'Could not load this list. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Typing fires one request 400ms after the last keystroke rather than one
  /// per character.
  void onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      search.value = value.trim();
      load(resetPage: true);
    });
  }

  void clearSearch() {
    _debounce?.cancel();
    searchController.clear();
    search.value = '';
    load(resetPage: true);
  }

  void nextPage() {
    if (page.value >= pages.value) return;
    page.value++;
    load();
  }

  void previousPage() {
    if (page.value <= 1) return;
    page.value--;
    load();
  }

  /// Runs a write action, then refreshes the list.
  ///
  /// Returns true on success. [isMutating] gates the row's controls so a
  /// double-tap cannot fire the same destructive action twice.
  Future<bool> mutate(
    Future<ApiResponse> Function() action, {
    required String successTitle,
    String? failureTitle,
    bool reload = true,
  }) async {
    if (isMutating.value) return false;
    isMutating.value = true;
    try {
      final response = await action();
      if (response.success) {
        adminToast(successTitle, response.message, isError: false);
        if (reload) await load();
        return true;
      }
      adminToast(
        failureTitle ?? 'Action failed',
        response.message.isNotEmpty ? response.message : 'The server rejected that action.',
        isError: true,
      );
      return false;
    } catch (e) {
      debugPrint('[$runtimeType] mutate failed: $e');
      adminToast(
        failureTitle ?? 'Action failed',
        'Could not reach the server. Please try again.',
        isError: true,
      );
      return false;
    } finally {
      isMutating.value = false;
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
