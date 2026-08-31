import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/admin_toast.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../controllers/staff_controller.dart';
import 'staff_list_view.dart';

/// Create or edit a console operator.
///
/// One screen for both: the only differences are that a new operator needs a
/// password and that editing sends just the fields that actually changed, so
/// an untouched field is never overwritten with a stale value.
class StaffAddEditView extends StatefulWidget {
  const StaffAddEditView({super.key});

  @override
  State<StaffAddEditView> createState() => _StaffAddEditViewState();
}

class _StaffAddEditViewState extends State<StaffAddEditView> {
  final StaffController controller = Get.find<StaffController>();
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  String _role = 'viewer';
  final Set<String> _extraPermissions = {};

  /// The record as it was loaded, so an edit can send only real changes.
  Map<String, dynamic> _original = const {};
  bool _loading = false;

  String get _staffId {
    final param = Get.parameters['id'];
    if (param != null && param.isNotEmpty) return param;
    final args = Get.arguments;
    return args is Map ? adminString(args['id']) : '';
  }

  bool get _isEdit => _staffId.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (_isEdit) _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await controller.loadDetails(_staffId);
    final data = controller.details.value;
    final staff = data != null && data['staff'] is Map
        ? Map<String, dynamic>.from(data['staff'] as Map)
        : <String, dynamic>{};

    if (mounted) {
      setState(() {
        _original = staff;
        _name.text = adminString(staff['fullName']);
        _email.text = adminString(staff['email']);
        _phone.text = adminString(staff['phone']);
        _role = adminString(staff['adminRole'], 'viewer');
        _extraPermissions
          ..clear()
          ..addAll(
            staff['permissions'] is List
                ? (staff['permissions'] as List).map((p) => p.toString())
                : const <String>[],
          );
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        backgroundColor: AdminColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18.sp, color: AdminColors.textPrimary),
          onPressed: Get.back,
        ),
        title: Text(
          _isEdit ? 'Edit operator' : 'Add operator',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: AdminColors.textPrimary,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AdminColors.primary),
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
                children: [
                  _buildIdentity(),
                  SizedBox(height: 14.h),
                  if (!_isEdit) ...[
                    _buildPassword(),
                    SizedBox(height: 14.h),
                  ],
                  _buildRole(),
                  SizedBox(height: 14.h),
                  _buildPermissions(),
                  SizedBox(height: 22.h),
                  Obx(() => AdminButton(
                        label: _isEdit ? 'Save changes' : 'Add operator',
                        icon: _isEdit ? Icons.save_outlined : Icons.person_add_alt_rounded,
                        isLoading: controller.isMutating.value,
                        onPressed: _submit,
                      )),
                ],
              ),
            ),
    );
  }

  // ── Sections ──────────────────────────────────────────────

  Widget _buildIdentity() {
    return AdminCard(
      title: 'Account',
      child: Column(
        children: [
          _field(_name, 'Full name', required: true),
          SizedBox(height: 12.h),
          _field(
            _email,
            'Email',
            required: true,
            keyboard: TextInputType.emailAddress,
            // The sign-in identity: changing it would change how they log in,
            // and the backend does not accept it on update either.
            enabled: !_isEdit,
            helper: _isEdit ? 'The sign-in address cannot be changed here.' : null,
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Email is required.';
              if (!value.contains('@') || !value.contains('.')) {
                return 'That does not look like an email address.';
              }
              return null;
            },
          ),
          SizedBox(height: 12.h),
          _field(
            _phone,
            'Phone',
            required: !_isEdit,
            keyboard: TextInputType.phone,
            enabled: !_isEdit,
            helper: _isEdit ? 'Phone is set when the account is created.' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPassword() {
    return AdminCard(
      title: 'Password',
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'There is no invitation email — pass these credentials on '
              'yourself and have them change the password after first sign-in.',
              style: TextStyle(
                fontSize: 11.5.sp,
                height: 1.45,
                color: AdminColors.textMuted,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          _field(
            _password,
            'Password',
            required: true,
            obscure: true,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Password is required.';
              if (value.length < 6) return 'Use at least 6 characters.';
              return null;
            },
          ),
          SizedBox(height: 12.h),
          _field(
            _confirm,
            'Confirm password',
            required: true,
            obscure: true,
            validator: (value) {
              // Checked here because the backend only ever receives one
              // password — a typo would otherwise create an account nobody
              // can sign in to.
              if (value != _password.text) return 'The passwords do not match.';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRole() {
    return AdminCard(
      title: 'Role',
      child: Obx(() {
        final roles = StaffController.builtInRoles;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final role in roles) _roleOption(role),
            if (controller.customRoles.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                'Custom roles are managed on the Roles screen and are not '
                'assignable here yet.',
                style: TextStyle(fontSize: 11.sp, color: AdminColors.textMuted),
              ),
            ],
          ],
        );
      }),
    );
  }

  Widget _roleOption(String role) {
    final selected = _role == role;
    // Only a super admin may grant super admin — the server refuses it
    // otherwise, so the option is shown but locked rather than hidden.
    final allowed = controller.canAssignRole(role);
    final grants = controller.rolePermissions[role] ?? const <String>[];
    final summary = grants.contains('*')
        ? 'Everything'
        : '${grants.length} permission${grants.length == 1 ? '' : 's'}';

    return Opacity(
      opacity: allowed ? 1 : 0.5,
      child: InkWell(
        onTap: allowed
            ? () => setState(() => _role = role)
            : () => adminToast('Not allowed',
                'Only a super admin can grant the super admin role.',
                isError: true),
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
          decoration: BoxDecoration(
            color: selected
                ? StaffListView.roleColor(role).withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: selected ? StaffListView.roleColor(role) : AdminColors.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                size: 18.sp,
                color: selected ? StaffListView.roleColor(role) : AdminColors.textMuted,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      adminLabel(role),
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                        color: AdminColors.textPrimary,
                      ),
                    ),
                    Text(
                      _roleDescription(role),
                      style: TextStyle(fontSize: 11.sp, color: AdminColors.textMuted),
                    ),
                  ],
                ),
              ),
              AdminStatusPill(
                label: summary,
                color: StaffListView.roleColor(role),
                compact: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _roleDescription(String role) {
    switch (role) {
      case 'super_admin':
        return 'Everything, including granting super admin';
      case 'admin':
        return 'Full day-to-day control, including deletes and staff';
      case 'manager':
        return 'Can edit and run the till, but not delete or manage staff';
      default:
        return 'Read-only across every section';
    }
  }

  Widget _buildPermissions() {
    return AdminCard(
      title: 'Extra permissions',
      child: Obx(() {
        final grouped = controller.permissionsByModule;
        final fromRole = controller.rolePermissions[_role] ?? const <String>[];
        final roleHasAll = fromRole.contains('*');

        if (grouped.isEmpty) {
          return Text(
            'The permission catalogue could not be loaded.',
            style: TextStyle(fontSize: 12.sp, color: AdminColors.textMuted),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              roleHasAll
                  ? 'This role already grants everything, so extras add nothing.'
                  : 'Granted on top of the role. Anything already covered by '
                      'the role is shown ticked and locked.',
              style: TextStyle(
                fontSize: 11.5.sp,
                height: 1.45,
                color: AdminColors.textMuted,
              ),
            ),
            SizedBox(height: 12.h),
            for (final entry in grouped.entries) ...[
              Text(
                adminLabel(entry.key),
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w800,
                  color: AdminColors.textSecondary,
                ),
              ),
              SizedBox(height: 6.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  for (final permission in entry.value)
                    _permissionChip(permission, fromRole, roleHasAll),
                ],
              ),
              SizedBox(height: 12.h),
            ],
          ],
        );
      }),
    );
  }

  Widget _permissionChip(String permission, List<String> fromRole, bool roleHasAll) {
    // A permission the role already covers is shown as granted but not
    // togglable: unticking it here would not take it away.
    final coveredByRole = roleHasAll || fromRole.contains(permission);
    final selected = coveredByRole || _extraPermissions.contains(permission);
    final action = permission.split('.').last;

    return GestureDetector(
      onTap: coveredByRole
          ? () => adminToast('Already granted',
              'The ${adminLabel(_role)} role already includes this.',
              isError: false)
          : () => setState(() {
                if (_extraPermissions.contains(permission)) {
                  _extraPermissions.remove(permission);
                } else {
                  _extraPermissions.add(permission);
                }
              }),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: selected
              ? AdminColors.primary.withValues(alpha: coveredByRole ? 0.06 : 0.12)
              : AdminColors.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected
                ? AdminColors.primary.withValues(alpha: coveredByRole ? 0.3 : 1)
                : AdminColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected
                  ? (coveredByRole ? Icons.lock_outline_rounded : Icons.check_rounded)
                  : Icons.add_rounded,
              size: 13.sp,
              color: selected ? AdminColors.primary : AdminColors.textMuted,
            ),
            SizedBox(width: 5.w),
            Text(
              adminLabel(action),
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w600,
                color: selected ? AdminColors.primary : AdminColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Fields ────────────────────────────────────────────────

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    bool obscure = false,
    bool enabled = true,
    String? helper,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      enabled: enabled,
      keyboardType: keyboard,
      style: TextStyle(
        fontSize: 14.sp,
        color: enabled ? AdminColors.textPrimary : AdminColors.textMuted,
      ),
      validator: validator ??
          (value) {
            if (required && (value == null || value.trim().isEmpty)) {
              return '$label is required.';
            }
            return null;
          },
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        helperMaxLines: 2,
        labelStyle: TextStyle(fontSize: 13.sp, color: AdminColors.textSecondary),
        helperStyle: TextStyle(fontSize: 10.5.sp, color: AdminColors.textMuted),
        isDense: true,
        filled: !enabled,
        fillColor: AdminColors.background,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AdminColors.border),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AdminColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AdminColors.primary),
        ),
      ),
    );
  }

  // ── Submit ────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!controller.canAssignRole(_role)) {
      return adminToast('Not allowed',
          'Only a super admin can grant the super admin role.', isError: true);
    }

    if (_isEdit) {
      // Only what actually changed. Sending the whole form would rewrite
      // fields the operator never touched with whatever was loaded.
      final changes = <String, dynamic>{};
      if (_name.text.trim() != adminString(_original['fullName'])) {
        changes['fullName'] = _name.text.trim();
      }
      if (_role != adminString(_original['adminRole'], 'viewer')) {
        changes['adminRole'] = _role;
      }
      final originalExtras = _original['permissions'] is List
          ? (_original['permissions'] as List).map((p) => p.toString()).toSet()
          : <String>{};
      if (!_setEquals(originalExtras, _extraPermissions)) {
        changes['permissions'] = _extraPermissions.toList();
      }

      final ok = await controller.updateStaff(_staffId, changes);
      if (ok) Get.back(result: true);
      return;
    }

    final ok = await controller.createStaff(
      fullName: _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      password: _password.text,
      adminRole: _role,
      permissions: _extraPermissions.toList(),
    );
    if (ok) Get.back(result: true);
  }

  bool _setEquals(Set<String> a, Set<String> b) =>
      a.length == b.length && a.every(b.contains);
}
