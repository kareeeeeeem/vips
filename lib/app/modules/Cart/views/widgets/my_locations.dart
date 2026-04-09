import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

// ==================== MODEL ====================

class SavedLocation {
  final String id;
  final String name;
  final String address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;
  final double? latitude;
  final double? longitude;
  bool isDefault;

  SavedLocation({
    required this.id,
    required this.name,
    required this.address,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  String get fullAddress {
    List<String> parts = [address];
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (zipCode != null && zipCode!.isNotEmpty) parts.add(zipCode!);
    return parts.join(', ');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
    };
  }

  factory SavedLocation.fromJson(Map<String, dynamic> json) {
    return SavedLocation(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zipCode'],
      country: json['country'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      isDefault: json['isDefault'] ?? false,
    );
  }

  SavedLocation copyWith({
    String? id,
    String? name,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) {
    return SavedLocation(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

// ==================== CONTROLLER ====================

class MyLocationsController extends GetxController {
  var locations = <SavedLocation>[].obs;
  var selectedLocationIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadLocations();
  }

  void _loadLocations() {
    // Sample data - remplacer avec des données depuis API/Storage
    locations.value = [
      SavedLocation(
        id: '1',
        name: "MAM'S HOUSE",
        address: '110 Baker Street, London, United Kingdom',
        city: 'London',
        country: 'United Kingdom',
        isDefault: false,
      ),
      SavedLocation(
        id: '2',
        name: 'HOME',
        address: '2464 Royal Ln. Mesa, New Jersey 45463',
        city: 'Mesa',
        state: 'New Jersey',
        zipCode: '45463',
        country: 'USA',
        isDefault: true,
      ),
      SavedLocation(
        id: '3',
        name: 'WORK',
        address: '3891 Ranchview Dr. Richardson, California 62639',
        city: 'Richardson',
        state: 'California',
        zipCode: '62639',
        country: 'USA',
        isDefault: false,
      ),
    ];

    // Sélectionner l'adresse par défaut ou la première
    final defaultIndex = locations.indexWhere((loc) => loc.isDefault);
    selectedLocationIndex.value = defaultIndex != -1 ? defaultIndex : 0;
  }

  void selectLocation(int index) {
    selectedLocationIndex.value = index;
  }

  void addNewLocation() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add New Location',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontFamily: 'SF Pro Display',
                ),
              ),
              SizedBox(height: 20.h),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Location Name (e.g., Home, Work)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Full Address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: const Color(0xFFE5E7EB),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B7280),
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implémenter l'ajout
                        Get.back();
                        Get.snackbar(
                          'Success',
                          'New location added successfully',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(
                            0xFF22C55E,
                          ).withOpacity(0.9),
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                          margin: EdgeInsets.all(16.w),
                          borderRadius: 12.r,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      child: Text(
                        'Add',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void editLocation(SavedLocation location) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edit Location',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontFamily: 'SF Pro Display',
                ),
              ),
              SizedBox(height: 20.h),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Location Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                ),
                controller: TextEditingController(text: location.name),
              ),
              SizedBox(height: 16.h),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Full Address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                ),
                controller: TextEditingController(text: location.address),
                maxLines: 2,
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: const Color(0xFFE5E7EB),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B7280),
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implémenter la mise à jour
                        Get.back();
                        Get.snackbar(
                          'Success',
                          'Location updated successfully',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(
                            0xFF22C55E,
                          ).withOpacity(0.9),
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                          margin: EdgeInsets.all(16.w),
                          borderRadius: 12.r,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      child: Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void deleteLocation(int index) {
    final location = locations[index];

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 30.sp,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Delete Location',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontFamily: 'SF Pro Display',
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Are you sure you want to delete "${location.name}"?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF6B7280),
                  fontFamily: 'SF Pro Text',
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: const Color(0xFFE5E7EB),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B7280),
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        locations.removeAt(index);

                        // Ajuster l'index sélectionné si nécessaire
                        if (selectedLocationIndex.value >= locations.length) {
                          selectedLocationIndex.value =
                              locations.length > 0 ? locations.length - 1 : 0;
                        }

                        Get.back();

                        Get.snackbar(
                          'Deleted',
                          'Location deleted successfully',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red.withOpacity(0.9),
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                          margin: EdgeInsets.all(16.w),
                          borderRadius: 12.r,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      child: Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void applySelectedLocation() {
    if (locations.isEmpty) {
      Get.snackbar(
        'No Location',
        'Please add a location first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: EdgeInsets.all(16.w),
        borderRadius: 12.r,
      );
      return;
    }

    final selectedLocation = locations[selectedLocationIndex.value];

    // Retourner la location sélectionnée
    Get.back(result: selectedLocation);

    Get.snackbar(
      'Location Selected',
      '${selectedLocation.name} has been set as delivery address',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF22C55E).withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: EdgeInsets.all(16.w),
      borderRadius: 12.r,
    );
  }

  void goBack() {
    Get.back();
  }

  // ==================== UTILITY METHODS ====================

  SavedLocation? get selectedLocation {
    if (locations.isEmpty) return null;
    return locations[selectedLocationIndex.value];
  }

  void setDefaultLocation(int index) {
    // Retirer le flag default de toutes les locations
    for (var location in locations) {
      location.isDefault = false;
    }

    // Définir la nouvelle location par défaut
    locations[index].isDefault = true;
    locations.refresh();
  }

  Future<void> saveLocations() async {
    // TODO: Sauvegarder dans le storage ou API
    // GetStorage().write('saved_locations', locations.map((l) => l.toJson()).toList());
  }

  Future<void> loadSavedLocations() async {
    // TODO: Charger depuis le storage ou API
    // final saved = GetStorage().read('saved_locations');
    // if (saved != null) {
    //   locations.value = (saved as List).map((json) => SavedLocation.fromJson(json)).toList();
    // }
  }
}

class MyLocationsView extends GetView<MyLocationsController> {
  const MyLocationsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(MyLocationsController());
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    // Liste des adresses
                    Obx(
                      () => ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: controller.locations.length,
                        itemBuilder: (context, index) {
                          final location = controller.locations[index];
                          return _buildLocationCard(location, index);
                        },
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Bouton Add New Location
                    _buildAddLocationButton(),

                    SizedBox(height: 100.h),
                  ],
                ),
              ),
            ),
            _buildApplyButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: controller.goBack,
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
                size: 18.sp,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'My Locations',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontFamily: 'SF Pro Display',
                ),
              ),
            ),
          ),
          SizedBox(width: 40.w), // For symmetry
        ],
      ),
    );
  }

  Widget _buildLocationCard(SavedLocation location, int index) {
    return Obx(() {
      final isSelected = controller.selectedLocationIndex.value == index;

      return GestureDetector(
        onTap: () => controller.selectLocation(index),
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? const Color(0xFFFF6B35) : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              // Radio Button
              Container(
                width: 24.w,
                height: 24.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        isSelected
                            ? const Color(0xFFFF6B35)
                            : const Color(0xFFD1D5DB),
                    width: 2,
                  ),
                ),
                child:
                    isSelected
                        ? Center(
                          child: Container(
                            width: 12.w,
                            height: 12.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFFF6B35),
                            ),
                          ),
                        )
                        : null,
              ),

              SizedBox(width: 12.w),

              // Location Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.name,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      location.address,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF9CA3AF),
                        fontFamily: 'SF Pro Text',
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              SizedBox(width: 12.w),

              // Action Buttons (Edit | Delete)
              Row(
                children: [
                  GestureDetector(
                    onTap: () => controller.editLocation(location),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      child: Icon(
                        Icons.edit_outlined,
                        color: const Color(0xFFFF6B35),
                        size: 20.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  GestureDetector(
                    onTap: () => controller.deleteLocation(index),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      child: Icon(
                        Icons.delete_outline,
                        color: const Color(0xFFFF6B35),
                        size: 20.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAddLocationButton() {
    return GestureDetector(
      onTap: controller.addNewLocation,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEDE8),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: const Color(0xFFFF6B35), size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'Add New Location',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFF6B35),
                fontFamily: 'SF Pro Display',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplyButton() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: controller.applySelectedLocation,
        child: Container(
          width: double.infinity,
          height: 52.h,
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B35),
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B35).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'Apply',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFamily: 'SF Pro Display',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== BINDING ====================

class MyLocationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyLocationsController>(() => MyLocationsController());
  }
}
