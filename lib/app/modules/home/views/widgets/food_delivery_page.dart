import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'auth_bottom_sheet.dart';
import 'build_appbar.dart';
import 'build_drawer_menu.dart';
import 'build_section_category_filter.dart';

// ============================================================
// CONTROLLER (Pour GetX)
// ============================================================

class FoodDeliveryController extends GetxController {
  // État observable
  final RxInt selectedCategory = 0.obs;
  final RxString selectedFilter = 'Hot Deals'.obs;
  final RxList<FoodItem> foodItems = <FoodItem>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  // Charger les produits
  Future<void> loadProducts() async {
    isLoading.value = true;

    // Simuler un appel API
    await Future.delayed(const Duration(seconds: 1));

    foodItems.value = [
      FoodItem(
        id: '1',
        name: 'Ramen Noodles',
        imageUrl:
            'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400',
        discount: 30,
        isFree: true,
        distance: 100,
        duration: 20,
        currentPrice: 6000,
        oldPrice: 10000,
        isFavorite: false,
      ),
      FoodItem(
        id: '2',
        name: 'Pho Noodles',
        imageUrl:
            'https://images.unsplash.com/photo-1591814468924-caf88d1232e1?w=400',
        discount: 30,
        isFree: true,
        distance: 100,
        duration: 20,
        currentPrice: 6000,
        oldPrice: 10000,
        isFavorite: false,
      ),
      FoodItem(
        id: '3',
        name: 'Fresh Fruit Donuts',
        imageUrl:
            'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=400',
        discount: 30,
        isFree: true,
        distance: 100,
        duration: 20,
        currentPrice: 6000,
        oldPrice: 10000,
        isFavorite: false,
      ),
      FoodItem(
        id: '4',
        name: 'Rotini',
        imageUrl:
            'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=400',
        discount: 30,
        isFree: true,
        distance: 100,
        duration: 20,
        currentPrice: 6000,
        oldPrice: 10000,
        isFavorite: false,
      ),
      FoodItem(
        id: '5',
        name: 'Penne',
        imageUrl:
            'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=400',
        discount: 30,
        isFree: true,
        distance: 100,
        duration: 20,
        currentPrice: 6000,
        oldPrice: 10000,
        isFavorite: false,
      ),
      FoodItem(
        id: '6',
        name: 'Farfalle',
        imageUrl:
            'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',
        discount: 30,
        isFree: true,
        distance: 100,
        duration: 20,
        currentPrice: 6000,
        oldPrice: 10000,
        isFavorite: false,
      ),
    ];

    isLoading.value = false;
  }

  // Changer de catégorie
  void changeCategory(int index) {
    selectedCategory.value = index;
    print('Category changed to: $index');
    // Rechargez vos produits selon la catégorie
    filterProductsByCategory(index);
  }

  // Changer de filtre
  void changeFilter(String filter) {
    selectedFilter.value = filter;
    print('Filter changed to: $filter');
    // Appliquez le filtre
    applyFilter(filter);
  }

  // Filtrer par catégorie
  void filterProductsByCategory(int categoryIndex) {
    // Votre logique de filtrage ici
  }

  // Appliquer un filtre
  void applyFilter(String filter) {
    if (filter == 'Hot Deals') {
      // Trier par promotions
    } else if (filter == 'Nearest') {
      // Trier par proximité
    } else if (filter == 'Recent') {
      // Trier par récence
    }
  }

  // Toggle favori
  void toggleFavorite(String productId) {
    final index = foodItems.indexWhere((item) => item.id == productId);
    if (index != -1) {
      foodItems[index].isFavorite = !foodItems[index].isFavorite;
      foodItems.refresh();
    }
  }

  // Ajouter au panier
  void addToCart(FoodItem item) {
    print('Added to cart: ${item.name}');
    // Votre logique panier ici
    Get.snackbar(
      'Ajouté au panier',
      item.name,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Ouvrir les détails
  void openProductDetails(FoodItem item) {
    print('Opening details for: ${item.name}');
    // Naviguer vers la page de détails
    // Get.to(() => ProductDetailPage(product: item));
  }
}

// ============================================================
// MODÈLE
// ============================================================

class FoodItem {
  final String id;
  final String name;
  final String imageUrl;
  final int discount;
  final bool isFree;
  final int distance;
  final int duration;
  final int currentPrice;
  final int oldPrice;
  bool isFavorite;

  FoodItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.discount,
    required this.isFree,
    required this.distance,
    required this.duration,
    required this.currentPrice,
    required this.oldPrice,
    this.isFavorite = false,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'],
      discount: json['discount'],
      isFree: json['is_free'],
      distance: json['distance'],
      duration: json['duration'],
      currentPrice: json['current_price'],
      oldPrice: json['old_price'],
      isFavorite: json['is_favorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'discount': discount,
      'is_free': isFree,
      'distance': distance,
      'duration': duration,
      'current_price': currentPrice,
      'old_price': oldPrice,
      'is_favorite': isFavorite,
    };
  }
}

class FoodDeliveryPage extends GetView<FoodDeliveryController> {
  FoodDeliveryPage({Key? key}) : super(key: key);
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    Get.put(FoodDeliveryController());

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: DrawerMenu(),
      body: Container(
        color: const Color(0xFFF8FAFC),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: BuildAppbar(() {
                  scaffoldKey.currentState?.openDrawer();
                }, true),
              ),
              CategoryFilterBar(),
              const SizedBox(height: 20),
              Expanded(child: _buildProductsGrid()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildIconButton(Icons.menu, Colors.white, Colors.black87, () {}),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'What are you l...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildIconButton(
            Icons.notifications_outlined,
            Colors.white,
            Colors.black87,
            () {},
          ),
          const SizedBox(width: 12),
          _buildIconButton(
            Icons.shopping_bag_outlined,
            const Color(0xFFFF6B35),
            Colors.white,
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(
    IconData icon,
    Color bgColor,
    Color iconColor,
    VoidCallback onPressed,
  ) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                bgColor == const Color(0xFFFF6B35)
                    ? bgColor.withOpacity(0.3)
                    : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return SizedBox(
      height: 100,
      child: Row(
        children: [
          const SizedBox(width: 16),
          _buildPromoBadge(),
          const SizedBox(width: 16),
          Container(width: 1, height: 60, color: Colors.grey[300]),
          const SizedBox(width: 16),
          Expanded(
            child: Obx(
              () => ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategory(0, 'Category 1', true),
                  _buildCategory(1, 'Category 2', false),
                  _buildCategory(2, 'Category 3', false),
                  _buildCategory(3, 'Category 4', false),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildPromoBadge() {
    return Container(
      width: 60,
      height: 60,
      decoration: const BoxDecoration(
        color: Color(0xFFFF6B35),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.percent, color: Colors.white, size: 32),
    );
  }

  Widget _buildCategory(int index, String title, bool hasTopBadge) {
    return Obx(() {
      final isSelected = controller.selectedCategory.value == index;

      return GestureDetector(
        onTap: () => controller.changeCategory(index),
        child: Container(
          width: 90,
          margin: const EdgeInsets.only(right: 16),
          child: Column(
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        isSelected
                            ? const Color(0xFFFF6B35)
                            : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: const Icon(Icons.restaurant_menu, size: 30),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color:
                      isSelected ? const Color(0xFFFF6B35) : Colors.grey[700],
                ),
              ),
              if (hasTopBadge && index == 0)
                const Text(
                  'TOP',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6B35),
                  ),
                ),
              if (isSelected)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 50,
                  height: 3,
                  color: const Color(0xFFFF6B35),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFiltersSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterIcon(Icons.tune),
          const SizedBox(width: 12),
          _buildFilterIcon(Icons.sort),
          const SizedBox(width: 16),
          Container(width: 1, height: 30, color: Colors.grey[300]),
          const SizedBox(width: 20),
          Expanded(
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildFilterTab('Hot Deals'),
                  _buildFilterTab('Nearest'),
                  _buildFilterTab('Recent'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterIcon(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 20, color: Colors.grey[600]),
    );
  }

  Widget _buildFilterTab(String title) {
    final isSelected = controller.selectedFilter.value == title;

    return GestureDetector(
      onTap: () => controller.changeFilter(title),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.black : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildProductsGrid() {
    return Obx(
      () => GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: controller.foodItems.length,
        itemBuilder: (context, index) {
          return _buildFoodCard(controller.foodItems[index]);
        },
      ),
    );
  }

  Widget _buildFoodCard(FoodItem item) {
    return GestureDetector(
      onTap: () => controller.openProductDetails(item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.network(
                    item.imageUrl,
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 130,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, size: 50),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${item.discount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.percent,
                          color: Colors.white,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
                // ✅ MODIFIÉ : Afficher la bottom sheet au lieu de toggle direct
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () async {
                      final result = await AuthBottomSheet.show(Get.context!);

                      // Si l'utilisateur s'est connecté avec succès
                      if (result == true) {
                        // Alors on peut ajouter aux favoris
                        controller.toggleFavorite(item.id);

                        // Optionnel : afficher un message de confirmation
                        ScaffoldMessenger.of(Get.context!).showSnackBar(
                          SnackBar(
                            content: Text(
                              item.isFavorite
                                  ? 'Removed from favorites'
                                  : 'Added to favorites',
                            ),
                            duration: const Duration(seconds: 2),
                            backgroundColor: const Color(0xFFFF6B35),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: const Color(0xFFFF6B35),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Row avec espacements réduits
                  Row(
                    children: [
                      const Icon(
                        Icons.delivery_dining,
                        color: Color(0xFFFF6B35),
                        size: 14,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        item.isFree ? 'Free' : 'Paid',
                        style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFFFF6B35),
                        size: 14,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '+${item.distance}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.access_time,
                        color: Color(0xFFFF6B35),
                        size: 14,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${item.duration} min',
                        style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'D ${(item.currentPrice / 1000).toStringAsFixed(3)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6B35),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(item.oldPrice / 1000).toStringAsFixed(3)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
