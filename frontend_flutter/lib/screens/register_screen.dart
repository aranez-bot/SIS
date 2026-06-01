import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/student_auth_layout.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _userIdentifier = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordConfirmation = TextEditingController();
  bool _showPassword = false;
  bool _showConfirmation = false;

  @override
  void dispose() {
    _name.dispose();
    _userIdentifier.dispose();
    _email.dispose();
    _password.dispose();
    _passwordConfirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isWide = MediaQuery.sizeOf(context).width >= 620;

    return StudentAuthLayout(
      title: 'Create your account',
      subtitle: 'Enter your details to start using the inquiry portal.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ResponsiveFields(
              isWide: isWide,
              children: [
                StudentAuthTextField(
                  controller: _name,
                  label: 'Full name',
                  hintText: 'Juan Dela Cruz',
                  icon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Name is required'
                      : null,
                ),
                StudentAuthTextField(
                  controller: _userIdentifier,
                  label: 'Student ID',
                  hintText: 'STU-2026-001',
                  icon: Icons.badge_outlined,
                  textInputAction: TextInputAction.next,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Student ID is required'
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 22),
            StudentAuthTextField(
              controller: _email,
              label: 'Email address',
              hintText: 'student@university.edu',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
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
            const SizedBox(height: 22),
            _ResponsiveFields(
              isWide: isWide,
              children: [
                StudentAuthTextField(
                  controller: _password,
                  label: 'Password',
                  hintText: 'Enter your password',
                  icon: Icons.lock_outline,
                  obscureText: !_showPassword,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                  suffix: IconButton(
                    tooltip: _showPassword ? 'Hide password' : 'Show password',
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                    icon: Icon(_showPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                  ),
                ),
                StudentAuthTextField(
                  controller: _passwordConfirmation,
                  label: 'Confirm password',
                  hintText: 'Confirm your password',
                  icon: Icons.lock_outline,
                  obscureText: !_showConfirmation,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _password.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  suffix: IconButton(
                    tooltip:
                        _showConfirmation ? 'Hide password' : 'Show password',
                    onPressed: () =>
                        setState(() => _showConfirmation = !_showConfirmation),
                    icon: Icon(_showConfirmation
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                  ),
                ),
              ],
            ),
            if (auth.error != null) ...[
              const SizedBox(height: 14),
              Text(auth.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 26),
            StudentAuthSubmitButton(
              label: 'Create account',
              isLoading: auth.isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: 28),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: const Color(0xff7d8797)),
                ),
                TextButton(
                  onPressed:
                      auth.isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Sign in'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final created = await context.read<AuthProvider>().register(
          name: _name.text.trim(),
          userIdentifier: _userIdentifier.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
          passwordConfirmation: _passwordConfirmation.text,
        );

    if (created && mounted) {
      Navigator.pop(context);
    }
  }
}

class _ResponsiveFields extends StatelessWidget {
  const _ResponsiveFields({required this.isWide, required this.children});

  final bool isWide;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (!isWide) {
      return Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            if (index > 0) const SizedBox(height: 22),
            children[index],
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < children.length; index++) ...[
          if (index > 0) const SizedBox(width: 18),
          Expanded(child: children[index]),
        ],
      ],
    );
  }
}
