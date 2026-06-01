import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/inquiry.dart';
import '../providers/auth_provider.dart';
import '../providers/inquiry_provider.dart';
import '../widgets/app_ui.dart';
import 'inquiry_detail_screen.dart';
import 'inquiry_form_screen.dart';

class InquiryListScreen extends StatefulWidget {
  const InquiryListScreen({
    super.key,
    this.title,
    this.subtitle,
    this.initialStatus,
    this.focusSearch = false,
    this.showCategoryFilter = true,
  });

  final String? title;
  final String? subtitle;
  final String? initialStatus;
  final bool focusSearch;
  final bool showCategoryFilter;

  @override
  State<InquiryListScreen> createState() => _InquiryListScreenState();
}

class _InquiryListScreenState extends State<InquiryListScreen> {
  final _search = TextEditingController();
  String? _status;
  String? _category;
  int? _departmentId;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final provider = context.read<InquiryProvider>();
      await provider.loadDepartments();
      if (!mounted) return;
      await _load();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InquiryProvider>();
    final userType = context.watch<AuthProvider>().user?.userType;
    final isSuperAdmin = userType == 'super_admin';
    final isDepartmentAdmin = userType == 'department_admin';

    return AppScreen(
      onRefresh: _load,
      children: [
        AppHeader(
          icon: Icons.inbox_outlined,
          title: widget.title ??
              (isSuperAdmin
                  ? 'All Inquiries'
                  : isDepartmentAdmin
                      ? 'Assigned Inquiries'
                      : 'My Inquiries'),
          subtitle: widget.subtitle ??
              (isSuperAdmin
                  ? 'Search and monitor inquiries from every department.'
                  : isDepartmentAdmin
                      ? 'Review, respond, and update assigned inquiries.'
                      : 'Track all inquiries you have submitted.'),
          trailing: IconButton.outlined(
            tooltip: 'Refresh',
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ),
        const SizedBox(height: 16),
        _Filters(
          search: _search,
          status: _status,
          category: _category,
          departmentId: _departmentId,
          isDepartmentAdmin: isDepartmentAdmin,
          showCategoryFilter: widget.showCategoryFilter,
          focusSearch: widget.focusSearch,
          fromDate: _fromDate,
          toDate: _toDate,
          onStatusChanged: (value) => setState(() => _status = value),
          onCategoryChanged: (value) => setState(() => _category = value),
          onDepartmentChanged: (value) => setState(() => _departmentId = value),
          onFromDateChanged: (value) => setState(() => _fromDate = value),
          onToDateChanged: (value) => setState(() => _toDate = value),
          onApply: _load,
          onClear: () {
            setState(() {
              _search.clear();
              _status = null;
              _category = null;
              _departmentId = null;
              _fromDate = null;
              _toDate = null;
            });
            _load();
          },
        ),
        const SizedBox(height: 16),
        if (provider.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: CircularProgressIndicator(),
            ),
          )
        else
          _InquiryResults(
              inquiries: provider.inquiries,
              isSuperAdmin: isSuperAdmin,
              isDepartmentAdmin: isDepartmentAdmin),
      ],
    );
  }

  Future<void> _load() {
    return context.read<InquiryProvider>().loadInquiries(
          search: _search.text,
          status: _status,
          category: _category,
          departmentId: _departmentId,
          fromDate: _fromDate,
          toDate: _toDate,
        );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.search,
    required this.status,
    required this.category,
    required this.departmentId,
    required this.isDepartmentAdmin,
    required this.showCategoryFilter,
    required this.focusSearch,
    required this.fromDate,
    required this.toDate,
    required this.onStatusChanged,
    required this.onCategoryChanged,
    required this.onDepartmentChanged,
    required this.onFromDateChanged,
    required this.onToDateChanged,
    required this.onApply,
    required this.onClear,
  });

  final TextEditingController search;
  final String? status;
  final String? category;
  final int? departmentId;
  final bool isDepartmentAdmin;
  final bool showCategoryFilter;
  final bool focusSearch;
  final DateTime? fromDate;
  final DateTime? toDate;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<int?> onDepartmentChanged;
  final ValueChanged<DateTime?> onFromDateChanged;
  final ValueChanged<DateTime?> onToDateChanged;
  final VoidCallback onApply;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final departments = context.watch<InquiryProvider>().departments;

    return AppPanel(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;
          final fieldWidth = compact ? constraints.maxWidth : 220.0;
          final wideFieldWidth = compact ? constraints.maxWidth : 300.0;
          final buttonWidth = compact ? constraints.maxWidth : null;

          return Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: wideFieldWidth,
                child: TextField(
                  controller: search,
                  autofocus: focusSearch,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    labelText: 'Search inquiry',
                  ),
                  onSubmitted: (_) => onApply(),
                ),
              ),
              SizedBox(
                width: fieldWidth,
                child: DropdownButtonFormField<String>(
                  key: ValueKey(status ?? 'all-statuses'),
                  initialValue: status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(
                        value: 'in_progress', child: Text('In Progress')),
                    DropdownMenuItem(
                        value: 'resolved', child: Text('Resolved')),
                    DropdownMenuItem(value: 'closed', child: Text('Closed')),
                  ],
                  onChanged: onStatusChanged,
                ),
              ),
              if (showCategoryFilter)
                SizedBox(
                  width: fieldWidth,
                  child: DropdownButtonFormField<String>(
                    key: ValueKey(category ?? 'all-categories'),
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: InquiryProvider.categories
                        .map((item) => DropdownMenuItem(
                            value: item, child: Text(_label(item))))
                        .toList(),
                    onChanged: onCategoryChanged,
                  ),
                ),
              if (!isDepartmentAdmin)
                SizedBox(
                  width: compact ? constraints.maxWidth : 250,
                  child: DropdownButtonFormField<int>(
                    key: ValueKey(departmentId ?? 0),
                    initialValue: departments
                            .any((department) => department.id == departmentId)
                        ? departmentId
                        : null,
                    decoration: const InputDecoration(labelText: 'Department'),
                    items: departments
                        .map((department) => DropdownMenuItem(
                            value: department.id, child: Text(department.name)))
                        .toList(),
                    onChanged: onDepartmentChanged,
                  ),
                ),
              SizedBox(
                width: buttonWidth,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await _pickDate(context, fromDate);
                    if (picked != null) onFromDateChanged(picked);
                  },
                  icon: const Icon(Icons.date_range),
                  label: Text(
                      fromDate == null ? 'From date' : _dateLabel(fromDate!)),
                ),
              ),
              SizedBox(
                width: buttonWidth,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await _pickDate(context, toDate);
                    if (picked != null) onToDateChanged(picked);
                  },
                  icon: const Icon(Icons.event),
                  label: Text(toDate == null ? 'To date' : _dateLabel(toDate!)),
                ),
              ),
              SizedBox(
                width: buttonWidth,
                child: FilledButton.icon(
                  onPressed: onApply,
                  icon: const Icon(Icons.filter_alt),
                  label: const Text('Apply'),
                ),
              ),
              SizedBox(
                width: buttonWidth,
                child:
                    TextButton(onPressed: onClear, child: const Text('Clear')),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<DateTime?> _pickDate(BuildContext context, DateTime? initialDate) {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
    );
  }

  String _dateLabel(DateTime date) => '${date.month}/${date.day}/${date.year}';
}

class _InquiryResults extends StatelessWidget {
  const _InquiryResults(
      {required this.inquiries,
      required this.isSuperAdmin,
      required this.isDepartmentAdmin});

  final List<Inquiry> inquiries;
  final bool isSuperAdmin;
  final bool isDepartmentAdmin;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.all(context.isCompact ? 14 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionTitle(
            title: isSuperAdmin
                ? 'All Inquiries'
                : isDepartmentAdmin
                    ? 'Assigned Inquiries'
                    : 'Inquiry History',
            trailing: AppStatusChip(
              icon: Icons.table_rows_outlined,
              label:
                  '${inquiries.length} record${inquiries.length == 1 ? '' : 's'}',
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          if (inquiries.isEmpty)
            const _EmptyState()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 760) {
                  return Column(
                    children: inquiries
                        .map(
                          (inquiry) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _InquiryCard(
                                inquiry: inquiry,
                                isSuperAdmin: isSuperAdmin,
                                isDepartmentAdmin: isDepartmentAdmin),
                          ),
                        )
                        .toList(),
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      columnSpacing: 42,
                      dataRowMaxHeight: 72,
                      dataRowMinHeight: 60,
                      dividerThickness: 0.7,
                      headingRowHeight: 54,
                      horizontalMargin: 20,
                      headingRowColor:
                          WidgetStateProperty.all(AppColors.surfaceAlt),
                      headingTextStyle:
                          Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AppColors.muted,
                                fontWeight: FontWeight.w800,
                              ),
                      dataTextStyle:
                          Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AppColors.text,
                                fontWeight: FontWeight.w500,
                              ),
                      columns: const [
                        DataColumn(label: Text('Inquiry ID')),
                        DataColumn(label: Text('Subject')),
                        DataColumn(label: Text('Department')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Date Submitted')),
                        DataColumn(label: Text('Action')),
                      ],
                      rows: inquiries
                          .map(
                            (inquiry) => DataRow(
                              cells: [
                                DataCell(Text(
                                    'INQ-${inquiry.id.toString().padLeft(3, '0')}')),
                                DataCell(
                                  ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 360),
                                    child: Text(
                                      inquiry.subject,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                                DataCell(Text(
                                    inquiry.departmentName ?? 'Department')),
                                DataCell(_StatusBadge(status: inquiry.status)),
                                DataCell(Text(_formatDate(inquiry.createdAt))),
                                DataCell(_InquiryActions(
                                    inquiry: inquiry,
                                    isSuperAdmin: isSuperAdmin,
                                    isDepartmentAdmin: isDepartmentAdmin)),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _InquiryCard extends StatelessWidget {
  const _InquiryCard(
      {required this.inquiry,
      required this.isSuperAdmin,
      required this.isDepartmentAdmin});

  final Inquiry inquiry;
  final bool isSuperAdmin;
  final bool isDepartmentAdmin;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      padding: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        leading: AppIconBox(
          icon: Icons.chat_bubble_outline,
          size: 42,
          color: _priorityColor(inquiry.priority),
        ),
        title: Text(
          inquiry.subject,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                inquiry.departmentName ?? 'Department',
                style: const TextStyle(color: AppColors.muted),
              ),
              _StatusBadge(status: inquiry.status),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'view') _openDetail(context, inquiry.id);
            if (value == 'edit') _openEdit(context, inquiry);
            if (value == 'delete') {
              context.read<InquiryProvider>().deleteInquiry(inquiry.id);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'view', child: Text('View')),
            if (!isSuperAdmin && !isDepartmentAdmin)
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
            if (!isSuperAdmin && !isDepartmentAdmin)
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
        onTap: () => _openDetail(context, inquiry.id),
      ),
    );
  }
}

class _InquiryActions extends StatelessWidget {
  const _InquiryActions(
      {required this.inquiry,
      required this.isSuperAdmin,
      required this.isDepartmentAdmin});

  final Inquiry inquiry;
  final bool isSuperAdmin;
  final bool isDepartmentAdmin;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'View',
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xffeef3ff),
            foregroundColor: const Color(0xff4f67d8),
            minimumSize: const Size(46, 46),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.visibility_outlined),
          onPressed: () => _openDetail(context, inquiry.id),
        ),
        if (!isSuperAdmin && !isDepartmentAdmin)
          IconButton(
            tooltip: 'Edit',
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xffedf8f6),
              foregroundColor: const Color(0xff4fa7a1),
              minimumSize: const Size(46, 46),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _openEdit(context, inquiry),
          ),
        if (!isSuperAdmin && !isDepartmentAdmin)
          IconButton(
            tooltip: 'Delete',
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xfffff1f3),
              foregroundColor: const Color(0xffc75b68),
              minimumSize: const Size(46, 46),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.delete_outline),
            onPressed: () =>
                context.read<InquiryProvider>().deleteInquiry(inquiry.id),
          ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'pending' => AppColors.warning,
      'in_progress' => AppColors.primary,
      'answered' => AppColors.teal,
      'resolved' => AppColors.success,
      'rejected' => AppColors.danger,
      _ => AppColors.muted,
    };

    return AppStatusChip(label: _label(status), color: color);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const AppEmptyState(
      icon: Icons.inbox_outlined,
      title: 'No inquiries found',
      message: 'Try adjusting your search or filters.',
    );
  }
}

void _openDetail(BuildContext context, int inquiryId) {
  Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => InquiryDetailScreen(inquiryId: inquiryId)));
}

void _openEdit(BuildContext context, Inquiry inquiry) {
  Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => InquiryFormScreen(inquiry: inquiry)));
}

String _label(String value) => value
    .split('_')
    .map((word) =>
        word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}')
    .join(' ');

String _formatDate(String? value) {
  if (value == null || value.isEmpty) return '-';
  final date = DateTime.tryParse(value);
  if (date == null) return value;
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

Color _priorityColor(int priority) => switch (priority) {
      1 => AppColors.success,
      2 => AppColors.teal,
      3 => AppColors.warning,
      _ => AppColors.danger,
    };
