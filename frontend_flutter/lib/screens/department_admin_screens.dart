import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/faq_item.dart';
import '../models/inquiry.dart';
import '../providers/inquiry_provider.dart';

class DepartmentReportsScreen extends StatefulWidget {
  const DepartmentReportsScreen({super.key});

  @override
  State<DepartmentReportsScreen> createState() =>
      _DepartmentReportsScreenState();
}

class _DepartmentReportsScreenState extends State<DepartmentReportsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_loadReports);
  }

  Future<void> _loadReports() async {
    final provider = context.read<InquiryProvider>();
    await provider.loadDashboard();
    await provider.loadInquiries();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InquiryProvider>();
    final counts = provider.counts;
    final inquiries = provider.inquiries.isNotEmpty
        ? provider.inquiries
        : provider.recentInquiries;
    final total = _count(counts, 'total');
    final completed = _count(counts, 'resolved') + _count(counts, 'closed');
    final rate = total == 0 ? 0 : ((completed / total) * 100).round();
    final pending = _count(counts, 'pending');
    final inProgress = _count(counts, 'in_progress');
    final resolved = _count(counts, 'resolved');
    final closed = _count(counts, 'closed');
    final categories =
        _frequency(inquiries.map((item) => _label(item.category)));
    final priorities =
        _frequency(inquiries.map((item) => _priorityLabel(item.priority)));

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
          onRefresh: _loadReports,
          child: ListView(
            padding: const EdgeInsets.all(30),
            children: [
              _ReportHero(
                total: total,
                rate: rate,
                isLoading: provider.isLoading,
                onRefresh: _loadReports,
              ),
              const SizedBox(height: 22),
              _ReportMetricGrid(
                total: total,
                pending: pending,
                inProgress: inProgress,
                resolved: resolved,
                closed: closed,
              ),
              const SizedBox(height: 22),
              LayoutBuilder(
                builder: (context, constraints) {
                  final panels = [
                    _StatusBreakdownPanel(
                      total: total,
                      rows: [
                        _ReportStatusRow(
                            'Pending',
                            pending,
                            const Color(0xffc48a3a),
                            Icons.hourglass_top_outlined),
                        _ReportStatusRow('In Progress', inProgress,
                            const Color(0xff4f67d8), Icons.sync_outlined),
                        _ReportStatusRow(
                            'Resolved',
                            resolved,
                            const Color(0xff4c9a73),
                            Icons.check_circle_outline),
                        _ReportStatusRow('Closed', closed,
                            const Color(0xff718096), Icons.lock_outline),
                      ],
                    ),
                    _CategoryReportPanel(
                        title: 'Common Categories',
                        items: _topEntries(categories)),
                    _CategoryReportPanel(
                        title: 'Priority Mix', items: _topEntries(priorities)),
                  ];

                  if (constraints.maxWidth < 980) {
                    return Column(
                      children: panels
                          .map((panel) => Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: panel,
                              ))
                          .toList(),
                    );
                  }

                  return Column(
                    children: [
                      panels.first,
                      const SizedBox(height: 18),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: panels[1]),
                          const SizedBox(width: 18),
                          Expanded(child: panels[2]),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 22),
              _RecentReportPanel(inquiries: inquiries),
              if (provider.error != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xfffff4f4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xffffd6d6)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xffd45a5a)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          provider.error!,
                          style: const TextStyle(
                              color: Color(0xff9b2f2f),
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportHero extends StatelessWidget {
  const _ReportHero({
    required this.total,
    required this.rate,
    required this.isLoading,
    required this.onRefresh,
  });

  final int total;
  final int rate;
  final bool isLoading;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 175),
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff4f67d8), Color(0xff5db4a8)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff4f67d8).withValues(alpha: 0.18),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final heading = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.analytics_outlined,
                        color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Department Reports',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Review inquiry volume, status movement, and department workload patterns.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
                    height: 1.48,
                    fontSize: 16),
              ),
            ],
          );

          final snapshot = Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _HeroPill(icon: Icons.inbox_outlined, label: '$total total'),
              _HeroPill(
                  icon: Icons.check_circle_outline, label: '$rate% resolved'),
              IconButton.filledTonal(
                tooltip: 'Refresh',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  foregroundColor: Colors.white,
                ),
                onPressed: isLoading ? null : onRefresh,
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.refresh),
              ),
            ],
          );

          if (constraints.maxWidth < 760) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heading,
                const SizedBox(height: 22),
                snapshot,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: heading),
              const SizedBox(width: 24),
              snapshot,
            ],
          );
        },
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 21),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _ReportMetricGrid extends StatelessWidget {
  const _ReportMetricGrid({
    required this.total,
    required this.pending,
    required this.inProgress,
    required this.resolved,
    required this.closed,
  });

  final int total;
  final int pending;
  final int inProgress;
  final int resolved;
  final int closed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1180
            ? 3
            : constraints.maxWidth >= 760
                ? 2
                : 1;
        final width = (constraints.maxWidth - ((columns - 1) * 16)) / columns;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _ReportMetricCard(
                width: width,
                label: 'Total',
                value: total,
                icon: Icons.inbox_outlined,
                color: const Color(0xff4f67d8)),
            _ReportMetricCard(
                width: width,
                label: 'Pending',
                value: pending,
                icon: Icons.hourglass_top_outlined,
                color: const Color(0xffc48a3a)),
            _ReportMetricCard(
                width: width,
                label: 'In Progress',
                value: inProgress,
                icon: Icons.sync_outlined,
                color: const Color(0xff4f67d8)),
            _ReportMetricCard(
                width: width,
                label: 'Resolved',
                value: resolved,
                icon: Icons.check_circle_outline,
                color: const Color(0xff4c9a73)),
            _ReportMetricCard(
                width: width,
                label: 'Closed',
                value: closed,
                icon: Icons.lock_outline,
                color: const Color(0xff718096)),
          ],
        );
      },
    );
  }
}

class _ReportMetricCard extends StatelessWidget {
  const _ReportMetricCard(
      {required this.width,
      required this.label,
      required this.value,
      required this.icon,
      required this.color});

  final double width;
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        constraints: const BoxConstraints(minHeight: 150),
        decoration: _departmentPanelDecoration(),
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const Spacer(),
                Text('$value',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(color: color, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 16),
            Text(label,
                style: const TextStyle(
                    color: Color(0xff253044),
                    fontSize: 17,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            const Text('Department inquiries',
                style: TextStyle(color: Color(0xff718096), fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _ReportStatusRow {
  const _ReportStatusRow(this.label, this.value, this.color, this.icon);

  final String label;
  final int value;
  final Color color;
  final IconData icon;
}

class _StatusBreakdownPanel extends StatelessWidget {
  const _StatusBreakdownPanel({required this.total, required this.rows});

  final int total;
  final List<_ReportStatusRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _departmentPanelDecoration(),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
              icon: Icons.stacked_bar_chart_outlined,
              title: 'Status Breakdown'),
          const SizedBox(height: 18),
          for (final row in rows) _StatusBreakdownRow(row: row, total: total),
        ],
      ),
    );
  }
}

class _StatusBreakdownRow extends StatelessWidget {
  const _StatusBreakdownRow({required this.row, required this.total});

  final _ReportStatusRow row;
  final int total;

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0.0 : row.value / total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            children: [
              Icon(row.icon, color: row.color, size: 20),
              const SizedBox(width: 9),
              Expanded(
                  child: Text(row.label,
                      style: const TextStyle(
                          color: Color(0xff253044),
                          fontSize: 15,
                          fontWeight: FontWeight.w800))),
              Text('${row.value}',
                  style: TextStyle(
                      color: row.color,
                      fontSize: 16,
                      fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: percent,
              backgroundColor: const Color(0xffeef3f8),
              valueColor: AlwaysStoppedAnimation(row.color),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryReportPanel extends StatelessWidget {
  const _CategoryReportPanel({required this.title, required this.items});

  final String title;
  final List<MapEntry<String, int>> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _departmentPanelDecoration(),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelTitle(icon: Icons.pie_chart_outline, title: title),
          const SizedBox(height: 18),
          if (items.isEmpty)
            const _DepartmentEmptyState(compact: true)
          else
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(item.key,
                            style: const TextStyle(
                                color: Color(0xff253044),
                                fontSize: 15,
                                fontWeight: FontWeight.w800))),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 11, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xffeef3ff),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text('${item.value}',
                          style: const TextStyle(
                              color: Color(0xff4f67d8),
                              fontSize: 14,
                              fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _RecentReportPanel extends StatelessWidget {
  const _RecentReportPanel({required this.inquiries});

  final List<Inquiry> inquiries;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _departmentPanelDecoration(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                  child: _PanelTitle(
                      icon: Icons.table_chart_outlined,
                      title: 'Inquiry Report')),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xffeef3ff),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('${inquiries.length} shown',
                    style: const TextStyle(
                        color: Color(0xff4f67d8),
                        fontSize: 14,
                        fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (inquiries.isEmpty)
            const _DepartmentEmptyState()
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                dataRowMinHeight: 58,
                dataRowMaxHeight: 66,
                headingRowHeight: 54,
                headingRowColor:
                    WidgetStateProperty.all(const Color(0xfff3f6fb)),
                columnSpacing: 36,
                horizontalMargin: 20,
                columns: const [
                  DataColumn(label: _TableHeader('Inquiry ID')),
                  DataColumn(label: _TableHeader('Subject')),
                  DataColumn(label: _TableHeader('Student')),
                  DataColumn(label: _TableHeader('Status')),
                  DataColumn(label: _TableHeader('Priority')),
                  DataColumn(label: _TableHeader('Submitted')),
                ],
                rows: [
                  for (final inquiry in inquiries)
                    DataRow(
                      cells: [
                        DataCell(Text(_formatInquiryId(inquiry.id),
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w900))),
                        DataCell(SizedBox(
                            width: 280,
                            child: Text(inquiry.subject,
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis))),
                        DataCell(Text(inquiry.studentName ?? 'Student',
                            style: const TextStyle(fontSize: 14))),
                        DataCell(_StatusChip(status: inquiry.status)),
                        DataCell(Text(_priorityLabel(inquiry.priority),
                            style: const TextStyle(fontSize: 14))),
                        DataCell(Text(_formatDate(inquiry.createdAt),
                            style: const TextStyle(fontSize: 14))),
                      ],
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xff53627a),
        fontSize: 13,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xffeef3ff),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: const Color(0xff4f67d8), size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xff253044), fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon(status), color: color, size: 16),
          const SizedBox(width: 6),
          Text(_label(status),
              style: TextStyle(
                  color: color, fontSize: 13, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

Color _statusColor(String status) {
  return switch (status) {
    'pending' => const Color(0xffc48a3a),
    'in_progress' => const Color(0xff4f67d8),
    'resolved' => const Color(0xff4c9a73),
    'closed' => const Color(0xff718096),
    _ => const Color(0xff4f67d8),
  };
}

IconData _statusIcon(String status) {
  return switch (status) {
    'pending' => Icons.hourglass_top_outlined,
    'in_progress' => Icons.sync_outlined,
    'resolved' => Icons.check_circle_outline,
    'closed' => Icons.lock_outline,
    _ => Icons.flag_outlined,
  };
}

Map<String, int> _frequency(Iterable<String> values) {
  final map = <String, int>{};
  for (final value in values) {
    if (value.trim().isEmpty) continue;
    map[value] = (map[value] ?? 0) + 1;
  }
  return map;
}

List<MapEntry<String, int>> _topEntries(Map<String, int> values) {
  final entries = values.entries.toList()
    ..sort((a, b) {
      final byTotal = b.value.compareTo(a.value);
      if (byTotal != 0) return byTotal;
      return a.key.compareTo(b.key);
    });

  return entries.take(5).toList();
}

String _priorityLabel(int priority) {
  return switch (priority) {
    1 => '1 - Low',
    2 => '2 - Medium',
    3 => '3 - High',
    4 => '4 - Urgent',
    _ => '$priority',
  };
}

String _formatInquiryId(int id) => 'INQ-${id.toString().padLeft(3, '0')}';

String _formatDate(String? raw) {
  if (raw == null || raw.isEmpty) return '-';
  final date = DateTime.tryParse(raw);
  if (date == null) return raw;
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

class DepartmentFaqManagerScreen extends StatefulWidget {
  const DepartmentFaqManagerScreen({super.key});

  @override
  State<DepartmentFaqManagerScreen> createState() =>
      _DepartmentFaqManagerScreenState();
}

class _DepartmentFaqManagerScreenState
    extends State<DepartmentFaqManagerScreen> {
  final _question = TextEditingController();
  final _answer = TextEditingController();
  final _category = TextEditingController();
  int? _editingId;
  bool _isActive = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<InquiryProvider>().loadDepartmentFaqs();
    });
  }

  @override
  void dispose() {
    _question.dispose();
    _answer.dispose();
    _category.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InquiryProvider>();

    return Scaffold(
      backgroundColor: const Color(0xfff6f8fb),
      body: RefreshIndicator(
        onRefresh: () => context.read<InquiryProvider>().loadDepartmentFaqs(),
        child: ListView(
          padding: const EdgeInsets.all(28),
          children: [
            Text('Manage Department FAQ',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_editingId == null ? 'Add FAQ' : 'Update FAQ',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    TextField(
                        controller: _question,
                        decoration:
                            const InputDecoration(labelText: 'Question')),
                    const SizedBox(height: 12),
                    TextField(
                        controller: _category,
                        decoration:
                            const InputDecoration(labelText: 'Category')),
                    const SizedBox(height: 12),
                    TextField(
                        controller: _answer,
                        minLines: 3,
                        maxLines: 8,
                        decoration: const InputDecoration(labelText: 'Answer')),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Active'),
                      value: _isActive,
                      onChanged: (value) => setState(() => _isActive = value),
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: _isSaving ? null : _save,
                          icon: const Icon(Icons.save_outlined),
                          label: Text(
                              _editingId == null ? 'Save FAQ' : 'Update FAQ'),
                        ),
                        if (_editingId != null)
                          TextButton(
                            onPressed: _clear,
                            child: const Text('Cancel'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Existing FAQs',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    if (provider.departmentFaqs.isEmpty)
                      const Text('No department FAQs yet.')
                    else
                      ...provider.departmentFaqs.map(
                        (faq) => _FaqRow(
                          faq: faq,
                          onEdit: () => _edit(faq),
                          onDelete:
                              faq.id == null ? null : () => _delete(faq.id!),
                        ),
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
    if (_question.text.trim().isEmpty || _answer.text.trim().isEmpty) return;

    setState(() => _isSaving = true);
    try {
      await context.read<InquiryProvider>().saveDepartmentFaq(
            id: _editingId,
            question: _question.text.trim(),
            answer: _answer.text.trim(),
            category:
                _category.text.trim().isEmpty ? null : _category.text.trim(),
            isActive: _isActive,
          );
      _clear();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _edit(FaqItem faq) {
    setState(() {
      _editingId = faq.id;
      _question.text = faq.question;
      _answer.text = faq.answer;
      _category.text = faq.category ?? '';
      _isActive = faq.isActive;
    });
  }

  Future<void> _delete(int id) async {
    await context.read<InquiryProvider>().deleteDepartmentFaq(id);
  }

  void _clear() {
    setState(() {
      _editingId = null;
      _question.clear();
      _answer.clear();
      _category.clear();
      _isActive = true;
    });
  }
}

class _DepartmentEmptyState extends StatelessWidget {
  const _DepartmentEmptyState({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 22 : 34),
      decoration: BoxDecoration(
        color: const Color(0xfff8fbfd),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffe3ebf5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!compact) ...[
            const CircleAvatar(
              radius: 32,
              backgroundColor: Color(0xffeef3ff),
              foregroundColor: Color(0xff4f67d8),
              child: Icon(Icons.insights_outlined, size: 30),
            ),
            const SizedBox(height: 16),
          ],
          const Text('No inquiry data yet',
              style: TextStyle(
                  color: Color(0xff253044),
                  fontSize: 16,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('Department report details will appear here.',
              style: TextStyle(color: Color(0xff718096), fontSize: 14)),
        ],
      ),
    );
  }
}

BoxDecoration _departmentPanelDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(22),
    border: Border.all(color: const Color(0xffe3ebf5)),
    boxShadow: [
      BoxShadow(
        color: const Color(0xff202838).withValues(alpha: 0.055),
        blurRadius: 34,
        offset: const Offset(0, 18),
      ),
    ],
  );
}

class _FaqRow extends StatelessWidget {
  const _FaqRow(
      {required this.faq, required this.onEdit, required this.onDelete});

  final FaqItem faq;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xfff8fafc),
      child: ListTile(
        title: Text(faq.question),
        subtitle: Text(faq.answer),
        leading: Icon(faq.isActive
            ? Icons.check_circle_outline
            : Icons.pause_circle_outline),
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton(
                tooltip: 'Edit',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined)),
            IconButton(
                tooltip: 'Delete',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline)),
          ],
        ),
      ),
    );
  }
}

int _count(Map<String, dynamic> counts, String key) {
  final value = counts[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}

String _label(String value) => value
    .split('_')
    .map((word) =>
        word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}')
    .join(' ');
