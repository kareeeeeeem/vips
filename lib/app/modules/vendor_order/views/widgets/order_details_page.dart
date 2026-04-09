import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailsPage extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailsPage({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  late String currentStatus;
  double _swipeOffset = 0;
  final double _maxSwipeDistance = 250.0;

  final List<String> statusOptions = [
    'Pending',
    'Confirmed',
    'Processing',
    'Ready',
    'Delivered',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    currentStatus = widget.order['status'] ?? 'Pending';
  }

  void _onSwipeComplete() {
    setState(() {
      currentStatus = 'Shipping';
    });
    setState(() {
      _swipeOffset = 0;
    });
  }

  void _openCustomerChat() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Order Details',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Color(0xFFE84C4F),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20.sp),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            _buildOrderTimeline(),
            SizedBox(height: 30.h),
            _buildOrderInformationCard(),
            SizedBox(height: 20.h),
            _buildOrderedProductsSection(),
            SizedBox(height: 20.h),
            _buildPriceBreakdown(),
            SizedBox(height: 30.h),
          ],
        ),
      ),
      bottomSheet:
          currentStatus.toLowerCase() == 'confirmed' ||
                  currentStatus.toLowerCase() == 'processing'
              ? Container(color: Colors.white, child: _buildSwipeButton())
              : SizedBox(height: 30.h),
    );
  }

  Widget _buildOrderTimeline() {
    final steps = [
      {
        'icon': Icons.shopping_bag_outlined,
        'label': 'Placed',
        'color': Color(0xFFE84C4F),
      },
      {
        'icon': Icons.verified_outlined,
        'label': 'Confirmed',
        'color': Color(0xFF2196F3),
      },
      {
        'icon': Icons.local_shipping_outlined,
        'label': 'Shipping',
        'color': Color(0xFFFFC107),
      },
      {
        'icon': Icons.check_circle,
        'label': 'Delivered',
        'color': Color(0xFF4CAF50),
      },
    ];

    final currentStepIndex = _getCurrentStepIndex(currentStatus);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      height: 100.h,
      child: Stack(
        children: [
          Positioned(
            top: 28.h,
            left: 30.w,
            right: 30.w,
            child: CustomPaint(
              size: Size(double.infinity, 4.h),
              painter: _CurvedLinePainter(
                progress: (currentStepIndex + 1) / steps.length,
                activeColor: Color(0xFF4CAF50),
                inactiveColor: Colors.grey.shade200,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(steps.length, (index) {
              final step = steps[index];
              final isCompleted = index <= currentStepIndex;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60.w,
                    height: 60.h,
                    decoration: BoxDecoration(
                      color:
                          isCompleted ? (step['color'] as Color) : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            isCompleted
                                ? (step['color'] as Color)
                                : Colors.grey.shade300,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              isCompleted
                                  ? (step['color'] as Color).withOpacity(0.3)
                                  : Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      step['icon'] as IconData,
                      color: isCompleted ? Colors.white : Colors.grey.shade400,
                      size: 28.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    step['label'] as String,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight:
                          isCompleted ? FontWeight.w700 : FontWeight.w500,
                      color:
                          isCompleted ? Colors.black87 : Colors.grey.shade500,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInformationCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInfoColumn(
                  'Order Code',
                  widget.order['id'] ?? '20241205-09411459',
                  isHighlighted: true,
                ),
              ),
              _buildInfoColumn(
                'Shipping Method',
                widget.order['deliveryType'] ?? 'Home Delivery',
                isEnd: true,
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInfoColumn(
                  'Order Date',
                  widget.order['date'] ?? '05-12-2024',
                ),
              ),
              SizedBox(width: 20.w),
              _buildInfoColumn(
                'Payment Method',
                widget.order['paymentMethod'] ?? 'Cash On Delivery',
                isEnd: true,
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Status',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Text(
                          'Paid',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildInfoColumn('Delivery Status', currentStatus, isEnd: true),
            ],
          ),
          SizedBox(height: 20.h),
          Divider(color: Colors.grey.shade300, thickness: 1),
          SizedBox(height: 20.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shipping Address',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Name: ${widget.order['customerName'] ?? 'Paul K. Jensen'}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                    Text(
                      'Email: ${widget.order['customerEmail'] ?? 'customer@example.com'}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                    Text(
                      'Address: ${widget.order['address'] ?? 'Gulshan Dhaka'}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                    Text(
                      'City: ${widget.order['city'] ?? 'Dhaka'}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                    Text(
                      'Country: ${widget.order['country'] ?? 'Bangladesh'}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                    Text(
                      'Phone: ${widget.order['customerPhone'] ?? '+18546878168'}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                    Text(
                      'Postal code: ${widget.order['postalCode'] ?? '1212'}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildInfoColumn(
                      'Total Amount',
                      '\$${widget.order['amount']?.toStringAsFixed(3) ?? '90.000'}',
                      isPrice: true,
                      isEnd: true,
                    ),
                    SizedBox(height: 40.h),

                    Column(
                      children: [
                        Text(
                          'Customer Chat',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.lightGreen,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.all(10.sp),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 22.sp,
                            color: Colors.lightGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(
    String label,
    String value, {
    bool isHighlighted = false,
    bool isEnd = false,
    bool isPrice = false,
  }) {
    return Column(
      crossAxisAlignment:
          !isEnd ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(
            fontSize: isPrice ? 20.sp : 13.sp,
            fontWeight: isPrice ? FontWeight.w700 : FontWeight.w400,
            color:
                isHighlighted || isPrice
                    ? Color(0xFFE84C4F)
                    : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderedProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Text(
            'Ordered Product',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        ...List.generate((widget.order['products'] as List?)?.length ?? 1, (
          index,
        ) {
          final product =
              (widget.order['products'] as List?)?[index] ??
              {
                'name':
                    'ZAGG - Pro Keys Wireless Keyboard & Detachable Case for Apple iPad 10.9" 10th Gen',
                'quantity': 1,
                'price': 90.000,
              };

          return Container(
            margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 12.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'] ?? '',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '${product['quantity']} x item',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  '\$${product['price']?.toStringAsFixed(3) ?? '90.000'}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE84C4F),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPriceBreakdown() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildPriceRow(
            'SUB TOTAL',
            '\$${widget.order['subtotal']?.toStringAsFixed(3) ?? '90.000'}',
          ),
          SizedBox(height: 12.h),
          _buildPriceRow(
            'TAX',
            '\$${widget.order['tax']?.toStringAsFixed(3) ?? '0.000'}',
          ),
          SizedBox(height: 12.h),
          _buildPriceRow(
            'Shipping Cost',
            '\$${widget.order['shipping']?.toStringAsFixed(3) ?? '0.000'}',
          ),
          SizedBox(height: 12.h),
          _buildPriceRow(
            'DISCOUNT',
            '\$${widget.order['discount']?.toStringAsFixed(3) ?? '0.000'}',
          ),
          SizedBox(height: 16.h),
          Divider(color: Colors.grey.shade300, thickness: 1),
          SizedBox(height: 16.h),
          _buildPriceRow(
            'GRAND TOTAL',
            '\$${widget.order['amount']?.toStringAsFixed(3) ?? '90.000'}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            color: Colors.black87,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 18.sp : 14.sp,
            fontWeight: FontWeight.w700,
            color: isTotal ? Color(0xFFE84C4F) : Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildSwipeButton() {
    final swipeProgress = _swipeOffset / _maxSwipeDistance;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      height: 50.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFE5E5), Color(0xFFFFD5D5)],
        ),
        borderRadius: BorderRadius.circular(35.r),
        border: Border.all(
          color: Color(0xFFE84C4F).withOpacity(0.3),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFE84C4F).withOpacity(0.15),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Texte central avec animation
          Center(
            child: AnimatedOpacity(
              opacity: 1 - swipeProgress,
              duration: Duration(milliseconds: 100),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.double_arrow_rounded,
                    color: Color(0xFFE84C4F),
                    size: 28.sp,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Swipe if On The Way',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFE84C4F),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bouton glissant
          Positioned(
            left: 5.w + _swipeOffset,
            top: 5.h,
            bottom: 5.h,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _swipeOffset += details.delta.dx;
                  if (_swipeOffset < 0) _swipeOffset = 0;
                  if (_swipeOffset > _maxSwipeDistance) {
                    _swipeOffset = _maxSwipeDistance;
                  }
                });
              },
              onHorizontalDragEnd: (details) {
                if (_swipeOffset >= _maxSwipeDistance * 0.75) {
                  _onSwipeComplete();
                } else {
                  setState(() {
                    _swipeOffset = 0;
                  });
                }
              },
              child: Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE84C4F), Color(0xFFD43D40)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFE84C4F).withOpacity(0.5),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 32.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getCurrentStepIndex(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
      case 'order placed':
        return 0;
      case 'confirmed':
      case 'preparing':
      case 'processing':
        return 1;
      case 'on delivery':
      case 'shipping':
      case 'ready':
        return 2;
      case 'delivered':
      case 'completed':
        return 3;
      default:
        return 0;
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }
}

class _CurvedLinePainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color inactiveColor;

  _CurvedLinePainter({
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    paint.color = inactiveColor;
    canvas.drawLine(Offset(0, 0), Offset(size.width, 0), paint);

    paint.color = activeColor;
    canvas.drawLine(Offset(0, 0), Offset(size.width * progress, 0), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
