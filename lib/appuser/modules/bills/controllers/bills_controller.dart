import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/api_service.dart';
import '../views/widgets/product_detail_page.dart';
import '../views/widgets/product_list_page.dart';

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
  // Real active promotions from GET /content/promotions (same endpoint the
  // Home tab's hero banner uses) — this used to be 3 hardcoded stock photos
  // labeled "Special Offer 1/2/3, get amazing deals on your bills" with no
  // real offer behind them and no tap action at all.
  final RxList<Map<String, dynamic>> promoBanners = <Map<String, dynamic>>[].obs;

  Future<void> fetchPromoBanners() async {
    try {
      final response = await ApiService().get('/content/promotions');
      if (response.success && response.data is List) {
        promoBanners.assignAll((response.data as List).whereType<Map>().map((p) => Map<String, dynamic>.from(p)).take(5));
        _startAutoSlide();
      }
    } catch (_) {}
  }

  // Derived from the categories actually present in GET /content/products
  // (see _rebuildCategories), never hardcoded — a hardcoded list drifts the
  // moment the catalog changes, which is exactly what happened before: a
  // 'Food' chip was shown while no product had that category, so tapping it
  // opened a guaranteed-empty screen. Building the list from real data makes
  // an empty chip structurally impossible.
  static const Map<String, IconData> _categoryIcons = {
    'Photo': Icons.photo_library,
    'Course': Icons.school,
    'Ticket': Icons.local_activity,
    'E-book': Icons.menu_book,
    'Guide': Icons.book,
    'Food': Icons.fastfood,
  };

  final RxList<CategoryItem> categories = <CategoryItem>[].obs;

  void _rebuildCategories(List<ProductItem> products) {
    final seen = <String>[];
    for (final p in products) {
      final c = p.category.trim();
      if (c.isNotEmpty && !seen.contains(c)) seen.add(c);
    }
    categories.assignAll(
      seen.map((c) => CategoryItem(
            icon: _categoryIcons[c] ?? Icons.category,
            title: c,
            color: const Color(0xFFFF6B35),
          )),
    );
  }

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
    fetchPromoBanners();
    fetchProducts();
    fetchOrderHistory();
  }

  // This used to read /user/transactions — real wallet credit/debit
  // records (top-ups, rewards, gifts) — and mislabel every one of them as
  // a product order with a hardcoded "Mobil Card Type" tag regardless of
  // what actually happened. Real product purchase history lives on
  // Order documents, so this now matches what Profile's own order
  // history already correctly uses (/order/my-orders).
  Future<void> fetchOrderHistory() async {
    try {
      final response = await ApiService().get('/order/my-orders');
      if (response.success && response.data is List) {
        final List<dynamic> orderList = response.data;
        orders.value = orderList.map((o) {
          final items = (o['items'] as List?) ?? [];
          final itemNames = items
              .map((i) => (i['item_name'] ?? '').toString())
              .where((n) => n.isNotEmpty)
              .join(', ');
          // tryParse, not parse: one malformed createdAt on any single order
          // used to throw inside this .map(), which the outer try/catch
          // would swallow — silently blanking the *entire* order history
          // list instead of just that one order's date.
          final createdAt = o['createdAt'] != null ? DateTime.tryParse(o['createdAt'].toString()) : null;
          final merchant = o['merchantId'];
          final storeName = merchant is Map
              ? (merchant['storeName'] ?? merchant['fullName'] ?? 'VIPs Store').toString()
              : 'VIPs Store';
          final status = (o['status'] ?? 'pending').toString();
          return OrderItem(
            id: (o['_id'] ?? '').toString(),
            orderId: (o['orderNumber']?.toString() ?? (o['_id'] ?? '').toString()),
            type: _formatStatusLabel(status),
            day: createdAt != null ? createdAt.day.toString() : '--',
            month: createdAt != null ? _monthName(createdAt.month) : '--',
            cardType: itemNames.isNotEmpty ? itemNames : 'Order',
            price: '${((o['totalAmount'] ?? 0) as num).toDouble().toStringAsFixed(2)} TND',
            transId: (o['orderNumber']?.toString() ?? (o['_id'] ?? '').toString()),
            store: storeName,
            itemCount: items.length,
            rating: ((o['rating'] ?? 0) as num).toInt(),
            fullDate: createdAt != null ? createdAt.toString().substring(0, 16) : '',
          );
        }).toList();
        expandedOrders.value = List.generate(orders.length, (_) => false);
      }
    } catch (_) {}
  }

  // models/Order.js's real status enum is pending/confirmed/processing/ready/
  // handover/picked_up/delivered/cancelled/refund_requested/refunded — a
  // plain first-letter capitalize left the underscore visible for every
  // multi-word status ("Refund_requested", "Picked_up").
  String _formatStatusLabel(String raw) {
    switch (raw) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'processing':
        return 'Processing';
      case 'ready':
        return 'Ready';
      case 'handover':
        return 'Handover';
      case 'picked_up':
        return 'Picked Up';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
      case 'canceled':
        return 'Cancelled';
      case 'refund_requested':
        return 'Refund Requested';
      case 'refunded':
        return 'Refunded';
      default:
        return raw.isEmpty ? 'Pending' : raw[0].toUpperCase() + raw.substring(1);
    }
  }

  String _monthName(int month) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return month >= 1 && month <= 12 ? months[month - 1] : '--';
  }

  final RxBool hasLoadError = false.obs;

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      hasLoadError.value = false;
      final response = await ApiService().get('/content/products');
      if (response.success && response.data != null) {
        final List<dynamic> productsJson = response.data;
        final products = productsJson.map((json) {
          final merchant = json['merchantId'];
          return ProductItem(
            id: json['_id'] ?? '',
            title: json['name'] ?? '',
            category: json['category'] ?? '',
            price: (json['price'] as num?)?.toDouble() ?? 0.0,
            imageUrl: json['image'] ?? 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=300&h=200&fit=crop',
            description: (json['description'] ?? '').toString(),
            avgRating: (json['avgRating'] as num?)?.toDouble() ?? 0.0,
            reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
            sellCount: (json['salesCount'] as num?)?.toInt() ?? 0,
            merchantName: merchant is Map ? (merchant['storeName'] ?? merchant['fullName'])?.toString() : null,
            createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
          );
        }).toList();

        allProducts.assignAll(products);
        _rebuildCategories(products);

        // "Best Selling" / "Trending" reflect real category splits, not a
        // real sales ranking — GET /content/products doesn't support
        // sorting by salesCount server-side. Category grouping is the
        // real, verified-live signal available; sorting by the now-real
        // salesCount would need a backend change to add that as a sort
        // option, which is a reasonable follow-up but out of this pass.
        bestSellingProducts.assignAll(products.where((p) => p.category == 'Photo' || p.category == 'Course').take(6).toList());
        trendingProducts.assignAll(products.where((p) => p.category == 'E-book' || p.category == 'Ticket' || p.category == 'Course').take(9).toList());
        featureProducts.assignAll(products.take(6).toList());
      } else {
        allProducts.clear();
        bestSellingProducts.clear();
        trendingProducts.clear();
        featureProducts.clear();
        hasLoadError.value = true;
      }
    } catch (_) {
      allProducts.clear();
      categories.clear();
      bestSellingProducts.clear();
      trendingProducts.clear();
      featureProducts.clear();
      hasLoadError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void _startAutoSlide() {
    if (promoBanners.length <= 1) return;
    Future.delayed(const Duration(seconds: 3), () {
      _autoSlide();
    });
  }

  void _autoSlide() {
    if (pageController.hasClients && promoBanners.isNotEmpty) {
      currentIndex.value = (currentIndex.value + 1) % promoBanners.length;
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

  // selectedRole never changed from 'Customer' (the consumer app has no role
  // switcher), so the Vendor/Agent/Business branches of this colour switch
  // could never be reached — it always resolved to orange.
  Color get primaryColor => Colors.orange;

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
    // 'recharge' = prepaid airtime top-up (-> /mobile). 'mobile bills' is a
    // real seeded BillService (type: 'mobile', provider: Ooredoo) and
    // belongs on the bill-payment list like every other bill (-> /pay-bills)
    // — it used to match the 'mobile' check below and land on the wrong
    // screen (airtime top-up instead of the bill it's actually named for).
    if (name.contains('recharge')) {
      Get.toNamed('/mobile');
    } else if (name.contains('electric') || name.contains('water') ||
        name.contains('internet') || name.contains('adsl') ||
        name.contains('phone') || name.contains('land') ||
        name.contains('traffic') || name.contains('education') ||
        name.contains('health') || name.contains('construction') ||
        name.contains('mobile')) {
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
    Get.to(() => ProductListPage(title: categoryName, category: categoryName));
  }

  // onProductTap() duplicated what bills_view/product_list_page already do
  // directly (open ProductDetailPage); nothing called it.


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
  final String description;
  // Real values from GET /content/products — aggregated server-side from
  // actual Orders, not decorative placeholders.
  final double avgRating;
  final int reviewCount;
  final int sellCount;
  final String? merchantName;
  final DateTime? createdAt;

  ProductItem({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    this.createdAt,
    required this.imageUrl,
    this.description = '',
    this.avgRating = 0,
    this.reviewCount = 0,
    required this.sellCount,
    this.merchantName,
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
  final String id;
  final String orderId;
  final String type;
  final String day;
  final String month;
  final String cardType;
  final String price;
  final String transId;
  final String store;
  final int itemCount;
  final int rating;
  final String fullDate;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.type,
    required this.day,
    required this.month,
    required this.cardType,
    required this.price,
    required this.transId,
    required this.store,
    required this.itemCount,
    required this.rating,
    required this.fullDate,
  });
}
