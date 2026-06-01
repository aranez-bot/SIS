import 'package:flutter/material.dart';

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
      backgroundColor: const Color(0xfff6f7fb),
      body: isWide
          ? Row(
              children: [
                const Expanded(flex: 9, child: _AuthBrandPanel()),
                Expanded(
                  flex: 11,
                  child: _AuthFormPanel(title: title, subtitle: subtitle, child: child),
                ),
              ],
            )
          : CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 360, child: _AuthBrandPanel(compact: true))),
                SliverToBoxAdapter(
                  child: _AuthFormPanel(title: title, subtitle: subtitle, child: child, compact: true),
                ),
              ],
            ),
    );
  }
}

class _AuthBrandPanel extends StatelessWidget {
  const _AuthBrandPanel({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff5660d8), Color(0xff7f90ed), Color(0xff9ab8f6)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            top: compact ? 148 : 250,
            right: 50,
            child: _GlassShape(width: 200, height: 122, radius: 22),
          ),
          Positioned(
            top: compact ? 218 : 324,
            right: 100,
            child: _GlassShape(width: 140, height: 70, radius: 18),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(compact ? 24 : 48, compact ? 28 : 42, compact ? 24 : 48, compact ? 24 : 42),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _AuthLogo(),
                const Spacer(),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your academic\nsupport portal',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              height: 1.08,
                              letterSpacing: 0,
                              fontSize: compact ? 34 : null,
                            ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'A dedicated platform for students to submit, track, and resolve academic inquiries fast and hassle-free.',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.84),
                              height: 1.55,
                            ),
                      ),
                    ],
                  ),
                ),
                if (!compact) ...[
                  const Spacer(),
                  const _AuthBenefits(),
                ] else
                  const SizedBox(height: 20),
              ],
            ),
          ),
        ],
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
        _GlassIcon(icon: Icons.school_outlined, size: 56),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student Inquiry',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
            ),
            Text(
              'System',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
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
      (Icons.chat_bubble_outline, 'Submit Inquiries Easily', 'Send questions to department heads from anywhere, anytime.'),
      (Icons.assignment_outlined, 'Track Your Requests', 'Monitor the status of every inquiry in real time.'),
      (Icons.menu_book_outlined, 'Academic Support', 'Get help with enrollment, grades, schedules, and more.'),
    ];

    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              children: [
                _GlassIcon(icon: item.$1, size: 45),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.$2,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.$3,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.78),
                            ),
                      ),
                    ],
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
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: compact ? 22 : 48, vertical: compact ? 36 : 48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: const Color(0xff171b29),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                        height: 1.08,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xff748197),
                        height: 1.35,
                      ),
                ),
                const SizedBox(height: 48),
                child,
              ],
            ),
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
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: const Color(0xff202433),
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),
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
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xffd5dce9)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xff6b76e7), width: 1.4),
            ),
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
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(colors: [Color(0xff5960d7), Color(0xff96b6f5)]),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff5960d7).withValues(alpha: 0.22),
            blurRadius: 36,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: FilledButton(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _GlassIcon extends StatelessWidget {
  const _GlassIcon({required this.icon, required this.size});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.13),
        border: Border.all(color: Colors.white.withValues(alpha: 0.34)),
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.42),
    );
  }
}

class _GlassShape extends StatelessWidget {
  const _GlassShape({required this.width, required this.height, required this.radius});

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
      ),
    );
  }
}
