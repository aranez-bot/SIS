import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/inquiry.dart';
import '../providers/auth_provider.dart';
import '../providers/inquiry_provider.dart';
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
    Future.microtask(() async {
      final provider = context.read<InquiryProvider>();
      await provider.loadDepartments();
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
        child: RefreshIndicator(
          onRefresh: _load,
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final heading = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Breadcrumb(onDark: true),
                        const SizedBox(height: 10),
                        Text(
                          widget.title ??
                              (isSuperAdmin
                                  ? 'Monitor All Inquiries'
                                  : isDepartmentAdmin
                                      ? 'Assigned Department Inquiries'
                                      : 'My Inquiries'),
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.subtitle ??
                              (isSuperAdmin
                                  ? 'Search, filter, and monitor inquiries from every department.'
                                  : isDepartmentAdmin
                                      ? 'Search, respond, update status, and forward inquiries assigned to your department.'
                                      : 'Search, filter, and track all inquiries you have submitted.'),
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.84),
                                  height: 1.42),
                        ),
                      ],
                    );

                    final refresh = IconButton.filledTonal(
                      tooltip: 'Refresh',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.18),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _load,
                      icon: const Icon(Icons.refresh),
                    );

                    if (constraints.maxWidth < 720) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          heading,
                          const SizedBox(height: 16),
                          refresh,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: heading),
                        const SizedBox(width: 18),
                        refresh,
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 22),
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
                onDepartmentChanged: (value) =>
                    setState(() => _departmentId = value),
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
              const SizedBox(height: 22),
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
          ),
        ),
      ),
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

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({this.onDark = false});

  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final color =
        onDark ? Colors.white.withValues(alpha: 0.76) : const Color(0xff64748b);
    final activeColor = onDark ? Colors.white : const Color(0xff253044);

    return Row(
      children: [
        Text('Dashboard',
            style:
                Theme.of(context).textTheme.bodyMedium?.copyWith(color: color)),
        Icon(Icons.chevron_right, size: 18, color: color),
        Text('Inquiries',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: activeColor, fontWeight: FontWeight.w800)),
      ],
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

    return Container(
      decoration: _inquiryPanelDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 300,
              child: TextField(
                controller: search,
                autofocus: focusSearch,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  labelText: 'Search inquiry',
                  filled: true,
                  fillColor: Color(0xfff8fafc),
                ),
                onSubmitted: (_) => onApply(),
              ),
            ),
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<String>(
                key: ValueKey(status ?? 'all-statuses'),
                initialValue: status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  filled: true,
                  fillColor: Color(0xfff8fafc),
                ),
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(
                      value: 'in_progress', child: Text('In Progress')),
                  DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
                  DropdownMenuItem(value: 'closed', child: Text('Closed')),
                ],
                onChanged: onStatusChanged,
              ),
            ),
            if (showCategoryFilter)
              SizedBox(
                width: 220,
                child: DropdownButtonFormField<String>(
                  key: ValueKey(category ?? 'all-categories'),
                  initialValue: category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    filled: true,
                    fillColor: Color(0xfff8fafc),
                  ),
                  items: InquiryProvider.categories
                      .map((item) => DropdownMenuItem(
                          value: item, child: Text(_label(item))))
                      .toList(),
                  onChanged: onCategoryChanged,
                ),
              ),
            SizedBox(
              width: 250,
              child: isDepartmentAdmin
                  ? const SizedBox.shrink()
                  : DropdownButtonFormField<int>(
                      key: ValueKey(departmentId ?? 0),
                      initialValue: departments.any(
                              (department) => department.id == departmentId)
                          ? departmentId
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Department',
                        filled: true,
                        fillColor: Color(0xfff8fafc),
                      ),
                      items: departments
                          .map((department) => DropdownMenuItem(
                              value: department.id,
                              child: Text(department.name)))
                          .toList(),
                      onChanged: onDepartmentChanged,
                    ),
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(128, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final picked = await _pickDate(context, fromDate);
                if (picked != null) onFromDateChanged(picked);
              },
              icon: const Icon(Icons.date_range),
              label:
                  Text(fromDate == null ? 'From date' : _dateLabel(fromDate!)),
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(128, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final picked = await _pickDate(context, toDate);
                if (picked != null) onToDateChanged(picked);
              },
              icon: const Icon(Icons.event),
              label: Text(toDate == null ? 'To date' : _dateLabel(toDate!)),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size(112, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onApply,
              icon: const Icon(Icons.filter_alt),
              label: const Text('Apply'),
            ),
            TextButton(onPressed: onClear, child: const Text('Clear')),
          ],
        ),
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
    return Container(
      decoration: _inquiryPanelDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  isSuperAdmin
                      ? 'All Inquiries'
                      : isDepartmentAdmin
                          ? 'Assigned Inquiries'
                          : 'Inquiry History',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: const Color(0xff253044),
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const Spacer(),
                Chip(
                  avatar: const Icon(Icons.table_rows_outlined,
                      size: 17, color: Color(0xff4f67d8)),
                  label: Text(
                      '${inquiries.length} record${inquiries.length == 1 ? '' : 's'}'),
                  backgroundColor: const Color(0xffeef3ff),
                  labelStyle: const TextStyle(
                      color: Color(0xff4f67d8), fontWeight: FontWeight.w800),
                  side: BorderSide.none,
                ),
              ],
            ),
            const SizedBox(height: 20),
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
                      constraints:
                          BoxConstraints(minWidth: constraints.maxWidth),
                      child: DataTable(
                        columnSpacing: 54,
                        dataRowMaxHeight: 76,
                        dataRowMinHeight: 68,
                        dividerThickness: 0.8,
                        headingRowHeight: 62,
                        horizontalMargin: 30,
                        headingRowColor:
                            WidgetStateProperty.all(const Color(0xfff6f9fd)),
                        headingTextStyle:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: const Color(0xff526074),
                                  fontWeight: FontWeight.w800,
                                ),
                        dataTextStyle:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: const Color(0xff344054),
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
                                          const BoxConstraints(maxWidth: 380),
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
                                  DataCell(
                                      _StatusBadge(status: inquiry.status)),
                                  DataCell(
                                      Text(_formatDate(inquiry.createdAt))),
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffe3ebf5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff202838).withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(18),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: const Color(0xffdbeafe),
          foregroundColor: const Color(0xff1d4ed8),
          child: Text('${inquiry.priority}'),
        ),
        title: Text(
          inquiry.subject,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(inquiry.departmentName ?? 'Department'),
              _StatusBadge(status: inquiry.status),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'view') _openDetail(context, inquiry.id);
            if (value == 'edit') _openEdit(context, inquiry);
            if (value == 'delete')
              context.read<InquiryProvider>().deleteInquiry(inquiry.id);
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
      'pending' => const Color(0xffd97706),
      'in_progress' => const Color(0xff2563eb),
      'answered' => const Color(0xff7c3aed),
      'resolved' => const Color(0xff059669),
      'rejected' => const Color(0xffdc2626),
      _ => const Color(0xff64748b),
    };

    return Chip(
      label: Text(_label(status)),
      labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      backgroundColor: color.withValues(alpha: 0.12),
      labelStyle:
          TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w700),
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: const Color(0xfff8fbfd),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffe3ebf5)),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined,
              size: 42, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text('No inquiries found',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          const Text('Try adjusting your search or filters.'),
        ],
      ),
    );
  }
}

BoxDecoration _inquiryPanelDecoration() {
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
