import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/app/modules/search/views/search_view.dart';

import '../models/gift_voucher.dart';

class HomeController extends GetxController {
  // Observables
  late PageController pageController;
  late CarouselSliderController carouselController = CarouselSliderController();
  final isLoading = false.obs;
  final notificationCount = 0.obs;
  final cartItemCount = 0.obs;
  // Index de la page actuelle
  var currentPage = 0.obs;

  int currentIndex = 0;

  // Liste des images du carousel avec leurs données
  List<Map<String, String>> carouselImages = [
    {
      'image':
          'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
      'title': 'special_gaming_offer'.tr,
      'subtitle': 'save_up_to_50_percent'.tr,
      'actionText': 'shop_now'.tr,
    },
    {
      'image':
          'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
      'title': 'electronic_deals'.tr,
      'subtitle': 'latest_gadgets_best_prices'.tr,
      'actionText': 'explore'.tr,
    },
    {
      'image':
          'https://images.unsplash.com/photo-1542744173-8e7e53415bb0?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
      'title': 'fashion_sale'.tr,
      'subtitle': 'trendy_clothes_accessories'.tr,
      'actionText': 'discover'.tr,
    },
    {
      'image':
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
      'title': 'food_delivery'.tr,
      'subtitle': 'delicious_meals_your_door'.tr,
      'actionText': 'order_now'.tr,
    },
  ];

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();

    // Auto-scroll du carousel (optionnel)
    _startAutoScroll();
    loadGiftVouchers();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  // Méthode appelée quand la page change
  void onPageChanged(int index) {
    currentPage.value = index;
  }

  // Méthode appelée quand on tape sur une image du carousel
  void onCarouselTap(int index) {
    // Logique de navigation selon l'image tapée
    switch (index) {
      case 0:
        // Navigation vers gaming
        navigateToGaming();
        break;
      case 1:
        // Navigation vers electronics
        navigateToElectronics();
        break;
      case 2:
        // Navigation vers fashion
        navigateToFashion();
        break;
      case 3:
        // Navigation vers food
        navigateToFood();
        break;
    }
  }

  // Auto-scroll du carousel
  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (pageController.hasClients) {
        int nextPage = (currentPage.value + 1) % carouselImages.length;
        pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _startAutoScroll(); // Relancer le timer
      }
    });
  }

  // Méthodes de navigation existantes et nouvelles
  void navigateToSearch() {
    Get.to(() => SearchView());
  }

  void navigateToNotifications() {
    Get.toNamed('/notifications');
  }

  void navigateToCart() {
    Get.toNamed('/cart');
  }

  void navigateToOffers() {
    Get.toNamed('/offers');
  }

  void navigateToBills() {
    Get.toNamed('/bills');
  }

  void navigateToGaming() {
    Get.toNamed('/gaming');
  }

  void navigateToGiftVouchers() {
    Get.toNamed('/gift-vouchers');
  }

  // Nouvelles méthodes pour le carousel
  void navigateToElectronics() {
    Get.toNamed('/electronics');
  }

  void navigateToFashion() {
    Get.toNamed('/fashion');
  }

  void navigateToFood() {
    Get.toNamed('/food');
  }

  void onFavoriteToggle(int index) {
    // Logique pour gérer les favoris
    // Vous pouvez ajouter une liste observable des favoris
  }

  void onStoreAlertsBrowse() {
    // Navigation vers la liste des magasins
  }

  void onStoreAlertsEnable() {
    // Activer les alertes
  }

  void onPickAgain() {
    // Logique pour "Pick Again"
  }

  void onNearestForYou() {
    // Logique pour "Nearest for you"
  }

  void navigateToFavorites() {
    Get.toNamed('/favorites');
  }

  void navigateToFitness() {
    Get.toNamed('/fitness');
  }

  void navigateToEducation() {
    Get.toNamed('/education');
  }

  void navigateToEntertainment() {
    Get.toNamed('/entertainment');
  }

  void onSeeAllPressed(String section) {
    // Navigation basée sur la section
    switch (section) {
      case 'Top Categories':
        Get.toNamed('/categories');
        break;
      case 'Best Deals':
        Get.toNamed('/deals');
        break;
      case 'Recommended For You':
        Get.toNamed('/recommended');
        break;
      case 'Gaming Cards':
        Get.toNamed('/gaming');
        break;
      default:
        break;
    }
  }

  void navigateToNearestPlaces() {
    Get.toNamed('/nearest-places');
  }

  void navigateToFoodBeverage() {
    Get.toNamed('/food-beverage');
  }

  void navigateToFunActivities() {
    Get.toNamed('/fun-activities');
  }

  void navigateToShopping() {
    Get.toNamed('/shopping');
  }

  void navigateToTravel() {
    Get.toNamed('/travel');
  }

  void navigateToHealth() {
    Get.toNamed('/health-wellness');
  }

  List<Map<String, dynamic>> hotDeals = [
    {
      'id': '3',
      'title': 'Eastern El',
      'description': 'Pizza 4 season',
      'image':
          'https://images.unsplash.com/photo-1544551763-46a013bb70d5?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      'currentPrice': 120,
      'originalPrice': 240,
      'discount': 25,
      'rating': 4.5,
      'category': 'entertainment',
    },
    {
      'id': '4',
      'title': 'Spa & Wellness',
      'description': 'Relaxing spa treatments',
      'image':
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      'currentPrice': 299,
      'originalPrice': 450,
      'discount': 35,
      'rating': 4.9,
      'category': 'wellness',
    },
    {
      'id': '5',
      'title': 'Italian Restaurant',
      'description': 'Authentic cuisine',
      'image':
          'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      'currentPrice': 180,
      'originalPrice': 250,
      'discount': 28,
      'rating': 4.6,
      'category': 'food',
    },
    {
      'id': '6',
      'title': 'Adventure Park',
      'description': 'Thrilling outdoor activities',
      'image':
          'https://images.unsplash.com/photo-1453090927415-5f45085b65c0?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      'currentPrice': 320,
      'originalPrice': 400,
      'discount': 20,
      'rating': 4.4,
      'category': 'adventure',
    },
    {
      'id': '1',
      'title': 'Dream Park',
      'description': '29% off @Dream Park',
      'image':
          'https://images.unsplash.com/photo-1569973189506-82c9b96b8e30?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      'currentPrice': 265,
      'originalPrice': 375,
      'discount': 29,
      'rating': 4.8,
      'category': 'entertainment',
    },
    {
      'id': '2',
      'title': 'El Demeshky',
      'description': 'Syrian & Egyptian dishes',
      'image':
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      'currentPrice': 99,
      'originalPrice': 150,
      'discount': 37,
      'rating': 4.7,
      'category': 'food',
    },
  ];

  // Dans votre contrôleur, ajoutez des offres avec endTime
  List<Map<String, dynamic>> endingSoonDeals = [
    {
      'id': '1',
      'title': 'Mega Pizza Deal',
      'description': 'Large Pizza + 2 Sides',
      'image':
          'https://images.unsplash.com/photo-1513104890138-7c749659a591?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      'discount': 50,
      'currentPrice': 150,
      'originalPrice': 300,
      'endTime': DateTime.now().add(Duration(hours: 12, minutes: 30)),
      'isFavorite': false,
    },
    {
      'id': '2',
      'title': 'Sushi Combo',
      'description': '24 Pieces Mixed',
      'image':
          'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      'discount': 40,
      'currentPrice': 180,
      'originalPrice': 300,
      'endTime': DateTime.now().add(Duration(hours: 8, minutes: 45)),
      'isFavorite': false,
    },
    {
      'id': '3',
      'title': 'Burger Feast',
      'description': '2 Burgers + Fries',
      'image':
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      'discount': 45,
      'currentPrice': 110,
      'originalPrice': 200,
      'endTime': DateTime.now().add(Duration(hours: 18, minutes: 15)),
      'isFavorite': false,
    },
    {
      'id': '4',
      'title': 'Steak Dinner',
      'description': 'Premium Cut 300g',
      'image':
          'https://images.unsplash.com/photo-1558030006-450675393462?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      'discount': 35,
      'currentPrice': 390,
      'originalPrice': 600,
      'endTime': DateTime.now().add(Duration(hours: 6, minutes: 20)),
      'isFavorite': false,
    },
    {
      'id': '5',
      'title': 'Pasta Paradise',
      'description': 'Any Pasta + Drink',
      'image':
          'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      'discount': 30,
      'currentPrice': 140,
      'originalPrice': 200,
      'endTime': DateTime.now().add(Duration(hours: 15, minutes: 50)),
      'isFavorite': false,
    },
    {
      'id': '6',
      'title': 'Coffee & Cake',
      'description': 'Premium Dessert Set',
      'image':
          'https://images.unsplash.com/photo-1578985545062-69928b1d9587?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      'discount': 25,
      'currentPrice': 75,
      'originalPrice': 100,
      'endTime': DateTime.now().add(Duration(hours: 4, minutes: 10)),
      'isFavorite': false,
    },
    {
      'id': '7',
      'title': 'Seafood Platter',
      'description': 'Mixed Seafood Special',
      'image':
          'https://images.unsplash.com/photo-1559339352-11d035aa65de?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      'discount': 55,
      'currentPrice': 225,
      'originalPrice': 500,
      'endTime': DateTime.now().add(Duration(hours: 22, minutes: 40)),
      'isFavorite': false,
    },
  ];

  // Nouvelles méthodes pour Hot Deals
  void navigateToAllHotDeals() {
    Get.toNamed('/hot-deals');
  }

  void navigateToHotDeal(Map<String, dynamic> deal) {
    Get.toNamed('/deal-details', arguments: deal);
  }

  // Méthode pour filtrer les deals par catégorie
  List<Map<String, dynamic>> getHotDealsByCategory(String category) {
    return hotDeals.where((deal) => deal['category'] == category).toList();
  }

  // Méthode pour obtenir les deals les plus populaires
  List<Map<String, dynamic>> getTopRatedDeals() {
    var sortedDeals = List<Map<String, dynamic>>.from(hotDeals);
    sortedDeals.sort(
      (a, b) => (b['rating'] ?? 0.0).compareTo(a['rating'] ?? 0.0),
    );
    return sortedDeals.take(3).toList();
  }

  // Méthode pour obtenir les deals avec le plus de réduction
  List<Map<String, dynamic>> getBestDiscountDeals() {
    var sortedDeals = List<Map<String, dynamic>>.from(hotDeals);
    sortedDeals.sort(
      (a, b) => (b['discount'] ?? 0).compareTo(a['discount'] ?? 0),
    );
    return sortedDeals.take(3).toList();
  }

  // Méthode pour rafraîchir les deals (API call)
  Future<void> refreshHotDeals() async {
    // Simulation d'un appel API
    await Future.delayed(const Duration(seconds: 1));

    // Ici vous feriez appel à votre API
    // hotDeals = await ApiService.getHotDeals();

    update(); // Met à jour l'UI
  }

  // Méthode pour ajouter aux favoris
  void toggleFavorite(Map<String, dynamic> deal) {
    // Logic pour ajouter/supprimer des favoris
    // Vous pouvez utiliser une liste de favoris dans le controller
    // ou faire un appel API

    deal['isFavorite'] = !(deal['isFavorite'] ?? false);
    update();
  }

  // Méthode pour partager un deal
  void shareDeal(Map<String, dynamic> deal) {
    // Logic pour partager
    // Vous pouvez utiliser le package share_plus
    final String shareText = '''
Découvrez cette offre incroyable !
${deal['title']}
${deal['description']}
Prix: ${deal['currentPrice']} TN
Réduction: ${deal['discount']}%
''';

    // Share.share(shareText);
  }

  List<Map<String, dynamic>> outings = [
    {
      'id': '1',
      'title': 'Mall Of Egypt Offers',
      'subtitle': 'Shopping & Entertainment',
      'image':
          'https://images.unsplash.com/photo-1555529669-e69e7aa0ba9a?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      'category': 'Shopping',
      'location': 'New Cairo',
      'type': 'mall',
    },
    {
      'id': '2',
      'title': 'CFC Mall Offers',
      'subtitle': 'Family Fun & Dining',
      'image':
          'https://images.unsplash.com/photo-1519567241046-7f570eee3ce6?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      'category': 'Entertainment',
      'location': 'Sheikh Zayed',
      'type': 'mall',
    },
    {
      'id': '3',
      'title': 'City Center Almaza',
      'subtitle': 'Luxury Shopping',
      'image':
          'https://images.unsplash.com/photo-1441986300917-64674bd600d8?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      'category': 'Luxury',
      'location': 'Heliopolis',
      'type': 'mall',
    },
    {
      'id': '4',
      'title': 'Walk of Cairo',
      'subtitle': 'Outdoor Shopping Experience',
      'image':
          'https://images.unsplash.com/photo-1508739773434-c26b3d09e071?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      'category': 'Outdoor',
      'location': 'New Capital',
      'type': 'outdoor',
    },
    {
      'id': '5',
      'title': 'Festival City Mall',
      'subtitle': 'Complete Shopping Destination',
      'image':
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      'category': 'Shopping',
      'location': 'New Cairo',
      'type': 'mall',
    },
    {
      'id': '6',
      'title': 'Maadi Grand Mall',
      'subtitle': 'Local Shopping Hub',
      'image':
          'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      'category': 'Local',
      'location': 'Maadi',
      'type': 'mall',
    },
    {
      'id': '7',
      'title': 'Downtown Katameya',
      'subtitle': 'Modern Lifestyle Center',
      'image':
          'https://images.unsplash.com/photo-1567958451986-2de427a4a0be?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      'category': 'Modern',
      'location': 'New Cairo',
      'type': 'mall',
    },
    {
      'id': '8',
      'title': 'Dandy Mega Mall',
      'subtitle': 'Family Entertainment',
      'image':
          'https://images.unsplash.com/photo-1596178060810-4d3b0c750f2f?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      'category': 'Family',
      'location': 'Nasr City',
      'type': 'mall',
    },
    {
      'id': '9',
      'title': 'Citystars Mall',
      'subtitle': 'Iconic Shopping Experience',
      'image':
          'https://images.unsplash.com/photo-1528698827591-e19ccd7bc23d?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      'category': 'Premium',
      'location': 'Nasr City',
      'type': 'mall',
    },
    {
      'id': '10',
      'title': 'Arabella Plaza',
      'subtitle': 'Boutique Shopping',
      'image':
          'https://images.unsplash.com/photo-1534452203293-494d7ddbf7e0?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      'category': 'Boutique',
      'location': 'New Cairo',
      'type': 'plaza',
    },
    {
      'id': '11',
      'title': 'Point 90 Mall',
      'subtitle': 'Contemporary Shopping',
      'image':
          'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      'category': 'Contemporary',
      'location': 'New Cairo',
      'type': 'mall',
    },
    {
      'id': '12',
      'title': 'Galleria40 Mall',
      'subtitle': 'Dining & Lifestyle',
      'image':
          'https://images.unsplash.com/photo-1567449303183-1e36714d3e9d?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      'category': 'Lifestyle',
      'location': 'Sheikh Zayed',
      'type': 'mall',
    },
  ];

  // ... vos méthodes existantes ...

  // Nouvelles méthodes pour Outings
  void navigateToAllOutings() {
    Get.toNamed('/outings');
  }

  void navigateToOuting(Map<String, dynamic> outing) {
    Get.toNamed('/outing-details', arguments: outing);
  }

  // Méthode pour filtrer les outings par type
  List<Map<String, dynamic>> getOutingsByType(String type) {
    return outings.where((outing) => outing['type'] == type).toList();
  }

  // Méthode pour filtrer les outings par localisation
  List<Map<String, dynamic>> getOutingsByLocation(String location) {
    return outings.where((outing) => outing['location'] == location).toList();
  }

  // Méthode pour obtenir les malls populaires
  List<Map<String, dynamic>> getPopularMalls() {
    return outings.where((outing) => outing['type'] == 'mall').take(4).toList();
  }

  // Méthode pour obtenir les sorties outdoor
  List<Map<String, dynamic>> getOutdoorOutings() {
    return outings.where((outing) => outing['type'] == 'outdoor').toList();
  }

  // Méthode pour rafraîchir les outings (API call)
  Future<void> refreshOutings() async {
    // Simulation d'un appel API
    await Future.delayed(const Duration(seconds: 1));

    // Ici vous feriez appel à votre API
    // outings = await ApiService.getOutings();

    update(); // Met à jour l'UI
  }

  // Méthode pour rechercher des outings
  List<Map<String, dynamic>> searchOutings(String query) {
    if (query.isEmpty) return outings;

    return outings.where((outing) {
      final title = outing['title'].toString().toLowerCase();
      final subtitle = outing['subtitle'].toString().toLowerCase();
      final category = outing['category'].toString().toLowerCase();
      final location = outing['location'].toString().toLowerCase();
      final searchQuery = query.toLowerCase();

      return title.contains(searchQuery) ||
          subtitle.contains(searchQuery) ||
          category.contains(searchQuery) ||
          location.contains(searchQuery);
    }).toList();
  }

  // Méthode pour obtenir les outings par catégorie
  List<Map<String, dynamic>> getOutingsByCategory(String category) {
    return outings
        .where(
          (outing) =>
              outing['category'].toString().toLowerCase() ==
              category.toLowerCase(),
        )
        .toList();
  }

  // Méthode pour ajouter aux favoris
  void toggleOutingFavorite(Map<String, dynamic> outing) {
    outing['isFavorite'] = !(outing['isFavorite'] ?? false);
    update();
  }

  // Méthode pour partager un outing
  void shareOuting(Map<String, dynamic> outing) {
    final String shareText = '''
Découvrez cette sortie incroyable !
${outing['title']}
${outing['subtitle']}
Localisation: ${outing['location']}
Catégorie: ${outing['category']}
''';
  }

  // Méthode pour obtenir les recommendations
  List<Map<String, dynamic>> getRecommendedOutings() {
    // Logic pour recommander basé sur les préférences utilisateur
    return outings.take(3).toList();
  }

  List<Map<String, dynamic>> trendingMerchants = [
    {
      'id': '11',
      'name': 'Nestlé',
      'logo':
          'https://logos-world.net/wp-content/uploads/2020/09/Nestle-Logo.png',
      'category': 'Food',
      'brandColor': 0xFF991B1B, // Rouge foncé Nestlé
      'isTrending': false,
      'discountPercentage': 15,
    },
    {
      'id': '1',
      'name': 'Carrefour',
      'logo':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTOdP7dYdtDVHm7eDiHCdZaLxRpvw3HQAcFBg&s',
      'category': 'Shopping',
      'brandColor': 0xFF2563EB, // Bleu Carrefour
      'isTrending': true,
      'discountPercentage': 25,
    },
    {
      'id': '2',
      'name': 'McDonald\'s',
      'logo':
          "https://d1csarkz8obe9u.cloudfront.net/posterpreviews/mcdonald's-logo-design-template-c03c253e9d3c73bacdf4d3499e6a0b72_screen.jpg?ts=1738336858",
      'category': 'Food',
      'brandColor': 0xFFDC2626, // Rouge McDonald's
      'isTrending': true,
      'discountPercentage': 20,
    },
    {
      'id': '3',
      'name': 'Lidl',
      'logo':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/9/91/Lidl-Logo.svg/768px-Lidl-Logo.svg.png',
      'category': 'Shopping',
      'brandColor': 0xFF1E40AF, // Bleu Lidl
      'isTrending': true,
      'discountPercentage': 30,
    },
    {
      'id': '4',
      'name': 'Délice',
      'logo':
          'https://www.delice.com.tn/wp-content/uploads/2021/03/logo-delice.png',
      'category': 'Food',
      'brandColor': 0xFFEF4444, // Rouge Délice
      'isTrending': true,
      'discountPercentage': 15,
    },
    {
      'id': '5',
      'name': 'Danone',
      'logo':
          'https://logos-world.net/wp-content/uploads/2020/09/Danone-Logo.png',
      'category': 'Food',
      'brandColor': 0xFF3B82F6, // Bleu Danone
      'isTrending': true,
      'discountPercentage': 18,
    },
    {
      'id': '6',
      'name': 'KFC',
      'logo': 'https://logos-world.net/wp-content/uploads/2020/08/KFC-Logo.png',
      'category': 'Food',
      'brandColor': 0xFFDC2626, // Rouge KFC
      'isTrending': true,
      'discountPercentage': 22,
    },
    {
      'id': '7',
      'name': 'Pizza Hut',
      'logo':
          'https://logos-world.net/wp-content/uploads/2020/08/Pizza-Hut-Logo.png',
      'category': 'Food',
      'brandColor': 0xFFDC2626, // Rouge Pizza Hut
      'isTrending': false,
      'discountPercentage': 35,
    },
    {
      'id': '8',
      'name': 'Subway',
      'logo':
          'https://logos-world.net/wp-content/uploads/2020/08/Subway-Logo.png',
      'category': 'Food',
      'brandColor': 0xFF16A34A, // Vert Subway
      'isTrending': false,
      'discountPercentage': 12,
    },
    {
      'id': '9',
      'name': 'Starbucks',
      'logo':
          'https://logos-world.net/wp-content/uploads/2020/04/Starbucks-Logo.png',
      'category': 'Food',
      'brandColor': 0xFF059669, // Vert Starbucks
      'isTrending': true,
      'discountPercentage': 20,
    },
    {
      'id': '10',
      'name': 'Coca-Cola',
      'logo':
          'https://logos-world.net/wp-content/uploads/2020/09/Coca-Cola-Logo.png',
      'category': 'Food',
      'brandColor': 0xFFDC2626, // Rouge Coca-Cola
      'isTrending': false,
      'discountPercentage': 10,
    },

    {
      'id': '12',
      'name': 'Domino\'s',
      'logo':
          'https://logos-world.net/wp-content/uploads/2020/08/Dominos-Logo.png',
      'category': 'Food',
      'brandColor': 0xFF2563EB, // Bleu Domino's
      'isTrending': true,
      'discountPercentage': 40,
    },
  ];

  // Nouvelles méthodes pour Trending Merchants
  void navigateToMerchant(Map<String, dynamic> merchant) {
    Get.toNamed('/merchant-details', arguments: merchant);
  }

  void navigateToAllMerchants() {
    Get.toNamed('/all-merchants');
  }

  // Méthode pour filtrer les merchants par catégorie
  List<Map<String, dynamic>> getMerchantsByCategory(String category) {
    return trendingMerchants
        .where((merchant) => merchant['category'] == category)
        .toList();
  }

  // Méthode pour obtenir les merchants avec les meilleures réductions
  List<Map<String, dynamic>> getBestDiscountMerchants() {
    var sortedMerchants = List<Map<String, dynamic>>.from(trendingMerchants);
    sortedMerchants.sort(
      (a, b) => (b['discountPercentage'] ?? 0).compareTo(
        a['discountPercentage'] ?? 0,
      ),
    );
    return sortedMerchants.take(5).toList();
  }

  // Méthode pour obtenir les merchants trending seulement
  List<Map<String, dynamic>> getTrendingMerchantsOnly() {
    return trendingMerchants
        .where((merchant) => merchant['isTrending'] == true)
        .toList();
  }

  // Méthode pour rechercher des merchants
  List<Map<String, dynamic>> searchMerchants(String query) {
    if (query.isEmpty) return trendingMerchants;

    return trendingMerchants.where((merchant) {
      final name = merchant['name'].toString().toLowerCase();
      final category = merchant['category'].toString().toLowerCase();
      final searchQuery = query.toLowerCase();

      return name.contains(searchQuery) || category.contains(searchQuery);
    }).toList();
  }

  // Méthode pour ajouter aux favoris
  void toggleMerchantFavorite(Map<String, dynamic> merchant) {
    merchant['isFavorite'] = !(merchant['isFavorite'] ?? false);
    update();
  }

  // Méthode pour obtenir les merchants favoris
  List<Map<String, dynamic>> getFavoriteMerchants() {
    return trendingMerchants
        .where((merchant) => merchant['isFavorite'] == true)
        .toList();
  }

  // Méthode pour rafraîchir les merchants (API call)
  Future<void> refreshTrendingMerchants() async {
    // Simulation d'un appel API
    await Future.delayed(const Duration(seconds: 1));

    // Ici vous feriez appel à votre API
    // trendingMerchants = await ApiService.getTrendingMerchants();

    update(); // Met à jour l'UI
  }

  // Méthode pour obtenir les merchants par popularité
  List<Map<String, dynamic>> getPopularMerchants() {
    // Logic pour trier par popularité (nombre de vues, commandes, etc.)
    return trendingMerchants.take(6).toList();
  }

  // Méthode pour obtenir les nouveaux merchants
  List<Map<String, dynamic>> getNewMerchants() {
    // Logic pour obtenir les nouveaux merchants
    return trendingMerchants.reversed.take(4).toList();
  }

  // Méthode pour partager un merchant
  void shareMerchant(Map<String, dynamic> merchant) {
    final String shareText = '''
Découvrez ${merchant['name']} !
Catégorie: ${merchant['category']}
Réduction jusqu'à ${merchant['discountPercentage']}%
''';

    // Share.share(shareText);
  }

  List<Map<String, dynamic>> billServices = [
    {
      'id': '1',
      'name': 'Home\nInternet',
      'icon': Icons.router,
      'color': 0xFF059669, // Vert
      'type': 'internet',
    },
    {
      'id': '2',
      'name': 'Mobile Bills',
      'icon': Icons.smartphone,
      'color': 0xFF7C3AED, // Violet
      'type': 'mobile',
    },
    {
      'id': '3',
      'name': 'Electric Bills',
      'icon': Icons.lightbulb_outline,
      'color': 0xFFF59E0B, // Jaune/Orange
      'type': 'electricity',
    },
    {
      'id': '4',
      'name': 'Gas Bill',
      'icon': Icons.local_gas_station,
      'color': 0xFF64748B, // Gris
      'type': 'gas',
    },
    {
      'id': '5',
      'name': 'Donations',
      'icon': Icons.favorite,
      'color': 0xFFE11D48, // Rouge/Rose
      'type': 'donations',
    },
    {
      'id': '6',
      'name': 'Water Bills',
      'icon': Icons.water_drop,
      'color': 0xFF06B6D4, // Cyan
      'type': 'water',
    },
    {
      'id': '7',
      'name': 'TV/Cable',
      'icon': Icons.tv,
      'color': 0xFF8B5CF6, // Violet
      'type': 'tv',
    },
    {
      'id': '8',
      'name': 'Insurance',
      'icon': Icons.security,
      'color': 0xFF10B981, // Vert emeraude
      'type': 'insurance',
    },
    {
      'id': '9',
      'name': 'Education',
      'icon': Icons.school,
      'color': 0xFF3B82F6, // Bleu
      'type': 'education',
    },
    {
      'id': '10',
      'name': 'Government',
      'icon': Icons.account_balance,
      'color': 0xFF991B1B, // Rouge foncé
      'type': 'government',
    },
  ];

  // ... vos méthodes existantes ...

  // Nouvelles méthodes pour Bill Services
  void navigateToBillService(Map<String, dynamic> service) {
    Get.toNamed('/bill-service', arguments: service);
  }

  void navigateToAllBillServices() {
    Get.toNamed('/all-bill-services');
  }

  // Méthode pour filtrer les services par type
  List<Map<String, dynamic>> getBillServicesByType(String type) {
    return billServices.where((service) => service['type'] == type).toList();
  }

  // Méthode pour obtenir les services populaires
  List<Map<String, dynamic>> getPopularBillServices() {
    // Retourne les 5 premiers services (les plus utilisés)
    return billServices.take(5).toList();
  }

  // Méthode pour rechercher des services
  List<Map<String, dynamic>> searchBillServices(String query) {
    if (query.isEmpty) return billServices;

    return billServices.where((service) {
      final name = service['name'].toString().toLowerCase();
      final type = service['type'].toString().toLowerCase();
      final searchQuery = query.toLowerCase();

      return name.contains(searchQuery) || type.contains(searchQuery);
    }).toList();
  }

  // Méthode pour obtenir les services par catégorie
  Map<String, List<Map<String, dynamic>>> getBillServicesByCategory() {
    Map<String, List<Map<String, dynamic>>> categories = {
      'utilities': [],
      'communication': [],
      'entertainment': [],
      'financial': [],
      'others': [],
    };

    for (var service in billServices) {
      switch (service['type']) {
        case 'electricity':
        case 'gas':
        case 'water':
          categories['utilities']!.add(service);
          break;
        case 'mobile':
        case 'internet':
          categories['communication']!.add(service);
          break;
        case 'tv':
          categories['entertainment']!.add(service);
          break;
        case 'insurance':
          categories['financial']!.add(service);
          break;
        default:
          categories['others']!.add(service);
      }
    }

    return categories;
  }

  // Méthode pour ajouter aux favoris
  void toggleBillServiceFavorite(Map<String, dynamic> service) {
    service['isFavorite'] = !(service['isFavorite'] ?? false);
    update();
  }

  // Méthode pour obtenir les services favoris
  List<Map<String, dynamic>> getFavoriteBillServices() {
    return billServices
        .where((service) => service['isFavorite'] == true)
        .toList();
  }

  // Méthode pour rafraîchir les services (API call)
  Future<void> refreshBillServices() async {
    // Simulation d'un appel API
    await Future.delayed(const Duration(seconds: 1));

    // Ici vous feriez appel à votre API
    // billServices = await ApiService.getBillServices();

    update(); // Met à jour l'UI
  }

  // Méthode pour payer une facture
  void payBill(Map<String, dynamic> service, double amount) {
    // Logic pour le paiement
    // Redirection vers la page de paiement
    Get.toNamed(
      '/bill-payment',
      arguments: {'service': service, 'amount': amount},
    );
  }

  // Méthode pour consulter l'historique des factures
  void viewBillHistory(Map<String, dynamic> service) {
    Get.toNamed('/bill-history', arguments: service);
  }

  // Méthode pour configurer des rappels de factures
  void setBillReminder(Map<String, dynamic> service, DateTime dueDate) {
    // Logic pour configurer les notifications
    // Utilisation de packages comme flutter_local_notifications
    service['reminderDate'] = dueDate.toIso8601String();
    update();
  }

  // Méthode pour obtenir les factures en retard
  List<Map<String, dynamic>> getOverdueBills() {
    // Logic pour retourner les factures en retard
    return billServices.where((service) {
      final reminderDate = service['reminderDate'];
      if (reminderDate != null) {
        final dueDate = DateTime.parse(reminderDate);
        return dueDate.isBefore(DateTime.now());
      }
      return false;
    }).toList();
  }

  // Méthode pour calculer le total des factures du mois
  double getMonthlyBillsTotal() {
    // Logic pour calculer le total
    // Peut être basé sur des données réelles de l'utilisateur
    return 1250.0; // Exemple
  }

  List<Map<String, dynamic>> billTypes = [
    {
      'id': '1',
      'name': 'Internet',
      'imageUrl':
          'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
      'icon': Icons.wifi,
      'color': 0xFF059669, // Vert
      'type': 'internet',
      'count': 8,
    },
    {
      'id': '2',
      'name': 'Mobile',
      'imageUrl':
          'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
      'icon': Icons.smartphone,
      'color': 0xFF3B82F6, // Bleu
      'type': 'mobile',
      'count': 12,
    },
    {
      'id': '3',
      'name': 'Electric',
      'imageUrl':
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
      'icon': Icons.electrical_services,
      'color': 0xFFF59E0B, // Jaune
      'type': 'electricity',
      'count': 5,
    },
    {
      'id': '4',
      'name': 'Gas',
      'imageUrl':
          'https://images.unsplash.com/photo-1572949645841-094f3fd7dd65?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
      'icon': Icons.local_gas_station,
      'color': 0xFF64748B, // Gris
      'type': 'gas',
      'count': 3,
    },
    {
      'id': '5',
      'name': 'Water',
      'imageUrl':
          'https://images.unsplash.com/photo-1582268611958-ebfd161ef9cf?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
      'icon': Icons.water_drop,
      'color': 0xFF06B6D4, // Cyan
      'type': 'water',
      'count': 4,
    },
    {
      'id': '6',
      'name': 'TV/Cable',
      'imageUrl':
          'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
      'icon': Icons.tv,
      'color': 0xFF8B5CF6, // Violet
      'type': 'tv',
      'count': 6,
    },
    {
      'id': '7',
      'name': 'Insurance',
      'imageUrl':
          'https://images.unsplash.com/photo-1450101499163-c8848c66ca85?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
      'icon': Icons.security,
      'color': 0xFF10B981, // Vert émeraude
      'type': 'insurance',
      'count': 7,
    },
    {
      'id': '8',
      'name': 'Education',
      'imageUrl':
          'https://images.unsplash.com/photo-1427504494785-3a9ca7044f45?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
      'icon': Icons.school,
      'color': 0xFF2563EB, // Bleu foncé
      'type': 'education',
      'count': 9,
    },
    {
      'id': '9',
      'name': 'Government',
      'imageUrl':
          'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
      'icon': Icons.account_balance,
      'color': 0xFF991B1B, // Rouge foncé
      'type': 'government',
      'count': 15,
    },
    {
      'id': '10',
      'name': 'Banking',
      'imageUrl':
          'https://images.unsplash.com/photo-1556740758-90de374c12ad?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
      'icon': Icons.account_balance_wallet,
      'color': 0xFF7C3AED, // Violet foncé
      'type': 'banking',
      'count': 11,
    },
  ];

  // ... vos méthodes existantes ...

  // Nouvelles méthodes pour Bill Types
  void navigateToBillType(Map<String, dynamic> billType) {
    Get.toNamed('/bill-type', arguments: billType);
  }

  void navigateToAllBillTypes() {
    Get.toNamed('/all-bill-types');
  }

  // Méthode pour obtenir les types populaires
  List<Map<String, dynamic>> getPopularBillTypes() {
    var sortedTypes = List<Map<String, dynamic>>.from(billTypes);
    sortedTypes.sort((a, b) => (b['count'] ?? 0).compareTo(a['count'] ?? 0));
    return sortedTypes.take(6).toList();
  }

  // Méthode pour rechercher des types de factures
  List<Map<String, dynamic>> searchBillTypes(String query) {
    if (query.isEmpty) return billTypes;

    return billTypes.where((type) {
      final name = type['name'].toString().toLowerCase();
      final typeField = type['type'].toString().toLowerCase();
      final searchQuery = query.toLowerCase();

      return name.contains(searchQuery) || typeField.contains(searchQuery);
    }).toList();
  }

  // Méthode pour obtenir les types par catégorie
  Map<String, List<Map<String, dynamic>>> getBillTypesByCategory() {
    Map<String, List<Map<String, dynamic>>> categories = {
      'utilities': [],
      'communication': [],
      'entertainment': [],
      'financial': [],
      'others': [],
    };

    for (var type in billTypes) {
      switch (type['type']) {
        case 'electricity':
        case 'gas':
        case 'water':
          categories['utilities']!.add(type);
          break;
        case 'mobile':
        case 'internet':
          categories['communication']!.add(type);
          break;
        case 'tv':
          categories['entertainment']!.add(type);
          break;
        case 'banking':
        case 'insurance':
          categories['financial']!.add(type);
          break;
        default:
          categories['others']!.add(type);
      }
    }

    return categories;
  }

  // Méthode pour ajouter aux favoris
  void toggleBillTypeFavorite(Map<String, dynamic> billType) {
    billType['isFavorite'] = !(billType['isFavorite'] ?? false);
    update();
  }

  // Méthode pour obtenir les types favoris
  List<Map<String, dynamic>> getFavoriteBillTypes() {
    return billTypes.where((type) => type['isFavorite'] == true).toList();
  }

  // Méthode pour obtenir les statistiques
  Map<String, dynamic> getBillTypesStats() {
    int totalTypes = billTypes.length;
    int totalServices = billTypes.fold(0, (sum, type) => sum + (0));
    int popularThreshold = 10;
    int popularTypes =
        billTypes
            .where((type) => (type['count'] ?? 0) >= popularThreshold)
            .length;

    return {
      'totalTypes': totalTypes,
      'totalServices': totalServices,
      'popularTypes': popularTypes,
      'averageServices': totalServices / totalTypes,
    };
  }

  // Méthode pour rafraîchir les types (API call)
  Future<void> refreshBillTypes() async {
    // Simulation d'un appel API
    await Future.delayed(const Duration(seconds: 1));

    // Ici vous feriez appel à votre API
    // billTypes = await ApiService.getBillTypes();

    update(); // Met à jour l'UI
  }

  final giftVouchers = <GiftVoucher>[].obs;

  // Voucher sélectionné
  final selectedVoucher = Rx<GiftVoucher?>(null);

  // Montant sélectionné
  final selectedAmount = 0.obs;

  // Charger les gift vouchers
  Future<void> loadGiftVouchers() async {
    try {
      isLoading.value = true;

      // Simulation d'un appel API
      await Future.delayed(const Duration(seconds: 1));

      // Données exemple basées sur votre screenshot
      final vouchers = [
        GiftVoucher(
          id: '1',
          name: 'Carrefour',
          logoUrl: 'assets/carrefour_logo.png',
          minAmount: 200,
          maxAmount: 5000,
        ),
        GiftVoucher(
          id: '2',
          name: '2B',
          logoUrl: 'assets/2b_logo.png',
          minAmount: 500,
          maxAmount: 20000,
        ),
        GiftVoucher(
          id: '3',
          name: 'FiT&F',
          logoUrl: 'assets/fitf_logo.png',
          minAmount: 200,
          maxAmount: 1000,
        ),
      ];

      giftVouchers.value = vouchers;
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  // Sélectionner un voucher
  void selectVoucher(GiftVoucher voucher) {
    selectedVoucher.value = voucher;
    selectedAmount.value = voucher.minAmount;
  }

  // Mettre à jour le montant sélectionné
  void updateAmount(int amount) {
    if (selectedVoucher.value != null) {
      if (amount >= selectedVoucher.value!.minAmount &&
          amount <= selectedVoucher.value!.maxAmount) {
        selectedAmount.value = amount;
      } else {}
    }
  }

  // Acheter un gift voucher
  Future<void> purchaseVoucher() async {
    if (selectedVoucher.value == null) {
      return;
    }

    try {
      isLoading.value = true;

      // Simulation d'un achat
      await Future.delayed(const Duration(seconds: 2));

      // Réinitialiser la sélection
      selectedVoucher.value = null;
      selectedAmount.value = 0;
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  // Filtrer les vouchers par nom
  List<GiftVoucher> searchVouchers(String query) {
    if (query.isEmpty) return giftVouchers;
    return giftVouchers
        .where(
          (voucher) => voucher.name.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  // Réinitialiser la sélection
  void resetSelection() {
    selectedVoucher.value = null;
    selectedAmount.value = 0;
  }
}
