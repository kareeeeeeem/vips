import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/api_service.dart';

class BillsController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentIndex = 0.obs;
  final RxString selectedFilter = 'Products'.obs;
  final RxBool isLoading = false.obs;

  // For History - Track which orders are expanded
  final RxList<bool> expandedOrders = <bool>[].obs;
  // Gestion des dates
  final Rx<DateTime> fromDate = DateTime.now().subtract(Duration(days: 30)).obs;
  final Rx<DateTime> toDate = DateTime.now().obs;
  // Images du carrousel
  final List<String> carouselImages = [
    'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400&h=200&fit=crop',
    'https://images.unsplash.com/photo-1486312338219-ce68d2c6f44d?w=400&h=200&fit=crop',
    'https://images.unsplash.com/photo-1563206767-5b18f218e8de?w=400&h=200&fit=crop',
  ];

  // Catégories pour Products
  final List<CategoryItem> categories = [
    CategoryItem(
      icon: Icons.photo_library,
      title: 'Photo',
      color: Color(0xFFFF6B35),
    ),
    CategoryItem(icon: Icons.school, title: 'Course', color: Color(0xFFFF6B35)),
    CategoryItem(
      icon: Icons.local_activity,
      title: 'Ticket',
      color: Color(0xFFFF6B35),
    ),
    CategoryItem(
      icon: Icons.menu_book,
      title: 'E-book',
      color: Color(0xFFFF6B35),
    ),
    CategoryItem(icon: Icons.book, title: 'Guide', color: Color(0xFFFF6B35)),
  ];

  // Dynamic Product Lists
  final RxList<ProductItem> bestSellingProducts = <ProductItem>[].obs;
  final RxList<ProductItem> trendingProducts = <ProductItem>[].obs;
  final RxList<ProductItem> featureProducts = <ProductItem>[].obs;
  final RxList<ProductItem> allProducts = <ProductItem>[].obs;

  // Services data (gardé pour la section Services)
  final List<ServiceItem> services = [
    ServiceItem(
      icon: Icons.videogame_asset,
      title: 'Gaming',
      color: Colors.blue,
      imageUrl:
          'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=200&h=200&fit=crop',
    ),
    ServiceItem(
      icon: Icons.credit_card,
      title: 'Monthly\nInstallments',
      color: Colors.orange,
      imageUrl:
          'https://images.unsplash.com/photo-1563013544-824ae1b704d3?w=200&h=200&fit=crop',
    ),
    ServiceItem(
      icon: Icons.phone_android,
      title: 'Recharge',
      color: Colors.green,
      imageUrl:
          'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=200&h=200&fit=crop',
    ),
    ServiceItem(
      icon: Icons.receipt_long,
      title: 'Mobile Bills',
      color: Colors.purple,
      imageUrl:
          'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=200&h=200&fit=crop',
    ),
    ServiceItem(
      icon: Icons.wifi,
      title: 'Home Internet\n(ADSL)',
      color: Colors.teal,
      imageUrl:
          'https://images.unsplash.com/photo-1606904825846-647eb07f5be2?w=200&h=200&fit=crop',
    ),
    ServiceItem(
      icon: Icons.flash_on,
      title: 'Electric Bill',
      color: Colors.yellow,
      imageUrl:
          'https://images.unsplash.com/photo-1473341304170-971dccb5ac1e?w=200&h=200&fit=crop',
    ),
    ServiceItem(
      icon: Icons.phone,
      title: 'Land line Bills',
      color: Colors.indigo,
      imageUrl:
          'https://images.unsplash.com/photo-1557672172-298e090bd0f1?w=200&h=200&fit=crop',
    ),
    ServiceItem(
      icon: Icons.traffic,
      title: 'Traffic Fines',
      color: Colors.red,
      imageUrl:
          'https://images.unsplash.com/photo-1449965408869-eaa3f722e40d?w=200&h=200&fit=crop',
    ),
    ServiceItem(
      icon: Icons.construction,
      title: 'Construction',
      color: Colors.grey,
      imageUrl:
          'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=200&h=200&fit=crop',
    ),
    ServiceItem(
      icon: Icons.school,
      title: 'Education',
      color: Colors.deepPurple,
      imageUrl:
          'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=200&h=200&fit=crop',
    ),
    ServiceItem(
      icon: Icons.water_drop,
      title: 'Water Bill',
      color: Colors.cyan,
      imageUrl:
          'https://images.unsplash.com/photo-1548839140-29a749e1cf4d?w=200&h=200&fit=crop',
    ),
    ServiceItem(
      icon: Icons.favorite,
      title: 'Health',
      color: Colors.pink,
      imageUrl:
          'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?w=200&h=200&fit=crop',
    ),
  ];

  // History orders data — populated from API in fetchOrderHistory()
  final RxList<OrderItem> orders = <OrderItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _startAutoSlide();
    fetchProducts();
    fetchOrderHistory();
  }

  Future<void> fetchOrderHistory() async {
    try {
      final response = await ApiService().get('/user/transactions', queryParams: {'limit': '20'});
      if (response.success && response.data != null) {
        final List<dynamic> txList = response.data['transactions'] ?? [];
        if (txList.isNotEmpty) {
          orders.value = txList.map((tx) => OrderItem(
            orderId: tx['reference'] ?? tx['_id'].toString().substring(0, 7),
            type: tx['type'] == 'credit' ? 'Credit' : 'Debit',
            day: tx['createdAt'] != null ? DateTime.parse(tx['createdAt']).day.toString() : '--',
            month: tx['createdAt'] != null ? _monthName(DateTime.parse(tx['createdAt']).month) : '--',
            cardType: tx['type'] ?? 'transaction',
            price: 'D ${((tx['amount'] ?? 0) as num).toDouble().toStringAsFixed(2)}',
            transId: tx['reference'] ?? tx['_id'].toString(),
            points: 'Vpt ${((tx['amount'] ?? 0) as num).toDouble().toStringAsFixed(2)}',
            serviceCharge: 'Vpt 0',
            fullDate: tx['createdAt'] != null ? DateTime.parse(tx['createdAt']).toString().substring(0, 16) : '',
          )).toList();
          expandedOrders.value = List.generate(orders.length, (_) => false);
        }
      }
    } catch (_) {}
  }

  String _monthName(int month) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return month >= 1 && month <= 12 ? months[month - 1] : '--';
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final response = await ApiService().get('/content/products');
      if (response.success && response.data != null) {
        final List<dynamic> productsJson = response.data;
        final products = productsJson.map((json) {
          return ProductItem(
            id: json['_id'] ?? '',
            title: json['name'] ?? '',
            category: json['category'] ?? '',
            price: (json['price'] as num?)?.toDouble() ?? 0.0,
            imageUrl: json['image'] ?? 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=300&h=200&fit=crop',
            rating: 5.0,
            sellCount: 0,
          );
        }).toList();

        allProducts.assignAll(products);

        // Populate categorized lists
        bestSellingProducts.assignAll(products.where((p) => p.category == 'Photo' || p.category == 'Course').take(6).toList());
        trendingProducts.assignAll(products.where((p) => p.category == 'E-book' || p.category == 'Ticket' || p.category == 'Course').take(9).toList());
        featureProducts.assignAll(products.take(6).toList());
      } else {
        _loadMockProducts();
      }
    } catch (_) {
      _loadMockProducts();
    } finally {
      isLoading.value = false;
    }
  }

  void _loadMockProducts() {
    allProducts.assignAll([
      ProductItem(
        id: '1',
        title: 'Saas Landing Software Theme',
        category: 'E-book',
        price: 50.0,
        imageUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=300&h=200&fit=crop',
        rating: 5.0,
        sellCount: 0,
      ),
      ProductItem(
        id: '2',
        title: 'Oifolio-Digital Marketing Theme',
        category: 'Photo',
        price: 60.0,
        imageUrl: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=300&h=200&fit=crop',
        rating: 5.0,
        sellCount: 0,
      ),
      ProductItem(
        id: '3',
        title: 'Minimoll - Fashion eCommerce Flutte...',
        category: 'Ticket',
        price: 27.0,
        imageUrl: 'https://images.unsplash.com/photo-1542744173-8e7e53415bb0?w=300&h=200&fit=crop',
        rating: 5.0,
        sellCount: 0,
      ),
      ProductItem(
        id: '4',
        title: 'FoodBari - Flutter Food Restaurant B...',
        category: 'Photo',
        price: 15.0,
        imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=300&h=200&fit=crop',
        rating: 5.0,
        sellCount: 0,
      ),
      ProductItem(
        id: '5',
        title: 'Single-Branch Restaurant Manag...',
        category: 'Course',
        price: 15.0,
        imageUrl: 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=300&h=200&fit=crop',
        rating: 5.0,
        sellCount: 0,
      ),
      ProductItem(
        id: '6',
        title: 'Apps Premium Landing Theme',
        category: 'E-book',
        price: 33.0,
        imageUrl: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=300&h=200&fit=crop',
        rating: 5.0,
        sellCount: 0,
      ),
    ]);

    bestSellingProducts.assignAll([
      ProductItem(
        id: '1',
        title: 'Saas Landing Software Theme',
        category: 'Photo',
        price: 50.0,
        imageUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=300&h=200&fit=crop',
        rating: 5.0,
        sellCount: 0,
      ),
      ProductItem(
        id: '2',
        title: 'Oifolio-Digital Marketing Them',
        category: 'Course',
        price: 60.0,
        imageUrl: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=300&h=200&fit=crop',
        rating: 5.0,
        sellCount: 0,
      ),
      ProductItem(
        id: '3',
        title: 'Minimoll - Fashion eCommerce',
        category: 'E-book',
        price: 27.0,
        imageUrl: 'https://images.unsplash.com/photo-1542744173-8e7e53415bb0?w=300&h=200&fit=crop',
        rating: 5.0,
        sellCount: 0,
      ),
      ProductItem(
        id: '4',
        title: 'FoodBari - Flutter Food Restaurant',
        category: 'Photo',
        price: 15.0,
        imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=300&h=200&fit=crop',
        rating: 5.0,
        sellCount: 0,
      ),
      ProductItem(
        id: '5',
        title: 'Apps Premium Landing Theme',
        category: 'Course',
        price: 33.0,
        imageUrl: 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=300&h=200&fit=crop',
        rating: 5.0,
        sellCount: 0,
      ),
      ProductItem(
        id: '6',
        title: 'Business Corporate Theme',
        category: 'Guide',
        price: 45.0,
        imageUrl: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=300&h=200&fit=crop',
        rating: 5.0,
        sellCount: 0,
      ),
    ]);

    trendingProducts.assignAll([
      ProductItem(
        id: '7',
        title: 'Saas Landing Software Theme',
        category: 'E-book',
        price: 50.0,
        imageUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=300&h=200&fit=crop',
        rating: 5.0,
        sellCount: 0,
      ),
      ProductItem(
        id: '8',
        title: 'Oifolio-Digital Marketing Theme',
        category: 'Ticket',
        price: 60.0,
        imageUrl: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=300&h=200&fit=crop',
        rating: 5.0,
        sellCount: 0,
      ),
      ProductItem(
        id: '9',
        title: 'Apps Premium Landing Theme',
        category: 'Course',
        price: 33.0,
        imageUrl: 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=300&h=200&fit=crop',
        rating: 5.0,
        sellCount: 0,
      ),
      ProductItem(
        id: '10',
        title: 'Minimoll - Fashion eCommerce',
        category: 'Photo',
        price: 27.0,
        imageUrl: 'https://images.unsplash.com/photo-1542744173-8e7e53415bb0?w=300&h=200&fit=crop',
        rating: 5.0,
        sellCount: 0,
      ),
      ProductItem(
        id: '11',
        title: 'FoodBari - Flutter Food',
        category: 'E-book',
        price: 15.0,
        imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=300&h=200&fit=crop',
        rating: 5.0,
        sellCount: 0,
      ),
      ProductItem(
        id: '12',
        title: 'Real Estate Property Theme',
        category: 'Guide',
        price: 55.0,
        imageUrl: 'https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=300&h=200&fit=crop',
        rating: 5.0,
        sellCount: 0,
      ),
      ProductItem(
        id: '13',
        title: 'Travel Booking Platform',
        category: 'Ticket',
        price: 42.0,
        imageUrl: 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=300&h=200&fit=crop',
        rating: 5.0,
        sellCount: 0,
      ),
      ProductItem(
        id: '14',
        title: 'Fitness App UI Kit',
        category: 'Course',
        price: 38.0,
        imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=300&h=200&fit=crop',
        rating: 5.0,
        sellCount: 0,
      ),
      ProductItem(
        id: '15',
        title: 'Music Streaming App',
        category: 'Photo',
        price: 48.0,
        imageUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=300&h=200&fit=crop',
        rating: 5.0,
        sellCount: 0,
      ),
    ]);

    featureProducts.assignAll([
      ProductItem(
        id: '16',
        title: 'Saas Landing Software Theme',
        category: 'E-book',
        price: 50.0,
        imageUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=300&h=200&fit=crop',
        rating: 5.0,
        sellCount: 0,
      ),
      ProductItem(
        id: '17',
        title: 'Oifolio-Digital Marketing Them',
        category: 'Photo',
        price: 60.0,
        imageUrl: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=300&h=200&fit=crop',
        rating: 5.0,
        sellCount: 0,
      ),
      ProductItem(
        id: '18',
        title: 'Portfolio Creative Theme',
        category: 'Course',
        price: 35.0,
        imageUrl: 'https://images.unsplash.com/photo-1467232004584-a241de8bcf5d?w=300&h=200&fit=crop',
        rating: 5.0,
        sellCount: 0,
      ),
      ProductItem(
        id: '19',
        title: 'Blog Magazine Theme',
        category: 'Guide',
        price: 29.0,
        imageUrl: 'https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=300&h=200&fit=crop',
        rating: 5.0,
        sellCount: 0,
      ),
      ProductItem(
        id: '20',
        title: 'E-Learning Platform',
        category: 'Ticket',
        price: 52.0,
        imageUrl: 'https://images.unsplash.com/photo-1501504905252-473c47e087f8?w=300&h=200&fit=crop',
        rating: 5.0,
        sellCount: 0,
      ),
      ProductItem(
        id: '21',
        title: 'Restaurant Management',
        category: 'E-book',
        price: 41.0,
        imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=300&h=200&fit=crop',
        rating: 5.0,
        sellCount: 0,
      ),
    ]);
  }

  void _startAutoSlide() {
    Future.delayed(const Duration(seconds: 3), () {
      _autoSlide();
    });
  }

  void _autoSlide() {
    if (pageController.hasClients) {
      currentIndex.value = (currentIndex.value + 1) % carouselImages.length;
      pageController.animateToPage(
        currentIndex.value,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      Future.delayed(const Duration(seconds: 4), () {
        _autoSlide();
      });
    }
  }

  final RxString selectedRole = 'Customer'.obs;

  Color get primaryColor {
    switch (selectedRole.value) {
      case 'Vendor':
        return Color(0xFFFFC107);

      case 'Agent':
        return Color(0xFF2196F3);

      case 'Business':
        return Colors.blue;
      case 'Customer':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  Future<void> selectDateRange() async {
    final picked = await showDateRangePicker(
      context: Get.context!,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: fromDate.value, end: toDate.value),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: primaryColor,
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: primaryColor),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      fromDate.value = picked.start;
      toDate.value = picked.end;
    }
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  void onServiceTap(String serviceName) {
    final name = serviceName.toLowerCase();
    if (name.contains('recharge') || name.contains('mobile')) {
      Get.toNamed('/mobile');
    } else if (name.contains('electric') || name.contains('water') ||
        name.contains('internet') || name.contains('adsl') ||
        name.contains('phone') || name.contains('land') ||
        name.contains('traffic') || name.contains('education') ||
        name.contains('health') || name.contains('construction')) {
      Get.toNamed('/pay-bills');
    } else if (name.contains('donation')) {
      Get.toNamed('/donation');
    } else if (name.contains('gaming') || name.contains('installment') ||
        name.contains('credit')) {
      Get.toNamed('/credit');
    } else {
      Get.toNamed('/pay-bills');
    }
  }

  void onCategoryTap(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('photo') || name.contains('ticket') ||
        name.contains('e-book') || name.contains('guide') ||
        name.contains('course')) {
      Get.toNamed('/hot-deals');
    } else {
      Get.toNamed('/pay-bills');
    }
  }

  void onProductTap(ProductItem product) {
    Get.toNamed('/deal-details', arguments: {'product': product});
  }

  void onFilterChanged(String filter) {
    selectedFilter.value = filter;
  }

  void toggleOrder(int index) {
    expandedOrders[index] = !expandedOrders[index];
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

// Nouvelle classe pour les catégories
class CategoryItem {
  final IconData icon;
  final String title;
  final Color color;

  CategoryItem({required this.icon, required this.title, required this.color});
}

// Nouvelle classe pour les produits
class ProductItem {
  final String id;
  final String title;
  final String category;
  final double price;
  final String imageUrl;
  final double rating;
  final int sellCount;

  ProductItem({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.sellCount,
  });
}

class ServiceItem {
  final IconData icon;
  final String title;
  final Color color;
  final String imageUrl;

  ServiceItem({
    required this.icon,
    required this.title,
    required this.color,
    required this.imageUrl,
  });
}

class OrderItem {
  final String orderId;
  final String type;
  final String day;
  final String month;
  final String cardType;
  final String price;
  final String transId;
  final String points;
  final String serviceCharge;
  final String fullDate;

  OrderItem({
    required this.orderId,
    required this.type,
    required this.day,
    required this.month,
    required this.cardType,
    required this.price,
    required this.transId,
    required this.points,
    required this.serviceCharge,
    required this.fullDate,
  });
}
