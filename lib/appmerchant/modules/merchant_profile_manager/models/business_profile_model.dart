class BusinessProfile {
  final String id;
  final String name;
  final String type; // e.g. 'Restaurant', 'Clothing Store'
  final String logoUrl;
  final String pin; // Password/PIN for security
  final bool isActive;

  BusinessProfile({
    required this.id,
    required this.name,
    required this.type,
    required this.logoUrl,
    required this.pin,
    this.isActive = false,
  });
}
