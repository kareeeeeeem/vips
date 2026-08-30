import 'package:flutter/material.dart';

/// One navigation destination, shared by [AdminDrawer] and [AdminBottomNav]
/// so the two lists cannot describe the same route differently.
/// One navigation destination. Public because [AdminDrawer.entries] and
/// [AdminBottomNav.entries] expose the lists themselves.
class AdminNavEntry {
  final String route;
  final String label;
  final IconData icon;

  const AdminNavEntry(this.route, this.label, this.icon);
}
