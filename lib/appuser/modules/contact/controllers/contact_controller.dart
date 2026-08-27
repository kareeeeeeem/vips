import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class ContactController extends GetxController {
  final RxList<Map<String, dynamic>> contacts = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadContacts();
  }

  Future<void> loadContacts() async {
    try {
      isLoading.value = true;
      final response = await ApiService().get('/user/contacts');
      if (response.success && response.data != null) {
        contacts.value = List<Map<String, dynamic>>.from(response.data);
      }
    } catch (e) {
      debugPrint('Load contacts error: $e');
      safeSnackbar('Error', 'Could not load your contacts. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }
  void navigateToSearch() {
    Get.toNamed('/search');
  }

  Future<void> deleteContact(Map<String, dynamic> contact) async {
    final id = contact['_id']?.toString();
    if (id == null || id.isEmpty) return;
    final removed = contacts.firstWhere((c) => c['_id'] == id, orElse: () => {});
    contacts.removeWhere((c) => c['_id'] == id);
    try {
      final response = await ApiService().delete('/user/contacts/$id');
      if (!response.success) {
        if (removed.isNotEmpty) contacts.add(removed);
        safeSnackbar('Error', 'Could not delete contact.');
      }
    } catch (_) {
      if (removed.isNotEmpty) contacts.add(removed);
      safeSnackbar('Error', 'Could not delete contact.');
    }
  }

  void showContactOptions(Map<String, dynamic> contact) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(contact['name'] ?? 'Contact',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(contact['phone'] ?? '', style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  deleteContact(contact);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Delete Contact',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  // GET /user/contacts ignores every query param and always returns the
  // full list sorted by name (routes/user.js). 'recent' is applied
  // client-side below using the real `createdAt` timestamp; a 'frequent'
  // option was removed rather than kept as a chip that changes nothing —
  // there's no interaction-count field anywhere to back it.
  final RxString filterType = 'all'.obs;

  Future<void> toggleFavorite(Map<String, dynamic> contact) async {
    final id = contact['_id']?.toString();
    if (id == null || id.isEmpty) return;
    final index = contacts.indexWhere((c) => c['_id'] == id);
    if (index == -1) return;
    final current = contacts[index]['isFavorite'] == true;
    contacts[index] = {...contacts[index], 'isFavorite': !current};
    contacts.refresh();
    try {
      final response = await ApiService().patch('/user/contacts/$id/favorite', {});
      if (!response.success) {
        contacts[index] = {...contacts[index], 'isFavorite': current};
        contacts.refresh();
        safeSnackbar('Error', 'Could not update favorite.');
      }
    } catch (_) {
      contacts[index] = {...contacts[index], 'isFavorite': current};
      contacts.refresh();
      safeSnackbar('Error', 'Could not update favorite.');
    }
  }

  void applyFilter(String filter) {
    filterType.value = filter;
    if (filter == 'recent') {
      final sorted = contacts.toList()
        ..sort((a, b) => (b['createdAt'] ?? '').toString().compareTo((a['createdAt'] ?? '').toString()));
      contacts.assignAll(sorted);
    } else {
      loadContacts();
    }
  }

  final RxString newContactName = ''.obs;
  final RxString newContactPhone = ''.obs;

  void showAddContactSheet() {
    newContactName.value = '';
    newContactPhone.value = '';
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Contact',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => newContactName.value = v,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              onChanged: (v) => newContactPhone.value = v,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (newContactName.value.isEmpty || newContactPhone.value.isEmpty) {
                    safeSnackbar('Error', 'Name and phone are required');
                    return;
                  }
                  Get.back();
                  try {
                    final response = await ApiService().post('/user/contacts', {
                      'name': newContactName.value,
                      'phone': newContactPhone.value,
                    });
                    if (response.success) {
                      safeSnackbar('Success', 'Contact added',
                          backgroundColor: const Color(0xFF10B981),
                          colorText: Colors.white);
                      loadContacts();
                    } else {
                      safeSnackbar('Error', response.message);
                    }
                  } catch (_) {
                    safeSnackbar('Error', 'Failed to add contact');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Add Contact',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void showFilterSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter Contacts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Obx(() => Wrap(
              spacing: 8,
              children: ['all', 'recent'].map((f) {
                final selected = filterType.value == f;
                return ChoiceChip(
                  label: Text(f[0].toUpperCase() + f.substring(1)),
                  selected: selected,
                  selectedColor: const Color(0xFF10B981),
                  labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black87),
                  onSelected: (_) {
                    Get.back();
                    applyFilter(f);
                  },
                );
              }).toList(),
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

}
