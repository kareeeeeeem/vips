import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';

/// Search box plus a location chip row, shared by the inventory screens.
///
/// The location list is passed in from live data rather than hardcoded, so a
/// chip can never open a warehouse that holds nothing — the same mistake that
/// left the consumer app with a "Food" category chip behind an empty screen.
class InventoryFilter extends StatelessWidget {
  final TextEditingController searchController;
  final String hint;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchCleared;

  final List<Map<String, dynamic>> locations;
  final String selectedLocation;
  final ValueChanged<String> onLocationSelected;

  /// Optional extra row (e.g. the low-stock toggle) drawn under the chips.
  final Widget? trailing;

  const InventoryFilter({
    super.key,
    required this.searchController,
    required this.hint,
    required this.onSearchChanged,
    required this.onSearchCleared,
    this.locations = const [],
    this.selectedLocation = '',
    required this.onLocationSelected,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AdminColors.background,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      child: Column(
        children: [
          AdminSearchField(
            controller: searchController,
            hint: hint,
            onChanged: onSearchChanged,
            onClear: onSearchCleared,
          ),
          // Only worth showing once stock actually sits in more than one
          // place; a single-warehouse platform gets no useless chip row.
          if (locations.length > 1) ...[
            SizedBox(height: 10.h),
            AdminFilterChips(
              options: [
                AdminFilterOption('', 'All locations'),
                for (final location in locations)
                  AdminFilterOption(
                    adminString(location['location']),
                    adminString(location['location'], 'Main'),
                    count: adminInt(location['lines']),
                  ),
              ],
              selected: selectedLocation,
              onSelected: onLocationSelected,
            ),
          ],
          if (trailing != null) ...[
            SizedBox(height: 10.h),
            trailing!,
          ],
        ],
      ),
    );
  }
}
