import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/inquiry.dart';
import '../providers/auth_provider.dart';
import '../providers/inquiry_provider.dart';
import 'notifications_screen.dart';

class InquiryFormScreen extends StatefulWidget {
  const InquiryFormScreen({super.key, this.inquiry});

  final Inquiry? inquiry;

  @override
  State<InquiryFormScreen> createState() => _InquiryFormScreenState();
}

class _InquiryFormScreenState extends State<InquiryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _description = TextEditingController();
  int? _departmentId;
  String _category = 'registrar';
  int _priority = 1;
  bool _saving = false;

  bool get _isEditing => widget.inquiry != null;

  @override
  void initState() {
    super.initState();
    final inquiry = widget.inquiry;
    if (inquiry != null) {
      _subject.text = inquiry.subject;
      _description.text = inquiry.description;
      _departmentId = inquiry.departmentId;
      _category = inquiry.category;
      _priority = inquiry.priority.clamp(1, 4).toInt();
    }
    Future.microtask(() => context.read<InquiryProvider>().loadDepartments());
  }

  @override
  void dispose() {
    _subject.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<InquiryProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: const Color(0xfff6f8fb),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(28),
          children: [
            _TopHeader(
              name: user?.name ?? 'John Doe',
              role: _roleLabel(user?.userType ?? 'student'),
              unreadAlerts: provider.unreadNotifications,
            ),
            const SizedBox(height: 24),
            Text(
              _isEditing ? 'Edit Inquiry' : 'Create Inquiry',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff172033),
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Submit a concern or question to the appropriate department.',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: const Color(0xff64748b)),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              shadowColor: const Color(0xff0f172a).withValues(alpha: 0.08),
              surfaceTintColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<int>(
                      key: ValueKey(_departmentId ?? 0),
                      initialValue: provider.departments.any(
                              (department) => department.id == _departmentId)
                          ? _departmentId
                          : null,
                      decoration: InputDecoration(
                        label: const _RequiredLabel('Department'),
                        hintText: 'Select department',
                        prefixIcon: const Icon(Icons.apartment_outlined),
                        filled: true,
                        fillColor: const Color(0xfff8fafc),
                      ),
                      items: provider.departments
                          .map((department) => DropdownMenuItem(
                              value: department.id,
                              child: Text(department.name)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _departmentId = value),
                      validator: (value) =>
                          value == null ? 'Department is required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _subject,
                      decoration: InputDecoration(
                        label: const _RequiredLabel('Subject'),
                        hintText: 'Enter subject',
                        prefixIcon: const Icon(Icons.subject_outlined),
                        filled: true,
                        fillColor: const Color(0xfff8fafc),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Subject is required'
                              : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _description,
                      minLines: 8,
                      maxLines: 12,
                      decoration: InputDecoration(
                        label: const _RequiredLabel('Description'),
                        hintText: 'Provide details of your inquiry...',
                        alignLabelWithHint: true,
                        filled: true,
                        fillColor: const Color(0xfff8fafc),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Description is required'
                              : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: _priority,
                      decoration: InputDecoration(
                        labelText: 'Priority',
                        hintText: 'Select priority',
                        prefixIcon: const Icon(Icons.flag_outlined),
                        filled: true,
                        fillColor: const Color(0xfff8fafc),
                      ),
                      items: List.generate(4, (index) {
                        final value = index + 1;
                        return DropdownMenuItem(
                          value: value,
                          child: Text('$value - ${_priorityLabel(value)}'),
                        );
                      }),
                      onChanged: (value) =>
                          setState(() => _priority = value ?? 1),
                    ),
                    const SizedBox(height: 28),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        OutlinedButton(
                          onPressed: _saving ? null : _cancel,
                          child: const Text('Cancel'),
                        ),
                        FilledButton.icon(
                          icon: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.save_outlined),
                          onPressed: _saving ? null : _save,
                          label: Text(_saving ? 'Saving...' : 'Save Inquiry'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      await context.read<InquiryProvider>().saveInquiry(
            id: widget.inquiry?.id,
            departmentId: _departmentId!,
            category: _category,
            subject: _subject.text.trim(),
            description: _description.text.trim(),
            priority: _priority,
          );

      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else if (mounted) {
        _reset();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inquiry saved successfully.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _cancel() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    _reset();
  }

  void _reset() {
    _formKey.currentState!.reset();
    _subject.clear();
    _description.clear();
    setState(() {
      _departmentId = null;
      _category = 'registrar';
      _priority = 1;
    });
  }

  String _label(String value) => value
      .split('_')
      .map((word) =>
          word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');

  String _priorityLabel(int value) => switch (value) {
        1 => 'Low',
        2 => 'Medium',
        3 => 'High',
        _ => 'Urgent',
      };

  String _roleLabel(String value) => _label(value);
}

class _TopHeader extends StatelessWidget {
  const _TopHeader({
    required this.name,
    required this.role,
    required this.unreadAlerts,
  });

  final String name;
  final String role;
  final int unreadAlerts;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 12,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Dashboard',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: const Color(0xff64748b))),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xff94a3b8)),
            Text('Inquiries',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: const Color(0xff64748b))),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xff94a3b8)),
            Text('Create Inquiry',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Notifications',
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const NotificationsScreen())),
              icon: Badge(
                isLabelVisible: unreadAlerts > 0,
                label: Text('$unreadAlerts'),
                child: const Icon(Icons.notifications_outlined),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(child: Text(initials.isEmpty ? 'JD' : initials)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleSmall),
                Text(role,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: const Color(0xff64748b))),
              ],
            ),
            const Icon(Icons.keyboard_arrow_down, color: Color(0xff64748b)),
          ],
        ),
      ],
    );
  }
}

class _RequiredLabel extends StatelessWidget {
  const _RequiredLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: text,
        style: DefaultTextStyle.of(context).style,
        children: const [
          TextSpan(text: ' *', style: TextStyle(color: Color(0xffdc2626))),
        ],
      ),
    );
  }
}
