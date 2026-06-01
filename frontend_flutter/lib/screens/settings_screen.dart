import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/app_ui.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _studentId;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  late final TextEditingController _bio;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _name = TextEditingController(text: user?.name);
    _studentId = TextEditingController(text: user?.userIdentifier);
    _email = TextEditingController(text: user?.email);
    _phone = TextEditingController(text: user?.phone);
    _address = TextEditingController(text: user?.address);
    _bio = TextEditingController(text: user?.bio);
  }

  @override
  void dispose() {
    _name.dispose();
    _studentId.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    _bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: context.contentMaxWidth),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: context.pagePadding,
                children: [
                  const AppHeader(
                    icon: Icons.tune_outlined,
                    title: 'Settings',
                    subtitle: 'Update the account details used by the system.',
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final profile = _SettingsProfilePanel(
                        name: user?.name ?? 'Student',
                        email: user?.email ?? '',
                        identifier: user?.userIdentifier,
                        role: _roleLabel(user?.userType ?? 'student'),
                        onLogout: auth.logout,
                      );

                      final form = Container(
                        decoration: _settingsPanelDecoration(),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Update Your Details',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: const Color(0xff253044),
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                                'Changes are saved to your system profile.',
                                style: TextStyle(color: Color(0xff718096))),
                            const SizedBox(height: 18),
                            TextFormField(
                              controller: _name,
                              decoration: _settingsInputDecoration(
                                  'Full Name', Icons.person_outline),
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                      ? 'Name is required'
                                      : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _studentId,
                              decoration: _settingsInputDecoration(
                                  'Student / User ID', Icons.badge_outlined),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _email,
                              decoration: _settingsInputDecoration(
                                  'Email', Icons.email_outlined),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                if (!value.contains('@')) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _phone,
                              decoration: _settingsInputDecoration(
                                  'Phone', Icons.phone_outlined),
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _address,
                              decoration: _settingsInputDecoration(
                                  'Address', Icons.location_on_outlined),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _bio,
                              minLines: 3,
                              maxLines: 5,
                              decoration: _settingsInputDecoration(
                                  'Bio', Icons.notes_outlined),
                            ),
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton.icon(
                                icon: _saving
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : const Icon(Icons.save_outlined),
                                onPressed: _saving ? null : _save,
                                label: Text(
                                    _saving ? 'Saving...' : 'Save Details'),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (constraints.maxWidth < 880) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            profile,
                            const SizedBox(height: 18),
                            form,
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 330, child: profile),
                          const SizedBox(width: 18),
                          Expanded(child: form),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      await context.read<AuthProvider>().updateProfile(
            name: _name.text.trim(),
            userIdentifier:
                _studentId.text.trim().isEmpty ? null : _studentId.text.trim(),
            email: _email.text.trim(),
            phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
            address: _address.text.trim().isEmpty ? null : _address.text.trim(),
            bio: _bio.text.trim().isEmpty ? null : _bio.text.trim(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile details updated.')),
        );
      }
    } catch (exception) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(exception.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _roleLabel(String value) => value
      .split('_')
      .map((word) =>
          word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}

class _SettingsProfilePanel extends StatelessWidget {
  const _SettingsProfilePanel({
    required this.name,
    required this.email,
    required this.identifier,
    required this.role,
    required this.onLogout,
  });

  final String name;
  final String email;
  final String? identifier;
  final String role;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';
    final id = identifier;

    return Container(
      decoration: _settingsPanelDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: AppColors.primary.withValues(alpha: 0.10),
            foregroundColor: AppColors.primary,
            child: Text(initial,
                style:
                    const TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
          ),
          const SizedBox(height: 16),
          Text(name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.text, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(email, style: const TextStyle(color: AppColors.muted)),
          if (id != null && id.isNotEmpty) ...[
            const SizedBox(height: 10),
            _ProfileChip(icon: Icons.badge_outlined, label: 'ID: $id'),
          ],
          const SizedBox(height: 10),
          _ProfileChip(icon: Icons.verified_user_outlined, label: role),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: BorderSide(
                  color: AppColors.danger.withValues(alpha: 0.34),
                ),
              ),
              onPressed: onLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileChip extends StatelessWidget {
  const _ProfileChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 17, color: AppColors.teal),
      label: Text(label),
      backgroundColor: AppColors.teal.withValues(alpha: 0.10),
      labelStyle:
          const TextStyle(color: AppColors.teal, fontWeight: FontWeight.w800),
      side: BorderSide.none,
    );
  }
}

InputDecoration _settingsInputDecoration(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
  );
}

BoxDecoration _settingsPanelDecoration() {
  return BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: AppColors.border),
  );
}
