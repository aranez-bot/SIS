import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

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
      backgroundColor: const Color(0xfff4f7fb),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xfffbfcff), Color(0xfff4f9fb), Color(0xffeef4fb)],
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(28),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xff4f67d8), Color(0xff5db4a8)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff4f67d8).withValues(alpha: 0.18),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white.withValues(alpha: 0.18),
                      foregroundColor: Colors.white,
                      child: const Icon(Icons.tune_outlined, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Settings',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Keep your account details updated for smoother inquiry notifications and responses.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white.withValues(alpha: 0.84), height: 1.42),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              LayoutBuilder(
                builder: (context, constraints) {
                  final profile = _SettingsProfilePanel(
                    name: user?.name ?? 'Student',
                    email: user?.email ?? '',
                    identifier: user?.userIdentifier,
                    role: _roleLabel(user?.userType ?? 'student'),
                  );

                  final form = Container(
                    decoration: _settingsPanelDecoration(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Update Your Details',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: const Color(0xff253044),
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 4),
                        const Text('Changes are saved to your system profile.', style: TextStyle(color: Color(0xff718096))),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _name,
                          decoration: _settingsInputDecoration('Full Name', Icons.person_outline),
                          validator: (value) => value == null || value.trim().isEmpty ? 'Name is required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _studentId,
                          decoration: _settingsInputDecoration('Student / User ID', Icons.badge_outlined),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _email,
                          decoration: _settingsInputDecoration('Email', Icons.email_outlined),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Email is required';
                            if (!value.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phone,
                          decoration: _settingsInputDecoration('Phone', Icons.phone_outlined),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _address,
                          decoration: _settingsInputDecoration('Address', Icons.location_on_outlined),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _bio,
                          minLines: 3,
                          maxLines: 5,
                          decoration: _settingsInputDecoration('Bio', Icons.notes_outlined),
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(154, 48),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: _saving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.save_outlined),
                            onPressed: _saving ? null : _save,
                            label: Text(_saving ? 'Saving...' : 'Save Details'),
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
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      await context.read<AuthProvider>().updateProfile(
            name: _name.text.trim(),
            userIdentifier: _studentId.text.trim().isEmpty ? null : _studentId.text.trim(),
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
      .map((word) => word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}

class _SettingsProfilePanel extends StatelessWidget {
  const _SettingsProfilePanel({
    required this.name,
    required this.email,
    required this.identifier,
    required this.role,
  });

  final String name;
  final String email;
  final String? identifier;
  final String role;

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
            backgroundColor: const Color(0xffeef3ff),
            foregroundColor: const Color(0xff4f67d8),
            child: Text(initial, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
          ),
          const SizedBox(height: 16),
          Text(name, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: const Color(0xff253044), fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(email, style: const TextStyle(color: Color(0xff718096))),
          if (id != null && id.isNotEmpty) ...[
            const SizedBox(height: 10),
            _ProfileChip(icon: Icons.badge_outlined, label: 'ID: $id'),
          ],
          const SizedBox(height: 10),
          _ProfileChip(icon: Icons.verified_user_outlined, label: role),
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
      avatar: Icon(icon, size: 17, color: const Color(0xff4fa7a1)),
      label: Text(label),
      backgroundColor: const Color(0xffedf8f6),
      labelStyle: const TextStyle(color: Color(0xff2f756f), fontWeight: FontWeight.w800),
      side: BorderSide.none,
    );
  }
}

InputDecoration _settingsInputDecoration(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    filled: true,
    fillColor: const Color(0xfff8fbfd),
  );
}

BoxDecoration _settingsPanelDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: const Color(0xffe3ebf5)),
    boxShadow: [
      BoxShadow(
        color: const Color(0xff202838).withValues(alpha: 0.055),
        blurRadius: 28,
        offset: const Offset(0, 14),
      ),
    ],
  );
}
