import 'package:flutter/material.dart';

import 'app_ui.dart';

class StudentAuthLayout extends StatelessWidget {
  const StudentAuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: isWide
                ? Row(
                    children: [
                      const Expanded(child: _AuthBrandPanel()),
                      const SizedBox(width: 32),
                      Expanded(
                        child: _AuthFormPanel(
                          title: title,
                          subtitle: subtitle,
                          child: child,
                        ),
                      ),
                    ],
                  )
                : SingleChildScrollView(
                    padding: context.pagePadding,
                    child: _AuthFormPanel(
                      title: title,
                      subtitle: subtitle,
                      compact: true,
                      child: child,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _AuthBrandPanel extends StatelessWidget {
  const _AuthBrandPanel();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: AppPanel(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _AuthLogo(),
            const SizedBox(height: 34),
            Text(
              'Student Inquiry System',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                    letterSpacing: 0,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'A quiet workspace for academic questions, status tracking, and department responses.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.muted,
                    height: 1.45,
                  ),
            ),
            const SizedBox(height: 28),
            const _AuthBenefits(),
          ],
        ),
      ),
    );
  }
}

class _AuthLogo extends StatelessWidget {
  const _AuthLogo();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AppIconBox(icon: Icons.school_outlined),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inquiry',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
            ),
            const Text(
              'System',
              style: TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AuthBenefits extends StatelessWidget {
  const _AuthBenefits();

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.send_outlined, 'Submit inquiries'),
      (Icons.track_changes_outlined, 'Track progress'),
      (Icons.notifications_none_outlined, 'Receive updates'),
    ];

    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                AppIconBox(icon: item.$1, size: 38, color: AppColors.teal),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.$2,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _AuthFormPanel extends StatelessWidget {
  const _AuthFormPanel({
    required this.title,
    required this.subtitle,
    required this.child,
    this.compact = false,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final form = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (compact) ...[
          const _AuthLogo(),
          const SizedBox(height: 28),
        ],
        Text(
          title,
          style: (compact
                  ? Theme.of(context).textTheme.headlineMedium
                  : Theme.of(context).textTheme.displaySmall)
              ?.copyWith(
            color: AppColors.text,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.muted,
                height: 1.35,
              ),
        ),
        SizedBox(height: compact ? 30 : 40),
        child,
      ],
    );

    if (compact) return form;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 48, 32, 48),
      child: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: form,
          ),
        ),
      ),
    );
  }
}

class StudentAuthTextField extends StatelessWidget {
  const StudentAuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.validator,
    this.suffix,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}

class StudentAuthSubmitButton extends StatelessWidget {
  const StudentAuthSubmitButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(label),
    );
  }
}
