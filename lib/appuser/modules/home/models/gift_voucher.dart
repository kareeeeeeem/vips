class GiftVoucher {
  final String id;
  final String name;
  final String logoUrl;
  final int minAmount;
  final int maxAmount;
  final String currency;

  GiftVoucher({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.minAmount,
    required this.maxAmount,
    this.currency = 'TN',
  });

  factory GiftVoucher.fromJson(Map<String, dynamic> json) {
    return GiftVoucher(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
      minAmount: json['minAmount'] ?? 0,
      maxAmount: json['maxAmount'] ?? 0,
      currency: json['currency'] ?? 'TN',
    );
  }
}
