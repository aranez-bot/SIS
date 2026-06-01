import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/inquiry.dart';
import '../providers/inquiry_provider.dart';

class ConversationHistoryScreen extends StatefulWidget {
  const ConversationHistoryScreen({super.key});

  @override
  State<ConversationHistoryScreen> createState() =>
      _ConversationHistoryScreenState();
}

class _ConversationHistoryScreenState extends State<ConversationHistoryScreen> {
  late Future<List<Inquiry>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Inquiry>> _load() async {
    final provider = context.read<InquiryProvider>();
    await provider.loadInquiries();
    return Future.wait(
        provider.inquiries.map((inquiry) => provider.loadInquiry(inquiry.id)));
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
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
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List<Inquiry>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return ListView(
                  padding: const EdgeInsets.all(28),
                  children: [
                    _ConversationHeader(onRefresh: _refresh),
                    const SizedBox(height: 18),
                    _ConversationPanel(
                      child: Text(snapshot.error.toString()),
                    ),
                  ],
                );
              }

              final inquiries = snapshot.data ?? [];
              final withMessages = inquiries
                  .where((inquiry) => inquiry.messages.isNotEmpty)
                  .toList();

              return ListView(
                padding: const EdgeInsets.all(28),
                children: [
                  _ConversationHeader(onRefresh: _refresh),
                  const SizedBox(height: 18),
                  if (withMessages.isEmpty)
                    const _ConversationEmptyState()
                  else
                    ...withMessages.map((inquiry) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _InquiryConversationCard(inquiry: inquiry),
                        )),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ConversationHeader extends StatelessWidget {
  const _ConversationHeader({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conversation History',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'Review message exchanges between students and department staff.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.84),
                      height: 1.42),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          IconButton.filledTonal(
            tooltip: 'Refresh',
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              foregroundColor: Colors.white,
            ),
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}

class _InquiryConversationCard extends StatelessWidget {
  const _InquiryConversationCard({required this.inquiry});

  final Inquiry inquiry;

  @override
  Widget build(BuildContext context) {
    return _ConversationPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                inquiry.subject,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xff253044),
                    fontWeight: FontWeight.w800),
              ),
              _ConversationChip(
                  label: 'INQ-${inquiry.id.toString().padLeft(3, '0')}',
                  color: const Color(0xff4f67d8)),
              _ConversationChip(
                  label: _label(inquiry.status),
                  color: _statusColor(inquiry.status)),
            ],
          ),
          const SizedBox(height: 6),
          Text(inquiry.departmentName ?? 'Department',
              style: const TextStyle(
                  color: Color(0xff718096), fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          ...inquiry.messages
              .map((message) => _ConversationMessageTile(message: message)),
        ],
      ),
    );
  }
}

class _ConversationMessageTile extends StatelessWidget {
  const _ConversationMessageTile({required this.message});

  final InquiryMessage message;

  @override
  Widget build(BuildContext context) {
    final color = message.isDepartmentResponse
        ? const Color(0xff4fa7a1)
        : const Color(0xff4f67d8);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xfff8fbfd),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffe3ebf5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          foregroundColor: color,
          child: Icon(message.isDepartmentResponse
              ? Icons.support_agent
              : Icons.person_outline),
        ),
        title: Text(message.senderName ?? 'User',
            style: const TextStyle(
                color: Color(0xff253044), fontWeight: FontWeight.w800)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(message.message,
              style: const TextStyle(color: Color(0xff344054), height: 1.45)),
        ),
      ),
    );
  }
}

class _ConversationChip extends StatelessWidget {
  const _ConversationChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.12),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w800),
      side: BorderSide.none,
    );
  }
}

class _ConversationEmptyState extends StatelessWidget {
  const _ConversationEmptyState();

  @override
  Widget build(BuildContext context) {
    return const _ConversationPanel(
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Color(0xffeef3ff),
            foregroundColor: Color(0xff4f67d8),
            child: Icon(Icons.forum_outlined),
          ),
          SizedBox(height: 12),
          Text('No conversation history yet',
              style: TextStyle(
                  color: Color(0xff253044), fontWeight: FontWeight.w800)),
          SizedBox(height: 4),
          Text('Student and department messages will appear here.',
              style: TextStyle(color: Color(0xff718096))),
        ],
      ),
    );
  }
}

class _ConversationPanel extends StatelessWidget {
  const _ConversationPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
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
      ),
      padding: const EdgeInsets.all(18),
      child: child,
    );
  }
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

String _label(String value) => value
    .split('_')
    .map((word) =>
        word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}')
    .join(' ');
