import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'food_delivery_page.dart';
import 'location_permission_bottom_sheet.dart';

class BuildFeaturedCategories extends StatelessWidget {
  const BuildFeaturedCategories({Key? key, required this.fromHome})
    : super(key: key);
  final bool fromHome;

  @override
  Widget build(BuildContext context) {
    final categories = [
      CategoryItem(
        title: 'Nearest\nPlaces',
        icon: Icons.location_on,
        iconBackgroundColor: Color(0xFFFFB347),
        iconColor: Colors.white,
        textColor: Color(0xFFFF8C42),
        useIconOnly: true,
        isNearestPlaces: true, // Marqueur spécial
      ),
      CategoryItem(
        title: 'Computer &\nAccessories',
        backgroundImage:
            'https://images.unsplash.com/photo-1484704849700-f032a568e944?w=400&q=80',
        iconBackgroundColor: Color(0xFF3A3A3A),
        textColor: Color(0xFF9E9E9E),
        useIconOnly: false,
      ),
      CategoryItem(
        title: 'Men Clothing\n& Fashion',
        backgroundImage:
            'https://images.unsplash.com/photo-1490114538077-0a7f8cb49891?w=400&q=80',
        iconBackgroundColor: Color(0xFF87CEEB),
        textColor: Color(0xFF9E9E9E),
        useIconOnly: false,
      ),
      CategoryItem(
        title: 'Automobile &\nMotorcycle',
        backgroundImage:
            'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400&q=80',
        iconBackgroundColor: Color(0xFF6B9AC4),
        textColor: Color(0xFF9E9E9E),
        useIconOnly: false,
      ),
      CategoryItem(
        title: 'Beauty &\nCosmetics',
        backgroundImage:
            'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=400&q=80',
        iconBackgroundColor: Color(0xFFFFB6C1),
        textColor: Color(0xFF9E9E9E),
        useIconOnly: false,
      ),
      CategoryItem(
        title: 'Sports &\nFitness',
        backgroundImage:
            'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=400&q=80',
        iconBackgroundColor: Color(0xFF4CAF50),
        textColor: Color(0xFF9E9E9E),
        useIconOnly: false,
      ),
      CategoryItem(
        title: 'Home &\nFurniture',
        backgroundImage:
            'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400&q=80',
        iconBackgroundColor: Color(0xFF8D6E63),
        textColor: Color(0xFF9E9E9E),
        useIconOnly: false,
      ),
      CategoryItem(
        title: 'Books &\nStationery',
        backgroundImage:
            'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?w=400&q=80',
        iconBackgroundColor: Color(0xFF9C27B0),
        textColor: Color(0xFF9E9E9E),
        useIconOnly: false,
      ),
    ];

    return Row(
      children: [
        if (!fromHome)
          Container(
            margin: EdgeInsets.only(left: 12.w),
            width: 35,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Center(
              child: RotatedBox(
                quarterTurns: 3,
                child: const Text(
                  'Category',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
        if (!fromHome) const SizedBox(width: 0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (fromHome)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Featured Categories',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                      Text(
                        'See All',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF667eea),
                        ),
                      ),
                    ],
                  ),
                ),
              if (fromHome) SizedBox(height: 6.h),
              // Première ligne horizontale
              SizedBox(
                height: 75.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: (categories.length / 2).ceil(),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap:
                          () => _handleCategoryTap(context, categories[index]),
                      child: _buildCategoryCard(categories[index]),
                    );
                  },
                ),
              ),
              SizedBox(height: 12.h),
              // Deuxième ligne horizontale
              SizedBox(
                height: 75.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: categories.length - (categories.length / 2).ceil(),
                  itemBuilder: (context, index) {
                    int actualIndex = (categories.length / 2).ceil() + index;
                    return InkWell(
                      onTap:
                          () => _handleCategoryTap(
                            context,
                            categories[actualIndex],
                          ),
                      child: _buildCategoryCard(categories[actualIndex]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleCategoryTap(BuildContext context, CategoryItem item) {
    if (item.isNearestPlaces) {
      // Afficher la bottom sheet de demande de localisation
      LocationPermissionBottomSheet.show(
        context,
        onAllowActivation: () {
          print('Location permission granted');
          // Demander la permission de localisation
          _requestLocationPermission(context);
        },
        onNoThanks: () {
          print('Location permission denied');
          // Optionnel : afficher un message ou continuer sans localisation
        },
      );
    } else {
      // Navigation normale pour les autres catégories
      Get.to(() => FoodDeliveryPage());
    }
  }

  Future<void> _requestLocationPermission(BuildContext context) async {
    // Ici, vous pouvez intégrer le package de permissions
    // Par exemple avec geolocator ou permission_handler

    // Exemple avec permission_handler:
    // import 'package:permission_handler/permission_handler.dart';
    /*
    var status = await Permission.location.request();
    if (status.isGranted) {
      // Permission accordée, naviguer vers la page
      Get.to(() => FoodDeliveryPage());
    } else if (status.isDenied) {
      // Permission refusée
      Get.snackbar(
        'Permission refusée',
        'La localisation est nécessaire pour voir les lieux à proximité',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else if (status.isPermanentlyDenied) {
      // Ouvrir les paramètres
      openAppSettings();
    }
    */

    // Pour l'instant, on navigue simplement
    Get.to(() => FoodDeliveryPage());
  }

  Widget _buildCategoryCard(CategoryItem item) {
    return Container(
      width: 200.w,
      margin: EdgeInsets.only(right: 12.w),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icône / Image carrée
          Container(
            width: 58.w,
            height: 58.w,
            decoration: BoxDecoration(
              color: item.iconBackgroundColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child:
                item.useIconOnly
                    ? Icon(item.icon, color: item.iconColor, size: 30.sp)
                    : ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.network(
                        item.backgroundImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
          ),
          SizedBox(width: 12.w),
          // Texte
          Expanded(
            child: Text(
              item.title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: item.textColor,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryItem {
  final String title;
  final IconData? icon;
  final String? backgroundImage;
  final Color iconBackgroundColor;
  final Color? iconColor;
  final Color textColor;
  final bool useIconOnly;
  final bool isNearestPlaces;

  CategoryItem({
    required this.title,
    this.icon,
    this.backgroundImage,
    required this.iconBackgroundColor,
    this.iconColor,
    required this.textColor,
    this.useIconOnly = false,
    this.isNearestPlaces = false, // Par défaut false
  });
}
