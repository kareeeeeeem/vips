import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

/// Uploading a spreadsheet of products instead of typing them in one at a
/// time.
///
/// The file is always checked before it is imported. A bulk write that
/// creates three hundred products has no undo, so the merchant sees exactly
/// what would happen — how many rows are good, which lines are wrong and
/// why — and then decides.
class BulkImportController extends GetxController {
  final ApiService _api = ApiService();

  static const String _base = '/merchant/products/import';

  final RxString fileName = ''.obs;
  final RxInt fileSize = 0.obs;
  Uint8List? _bytes;

  final RxBool isChecking = false.obs;
  final RxBool isImporting = false.obs;
  final RxBool isDownloading = false.obs;

  /// The result of the last check. Null until a file has been checked, which
  /// is what gates the import button.
  final Rxn<Map<String, dynamic>> preview = Rxn<Map<String, dynamic>>();

  /// The result of the last real import.
  final Rxn<Map<String, dynamic>> result = Rxn<Map<String, dynamic>>();

  final RxList<Map<String, dynamic>> history = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingHistory = false.obs;

  bool get hasFile => _bytes != null && fileName.value.isNotEmpty;

  /// Only after a check that found at least one importable row.
  bool get canImport =>
      hasFile &&
      preview.value != null &&
      _int(preview.value!, 'wouldCreate') > 0 &&
      !isImporting.value;

  int _int(Map<String, dynamic> map, String key) {
    final value = map[key];
    return value is num ? value.toInt() : 0;
  }

  List<Map<String, dynamic>> issuesOf(Map<String, dynamic>? report) {
    final raw = report?['issues'];
    if (raw is! List) return const [];
    return raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  Future<void> pickFile() async {
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['csv'],
        // The bytes rather than a path: on the web there is no file path at
        // all, and reading bytes works the same way on every platform.
        withData: true,
      );
      if (picked == null || picked.files.isEmpty) return;

      final file = picked.files.single;
      if (file.bytes == null) {
        safeSnackbar('Could not read that file',
            'Try choosing it again, or export a fresh CSV.');
        return;
      }

      _bytes = file.bytes;
      fileName.value = file.name;
      fileSize.value = file.size;
      // A new file invalidates whatever the last one said.
      preview.value = null;
      result.value = null;
    } catch (e) {
      debugPrint('[BULK IMPORT] pick failed: $e');
      safeSnackbar('Could not open the file picker', 'Please try again.');
    }
  }

  void clearFile() {
    _bytes = null;
    fileName.value = '';
    fileSize.value = 0;
    preview.value = null;
    result.value = null;
  }

  /// Checks the file without writing anything.
  Future<void> check() async {
    if (!hasFile || isChecking.value) return;
    isChecking.value = true;
    result.value = null;
    try {
      final response = await _api.postFile(
        '$_base/csv',
        bytes: _bytes!,
        filename: fileName.value,
        contentType: 'text/csv',
        queryParams: {'dryRun': 'true'},
      );
      if (response.success && response.data is Map) {
        preview.value = Map<String, dynamic>.from(response.data as Map);
      } else {
        preview.value = null;
        safeSnackbar('Could not read that file', response.message);
      }
    } catch (e) {
      debugPrint('[BULK IMPORT] check failed: $e');
      safeSnackbar('Could not read that file', 'Please try again.');
    } finally {
      isChecking.value = false;
    }
  }

  /// Writes the products. Only reachable after a check.
  Future<void> import() async {
    if (!canImport) return;
    isImporting.value = true;
    try {
      final response = await _api.postFile(
        '$_base/csv',
        bytes: _bytes!,
        filename: fileName.value,
        contentType: 'text/csv',
      );
      if (response.success && response.data is Map) {
        result.value = Map<String, dynamic>.from(response.data as Map);
        preview.value = null;
        safeSnackbar('Import finished', response.message);
        await loadHistory();
      } else {
        safeSnackbar('Import failed', response.message);
      }
    } catch (e) {
      debugPrint('[BULK IMPORT] import failed: $e');
      safeSnackbar('Import failed', 'Could not reach the server.');
    } finally {
      isImporting.value = false;
    }
  }

  /// The template, returned as text for the merchant to save or copy.
  ///
  /// Handed over rather than written to disk: a browser download needs a user
  /// gesture this side cannot fake, and a button that silently saves nothing
  /// is worse than one that shows the file.
  Future<String?> downloadTemplate() async {
    if (isDownloading.value) return null;
    isDownloading.value = true;
    try {
      final bytes = await _api.getBytes('$_base/template');
      if (bytes == null) {
        safeSnackbar('Could not fetch the template', 'Please try again.');
        return null;
      }
      final text = String.fromCharCodes(bytes);
      // The byte-order mark makes Excel read Arabic correctly, but it would
      // show as a stray character in a text box.
      return text.startsWith('﻿') ? text.substring(1) : text;
    } catch (e) {
      debugPrint('[BULK IMPORT] template failed: $e');
      safeSnackbar('Could not fetch the template', 'Please try again.');
      return null;
    } finally {
      isDownloading.value = false;
    }
  }

  Future<void> loadHistory() async {
    isLoadingHistory.value = true;
    try {
      final response = await _api.get('$_base/history', queryParams: {'limit': 10});
      if (response.success && response.data is Map) {
        final raw = (response.data as Map)['items'];
        if (raw is List) {
          history.value =
              raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
    } catch (e) {
      debugPrint('[BULK IMPORT] history failed: $e');
    } finally {
      isLoadingHistory.value = false;
    }
  }
}
