import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class BusinessRegistrationController extends GetxController {
  final _api = ApiService();

  // Text Controllers for form fields
  final fullNameLatinCtrl  = TextEditingController();
  final fullNameArabicCtrl = TextEditingController();
  final emailCtrl          = TextEditingController();
  final phoneCtrl          = TextEditingController();
  final storeNameLatinCtrl  = TextEditingController();
  final storeNameArabicCtrl = TextEditingController();
  final addressCtrl        = TextEditingController();
  final apartmentCtrl      = TextEditingController();
  final locationNameCtrl   = TextEditingController();
  final descriptionCtrl    = TextEditingController();
  final tinCtrl            = TextEditingController();
  final facebookCtrl       = TextEditingController();
  final instagramCtrl      = TextEditingController();
  final websiteCtrl        = TextEditingController();

  // Dropdown selections
  final jobTitle    = 'Choose'.obs;
  final businessType = 'Choose'.obs;
  final category    = 'Choose'.obs;
  final countryCode = '+216'.obs; // Tunisia — the app's only market

  // Loading state
  final isLoading = false.obs;

  // Section expand/collapse state
  final isAdditionalInfoExpanded = true.obs;
  final isTimeInfoExpanded        = true.obs;
  final isLocationExpanded        = true.obs;
  final isSocialMediaExpanded     = true.obs;
  final isIdentityExpanded        = true.obs;

  // Business hours.
  //
  // A day holds a list of shifts, not one span: plenty of shops here close
  // over the middle of the day and open again in the afternoon, and a single
  // open/close could only describe that as one long stretch they are not
  // actually open for. `open`/`close` are kept alongside as the first shift
  // so anything still reading them keeps working.
  final schedule = <String, Map<String, dynamic>>{
    'Sunday':    {'enabled': true,  'shifts': [{'open': '09:00', 'close': '23:00'}]},
    'Monday':    {'enabled': true,  'shifts': [{'open': '09:00', 'close': '23:00'}]},
    'Tuesday':   {'enabled': true,  'shifts': [{'open': '09:00', 'close': '23:00'}]},
    'Wednesday': {'enabled': true,  'shifts': [{'open': '09:00', 'close': '23:00'}]},
    'Thursday':  {'enabled': true,  'shifts': [{'open': '09:00', 'close': '23:00'}]},
    'Friday':    {'enabled': false, 'shifts': [{'open': '14:00', 'close': '23:00'}]},
    'Saturday':  {'enabled': true,  'shifts': [{'open': '09:00', 'close': '23:00'}]},
  }.obs;

  /// The shifts recorded for a day, always at least one.
  List<Map<String, String>> shiftsFor(String day) {
    final raw = schedule[day]?['shifts'];
    if (raw is List && raw.isNotEmpty) {
      return raw
          .map((e) => Map<String, String>.from(
              (e as Map).map((k, v) => MapEntry('$k', '$v'))))
          .toList();
    }
    return [
      {'open': '09:00', 'close': '23:00'}
    ];
  }

  void _writeShifts(String day, List<Map<String, String>> shifts) {
    final current = Map<String, dynamic>.from(schedule[day] ?? {});
    current['shifts'] = shifts;
    // Mirrored for anything reading the old shape.
    current['open'] = shifts.first['open'];
    current['close'] = shifts.last['close'];
    schedule[day] = current;
    schedule.refresh();
  }

  /// Adds another shift to a day — an afternoon reopening, a night service.
  /// The new one starts where the last leaves off so the merchant edits from
  /// something sensible rather than from midnight.
  Future<void> addShift(BuildContext context, String day) async {
    final shifts = shiftsFor(day);
    final lastClose = _parseTime(shifts.last['close']) ?? const TimeOfDay(hour: 17, minute: 0);

    final open = await showTimePicker(
      context: context,
      initialTime: lastClose,
      helpText: 'Second opening — $day',
    );
    if (open == null) return;
    if (!context.mounted) return;

    final close = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: (open.hour + 4) % 24, minute: open.minute),
      helpText: 'Closing again — $day',
    );
    if (close == null) return;

    shifts.add({'open': _formatTime(open), 'close': _formatTime(close)});
    shifts.sort((a, b) => (a['open'] ?? '').compareTo(b['open'] ?? ''));

    final current = Map<String, dynamic>.from(schedule[day] ?? {});
    current['enabled'] = true;
    schedule[day] = current;
    _writeShifts(day, shifts);
  }

  /// Removes one shift. The last one stays: a day with no hours at all is
  /// what the day's own on/off switch is for.
  void removeShift(String day, int index) {
    final shifts = shiftsFor(day);
    if (shifts.length <= 1) {
      safeSnackbar('Closed all day?',
          'Turn $day off instead of removing its only opening hours.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    shifts.removeAt(index);
    _writeShifts(day, shifts);
  }

  /// Edits one shift in place.
  Future<void> editShift(BuildContext context, String day, int index) async {
    final shifts = shiftsFor(day);
    if (index >= shifts.length) return;

    final open = await showTimePicker(
      context: context,
      initialTime: _parseTime(shifts[index]['open']) ?? const TimeOfDay(hour: 9, minute: 0),
      helpText: 'Opening time — $day',
    );
    if (open == null) return;
    if (!context.mounted) return;

    final close = await showTimePicker(
      context: context,
      initialTime: _parseTime(shifts[index]['close']) ?? const TimeOfDay(hour: 23, minute: 0),
      helpText: 'Closing time — $day',
    );
    if (close == null) return;

    shifts[index] = {'open': _formatTime(open), 'close': _formatTime(close)};
    shifts.sort((a, b) => (a['open'] ?? '').compareTo(b['open'] ?? ''));

    final current = Map<String, dynamic>.from(schedule[day] ?? {});
    current['enabled'] = true;
    schedule[day] = current;
    _writeShifts(day, shifts);
  }

  // Loyalty type
  final isPrivetLoyalty = false.obs;

  // Document URLs (filled after upload)
  final documentUrls = <String>[].obs;
  final documentNames = <String>[].obs;
  final isUploadingDocument = false.obs;

  /// Licence expiry date. The registration form drew a date box with
  /// "Not set yet" and a calendar icon that was a plain Container — no picker,
  /// no field, nothing ever set it.
  final licenseExpiry = Rxn<DateTime>();

  @override
  void onClose() {
    fullNameLatinCtrl.dispose();
    fullNameArabicCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    storeNameLatinCtrl.dispose();
    storeNameArabicCtrl.dispose();
    addressCtrl.dispose();
    apartmentCtrl.dispose();
    locationNameCtrl.dispose();
    descriptionCtrl.dispose();
    tinCtrl.dispose();
    facebookCtrl.dispose();
    instagramCtrl.dispose();
    websiteCtrl.dispose();
    super.onClose();
  }

  void toggleSection(String section) {
    switch (section) {
      case 'Additional Info':  isAdditionalInfoExpanded.value = !isAdditionalInfoExpanded.value; break;
      case 'Time Info':        isTimeInfoExpanded.value        = !isTimeInfoExpanded.value; break;
      case 'Location':         isLocationExpanded.value        = !isLocationExpanded.value; break;
      case 'Social Media':     isSocialMediaExpanded.value     = !isSocialMediaExpanded.value; break;
      case 'Upload Identity':  isIdentityExpanded.value        = !isIdentityExpanded.value; break;
    }
  }

  void toggleDay(String day, bool enabled) {
    final current = Map<String, dynamic>.from(schedule[day]!);
    current['enabled'] = enabled;
    schedule[day] = current;
    schedule.refresh();
  }

  /// Opens two time pickers (open, then close) for one weekday and stores the
  /// result. The registration form drew each day's hours as a bordered Text
  /// box with no handler, so every merchant submitted the same default
  /// 09:00–23:00 schedule no matter what their real hours were.
  Future<void> pickDayHours(BuildContext context, String day) async {
    final data = schedule[day];
    if (data == null) return;

    final open = await showTimePicker(
      context: context,
      initialTime: _parseTime(data['open'] as String?) ?? const TimeOfDay(hour: 9, minute: 0),
      helpText: 'Opening time — $day',
    );
    if (open == null) return;
    if (!context.mounted) return;

    final close = await showTimePicker(
      context: context,
      initialTime: _parseTime(data['close'] as String?) ?? const TimeOfDay(hour: 23, minute: 0),
      helpText: 'Closing time — $day',
    );
    if (close == null) return;

    final updated = Map<String, dynamic>.from(data);
    updated['open'] = _formatTime(open);
    updated['close'] = _formatTime(close);
    updated['enabled'] = true;
    schedule[day] = updated;
    schedule.refresh();
  }

  TimeOfDay? _parseTime(String? value) {
    if (value == null) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  void removeDocument(int index) {
    if (index < 0 || index >= documentUrls.length) return;
    documentUrls.removeAt(index);
    if (index < documentNames.length) documentNames.removeAt(index);
  }

  /// Picks a licence/identity document and uploads it to the real
  /// POST /api/upload endpoint. The "Select a file" row used to be a
  /// decorative Container: there was no picker anywhere, so `documentUrls`
  /// was always empty and the `documents` array the backend stores was
  /// permanently empty for every merchant.
  Future<void> pickLicenseDocument() async {
    if (isUploadingDocument.value) return;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
      );
      final picked = result?.files.single;
      if (picked == null || picked.path == null) return;

      isUploadingDocument.value = true;
      final url = await _uploadFile(picked.path!, picked.name);
      if (url != null) {
        documentUrls.add(url);
        documentNames.add(picked.name);
        safeSnackbar('Uploaded', picked.name, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      debugPrint('pickLicenseDocument error: $e');
      safeSnackbar('Error', 'Could not upload the document. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isUploadingDocument.value = false;
    }
  }

  Future<String?> _uploadFile(String filePath, String fileName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final dioClient = dio.Dio(dio.BaseOptions(
        baseUrl: ApiService.baseUrl,
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      ));
      final formData = dio.FormData.fromMap({
        'image': await dio.MultipartFile.fromFile(filePath, filename: fileName),
      });
      final res = await dioClient.post('/upload', data: formData);
      if (res.data['success'] == true) {
        return res.data['data']['url'] as String;
      }
      safeSnackbar('Error', 'Upload failed', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      debugPrint('_uploadFile error: $e');
      safeSnackbar('Error', 'Could not upload the file', snackPosition: SnackPosition.BOTTOM);
    }
    return null;
  }

  Future<void> pickLicenseExpiry(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: licenseExpiry.value ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 20),
    );
    if (picked != null) licenseExpiry.value = picked;
  }

  Future<void> saveProfile() async {
    if (jobTitle.value == 'Choose') {
      safeSnackbar('Incomplete', 'Please choose a job title', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (category.value == 'Choose') {
      safeSnackbar('Incomplete', 'Please choose a category', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final storeName = storeNameLatinCtrl.text.trim();
    final fullName  = fullNameLatinCtrl.text.trim();
    final phone     = phoneCtrl.text.trim();

    if (storeName.isEmpty || fullName.isEmpty) {
      safeSnackbar('Incomplete', 'Please fill in your name and store name', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    // The backend's BusinessRegistration record requires both — submitting
    // without them fails with a raw Mongoose validation error instead of a
    // clean prompt, so catch it here first.
    if (emailCtrl.text.trim().isEmpty || addressCtrl.text.trim().isEmpty) {
      safeSnackbar('Incomplete', 'Please fill in your email and address', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      // 1 — Update merchant profile with store info
      await _api.put('/merchant/profile', {
        'storeName':     storeName,
        'storeCategory': category.value,
        if (phone.isNotEmpty) 'phone': phone,
        if (emailCtrl.text.isNotEmpty) 'email': emailCtrl.text.trim(),
        if (addressCtrl.text.isNotEmpty) 'address': addressCtrl.text.trim(),
        if (apartmentCtrl.text.isNotEmpty) 'apartment': apartmentCtrl.text.trim(),
        if (locationNameCtrl.text.isNotEmpty) 'locationName': locationNameCtrl.text.trim(),
        if (descriptionCtrl.text.isNotEmpty) 'description': descriptionCtrl.text.trim(),
        if (facebookCtrl.text.isNotEmpty) 'facebook': facebookCtrl.text.trim(),
        if (instagramCtrl.text.isNotEmpty) 'instagram': instagramCtrl.text.trim(),
        if (websiteCtrl.text.isNotEmpty) 'website': websiteCtrl.text.trim(),
      });

      // 2 — Submit partnership / business registration
      final response = await _api.post('/merchant/register', {
        'ownerName':      fullName,
        'ownerNameAr':    fullNameArabicCtrl.text.trim(),
        'storeName':      storeName,
        'storeNameAr':    storeNameArabicCtrl.text.trim(),
        'businessType':   businessType.value == 'Choose' ? 'retail' : businessType.value,
        'category':       category.value,
        'jobTitle':       jobTitle.value,
        'phone':          phone,
        'email':          emailCtrl.text.trim(),
        'address':        addressCtrl.text.trim(),
        'apartment':      apartmentCtrl.text.trim(),
        'locationName':   locationNameCtrl.text.trim(),
        'description':    descriptionCtrl.text.trim(),
        'schedule':       Map<String, dynamic>.from(schedule),
        'loyaltyType':    isPrivetLoyalty.value ? 'private' : 'everywhere',
        'documents':      documentUrls.toList(),
        'tin':            tinCtrl.text.trim(),
        if (licenseExpiry.value != null)
          'licenseExpiry': licenseExpiry.value!.toIso8601String(),
        'facebook':       facebookCtrl.text.trim(),
        'instagram':      instagramCtrl.text.trim(),
        'website':        websiteCtrl.text.trim(),
      });

      if (response.success) {
        Get.toNamed(MerchantRoutes.QR_RECEIVE);
      } else {
        safeSnackbar('Error', response.message, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      debugPrint('saveProfile error: $e');
      safeSnackbar('Error', 'Could not save your registration. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
