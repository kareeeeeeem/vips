class BusinessProfile {
  final String id;
  final String name;
  final String type; // e.g. 'Restaurant', 'Clothing Store'
  final String logoUrl;

  /// Partnership/registration state from BusinessRegistration.status —
  /// 'pending' | 'under_review' | 'approved' | 'rejected', or '' when the
  /// merchant has never submitted a registration.
  final String status;

  /// Whether this is the business the app is currently operating as.
  final bool isActive;

  const BusinessProfile({
    required this.id,
    required this.name,
    required this.type,
    required this.logoUrl,
    this.status = '',
    this.isActive = false,
  });

  String get statusLabel => switch (status) {
        'approved' => 'Approved',
        'pending' => 'Pending review',
        'under_review' => 'Under review',
        'rejected' => 'Rejected',
        _ => 'Not registered',
      };
}
