import 'package:flutter/material.dart';

/// One navigation destination. Public because [AdminDrawer.entries] and
/// [AdminBottomNav.entries] expose the lists themselves.
///
/// An entry with [children] is a collapsible group: [route] then names the
/// section's landing page and the children are the boards under it.
class AdminNavEntry {
  final String route;
  final String label;
  final IconData icon;

  /// Sub-destinations shown under this one. Empty for a plain entry.
  final List<AdminNavEntry> children;

  /// The permission this destination needs. Entries the signed-in operator
  /// cannot use are left out of the drawer rather than shown and then refused
  /// — presentation only, since the server gates every one of them too.
  final String? permission;

  const AdminNavEntry(
    this.route,
    this.label,
    this.icon, {
    this.children = const [],
    this.permission,
  });

  bool get isGroup => children.isNotEmpty;

  /// This entry and everything nested under it.
  Iterable<AdminNavEntry> get flattened sync* {
    yield this;
    for (final child in children) {
      yield* child.flattened;
    }
  }
}
