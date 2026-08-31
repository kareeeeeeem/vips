import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/routes/admin_routes.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_scaffold.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../controllers/audit_controller.dart';

/// Who did what in the console, and when.
class AuditLogsView extends GetView<AuditController> {
  const AuditLogsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Audit log',
      route: AdminRoutes.AUDIT,
      onRefresh: () => controller.load(),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: AdminColors.background,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      child: Column(
        children: [
          Obx(() {
            controller.search.value;
            return AdminSearchField(
              controller: controller.searchController,
              hint: 'Search by action, operator or record id',
              onChanged: controller.onSearchChanged,
              onClear: controller.clearSearch,
            );
          }),
          SizedBox(height: 12.h),
          Obx(() => AdminFilterChips(
                options: [
                  const AdminFilterOption('', 'All outcomes'),
                  for (final o in AuditController.outcomes)
                    AdminFilterOption(o, AuditController.outcomeLabel(o)),
                ],
                selected: controller.outcomeFilter.value,
                onSelected: controller.setOutcome,
              )),
          Obx(() {
            if (controller.targetTypes.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: AdminFilterChips(
                options: [
                  const AdminFilterOption('', 'Everything'),
                  for (final t in controller.targetTypes)
                    AdminFilterOption(t, AuditController.targetLabel(t)),
                ],
                selected: controller.targetFilter.value,
                onSelected: controller.setTarget,
              ),
            );
          }),
          Obx(() {
            if (controller.actors.length < 2) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: AdminFilterChips(
                options: [
                  const AdminFilterOption('', 'Every operator'),
                  for (final a in controller.actors)
                    AdminFilterOption(
                      adminString(a['actorId']),
                      '${adminString(a['name'], 'Unknown')} (${adminInt(a['entries'])})',
                    ),
                ],
                selected: controller.actorFilter.value,
                onSelected: controller.setActor,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildList() {
    return Obx(() {
      if (controller.isLoading.value && controller.items.isEmpty) {
        return const AdminLoading();
      }
      if (controller.errorMessage.isNotEmpty && controller.items.isEmpty) {
        return AdminErrorState(
          message: controller.errorMessage.value,
          onRetry: () => controller.load(),
        );
      }
      if (controller.items.isEmpty) {
        final filtered = controller.search.value.isNotEmpty ||
            controller.outcomeFilter.value.isNotEmpty ||
            controller.targetFilter.value.isNotEmpty ||
            controller.actorFilter.value.isNotEmpty;
        return AdminEmptyState(
          icon: Icons.fact_check_outlined,
          title: filtered ? 'Nothing matches these filters' : 'No entries yet',
          message: filtered
              ? 'No recorded action matches what you have selected.'
              : 'Every change made in the console is recorded here. Reads are '
                  'not — only what somebody changed.',
        );
      }

      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
        children: [
          _buildRefusedBanner(),
          for (final entry in controller.items) _buildRow(entry),
          AdminPaginator(
            page: controller.page.value,
            pages: controller.pages.value,
            total: controller.total.value,
            onPrevious: controller.previousPage,
            onNext: controller.nextPage,
          ),
        ],
      );
    });
  }

  /// A run of refusals is the pattern this screen exists to make visible, so
  /// it is counted rather than left to be spotted row by row.
  Widget _buildRefusedBanner() {
    final refused = controller.refusedCount;
    if (refused == 0 || controller.outcomeFilter.value == 'denied') {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: InkWell(
        onTap: () => controller.setOutcome('denied'),
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AdminColors.warning.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AdminColors.warning.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.gpp_maybe_outlined, size: 16.sp, color: AdminColors.warning),
              SizedBox(width: 9.w),
              Expanded(
                child: Text(
                  '$refused attempt${refused == 1 ? ' was' : 's were'} refused on '
                  'this page. Tap to see only those.',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    height: 1.35,
                    color: AdminColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(Map<String, dynamic> entry) {
    final success = adminBool(entry['success'], true);
    final action = adminString(entry['action'], 'Unknown action');
    final actor = adminString(entry['actorName'], 'Deleted operator');
    final role = adminString(entry['actorRole']);
    final at = adminDate(entry['createdAt']);
    final status = adminInt(entry['statusCode']);
    final message = adminString(entry['message']);

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => _showDetails(entry),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AdminColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: success
                  ? AdminColors.border
                  : AdminColors.warning.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: (success ? AdminColors.success : AdminColors.warning)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  success ? Icons.check_rounded : Icons.block_rounded,
                  size: 14.sp,
                  color: success ? AdminColors.success : AdminColors.warning,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AdminColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      // The operator's name is denormalised on the entry, so
                      // a line stays readable after the account is removed.
                      '$actor${role.isEmpty ? '' : ' · ${adminLabel(role)}'}',
                      style: TextStyle(
                          fontSize: 11.sp, color: AdminColors.textSecondary),
                    ),
                    if (!success && message.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          height: 1.3,
                          color: AdminColors.warning,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    adminRelative(at),
                    style:
                        TextStyle(fontSize: 10.5.sp, color: AdminColors.textMuted),
                  ),
                  SizedBox(height: 4.h),
                  AdminStatusPill(
                    label: '$status',
                    color: success ? AdminColors.textSecondary : AdminColors.warning,
                    compact: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetails(Map<String, dynamic> entry) {
    final changes = entry['changes'];
    final at = adminDate(entry['createdAt']);

    adminSheet(
      title: adminString(entry['action'], 'Audit entry'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminDetailRow(
            label: 'Operator',
            value: adminString(entry['actorName'], 'Deleted operator'),
          ),
          AdminDetailRow(label: 'Email', value: adminString(entry['actorEmail'], '—')),
          AdminDetailRow(
            label: 'Role',
            value: adminLabel(adminString(entry['actorRole'], 'unknown')),
          ),
          AdminDetailRow(label: 'When', value: adminDateTimeLabel(at)),
          AdminDetailRow(
            label: 'Outcome',
            value: adminBool(entry['success'], true)
                ? 'Went through (${adminInt(entry['statusCode'])})'
                : 'Refused (${adminInt(entry['statusCode'])})',
          ),
          AdminDetailRow(
            label: 'Endpoint',
            value: '${adminString(entry['method'])} ${adminString(entry['path'])}',
          ),
          if (adminString(entry['targetId']).isNotEmpty)
            AdminDetailRow(
              label: 'Record',
              value: adminString(entry['targetId']),
            ),
          if (adminString(entry['message']).isNotEmpty)
            AdminDetailRow(
              label: 'Server said',
              value: adminString(entry['message']),
            ),
          if (changes != null) ...[
            SizedBox(height: 14.h),
            Text(
              'What was sent',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AdminColors.textPrimary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              // Said explicitly, because a reader has to be able to trust
              // that a blank password field means "never stored" rather than
              // "the operator left it empty".
              'Passwords and tokens are replaced with [redacted] before the '
              'entry is written — they are never stored.',
              style: TextStyle(
                  fontSize: 10.5.sp, height: 1.3, color: AdminColors.textMuted),
            ),
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AdminColors.background,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AdminColors.border),
              ),
              child: SelectableText(
                _pretty(changes),
                style: TextStyle(
                  fontSize: 11.sp,
                  height: 1.5,
                  fontFamily: 'monospace',
                  color: AdminColors.textPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// One field per line. A raw map printed with toString runs off the edge of
  /// a phone and is unreadable exactly when somebody is trying to read it.
  String _pretty(dynamic changes) {
    if (changes is! Map) return '$changes';
    return changes.entries.map((e) => '${e.key}: ${e.value}').join('\n');
  }
}
