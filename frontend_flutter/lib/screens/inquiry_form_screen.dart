import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/inquiry.dart';
import '../providers/inquiry_provider.dart';
import '../widgets/app_ui.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<InquiryProvider>().loadDepartments();
    });
  }

  @override
  void dispose() {
    _subject.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InquiryProvider>();

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
                  AppHeader(
                    icon: _isEditing
                        ? Icons.edit_note_outlined
                        : Icons.add_comment_outlined,
                    title: _isEditing ? 'Edit Inquiry' : 'Create Inquiry',
                    subtitle:
                        'Send your concern to the department that can handle it.',
                    trailing: IconButton.outlined(
                      tooltip: 'Notifications',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const NotificationsScreen()),
                      ),
                      icon: Badge(
                        isLabelVisible: provider.unreadNotifications > 0,
                        label: Text('${provider.unreadNotifications}'),
                        child: const Icon(Icons.notifications_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DropdownButtonFormField<int>(
                          key: ValueKey(_departmentId ?? 0),
                          initialValue: provider.departments.any((department) =>
                                  department.id == _departmentId)
                              ? _departmentId
                              : null,
                          decoration: const InputDecoration(
                            label: _RequiredLabel('Department'),
                            hintText: 'Select department',
                            prefixIcon: Icon(Icons.apartment_outlined),
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
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          initialValue: _category,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            prefixIcon: Icon(Icons.category_outlined),
                          ),
                          items: InquiryProvider.categories
                              .map((item) => DropdownMenuItem(
                                  value: item, child: Text(_label(item))))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _category = value ?? _category),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _subject,
                          decoration: const InputDecoration(
                            label: _RequiredLabel('Subject'),
                            hintText: 'Enter subject',
                            prefixIcon: Icon(Icons.subject_outlined),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Subject is required'
                                  : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _description,
                          minLines: context.isCompact ? 6 : 8,
                          maxLines: 12,
                          decoration: const InputDecoration(
                            label: _RequiredLabel('Description'),
                            hintText: 'Provide details of your inquiry...',
                            alignLabelWithHint: true,
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Description is required'
                                  : null,
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<int>(
                          initialValue: _priority,
                          decoration: const InputDecoration(
                            labelText: 'Priority',
                            hintText: 'Select priority',
                            prefixIcon: Icon(Icons.flag_outlined),
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
                        const SizedBox(height: 22),
                        _FormActions(
                          saving: _saving,
                          onCancel: _cancel,
                          onSave: _save,
                        ),
                      ],
                    ),
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
      final provider = context.read<InquiryProvider>();
      await provider.saveInquiry(
        id: widget.inquiry?.id,
        departmentId: _departmentId!,
        category: _category,
        subject: _subject.text.trim(),
        description: _description.text.trim(),
        priority: _priority,
      );

      if (!mounted) return;

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
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
}

class _FormActions extends StatelessWidget {
  const _FormActions({
    required this.saving,
    required this.onCancel,
    required this.onSave,
  });

  final bool saving;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final saveButton = FilledButton.icon(
      icon: saving
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.save_outlined),
      onPressed: saving ? null : onSave,
      label: Text(saving ? 'Saving...' : 'Save Inquiry'),
    );

    if (context.isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          saveButton,
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: saving ? null : onCancel,
            child: const Text('Cancel'),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: saving ? null : onCancel,
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 12),
        saveButton,
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
          TextSpan(text: ' *', style: TextStyle(color: AppColors.danger)),
        ],
      ),
    );
  }
}
