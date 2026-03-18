import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/rbm_app_bar.dart';
import '../../../shared/widgets/top_snackbar.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

/// Edit personal profile details screen.
class EditProfileScreen extends ConsumerStatefulWidget {
  /// Creates edit profile screen.
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(staffProfileProvider);
    if (profile != null) {
      _fullNameCtrl.text = profile.fullName;
      _emailCtrl.text = profile.email;
      _phoneCtrl.text = profile.phoneMasked;
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    final profile = ref.read(staffProfileProvider);
    if (profile == null) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(authProvider.notifier)
          .updateStaffProfile(
            fullName: _fullNameCtrl.text,
            email: _emailCtrl.text,
            phoneMasked: _phoneCtrl.text,
            department: profile.department,
            grade: profile.grade,
          );
      if (!mounted) return;
      TopSnackBar.show(
        context,
        message: 'Personal details updated.',
        tone: TopSnackBarTone.success,
      );
      context.pop();
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(staffProfileProvider);
    return OfflineBanner(
      child: Scaffold(
        appBar: RbmAppBar(
          title: 'Edit Personal Details',
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
        body: profile == null
            ? const Center(child: Text('No profile data available.'))
            : ListView(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _FieldCard(
                          child: Column(
                            children: [
                              _LabeledField(
                                label: 'Full Name',
                                controller: _fullNameCtrl,
                                textInputAction: TextInputAction.next,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Enter full name'
                                    : null,
                              ),
                              const SizedBox(height: 10),
                              _LabeledField(
                                label: 'Email',
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: (v) {
                                  final value = (v ?? '').trim();
                                  if (value.isEmpty) return 'Enter email';
                                  if (!value.contains('@') ||
                                      !value.contains('.')) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              _LabeledField(
                                label: 'Phone',
                                controller: _phoneCtrl,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Enter phone number'
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _FieldCard(
                          child: Column(
                            children: [
                              _LabeledField(
                                label: 'Department',
                                initialValue: profile.department,
                                enabled: false,
                              ),
                              const SizedBox(height: 10),
                              _LabeledField(
                                label: 'Grade',
                                initialValue: profile.grade,
                                enabled: false,
                              ),
                              const SizedBox(height: 10),
                              _LabeledField(
                                label: 'Employee Number',
                                initialValue: profile.employeeNumber,
                                enabled: false,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
      ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EDF7)),
      ),
      child: child,
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    this.controller,
    this.initialValue,
    this.validator,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
  });

  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final String? Function(String?)? validator;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          validator: validator,
          enabled: enabled,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          decoration: InputDecoration(
            isDense: true,
            fillColor: enabled
                ? AppColors.backgroundLight
                : const Color(0xFFF0F2F5),
          ),
        ),
      ],
    );
  }
}
