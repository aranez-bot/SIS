import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/inquiry.dart';
import '../providers/auth_provider.dart';
import '../providers/inquiry_provider.dart';

class InquiryDetailScreen extends StatefulWidget {
  const InquiryDetailScreen({super.key, required this.inquiryId});

  final int inquiryId;

  @override
  State<InquiryDetailScreen> createState() => _InquiryDetailScreenState();
}

class _InquiryDetailScreenState extends State<InquiryDetailScreen> {
  late Future<Inquiry> _future;
  final _message = TextEditingController();
  int? _loadedInquiryId;
  String? _loadedInquiryStatus;
  String? _status;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _future = context.read<InquiryProvider>().loadInquiry(widget.inquiryId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<InquiryProvider>().loadDepartments();
    });
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        child: FutureBuilder<Inquiry>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Container(
                  margin: const EdgeInsets.all(28),
                  padding: const EdgeInsets.all(24),
                  decoration: _detailPanelDecoration(),
                  child: Text(snapshot.error.toString()),
                ),
              );
            }

            final inquiry = snapshot.data!;
            if (_loadedInquiryId != inquiry.id ||
                _loadedInquiryStatus != inquiry.status) {
              _loadedInquiryId = inquiry.id;
              _loadedInquiryStatus = inquiry.status;
              _status = inquiry.status;
            }

            final userType = context.watch<AuthProvider>().user?.userType;
            final isDepartmentAdmin = userType == 'department_admin';
            final isSuperAdmin = userType == 'super_admin';
            final canAdminister = isDepartmentAdmin || isSuperAdmin;

            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _future = context
                      .read<InquiryProvider>()
                      .loadInquiry(widget.inquiryId);
                });
              },
              child: ListView(
                padding: const EdgeInsets.all(28),
                children: [
                  _InquiryDetailHeader(inquiry: inquiry),
                  const SizedBox(height: 22),
                  _DetailBody(
                    inquiry: inquiry,
                    canAdminister: canAdminister,
                    status: _status ?? inquiry.status,
                    message: _message,
                    isSaving: _isSaving,
                    onStatusChanged: (value) => setState(() => _status = value),
                    onSendMessage: () => _sendMessage(inquiry.id),
                    onUpdateStatus: () =>
                        _updateStatus(inquiry.id, _status ?? inquiry.status),
                  ),
                  if (canAdminister) ...[
                    const SizedBox(height: 22),
                    _StudentInformation(inquiry: inquiry),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _sendMessage(int inquiryId) async {
    final text = _message.text.trim();
    if (text.isEmpty) return;
    await _save(
        () => context.read<InquiryProvider>().sendMessage(inquiryId, text));
    _message.clear();
  }

  Future<void> _updateStatus(int inquiryId, String status) async {
    await _save(
      () => context.read<InquiryProvider>().updateInquiryStatus(
            inquiryId: inquiryId,
            status: status,
          ),
    );
  }

  Future<void> _save(Future<void> Function() action) async {
    setState(() => _isSaving = true);
    try {
      await action();
      setState(() {
        _future = context.read<InquiryProvider>().loadInquiry(widget.inquiryId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Inquiry updated.')));
      }
    } catch (exception) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(exception.toString())));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.inquiry,
    required this.canAdminister,
    required this.status,
    required this.message,
    required this.isSaving,
    required this.onStatusChanged,
    required this.onSendMessage,
    required this.onUpdateStatus,
  });

  final Inquiry inquiry;
  final bool canAdminister;
  final String status;
  final TextEditingController message;
  final bool isSaving;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onSendMessage;
  final VoidCallback onUpdateStatus;

  @override
  Widget build(BuildContext context) {
    final mainColumn = Column(
      children: [
        _InquiryDescriptionPanel(
          title: canAdminister ? 'Student Inquiry' : 'Your Inquiry',
          description: inquiry.description,
        ),
        if (canAdminister) ...[
          const SizedBox(height: 18),
          _AdminActions(
            inquiry: inquiry,
            status: status,
            message: message,
            isSaving: isSaving,
            onStatusChanged: onStatusChanged,
            onSendMessage: onSendMessage,
            onUpdateStatus: onUpdateStatus,
          ),
        ],
        if (!canAdminister) ...[
          const SizedBox(height: 18),
          _StudentFollowUpPanel(
            message: message,
            isSaving: isSaving,
            onSendMessage: onSendMessage,
          ),
        ],
      ],
    );

    final sideColumn = Column(
      children: [
        _StatusTimelinePanel(status: inquiry.status),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 980) {
          return Column(
            children: [
              mainColumn,
              const SizedBox(height: 18),
              sideColumn,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 7, child: mainColumn),
            const SizedBox(width: 22),
            Expanded(flex: 3, child: sideColumn),
          ],
        );
      },
    );
  }
}

class _InquiryDetailHeader extends StatelessWidget {
  const _InquiryDetailHeader({required this.inquiry});

  final Inquiry inquiry;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(inquiry.status);

    return Container(
      padding: const EdgeInsets.all(28),
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
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (Navigator.canPop(context))
                    IconButton.filledTonal(
                      tooltip: 'Back',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.16),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                  _HeaderChip(
                    icon: Icons.tag_outlined,
                    label: 'INQ-${inquiry.id.toString().padLeft(3, '0')}',
                    color: Colors.white,
                  ),
                  _HeaderChip(
                    icon: Icons.flag_outlined,
                    label: _detailLabel(inquiry.status),
                    color: statusColor,
                  ),
                  _HeaderChip(
                    icon: Icons.business_outlined,
                    label: inquiry.departmentName ?? 'Department',
                    color: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                inquiry.subject,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                'Category: ${_detailLabel(inquiry.category)}  •  Submitted ${_detailFormatDate(inquiry.createdAt)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.86),
                      height: 1.42,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          );

          if (constraints.maxWidth < 780) {
            return heading;
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: heading),
              const SizedBox(width: 18),
              CircleAvatar(
                radius: 42,
                backgroundColor: Colors.white.withValues(alpha: 0.16),
                foregroundColor: Colors.white,
                child: const Icon(Icons.mark_chat_read_outlined, size: 36),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip(
      {required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isNeutral = color == Colors.white;
    final foreground = isNeutral ? const Color(0xff253044) : color;

    return Chip(
      avatar: Icon(icon, size: 17, color: foreground),
      label: Text(label),
      labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      backgroundColor: isNeutral
          ? Colors.white.withValues(alpha: 0.92)
          : Colors.white.withValues(alpha: 0.94),
      labelStyle: TextStyle(color: foreground, fontWeight: FontWeight.w800),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
    );
  }
}

class _InquiryDescriptionPanel extends StatelessWidget {
  const _InquiryDescriptionPanel({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _detailPanelDecoration(),
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xffeef3ff),
            foregroundColor: Color(0xff4f67d8),
            child: Icon(Icons.description_outlined),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xff253044),
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(description,
                    style:
                        const TextStyle(color: Color(0xff344054), height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTimelinePanel extends StatelessWidget {
  const _StatusTimelinePanel({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('pending', 'Submitted', Icons.outbox_outlined),
      ('in_progress', 'In Review', Icons.autorenew_outlined),
      ('resolved', 'Resolved', Icons.check_circle_outline),
    ];
    final currentIndex = switch (status) {
      'resolved' || 'closed' => 2,
      'in_progress' || 'answered' => 1,
      _ => 0,
    };

    return Container(
      decoration: _detailPanelDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xff253044),
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 16),
          for (var index = 0; index < steps.length; index++)
            _TimelineStep(
              label: steps[index].$2,
              icon: steps[index].$3,
              complete: index <= currentIndex,
              isLast: index == steps.length - 1,
            ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.label,
    required this.icon,
    required this.complete,
    required this.isLast,
  });

  final String label;
  final IconData icon;
  final bool complete;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = complete ? const Color(0xff4f67d8) : const Color(0xffcbd5e1);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withValues(alpha: complete ? 0.15 : 0.22),
              foregroundColor: color,
              child: Icon(icon, size: 18),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 34,
                color: complete
                    ? color.withValues(alpha: 0.35)
                    : const Color(0xffe5edf6),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Text(
            label,
            style: TextStyle(
              color:
                  complete ? const Color(0xff253044) : const Color(0xff718096),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _StudentFollowUpPanel extends StatelessWidget {
  const _StudentFollowUpPanel({
    required this.message,
    required this.isSaving,
    required this.onSendMessage,
  });

  final TextEditingController message;
  final bool isSaving;
  final VoidCallback onSendMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _detailPanelDecoration(),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Follow-up',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xff253044),
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: message,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Message',
              hintText: 'Type an update or follow-up question...',
              prefixIcon: Icon(Icons.chat_bubble_outline),
              filled: true,
              fillColor: Color(0xfff8fbfd),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size(148, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: isSaving ? null : onSendMessage,
              icon: const Icon(Icons.send_outlined),
              label: Text(isSaving ? 'Sending...' : 'Send'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentInformation extends StatelessWidget {
  const _StudentInformation({required this.inquiry});

  final Inquiry inquiry;

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Name', inquiry.studentName),
      ('Email', inquiry.studentEmail),
      ('Student ID', inquiry.studentIdentifier),
      ('Contact Number', inquiry.studentPhone),
      ('Address', inquiry.studentAddress),
      ('Profile Notes', inquiry.studentBio),
    ].where((row) => row.$2 != null && row.$2!.isNotEmpty).toList();

    return Container(
      decoration: _detailPanelDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xffedf8f6),
                  foregroundColor: Color(0xff4fa7a1),
                  child: Icon(Icons.school_outlined),
                ),
                const SizedBox(width: 12),
                Text(
                  'Student Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xff253044),
                      fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final row in rows)
                  _InfoTile(
                    label: row.$1,
                    value: row.$2!,
                    icon: _studentInfoIcon(row.$1),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile(
      {required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xfff8fbfd),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xffe3ebf5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xffeef3ff),
              foregroundColor: const Color(0xff4f67d8),
              child: Icon(icon, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: Color(0xff718096),
                          fontWeight: FontWeight.w800,
                          fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(value,
                      style: const TextStyle(
                          color: Color(0xff253044),
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _studentInfoIcon(String label) {
  return switch (label) {
    'Name' => Icons.person_outline,
    'Email' => Icons.email_outlined,
    'Student ID' => Icons.badge_outlined,
    'Contact Number' => Icons.phone_outlined,
    'Address' => Icons.location_on_outlined,
    _ => Icons.notes_outlined,
  };
}

BoxDecoration _detailPanelDecoration() {
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

Color _statusColor(String status) {
  return switch (status) {
    'pending' => const Color(0xffc48a3a),
    'in_progress' => const Color(0xff4fa7a1),
    'resolved' => const Color(0xff4c9a73),
    'closed' => const Color(0xff718096),
    'rejected' => const Color(0xffc75b68),
    _ => const Color(0xff4f67d8),
  };
}

String _detailLabel(String value) => value
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

String _detailFormatDate(String? value) {
  if (value == null || value.isEmpty) return 'Not available';
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

class _AdminActions extends StatelessWidget {
  const _AdminActions({
    required this.inquiry,
    required this.status,
    required this.message,
    required this.isSaving,
    required this.onStatusChanged,
    required this.onSendMessage,
    required this.onUpdateStatus,
  });

  final Inquiry inquiry;
  final String status;
  final TextEditingController message;
  final bool isSaving;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onSendMessage;
  final VoidCallback onUpdateStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _detailPanelDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(0xffeef3ff),
                  foregroundColor: Color(0xff4f67d8),
                  child: Icon(Icons.admin_panel_settings_outlined),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Department Response Center',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: const Color(0xff253044),
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Reply to the student, update the inquiry status, and record resolution notes in one place.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xff718096),
                              height: 1.4,
                            ),
                      ),
                    ],
                  ),
                ),
                _SoftStatusPill(status: status),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _AdminContextChip(
                  icon: Icons.person_outline,
                  label: 'Student',
                  value: inquiry.studentName ?? 'Student',
                  color: const Color(0xff4f67d8),
                ),
                _AdminContextChip(
                  icon: Icons.business_outlined,
                  label: 'Department',
                  value: inquiry.departmentName ?? 'Department',
                  color: const Color(0xff4fa7a1),
                ),
                _AdminContextChip(
                  icon: Icons.priority_high_outlined,
                  label: 'Priority',
                  value:
                      '${inquiry.priority} - ${_priorityLabel(inquiry.priority)}',
                  color: const Color(0xffc48a3a),
                ),
              ],
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final responseCard = _AdminResponseComposer(
                  message: message,
                  isSaving: isSaving,
                  onSendMessage: onSendMessage,
                );
                final statusCard = _AdminStatusPanel(
                  status: status,
                  isSaving: isSaving,
                  onStatusChanged: onStatusChanged,
                  onUpdateStatus: onUpdateStatus,
                );

                if (constraints.maxWidth < 920) {
                  return Column(
                    children: [
                      responseCard,
                      const SizedBox(height: 16),
                      statusCard,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: responseCard),
                    const SizedBox(width: 16),
                    Expanded(flex: 4, child: statusCard),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminContextChip extends StatelessWidget {
  const _AdminContextChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.14),
            foregroundColor: color,
            child: Icon(icon, size: 18),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xff718096),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xff253044),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminResponseComposer extends StatelessWidget {
  const _AdminResponseComposer({
    required this.message,
    required this.isSaving,
    required this.onSendMessage,
  });

  final TextEditingController message;
  final bool isSaving;
  final VoidCallback onSendMessage;

  @override
  Widget build(BuildContext context) {
    return _AdminWorkbenchCard(
      icon: Icons.reply_outlined,
      title: 'Compose Response',
      subtitle:
          'Send a clear update or answer that will appear in the inquiry thread.',
      color: const Color(0xff4f67d8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: message,
            minLines: 6,
            maxLines: 10,
            decoration: const InputDecoration(
              labelText: 'Response to student',
              alignLabelWithHint: true,
              hintText: 'Write your response here...',
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size(170, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                textStyle:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              onPressed: isSaving ? null : onSendMessage,
              icon: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_outlined),
              label: Text(isSaving ? 'Sending...' : 'Send Response'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminStatusPanel extends StatelessWidget {
  const _AdminStatusPanel({
    required this.status,
    required this.isSaving,
    required this.onStatusChanged,
    required this.onUpdateStatus,
  });

  final String status;
  final bool isSaving;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onUpdateStatus;

  @override
  Widget build(BuildContext context) {
    return _AdminWorkbenchCard(
      icon: Icons.task_alt_outlined,
      title: 'Status Update',
      subtitle:
          'Move the inquiry through the queue with a clear current state.',
      color: _statusColor(status),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey(status),
            initialValue: ['pending', 'in_progress', 'resolved', 'closed']
                    .contains(status)
                ? status
                : 'pending',
            decoration: const InputDecoration(
              labelText: 'Status',
              prefixIcon: Icon(Icons.flag_outlined),
              filled: true,
              fillColor: Colors.white,
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
          const SizedBox(height: 14),
          FilledButton.tonalIcon(
            style: FilledButton.styleFrom(
              minimumSize: const Size(170, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              textStyle:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            onPressed: isSaving ? null : onUpdateStatus,
            icon: const Icon(Icons.check_outlined),
            label: const Text('Update Status'),
          ),
        ],
      ),
    );
  }
}

class _AdminWorkbenchCard extends StatelessWidget {
  const _AdminWorkbenchCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xfff8fbfd),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffe3ebf5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.12),
                foregroundColor: color,
                child: Icon(icon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: const Color(0xff253044),
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xff718096),
                            height: 1.35,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SoftStatusPill extends StatelessWidget {
  const _SoftStatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);

    return Chip(
      label: Text(_detailLabel(status)),
      backgroundColor: color.withValues(alpha: 0.12),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w800),
      side: BorderSide.none,
    );
  }
}
