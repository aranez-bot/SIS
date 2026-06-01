import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/inquiry_provider.dart';
import 'inquiry_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<InquiryProvider>().loadNotifications());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InquiryProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Alerts')),
      body: RefreshIndicator(
        onRefresh: provider.loadNotifications,
        child: provider.notifications.isEmpty
            ? const Center(child: Text('No notifications yet.'))
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: provider.notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final notification = provider.notifications[index];
                  return Card(
                    child: ListTile(
                      leading: Icon(notification.isUnread ? Icons.notifications_active : Icons.notifications_none),
                      title: Text(notification.title),
                      subtitle: Text(notification.message),
                      trailing: notification.isUnread ? const Icon(Icons.circle, size: 10) : null,
                      onTap: () async {
                        if (notification.isUnread) {
                          await provider.markNotificationRead(notification.id);
                        }

                        if (context.mounted && notification.inquiryId != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => InquiryDetailScreen(inquiryId: notification.inquiryId!),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
