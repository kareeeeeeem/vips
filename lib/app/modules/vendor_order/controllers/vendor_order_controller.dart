import 'package:get/get.dart';

class VendorOrderController extends GetxController {
  // Couleur principale verte
  static const vendorGreen = 0xFF16A34A;

  // Observable states
  final _isLoading = false.obs;
  final _selectedStatusIndex = 0.obs;
  final _selectedOrderId = ''.obs;
  final _selectedFilterIndex = 0.obs; // Nouveau filtre

  // Getters
  bool get isLoading => _isLoading.value;
  int get selectedStatusIndex => _selectedStatusIndex.value;
  String get selectedOrderId => _selectedOrderId.value;
  int get selectedFilterIndex => _selectedFilterIndex.value;

  // Static counts
  final _todayOrderCount = 12.obs;
  final _thisWeekOrderCount = 45.obs;
  final _thisMonthOrderCount = 180.obs;

  int get todayOrderCount => _todayOrderCount.value;
  int get thisWeekOrderCount => _thisWeekOrderCount.value;
  int get thisMonthOrderCount => _thisMonthOrderCount.value;

  // Top level filters
  final List<String> topFilters = ['Active', 'Done', 'Refunded'];

  // Order statuses
  final List<String> orderStatuses = [
    'Pending',
    'Confirmed',
    'Processing',
    'Ready',
    'Delivered',
    'Cancelled',
  ];

  // Mock orders data
  final List<Map<String, dynamic>> allOrders = [
    {
      'id': '#100245',
      'customerName': 'John Doe',
      'customerPhone': '+1 234 567 8900',
      'customerImage': '',
      'items': 3,
      'amount': 45.50,
      'status': 'Pending',
      'orderType': 'Delivery',
      'paymentMethod': 'Cash on Delivery',
      'date': '18 Nov 2025',
      'time': '02:30 PM',
      'address': '123 Main St, New York, NY 10001',
      'orderNote': 'Please ring the doorbell',
      'refundStatus': 'none', // none, requested, approved
      'products': [
        {
          'name': 'Margherita Pizza',
          'quantity': 2,
          'price': 15.99,
          'addons': 'Extra Cheese',
          'image': '',
        },
        {
          'name': 'Caesar Salad',
          'quantity': 1,
          'price': 8.99,
          'addons': '',
          'image': '',
        },
      ],
    },
    {
      'id': '#100244',
      'customerName': 'Jane Smith',
      'customerPhone': '+1 234 567 8901',
      'customerImage': '',
      'items': 2,
      'amount': 32.00,
      'status': 'Confirmed',
      'orderType': 'Delivery',
      'paymentMethod': 'Card Payment',
      'date': '18 Nov 2025',
      'time': '01:45 PM',
      'address': '456 Oak Ave, Brooklyn, NY 11201',
      'orderNote': '',
      'refundStatus': 'none',
      'products': [
        {
          'name': 'Chicken Burger',
          'quantity': 2,
          'price': 12.99,
          'addons': 'Bacon',
          'image': '',
        },
      ],
    },
    {
      'id': '#100243',
      'customerName': 'Bob Johnson',
      'customerPhone': '+1 234 567 8902',
      'customerImage': '',
      'items': 5,
      'amount': 67.25,
      'status': 'Processing',
      'orderType': 'Takeaway',
      'paymentMethod': 'Cash on Delivery',
      'date': '18 Nov 2025',
      'time': '01:15 PM',
      'address': 'Pickup from store',
      'orderNote': 'Make it extra spicy',
      'refundStatus': 'none',
      'products': [
        {
          'name': 'Beef Tacos',
          'quantity': 3,
          'price': 9.99,
          'addons': 'Guacamole',
          'image': '',
        },
        {
          'name': 'Nachos',
          'quantity': 2,
          'price': 6.99,
          'addons': '',
          'image': '',
        },
      ],
    },
    {
      'id': '#100242',
      'customerName': 'Alice Brown',
      'customerPhone': '+1 234 567 8903',
      'customerImage': '',
      'items': 1,
      'amount': 18.50,
      'status': 'Ready',
      'orderType': 'Delivery',
      'paymentMethod': 'Wallet Payment',
      'date': '18 Nov 2025',
      'time': '12:30 PM',
      'address': '789 Pine Rd, Queens, NY 11354',
      'orderNote': '',
      'refundStatus': 'none',
      'products': [
        {
          'name': 'Pasta Carbonara',
          'quantity': 1,
          'price': 18.50,
          'addons': 'Extra Parmesan',
          'image': '',
        },
      ],
    },
    {
      'id': '#100241',
      'customerName': 'Charlie Wilson',
      'customerPhone': '+1 234 567 8904',
      'customerImage': '',
      'items': 4,
      'amount': 52.00,
      'status': 'Delivered',
      'orderType': 'Delivery',
      'paymentMethod': 'Card Payment',
      'date': '17 Nov 2025',
      'time': '07:20 PM',
      'address': '321 Elm St, Manhattan, NY 10002',
      'orderNote': '',
      'refundStatus': 'none',
      'products': [
        {
          'name': 'Sushi Roll Set',
          'quantity': 2,
          'price': 22.00,
          'addons': 'Wasabi, Ginger',
          'image': '',
        },
      ],
    },
    {
      'id': '#100240',
      'customerName': 'David Lee',
      'customerPhone': '+1 234 567 8905',
      'customerImage': '',
      'items': 2,
      'amount': 28.00,
      'status': 'Cancelled',
      'orderType': 'Delivery',
      'paymentMethod': 'Cash on Delivery',
      'date': '17 Nov 2025',
      'time': '06:45 PM',
      'address': '654 Maple Dr, Bronx, NY 10451',
      'orderNote': 'Customer cancelled',
      'refundStatus': 'approved',
      'products': [
        {
          'name': 'Fried Chicken',
          'quantity': 2,
          'price': 14.00,
          'addons': '',
          'image': '',
        },
      ],
    },
    {
      'id': '#100239',
      'customerName': 'Emma Davis',
      'customerPhone': '+1 234 567 8906',
      'customerImage': '',
      'items': 3,
      'amount': 42.00,
      'status': 'Delivered',
      'orderType': 'Delivery',
      'paymentMethod': 'Card Payment',
      'date': '16 Nov 2025',
      'time': '05:30 PM',
      'address': '987 Cedar Ln, Staten Island, NY 10301',
      'orderNote': '',
      'refundStatus': 'none',
      'products': [
        {
          'name': 'Pepperoni Pizza',
          'quantity': 3,
          'price': 14.00,
          'addons': '',
          'image': '',
        },
      ],
    },
    {
      'id': '#100238',
      'customerName': 'Michael Chen',
      'customerPhone': '+1 234 567 8907',
      'customerImage': '',
      'items': 2,
      'amount': 35.00,
      'status': 'Cancelled',
      'orderType': 'Delivery',
      'paymentMethod': 'Card Payment',
      'date': '16 Nov 2025',
      'time': '04:15 PM',
      'address': '246 Birch St, Manhattan, NY 10003',
      'orderNote': 'Refund requested',
      'refundStatus': 'requested',
      'products': [
        {
          'name': 'Grilled Salmon',
          'quantity': 2,
          'price': 17.50,
          'addons': 'Lemon sauce',
          'image': '',
        },
      ],
    },
    {
      'id': '#100242',
      'customerName': 'Alice Brown',
      'customerPhone': '+1 234 567 8903',
      'customerImage': '',
      'items': 1,
      'amount': 18.50,
      'status': 'Ready',
      'orderType': 'Delivery',
      'paymentMethod': 'Wallet Payment',
      'date': '18 Nov 2025',
      'time': '12:30 PM',
      'address': '789 Pine Rd, Queens, NY 11354',
      'orderNote': '',
      'refundStatus': 'none',
      'products': [
        {
          'name': 'Pasta Carbonara',
          'quantity': 1,
          'price': 18.50,
          'addons': 'Extra Parmesan',
          'image': '',
        },
      ],
    },
    {
      'id': '#100241',
      'customerName': 'Charlie Wilson',
      'customerPhone': '+1 234 567 8904',
      'customerImage': '',
      'items': 4,
      'amount': 52.00,
      'status': 'Delivered',
      'orderType': 'Delivery',
      'paymentMethod': 'Card Payment',
      'date': '17 Nov 2025',
      'time': '07:20 PM',
      'address': '321 Elm St, Manhattan, NY 10002',
      'orderNote': '',
      'refundStatus': 'none',
      'products': [
        {
          'name': 'Sushi Roll Set',
          'quantity': 2,
          'price': 22.00,
          'addons': 'Wasabi, Ginger',
          'image': '',
        },
      ],
    },
    {
      'id': '#100240',
      'customerName': 'David Lee',
      'customerPhone': '+1 234 567 8905',
      'customerImage': '',
      'items': 2,
      'amount': 28.00,
      'status': 'Cancelled',
      'orderType': 'Delivery',
      'paymentMethod': 'Cash on Delivery',
      'date': '17 Nov 2025',
      'time': '06:45 PM',
      'address': '654 Maple Dr, Bronx, NY 10451',
      'orderNote': 'Customer cancelled',
      'refundStatus': 'approved',
      'products': [
        {
          'name': 'Fried Chicken',
          'quantity': 2,
          'price': 14.00,
          'addons': '',
          'image': '',
        },
      ],
    },
    {
      'id': '#100239',
      'customerName': 'Emma Davis',
      'customerPhone': '+1 234 567 8906',
      'customerImage': '',
      'items': 3,
      'amount': 42.00,
      'status': 'Delivered',
      'orderType': 'Delivery',
      'paymentMethod': 'Card Payment',
      'date': '16 Nov 2025',
      'time': '05:30 PM',
      'address': '987 Cedar Ln, Staten Island, NY 10301',
      'orderNote': '',
      'refundStatus': 'none',
      'products': [
        {
          'name': 'Pepperoni Pizza',
          'quantity': 3,
          'price': 14.00,
          'addons': '',
          'image': '',
        },
      ],
    },
    {
      'id': '#100238',
      'customerName': 'Michael Chen',
      'customerPhone': '+1 234 567 8907',
      'customerImage': '',
      'items': 2,
      'amount': 35.00,
      'status': 'Cancelled',
      'orderType': 'Delivery',
      'paymentMethod': 'Card Payment',
      'date': '16 Nov 2025',
      'time': '04:15 PM',
      'address': '246 Birch St, Manhattan, NY 10003',
      'orderNote': 'Refund requested',
      'refundStatus': 'requested',
      'products': [
        {
          'name': 'Grilled Salmon',
          'quantity': 2,
          'price': 17.50,
          'addons': 'Lemon sauce',
          'image': '',
        },
      ],
    },
    {
      'id': '#100242',
      'customerName': 'Alice Brown',
      'customerPhone': '+1 234 567 8903',
      'customerImage': '',
      'items': 1,
      'amount': 18.50,
      'status': 'Ready',
      'orderType': 'Delivery',
      'paymentMethod': 'Wallet Payment',
      'date': '18 Nov 2025',
      'time': '12:30 PM',
      'address': '789 Pine Rd, Queens, NY 11354',
      'orderNote': '',
      'refundStatus': 'none',
      'products': [
        {
          'name': 'Pasta Carbonara',
          'quantity': 1,
          'price': 18.50,
          'addons': 'Extra Parmesan',
          'image': '',
        },
      ],
    },
    {
      'id': '#100241',
      'customerName': 'Charlie Wilson',
      'customerPhone': '+1 234 567 8904',
      'customerImage': '',
      'items': 4,
      'amount': 52.00,
      'status': 'Delivered',
      'orderType': 'Delivery',
      'paymentMethod': 'Card Payment',
      'date': '17 Nov 2025',
      'time': '07:20 PM',
      'address': '321 Elm St, Manhattan, NY 10002',
      'orderNote': '',
      'refundStatus': 'none',
      'products': [
        {
          'name': 'Sushi Roll Set',
          'quantity': 2,
          'price': 22.00,
          'addons': 'Wasabi, Ginger',
          'image': '',
        },
      ],
    },
    {
      'id': '#100240',
      'customerName': 'David Lee',
      'customerPhone': '+1 234 567 8905',
      'customerImage': '',
      'items': 2,
      'amount': 28.00,
      'status': 'Cancelled',
      'orderType': 'Delivery',
      'paymentMethod': 'Cash on Delivery',
      'date': '17 Nov 2025',
      'time': '06:45 PM',
      'address': '654 Maple Dr, Bronx, NY 10451',
      'orderNote': 'Customer cancelled',
      'refundStatus': 'approved',
      'products': [
        {
          'name': 'Fried Chicken',
          'quantity': 2,
          'price': 14.00,
          'addons': '',
          'image': '',
        },
      ],
    },
    {
      'id': '#100239',
      'customerName': 'Emma Davis',
      'customerPhone': '+1 234 567 8906',
      'customerImage': '',
      'items': 3,
      'amount': 42.00,
      'status': 'Delivered',
      'orderType': 'Delivery',
      'paymentMethod': 'Card Payment',
      'date': '16 Nov 2025',
      'time': '05:30 PM',
      'address': '987 Cedar Ln, Staten Island, NY 10301',
      'orderNote': '',
      'refundStatus': 'none',
      'products': [
        {
          'name': 'Pepperoni Pizza',
          'quantity': 3,
          'price': 14.00,
          'addons': '',
          'image': '',
        },
      ],
    },
    {
      'id': '#100238',
      'customerName': 'Michael Chen',
      'customerPhone': '+1 234 567 8907',
      'customerImage': '',
      'items': 2,
      'amount': 35.00,
      'status': 'Cancelled',
      'orderType': 'Delivery',
      'paymentMethod': 'Card Payment',
      'date': '16 Nov 2025',
      'time': '04:15 PM',
      'address': '246 Birch St, Manhattan, NY 10003',
      'orderNote': 'Refund requested',
      'refundStatus': 'requested',
      'products': [
        {
          'name': 'Grilled Salmon',
          'quantity': 2,
          'price': 17.50,
          'addons': 'Lemon sauce',
          'image': '',
        },
      ],
    },
    {
      'id': '#100242',
      'customerName': 'Alice Brown',
      'customerPhone': '+1 234 567 8903',
      'customerImage': '',
      'items': 1,
      'amount': 18.50,
      'status': 'Ready',
      'orderType': 'Delivery',
      'paymentMethod': 'Wallet Payment',
      'date': '18 Nov 2025',
      'time': '12:30 PM',
      'address': '789 Pine Rd, Queens, NY 11354',
      'orderNote': '',
      'refundStatus': 'none',
      'products': [
        {
          'name': 'Pasta Carbonara',
          'quantity': 1,
          'price': 18.50,
          'addons': 'Extra Parmesan',
          'image': '',
        },
      ],
    },
    {
      'id': '#100241',
      'customerName': 'Charlie Wilson',
      'customerPhone': '+1 234 567 8904',
      'customerImage': '',
      'items': 4,
      'amount': 52.00,
      'status': 'Delivered',
      'orderType': 'Delivery',
      'paymentMethod': 'Card Payment',
      'date': '17 Nov 2025',
      'time': '07:20 PM',
      'address': '321 Elm St, Manhattan, NY 10002',
      'orderNote': '',
      'refundStatus': 'none',
      'products': [
        {
          'name': 'Sushi Roll Set',
          'quantity': 2,
          'price': 22.00,
          'addons': 'Wasabi, Ginger',
          'image': '',
        },
      ],
    },
    {
      'id': '#100240',
      'customerName': 'David Lee',
      'customerPhone': '+1 234 567 8905',
      'customerImage': '',
      'items': 2,
      'amount': 28.00,
      'status': 'Cancelled',
      'orderType': 'Delivery',
      'paymentMethod': 'Cash on Delivery',
      'date': '17 Nov 2025',
      'time': '06:45 PM',
      'address': '654 Maple Dr, Bronx, NY 10451',
      'orderNote': 'Customer cancelled',
      'refundStatus': 'approved',
      'products': [
        {
          'name': 'Fried Chicken',
          'quantity': 2,
          'price': 14.00,
          'addons': '',
          'image': '',
        },
      ],
    },
    {
      'id': '#100239',
      'customerName': 'Emma Davis',
      'customerPhone': '+1 234 567 8906',
      'customerImage': '',
      'items': 3,
      'amount': 42.00,
      'status': 'Delivered',
      'orderType': 'Delivery',
      'paymentMethod': 'Card Payment',
      'date': '16 Nov 2025',
      'time': '05:30 PM',
      'address': '987 Cedar Ln, Staten Island, NY 10301',
      'orderNote': '',
      'refundStatus': 'none',
      'products': [
        {
          'name': 'Pepperoni Pizza',
          'quantity': 3,
          'price': 14.00,
          'addons': '',
          'image': '',
        },
      ],
    },
    {
      'id': '#100238',
      'customerName': 'Michael Chen',
      'customerPhone': '+1 234 567 8907',
      'customerImage': '',
      'items': 2,
      'amount': 35.00,
      'status': 'Cancelled',
      'orderType': 'Delivery',
      'paymentMethod': 'Card Payment',
      'date': '16 Nov 2025',
      'time': '04:15 PM',
      'address': '246 Birch St, Manhattan, NY 10003',
      'orderNote': 'Refund requested',
      'refundStatus': 'requested',
      'products': [
        {
          'name': 'Grilled Salmon',
          'quantity': 2,
          'price': 17.50,
          'addons': 'Lemon sauce',
          'image': '',
        },
      ],
    },
    {
      'id': '#100242',
      'customerName': 'Alice Brown',
      'customerPhone': '+1 234 567 8903',
      'customerImage': '',
      'items': 1,
      'amount': 18.50,
      'status': 'Ready',
      'orderType': 'Delivery',
      'paymentMethod': 'Wallet Payment',
      'date': '18 Nov 2025',
      'time': '12:30 PM',
      'address': '789 Pine Rd, Queens, NY 11354',
      'orderNote': '',
      'refundStatus': 'none',
      'products': [
        {
          'name': 'Pasta Carbonara',
          'quantity': 1,
          'price': 18.50,
          'addons': 'Extra Parmesan',
          'image': '',
        },
      ],
    },
    {
      'id': '#100241',
      'customerName': 'Charlie Wilson',
      'customerPhone': '+1 234 567 8904',
      'customerImage': '',
      'items': 4,
      'amount': 52.00,
      'status': 'Delivered',
      'orderType': 'Delivery',
      'paymentMethod': 'Card Payment',
      'date': '17 Nov 2025',
      'time': '07:20 PM',
      'address': '321 Elm St, Manhattan, NY 10002',
      'orderNote': '',
      'refundStatus': 'none',
      'products': [
        {
          'name': 'Sushi Roll Set',
          'quantity': 2,
          'price': 22.00,
          'addons': 'Wasabi, Ginger',
          'image': '',
        },
      ],
    },
    {
      'id': '#100240',
      'customerName': 'David Lee',
      'customerPhone': '+1 234 567 8905',
      'customerImage': '',
      'items': 2,
      'amount': 28.00,
      'status': 'Cancelled',
      'orderType': 'Delivery',
      'paymentMethod': 'Cash on Delivery',
      'date': '17 Nov 2025',
      'time': '06:45 PM',
      'address': '654 Maple Dr, Bronx, NY 10451',
      'orderNote': 'Customer cancelled',
      'refundStatus': 'approved',
      'products': [
        {
          'name': 'Fried Chicken',
          'quantity': 2,
          'price': 14.00,
          'addons': '',
          'image': '',
        },
      ],
    },
    {
      'id': '#100239',
      'customerName': 'Emma Davis',
      'customerPhone': '+1 234 567 8906',
      'customerImage': '',
      'items': 3,
      'amount': 42.00,
      'status': 'Delivered',
      'orderType': 'Delivery',
      'paymentMethod': 'Card Payment',
      'date': '16 Nov 2025',
      'time': '05:30 PM',
      'address': '987 Cedar Ln, Staten Island, NY 10301',
      'orderNote': '',
      'refundStatus': 'none',
      'products': [
        {
          'name': 'Pepperoni Pizza',
          'quantity': 3,
          'price': 14.00,
          'addons': '',
          'image': '',
        },
      ],
    },
    {
      'id': '#100238',
      'customerName': 'Michael Chen',
      'customerPhone': '+1 234 567 8907',
      'customerImage': '',
      'items': 2,
      'amount': 35.00,
      'status': 'Cancelled',
      'orderType': 'Delivery',
      'paymentMethod': 'Card Payment',
      'date': '16 Nov 2025',
      'time': '04:15 PM',
      'address': '246 Birch St, Manhattan, NY 10003',
      'orderNote': 'Refund requested',
      'refundStatus': 'requested',
      'products': [
        {
          'name': 'Grilled Salmon',
          'quantity': 2,
          'price': 17.50,
          'addons': 'Lemon sauce',
          'image': '',
        },
      ],
    },
    {
      'id': '#100242',
      'customerName': 'Alice Brown',
      'customerPhone': '+1 234 567 8903',
      'customerImage': '',
      'items': 1,
      'amount': 18.50,
      'status': 'Ready',
      'orderType': 'Delivery',
      'paymentMethod': 'Wallet Payment',
      'date': '18 Nov 2025',
      'time': '12:30 PM',
      'address': '789 Pine Rd, Queens, NY 11354',
      'orderNote': '',
      'refundStatus': 'none',
      'products': [
        {
          'name': 'Pasta Carbonara',
          'quantity': 1,
          'price': 18.50,
          'addons': 'Extra Parmesan',
          'image': '',
        },
      ],
    },
    {
      'id': '#100241',
      'customerName': 'Charlie Wilson',
      'customerPhone': '+1 234 567 8904',
      'customerImage': '',
      'items': 4,
      'amount': 52.00,
      'status': 'Delivered',
      'orderType': 'Delivery',
      'paymentMethod': 'Card Payment',
      'date': '17 Nov 2025',
      'time': '07:20 PM',
      'address': '321 Elm St, Manhattan, NY 10002',
      'orderNote': '',
      'refundStatus': 'none',
      'products': [
        {
          'name': 'Sushi Roll Set',
          'quantity': 2,
          'price': 22.00,
          'addons': 'Wasabi, Ginger',
          'image': '',
        },
      ],
    },
    {
      'id': '#100240',
      'customerName': 'David Lee',
      'customerPhone': '+1 234 567 8905',
      'customerImage': '',
      'items': 2,
      'amount': 28.00,
      'status': 'Cancelled',
      'orderType': 'Delivery',
      'paymentMethod': 'Cash on Delivery',
      'date': '17 Nov 2025',
      'time': '06:45 PM',
      'address': '654 Maple Dr, Bronx, NY 10451',
      'orderNote': 'Customer cancelled',
      'refundStatus': 'approved',
      'products': [
        {
          'name': 'Fried Chicken',
          'quantity': 2,
          'price': 14.00,
          'addons': '',
          'image': '',
        },
      ],
    },
    {
      'id': '#100239',
      'customerName': 'Emma Davis',
      'customerPhone': '+1 234 567 8906',
      'customerImage': '',
      'items': 3,
      'amount': 42.00,
      'status': 'Delivered',
      'orderType': 'Delivery',
      'paymentMethod': 'Card Payment',
      'date': '16 Nov 2025',
      'time': '05:30 PM',
      'address': '987 Cedar Ln, Staten Island, NY 10301',
      'orderNote': '',
      'refundStatus': 'none',
      'products': [
        {
          'name': 'Pepperoni Pizza',
          'quantity': 3,
          'price': 14.00,
          'addons': '',
          'image': '',
        },
      ],
    },
    {
      'id': '#100238',
      'customerName': 'Michael Chen',
      'customerPhone': '+1 234 567 8907',
      'customerImage': '',
      'items': 2,
      'amount': 35.00,
      'status': 'Cancelled',
      'orderType': 'Delivery',
      'paymentMethod': 'Card Payment',
      'date': '16 Nov 2025',
      'time': '04:15 PM',
      'address': '246 Birch St, Manhattan, NY 10003',
      'orderNote': 'Refund requested',
      'refundStatus': 'requested',
      'products': [
        {
          'name': 'Grilled Salmon',
          'quantity': 2,
          'price': 17.50,
          'addons': 'Lemon sauce',
          'image': '',
        },
      ],
    },
    {
      'id': '#100242',
      'customerName': 'Alice Brown',
      'customerPhone': '+1 234 567 8903',
      'customerImage': '',
      'items': 1,
      'amount': 18.50,
      'status': 'Ready',
      'orderType': 'Delivery',
      'paymentMethod': 'Wallet Payment',
      'date': '18 Nov 2025',
      'time': '12:30 PM',
      'address': '789 Pine Rd, Queens, NY 11354',
      'orderNote': '',
      'refundStatus': 'none',
      'products': [
        {
          'name': 'Pasta Carbonara',
          'quantity': 1,
          'price': 18.50,
          'addons': 'Extra Parmesan',
          'image': '',
        },
      ],
    },
    {
      'id': '#100241',
      'customerName': 'Charlie Wilson',
      'customerPhone': '+1 234 567 8904',
      'customerImage': '',
      'items': 4,
      'amount': 52.00,
      'status': 'Delivered',
      'orderType': 'Delivery',
      'paymentMethod': 'Card Payment',
      'date': '17 Nov 2025',
      'time': '07:20 PM',
      'address': '321 Elm St, Manhattan, NY 10002',
      'orderNote': '',
      'refundStatus': 'none',
      'products': [
        {
          'name': 'Sushi Roll Set',
          'quantity': 2,
          'price': 22.00,
          'addons': 'Wasabi, Ginger',
          'image': '',
        },
      ],
    },
    {
      'id': '#100240',
      'customerName': 'David Lee',
      'customerPhone': '+1 234 567 8905',
      'customerImage': '',
      'items': 2,
      'amount': 28.00,
      'status': 'Cancelled',
      'orderType': 'Delivery',
      'paymentMethod': 'Cash on Delivery',
      'date': '17 Nov 2025',
      'time': '06:45 PM',
      'address': '654 Maple Dr, Bronx, NY 10451',
      'orderNote': 'Customer cancelled',
      'refundStatus': 'approved',
      'products': [
        {
          'name': 'Fried Chicken',
          'quantity': 2,
          'price': 14.00,
          'addons': '',
          'image': '',
        },
      ],
    },
    {
      'id': '#100239',
      'customerName': 'Emma Davis',
      'customerPhone': '+1 234 567 8906',
      'customerImage': '',
      'items': 3,
      'amount': 42.00,
      'status': 'Delivered',
      'orderType': 'Delivery',
      'paymentMethod': 'Card Payment',
      'date': '16 Nov 2025',
      'time': '05:30 PM',
      'address': '987 Cedar Ln, Staten Island, NY 10301',
      'orderNote': '',
      'refundStatus': 'none',
      'products': [
        {
          'name': 'Pepperoni Pizza',
          'quantity': 3,
          'price': 14.00,
          'addons': '',
          'image': '',
        },
      ],
    },
    {
      'id': '#100238',
      'customerName': 'Michael Chen',
      'customerPhone': '+1 234 567 8907',
      'customerImage': '',
      'items': 2,
      'amount': 35.00,
      'status': 'Cancelled',
      'orderType': 'Delivery',
      'paymentMethod': 'Card Payment',
      'date': '16 Nov 2025',
      'time': '04:15 PM',
      'address': '246 Birch St, Manhattan, NY 10003',
      'orderNote': 'Refund requested',
      'refundStatus': 'requested',
      'products': [
        {
          'name': 'Grilled Salmon',
          'quantity': 2,
          'price': 17.50,
          'addons': 'Lemon sauce',
          'image': '',
        },
      ],
    },
  ];

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    _isLoading.value = true;

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    _isLoading.value = false;
  }

  void setStatusIndex(int index) {
    _selectedStatusIndex.value = index;
    update();
  }

  void setFilterIndex(int index) {
    _selectedFilterIndex.value = index;
    // Reset status filter when changing top filter
    _selectedStatusIndex.value = 0;
  }

  void selectOrder(String orderId) {
    _selectedOrderId.value = orderId;
  }

  List<Map<String, dynamic>> getFilteredOrders() {
    List<Map<String, dynamic>> filtered = [];

    // First, filter by top level filter (Active/Done/Refunded)
    switch (_selectedFilterIndex.value) {
      case 0: // Active
        filtered =
            allOrders
                .where(
                  (order) =>
                      order['status'] != 'Delivered' &&
                      order['status'] != 'Cancelled' &&
                      order['refundStatus'] != 'approved',
                )
                .toList();
        break;
      case 1: // Done
        filtered =
            allOrders
                .where(
                  (order) =>
                      order['status'] == 'Delivered' &&
                      order['refundStatus'] != 'approved',
                )
                .toList();
        break;
      case 2: // Refunded
        filtered =
            allOrders
                .where((order) => order['refundStatus'] == 'approved')
                .toList();
        break;
      default:
        filtered = allOrders;
    }

    // Then, filter by status if not "All"
    if (_selectedStatusIndex.value != 0) {
      String status = orderStatuses[_selectedStatusIndex.value];
      filtered = filtered.where((order) => order['status'] == status).toList();
    }

    return filtered;
  }

  Map<String, dynamic>? getOrderById(String orderId) {
    try {
      return allOrders.firstWhere((order) => order['id'] == orderId);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    _isLoading.value = true;

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Update order status in mock data
    final index = allOrders.indexWhere((order) => order['id'] == orderId);
    if (index != -1) {
      allOrders[index]['status'] = newStatus;
    }

    _isLoading.value = false;
    update();
  }

  int getCountForStatus(String status) {
    if (status == 'All') {
      // Return all orders count (no filter by status)
      return allOrders.length;
    }

    // Count orders with this specific status
    return allOrders.where((order) => order['status'] == status).length;
  }

  String getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return '0xFFFF9800';
      case 'confirmed':
        return '0xFF2196F3';
      case 'processing':
        return '0xFF9C27B0';
      case 'ready':
        return '0xFF16A34A';
      case 'delivered':
        return '0xFF009688';
      case 'cancelled':
        return '0xFFF44336';
      default:
        return '0xFF9E9E9E';
    }
  }

  // Counts for top filters
  int getActiveOrdersCount() {
    return allOrders
        .where(
          (order) =>
              order['status'] != 'Delivered' &&
              order['status'] != 'Cancelled' &&
              order['refundStatus'] != 'approved',
        )
        .length;
  }

  int getDoneOrdersCount() {
    return allOrders
        .where(
          (order) =>
              order['status'] == 'Delivered' &&
              order['refundStatus'] != 'approved',
        )
        .length;
  }

  int getRefundedOrdersCount() {
    return allOrders
        .where((order) => order['refundStatus'] == 'approved')
        .length;
  }
}
