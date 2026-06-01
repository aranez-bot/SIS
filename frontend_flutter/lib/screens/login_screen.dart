import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/student_auth_layout.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return StudentAuthLayout(
      title: 'Welcome back, student',
      subtitle: 'Sign in with your student account to continue.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StudentAuthTextField(
              controller: _email,
              label: 'Student email address',
              hintText: 'student@university.edu',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  value == null || value.isEmpty ? 'Email is required' : null,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Password',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: const Color(0xff202433),
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                const TextButton(
                  onPressed: null,
                  child: Text('Forgot password?'),
                ),
              ],
            ),
            const SizedBox(height: 2),
            StudentAuthTextField(
              controller: _password,
              label: '',
              hintText: 'Enter your password',
              icon: Icons.lock_outline,
              obscureText: !_showPassword,
              validator: (value) => value == null || value.isEmpty
                  ? 'Password is required'
                  : null,
              suffix: IconButton(
                tooltip: _showPassword ? 'Hide password' : 'Show password',
                onPressed: () => setState(() => _showPassword = !_showPassword),
                icon: Icon(_showPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined),
              ),
            ),
            if (auth.error != null) ...[
              const SizedBox(height: 14),
              Text(auth.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 26),
            StudentAuthSubmitButton(
              label: 'Sign in',
              isLoading: auth.isLoading,
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  context
                      .read<AuthProvider>()
                      .login(_email.text.trim(), _password.text);
                }
              },
            ),
            const SizedBox(height: 34),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'New student? ',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: const Color(0xff7d8797)),
                ),
                TextButton(
                  onPressed: auth.isLoading
                      ? null
                      : () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const RegisterScreen()),
                          ),
                  child: const Text('Create your account'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
