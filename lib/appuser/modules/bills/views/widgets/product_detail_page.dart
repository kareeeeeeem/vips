import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vip/core/services/api_service.dart';

import '../../controllers/bills_controller.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductItem product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _selectedTabIndex = 0;
  int _cartCount = 0;
  bool _addingToCart = false;
  final _commentController = TextEditingController();
  bool _submittingComment = false;

  // Real product detail (description, comments with real commenter names,
  // aggregated rating/sales, seller) from GET /content/products/:id —
  // this screen used to show the exact same hardcoded SaaS-theme
  // description, a single fake "John doe" comment/review, and fabricated
  // "TRUSTED"/certificate copy for every product regardless of which one
  // was actually opened.
  bool _loadingDetail = true;
  String? _detailError;
  String _description = '';
  String? _merchantName;
  double _avgRating = 0;
  int _reviewCount = 0;
  int _salesCount = 0;
  List<Map<String, dynamic>> _comments = [];
  DateTime? _createdAt;
  DateTime? _updatedAt;

  @override
  void initState() {
    super.initState();
    _avgRating = widget.product.avgRating;
    _reviewCount = widget.product.reviewCount;
    _salesCount = widget.product.sellCount;
    _description = widget.product.description;
    _merchantName = widget.product.merchantName;
    _loadCartCount();
    _loadProductDetail();
  }

  Future<void> _loadProductDetail() async {
    setState(() => _loadingDetail = true);
    try {
      final r = await ApiService().get('/content/products/${widget.product.id}');
      if (r.success && r.data is Map && mounted) {
        final data = r.data as Map;
        setState(() {
          _description = (data['description'] ?? '').toString();
          _merchantName = data['merchantName']?.toString();
          _avgRating = (data['avgRating'] as num?)?.toDouble() ?? 0;
          _reviewCount = (data['reviewCount'] as num?)?.toInt() ?? 0;
          _salesCount = (data['salesCount'] as num?)?.toInt() ?? 0;
          _comments = ((data['comments'] as List?) ?? [])
              .map((c) => Map<String, dynamic>.from(c as Map))
              .toList();
          _createdAt = data['createdAt'] != null ? DateTime.tryParse(data['createdAt']) : null;
          _updatedAt = data['updatedAt'] != null ? DateTime.tryParse(data['updatedAt']) : null;
          _detailError = null;
        });
      } else if (mounted) {
        setState(() => _detailError = r.message.isNotEmpty ? r.message : 'Could not load product details.');
      }
    } catch (_) {
      if (mounted) setState(() => _detailError = 'Could not load product details.');
    } finally {
      if (mounted) setState(() => _loadingDetail = false);
    }
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    setState(() => _submittingComment = true);
    try {
      final r = await ApiService().post('/content/products/${widget.product.id}/comment', {'comment': text});
      if (r.success) {
        _commentController.clear();
        safeSnackbar('Comment Submitted', 'Thank you for your feedback!',
            backgroundColor: const Color(0xFF10B981), colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
        // Refresh so the real comment (with the real commenter name the
        // backend resolves) shows up immediately instead of only ever
        // appearing after leaving and reopening this screen.
        await _loadProductDetail();
      } else {
        safeSnackbar('Error', r.message.isNotEmpty ? r.message : 'Could not submit comment.',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (_) {
      safeSnackbar('Error', 'Could not submit comment.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _submittingComment = false);
    }
  }

  Future<void> _loadCartCount() async {
    try {
      final r = await ApiService().get('/cart');
      // GET /cart returns a plain array (`{success, data: [...]}`), not
      // `{items: [...]}` — indexing a List with a String key throws at
      // runtime, so this was silently caught below and _cartCount never
      // updated from its initial 0.
      if (r.success && mounted) {
        final items = r.data as List? ?? [];
        setState(() => _cartCount = items.length);
      }
    } catch (_) {}
  }

  Future<void> _addToCart() async {
    setState(() => _addingToCart = true);
    try {
      await ApiService().post('/cart/add', {
        'itemId': widget.product.id,
        'itemType': 'product',
        'name': widget.product.title,
        'price': widget.product.price,
        'quantity': 1,
      });
      if (mounted) setState(() => _cartCount++);
    } catch (_) {}
    if (mounted) setState(() => _addingToCart = false);
    safeSnackbar('Added to Cart', 'Item added to your cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0066FF),
        colorText: Colors.white);
    Get.toNamed('/cart');
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.grey),
            onPressed: () => Get.toNamed('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.grey),
            onPressed: () => Get.toNamed('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
            onPressed: () => Get.toNamed('/cart'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Carousel - PLUS GRANDE
            Stack(
              children: [
                Container(
                  height: 350.h, // Image plus grande
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 80),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            // Price and Sell Count
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${widget.product.price.toStringAsFixed(1)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.file_download_outlined, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '$_salesCount Sell',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      if (_reviewCount > 0) ...[
                        const SizedBox(width: 12),
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          '${_avgRating.toStringAsFixed(1)} ($_reviewCount)',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Tabs - AVEC TOUS LES ONGLETS
            Container(
              color: Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTab('Description', 0),
                    _buildTab('Comment', 1),
                    _buildTab('Review', 2),
                    _buildTab('Product Info', 3),
                    IconButton(
                      icon: const Icon(Icons.share_outlined, size: 20),
                      onPressed: () => SharePlus.instance.share(ShareParams(
                        text: '${widget.product.title} — Check it out on VIPs!\nPrice: \$${widget.product.price.toStringAsFixed(2)}',
                        subject: widget.product.title,
                      )),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Content based on selected tab
            _buildTabContent(),

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Cart Icon with badge
            Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () => Get.toNamed('/cart'),
                  ),
                ),
                if (_cartCount > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$_cartCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Add to Cart Button
            Expanded(
              child: ElevatedButton(
                onPressed: _addingToCart ? null : _addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  disabledBackgroundColor: const Color(0xFF0066FF).withValues(alpha: 0.6),
                ),
                child: _addingToCart
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text(
                        'Add To Cart',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isActive = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? const Color(0xFF0066FF) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF0066FF) : Colors.grey,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0: // Description
        return _buildDescriptionTab();
      case 1: // Comment
        return _buildCommentTab();
      case 2: // Review
        return _buildReviewTab();
      case 3: // Product Info
        return _buildProductInfoTab();
      default:
        return _buildDescriptionTab();
    }
  }

  Widget _buildDescriptionTab() {
    if (_loadingDetail) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator(color: Color(0xFF0066FF))),
      );
    }
    return Column(
      children: [
        if (_detailError != null)
          Container(
            width: double.infinity,
            color: Colors.orange.shade50,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 18, color: Colors.orange.shade800),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _detailError!,
                    style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
                  ),
                ),
                TextButton(onPressed: _loadProductDetail, child: const Text('Retry')),
              ],
            ),
          ),
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Description:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _description.isNotEmpty ? _description : 'No description provided for this product yet.',
                style: TextStyle(
                  fontSize: 13,
                  color: _description.isNotEmpty ? Colors.grey[700] : Colors.grey[400],
                  height: 1.5,
                  fontStyle: _description.isNotEmpty ? FontStyle.normal : FontStyle.italic,
                ),
              ),
              if (_merchantName != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.storefront_outlined, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      'Sold by $_merchantName',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentTab() {
    return Column(
      children: [
        // Leave a Comment
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Leave a Comment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _commentController,
                maxLines: 3,
                enabled: !_submittingComment,
                decoration: InputDecoration(
                  hintText: 'leave a comment',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submittingComment ? null : _submitComment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _submittingComment
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Submit Comment',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Real comments (with real commenter names) fetched from
        // GET /content/products/:id — this used to always show a single
        // hardcoded "John doe" comment no matter what was actually
        // submitted, so a real submission was never visible anywhere.
        if (_loadingDetail)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator(color: Color(0xFF0066FF))),
          )
        else if (_comments.isEmpty)
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(24.w),
            child: Center(
              child: Text(
                'No comments yet. Be the first to leave one!',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ),
          )
        else
          ..._comments.map((c) => _buildCommentCard(c)),
      ],
    );
  }

  Widget _buildCommentCard(Map<String, dynamic> comment) {
    final userName = (comment['userName'] ?? 'VIPs User').toString();
    final initials = userName.trim().isNotEmpty
        ? userName.trim().split(RegExp(r'\s+')).map((w) => w[0]).take(2).join().toUpperCase()
        : 'U';
    final createdAt = comment['createdAt'] != null ? DateTime.tryParse(comment['createdAt'].toString()) : null;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.w),
      margin: const EdgeInsets.only(top: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.orange,
            child: Text(
              initials,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
                    ),
                    if (createdAt != null)
                      Text(
                        '${createdAt.day}/${createdAt.month}/${createdAt.year}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  (comment['text'] ?? '').toString(),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Reviews come from POST /order/:id/review — a rating left on a real
  // completed order, not a standalone per-product review, so there's no
  // individual review text to list here (an order can contain several
  // products and rates them all at once). What's shown is the real
  // aggregate: average rating and how many order-reviews it's based on.
  Widget _buildReviewTab() {
    if (_loadingDetail) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator(color: Color(0xFF0066FF))),
      );
    }
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Text(
            _reviewCount > 0 ? _avgRating.toStringAsFixed(1) : '—',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(5, (index) {
                    final filled = index < _avgRating.round();
                    return Icon(
                      filled ? Icons.star : Icons.star_border,
                      size: 16,
                      color: filled ? Colors.amber : Colors.grey,
                    );
                  }),
                ),
                const SizedBox(height: 4),
                Text(
                  _reviewCount > 0
                      ? '$_reviewCount review${_reviewCount > 1 ? 's' : ''} from verified purchases'
                      : 'No reviews yet — reviews appear here after a customer rates an order containing this product.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfoTab() {
    final relatedProducts = Get.isRegistered<BillsController>()
        ? Get.find<BillsController>()
            .allProducts
            .where((p) => p.category == widget.product.category && p.id != widget.product.id)
            .take(6)
            .toList()
        : <ProductItem>[];

    return Column(
      children: [
        // Product Details — real fields (this used to be entirely
        // hardcoded software-marketplace boilerplate: "File Type: script",
        // "High Resolution: Yes", fake fixed release/update dates, and a
        // fixed Tags list — none of it tied to the real product at all).
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              _buildDetailRow('Category', widget.product.category),
              _buildDetailRow('Price', '\$${widget.product.price.toStringAsFixed(2)}'),
              if (_createdAt != null) _buildDetailRow('Listed', _formatDate(_createdAt!)),
              if (_updatedAt != null && _updatedAt != _createdAt) _buildDetailRow('Updated', _formatDate(_updatedAt!)),
              if (_merchantName != null) _buildDetailRow('Sold by', _merchantName!),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Contact seller — real action, unchanged. The fake "Trusted" /
        // certificate claim ("reviewed by VIPsApp") that used to sit next
        // to this is gone — nothing on this platform actually reviews or
        // certifies products, so claiming it was simply false.
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Questions about this product?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.toNamed('/contact'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Send Message',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        if (relatedProducts.isNotEmpty) ...[
          const SizedBox(height: 8),

          // Related Products — real products sharing this one's category,
          // not two hardcoded "FoodBari" cards shown for every product
          // regardless of what it actually was.
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Related Products',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: relatedProducts.length,
                    itemBuilder: (context, index) {
                      return _buildRelatedProductCard(relatedProducts[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          Text(value, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRelatedProductCard(ProductItem product) {
    return GestureDetector(
      onTap: () {
        Get.off(() => ProductDetailPage(product: product));
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.network(
                    product.imageUrl,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 100,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 32),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0066FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '\$${product.price.toStringAsFixed(1)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category,
                    style: const TextStyle(
                      color: Color(0xFF0066FF),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.download, size: 10, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${product.sellCount} Sell',
                        style: const TextStyle(fontSize: 9, color: Colors.grey),
                      ),
                      const Spacer(),
                      if (product.reviewCount > 0) ...[
                        const Icon(Icons.star, size: 10, color: Colors.amber),
                        Text(
                          product.avgRating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 9, color: Colors.grey),
                        ),
                      ],
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
