import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_notification.dart';
import '../providers/inquiry_provider.dart';
import '../widgets/app_ui.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<InquiryProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InquiryProvider>();

    return AppScreen(
      onRefresh: provider.loadNotifications,
      children: [
        AppHeader(
          icon: Icons.notifications_none_outlined,
          title: 'Notifications',
          trailing: IconButton.outlined(
            tooltip: 'Refresh',
            onPressed: provider.loadNotifications,
            icon: const Icon(Icons.refresh),
          ),
        ),
        const SizedBox(height: 16),
        if (provider.notifications.isEmpty)
          const AppEmptyState(
            icon: Icons.notifications_none_outlined,
            title: 'No notifications yet',
          )
        else
          for (final notification in provider.notifications) ...[
            _NotificationTile(
              notification: notification,
              onTap: () => _openNotification(provider, notification),
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }

  Future<void> _openNotification(
      InquiryProvider provider, AppNotification notification) async {
    if (notification.isUnread) {
      await provider.markNotificationRead(notification.id);
    }

    if (mounted && notification.inquiryId != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              InquiryDetailScreen(inquiryId: notification.inquiryId!),
        ),
      );
    }
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      padding: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
        leading: AppIconBox(
          icon: notification.isUnread
              ? Icons.notifications_active_outlined
              : Icons.notifications_none_outlined,
          color: notification.isUnread ? AppColors.primary : AppColors.muted,
        ),
        title: Text(
          notification.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          notification.message,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.muted),
        ),
        trailing: notification.isUnread
            ? const AppStatusChip(label: 'New', color: AppColors.primary)
            : null,
        onTap: onTap,
      ),
    );
  }
}
