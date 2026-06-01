import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/inquiry.dart';
import '../providers/auth_provider.dart';
import '../providers/inquiry_provider.dart';
import '../widgets/app_ui.dart';
import 'inquiry_detail_screen.dart';
import 'inquiry_form_screen.dart';
import 'inquiry_list_screen.dart';
import 'mobile_app_screen.dart';
import 'notifications_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<InquiryProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<InquiryProvider>();
    final counts = provider.counts;
    final user = auth.user;
    final isSuperAdmin = user?.userType == 'super_admin';
    final isDepartmentAdmin = user?.userType == 'department_admin';
    return AppScreen(
      onRefresh: () => context.read<InquiryProvider>().loadDashboard(),
      children: [
        _Header(
          name: user?.name ?? 'Student',
          email: user?.email ?? '',
          userIdentifier: user?.userIdentifier,
          isSuperAdmin: isSuperAdmin,
          isDepartmentAdmin: isDepartmentAdmin,
          unreadAlerts: provider.unreadNotifications,
          onCreate: () => _open(context, const InquiryFormScreen()),
          onAlerts: () => _open(context, const NotificationsScreen()),
          onDownloadApp: () => _open(context, const MobileAppScreen()),
          onLogout: auth.logout,
        ),
        const SizedBox(height: 16),
        if (isSuperAdmin) ...[
          _SuperadminMetricGrid(counts: counts),
          const SizedBox(height: 16),
          _SuperadminOperations(
              counts: counts, recentInquiries: provider.recentInquiries),
        ] else if (isDepartmentAdmin) ...[
          _DepartmentMetricGrid(counts: counts),
        ] else ...[
          _StudentMetricGrid(counts: counts),
          const SizedBox(height: 16),
          _RecentInquiries(
              inquiries: provider.recentInquiries,
              isSuperAdmin: false,
              isDepartmentAdmin: false),
        ],
      ],
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.email,
    required this.userIdentifier,
    required this.isSuperAdmin,
    required this.isDepartmentAdmin,
    required this.unreadAlerts,
    required this.onCreate,
    required this.onAlerts,
    required this.onDownloadApp,
    required this.onLogout,
  });

  final String name;
  final String email;
  final String? userIdentifier;
  final bool isSuperAdmin;
  final bool isDepartmentAdmin;
  final int unreadAlerts;
  final VoidCallback onCreate;
  final VoidCallback onAlerts;
  final VoidCallback onDownloadApp;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    if (isSuperAdmin) {
      return _SuperadminHeader(
          name: name, email: email, userIdentifier: userIdentifier);
    }

    if (isDepartmentAdmin) {
      return _DepartmentHeader(
        name: name,
        email: email,
        unreadAlerts: unreadAlerts,
        onAlerts: onAlerts,
        onLogout: onLogout,
      );
    }

    final actions = [
      FilledButton.icon(
        onPressed: onCreate,
        icon: const Icon(Icons.add),
        label: const Text('New Inquiry'),
      ),
      OutlinedButton.icon(
        onPressed: onDownloadApp,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.border),
        ),
        icon: const Icon(Icons.android_outlined),
        label: const Text('Download APK'),
      ),
      IconButton(
        tooltip: 'Notifications',
        onPressed: onAlerts,
        color: AppColors.primary,
        icon: Badge(
          isLabelVisible: unreadAlerts > 0,
          label: Text('$unreadAlerts'),
          child: const Icon(Icons.notifications_outlined),
        ),
      ),
      _ProfileMenu(name: name, email: email, onLogout: onLogout),
    ];

    return _DashboardHero(
      icon: Icons.school_outlined,
      badge: 'Student Workspace',
      title: 'Welcome back, $name',
      subtitle:
          'Track your submitted inquiries, view responses, and stay updated without losing the thread.',
      gradient: const [Color(0xff596bdd), Color(0xff7aa6e8)],
      trailing: _HeroActions(children: actions),
    );
  }
}

class _SuperadminHeader extends StatelessWidget {
  const _SuperadminHeader({
    required this.name,
    required this.email,
    required this.userIdentifier,
  });

  final String name;
  final String email;
  final String? userIdentifier;

  @override
  Widget build(BuildContext context) {
    return _DashboardHero(
      icon: Icons.admin_panel_settings_outlined,
      badge: 'Superadmin',
      title: 'System Dashboard',
      subtitle:
          'Monitor inquiry performance, department workload, account activity, and system health from one overview.',
      gradient: const [Color(0xff475bd3), Color(0xff4fa7a1)],
      trailing: _HeroIdentity(
        name: name,
        email: email,
        userIdentifier: userIdentifier,
        avatarText: name.isEmpty ? 'S' : name[0].toUpperCase(),
      ),
    );
  }
}

class _DepartmentHeader extends StatelessWidget {
  const _DepartmentHeader({
    required this.name,
    required this.email,
    required this.unreadAlerts,
    required this.onAlerts,
    required this.onLogout,
  });

  final String name;
  final String email;
  final int unreadAlerts;
  final VoidCallback onAlerts;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return _DashboardHero(
      icon: Icons.business_center_outlined,
      badge: 'Department Head',
      title: 'Welcome back, $name',
      subtitle:
          'Monitor your department workload, respond to students, and keep inquiry progress moving clearly.',
      gradient: const [Color(0xff4f67d8), Color(0xff5db4a8)],
      trailing: _HeroAccountActions(
        name: name,
        email: email,
        unreadAlerts: unreadAlerts,
        onAlerts: onAlerts,
        onLogout: onLogout,
      ),
    );
  }
}

class _DashboardHero extends StatelessWidget {
  const _DashboardHero({
    required this.icon,
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.gradient,
    this.trailing,
  });

  final IconData icon;
  final String badge;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppStatusChip(icon: icon, label: badge, color: gradient.first),
              const SizedBox(height: 14),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w800,
                      height: 1.08,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.muted,
                      height: 1.4,
                    ),
              ),
            ],
          );

          if (trailing == null) return content;

          if (constraints.maxWidth < 760) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                content,
                const SizedBox(height: 16),
                trailing!,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: content),
              const SizedBox(width: 18),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: trailing!,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeroActions extends StatelessWidget {
  const _HeroActions({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}

class _HeroIdentity extends StatelessWidget {
  const _HeroIdentity({
    required this.name,
    required this.email,
    required this.avatarText,
    this.userIdentifier,
  });

  final String name;
  final String email;
  final String avatarText;
  final String? userIdentifier;

  @override
  Widget build(BuildContext context) {
    return _HeroGlassBox(
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withValues(alpha: 0.10),
            foregroundColor: AppColors.primary,
            child: Text(avatarText),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Account Details',
                    style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w800)),
                Text(name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.text, fontWeight: FontWeight.w800)),
                Text(email,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.muted)),
                if (userIdentifier != null && userIdentifier!.isNotEmpty)
                  Text('ID: $userIdentifier',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroAccountActions extends StatelessWidget {
  const _HeroAccountActions({
    required this.name,
    required this.email,
    required this.unreadAlerts,
    required this.onAlerts,
    required this.onLogout,
  });

  final String name;
  final String email;
  final int unreadAlerts;
  final VoidCallback onAlerts;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return _HeroGlassBox(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.10),
            foregroundColor: AppColors.primary,
            child: Text(name.isEmpty ? 'D' : name[0].toUpperCase()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.text, fontWeight: FontWeight.w800)),
                Text(email,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.muted)),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: onAlerts,
            color: AppColors.primary,
            icon: Badge(
              isLabelVisible: unreadAlerts > 0,
              label: Text('$unreadAlerts'),
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Profile',
            onSelected: (value) {
              if (value == 'logout') onLogout();
            },
            itemBuilder: (context) => [
              PopupMenuItem(enabled: false, child: Text(name)),
              PopupMenuItem(enabled: false, child: Text(email)),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
            child: const Icon(Icons.more_vert, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _HeroGlassBox extends StatelessWidget {
  const _HeroGlassBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: child,
      ),
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu(
      {required this.name, required this.email, required this.onLogout});

  final String name;
  final String email;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Profile',
      onSelected: (value) {
        if (value == 'logout') onLogout();
      },
      itemBuilder: (context) => [
        PopupMenuItem(enabled: false, child: Text(name)),
        PopupMenuItem(enabled: false, child: Text(email)),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'logout', child: Text('Logout')),
      ],
      child: CircleAvatar(
        backgroundColor: AppColors.primary.withValues(alpha: 0.10),
        foregroundColor: AppColors.primary,
        child: Text(name.isEmpty ? 'S' : name[0].toUpperCase()),
      ),
    );
  }
}

class _StudentMetricGrid extends StatelessWidget {
  const _StudentMetricGrid({required this.counts});

  final Map<String, dynamic> counts;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1200
            ? 4
            : width >= 760
                ? 2
                : 1;
        final itemWidth = (width - ((columns - 1) * 12)) / columns;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _SummaryCard(
              width: itemWidth,
              label: 'Total Inquiries',
              value: _count(counts, 'total'),
              detail: 'All submitted requests',
              icon: Icons.description_outlined,
              color: const Color(0xff55627a),
            ),
            _SummaryCard(
              width: itemWidth,
              label: 'Pending',
              value: _count(counts, 'pending'),
              detail: 'Waiting for department response',
              icon: Icons.hourglass_top_outlined,
              color: const Color(0xffc48a3a),
            ),
            _SummaryCard(
              width: itemWidth,
              label: 'In Progress',
              value: _count(counts, 'in_progress'),
              detail: 'Currently being reviewed',
              icon: Icons.sync_outlined,
              color: const Color(0xff4f67d8),
            ),
            _SummaryCard(
              width: itemWidth,
              label: 'Resolved',
              value: _count(counts, 'resolved'),
              detail: 'Completed inquiries',
              icon: Icons.check_circle_outline,
              color: const Color(0xff4c9a73),
            ),
          ],
        );
      },
    );
  }
}

class _SuperadminMetricGrid extends StatelessWidget {
  const _SuperadminMetricGrid({required this.counts});

  final Map<String, dynamic> counts;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1240
            ? 4
            : width >= 820
                ? 3
                : width >= 560
                    ? 2
                    : 1;
        final itemWidth = (width - ((columns - 1) * 12)) / columns;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _SummaryCard(
              width: itemWidth,
              label: 'Total Inquiries',
              value: _count(counts, 'total'),
              detail: 'Across all departments',
              icon: Icons.description_outlined,
              color: const Color(0xff55627a),
            ),
            _SummaryCard(
              width: itemWidth,
              label: 'Pending',
              value: _count(counts, 'pending'),
              detail: 'Waiting for first action',
              icon: Icons.hourglass_top_outlined,
              color: const Color(0xffc48a3a),
            ),
            _SummaryCard(
              width: itemWidth,
              label: 'In Progress',
              value: _count(counts, 'in_progress'),
              detail: 'Being reviewed now',
              icon: Icons.sync_outlined,
              color: const Color(0xff4f67d8),
            ),
            _SummaryCard(
              width: itemWidth,
              label: 'Answered',
              value: _count(counts, 'answered'),
              detail: 'Responses sent',
              icon: Icons.mark_chat_read_outlined,
              color: const Color(0xff4fa7a1),
            ),
            _SummaryCard(
              width: itemWidth,
              label: 'Resolved',
              value: _count(counts, 'resolved'),
              detail: 'Completed inquiries',
              icon: Icons.check_circle_outline,
              color: const Color(0xff4c9a73),
            ),
          ],
        );
      },
    );
  }
}

class _DepartmentMetricGrid extends StatelessWidget {
  const _DepartmentMetricGrid({required this.counts});

  final Map<String, dynamic> counts;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1360
            ? 5
            : width >= 1040
                ? 4
                : width >= 760
                    ? 2
                    : 1;
        final itemWidth = (width - ((columns - 1) * 12)) / columns;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _SummaryCard(
              width: itemWidth,
              label: 'Assigned Inquiries',
              value: _count(counts, 'total'),
              detail: 'Directed to your department',
              icon: Icons.inbox_outlined,
              color: const Color(0xff55627a),
            ),
            _SummaryCard(
              width: itemWidth,
              label: 'Pending',
              value: _count(counts, 'pending'),
              detail: 'Waiting for action',
              icon: Icons.hourglass_top_outlined,
              color: const Color(0xffc48a3a),
            ),
            _SummaryCard(
              width: itemWidth,
              label: 'In Progress',
              value: _count(counts, 'in_progress'),
              detail: 'Currently being handled',
              icon: Icons.sync_outlined,
              color: const Color(0xff4f67d8),
            ),
            _SummaryCard(
              width: itemWidth,
              label: 'Resolved',
              value: _count(counts, 'resolved'),
              detail: 'Student concern completed',
              icon: Icons.check_circle_outline,
              color: const Color(0xff4c9a73),
            ),
            _SummaryCard(
              width: itemWidth,
              label: 'Closed',
              value: _count(counts, 'closed'),
              detail: 'Archived department inquiries',
              icon: Icons.lock_outline,
              color: const Color(0xff718096),
            ),
          ],
        );
      },
    );
  }
}

class _SuperadminOperations extends StatelessWidget {
  const _SuperadminOperations({
    required this.counts,
    required this.recentInquiries,
  });

  final Map<String, dynamic> counts;
  final List<Inquiry> recentInquiries;

  @override
  Widget build(BuildContext context) {
    final total = _count(counts, 'total');
    final pending = _count(counts, 'pending');
    final inProgress = _count(counts, 'in_progress');
    final answered = _count(counts, 'answered');
    final resolved = _count(counts, 'resolved');
    final open = pending + inProgress + answered;
    final resolutionRate = total == 0 ? 0 : ((resolved / total) * 100).round();

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 980;
        final panelWidth =
            wide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: panelWidth,
              child: _Panel(
                title: 'Inquiry Status',
                subtitle: 'Live workload distribution',
                child: Column(
                  children: [
                    _StatusProgress(
                        label: 'Pending',
                        value: pending,
                        total: total,
                        color: const Color(0xffc48a3a)),
                    _StatusProgress(
                        label: 'In Progress',
                        value: inProgress,
                        total: total,
                        color: const Color(0xff4f67d8)),
                    _StatusProgress(
                        label: 'Answered',
                        value: answered,
                        total: total,
                        color: const Color(0xff4fa7a1)),
                    _StatusProgress(
                        label: 'Resolved',
                        value: resolved,
                        total: total,
                        color: const Color(0xff4c9a73)),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: panelWidth,
              child: _Panel(
                title: 'Operations Snapshot',
                subtitle: 'Key system monitoring signals',
                child: Column(
                  children: [
                    _SnapshotRow(
                      icon: Icons.pending_actions_outlined,
                      label: 'Open workload',
                      value: '$open active',
                      color: const Color(0xff4f67d8),
                    ),
                    _SnapshotRow(
                      icon: Icons.verified_outlined,
                      label: 'Resolution rate',
                      value: '$resolutionRate%',
                      color: const Color(0xff4c9a73),
                    ),
                    _SnapshotRow(
                      icon: Icons.history_outlined,
                      label: 'Recent activity',
                      value: '${recentInquiries.length} latest',
                      color: const Color(0xff7b72d8),
                    ),
                    _SnapshotRow(
                      icon: Icons.warning_amber_outlined,
                      label: 'Needs attention',
                      value: '$pending pending',
                      color: const Color(0xffc75b68),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _softCardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xffeef3ff),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.insights_outlined,
                      color: Color(0xff4f67d8), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xff253044))),
                      const SizedBox(height: 3),
                      Text(subtitle,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: const Color(0xff718096))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }
}

class _StatusProgress extends StatelessWidget {
  const _StatusProgress({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
  });

  final String label;
  final int value;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : value / total;
    final clampedProgress =
        progress < 0 ? 0.0 : (progress > 1 ? 1.0 : progress);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(label,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xff344054)))),
              Text('$value',
                  style: TextStyle(color: color, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: clampedProgress,
              minHeight: 10,
              color: color,
              backgroundColor: color.withValues(alpha: 0.13),
            ),
          ),
        ],
      ),
    );
  }
}

class _SnapshotRow extends StatelessWidget {
  const _SnapshotRow({
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xfff8fbff),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xffe3ebf5)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.13),
                foregroundColor: color,
                child: Icon(icon),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(label,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xff344054)))),
              Text(value,
                  style: TextStyle(color: color, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.width,
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    required this.color,
  });

  final double width;
  final String label;
  final Object value;
  final String detail;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        decoration: _softCardDecoration(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 23,
                    backgroundColor: color.withValues(alpha: 0.13),
                    foregroundColor: color,
                    child: Icon(icon),
                  ),
                  const Spacer(),
                  Text(
                    '$value',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xff253044))),
              const SizedBox(height: 4),
              Text(detail,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: const Color(0xff718096))),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentInquiries extends StatelessWidget {
  const _RecentInquiries(
      {required this.inquiries,
      required this.isSuperAdmin,
      required this.isDepartmentAdmin});

  final List<Inquiry> inquiries;
  final bool isSuperAdmin;
  final bool isDepartmentAdmin;

  @override
  Widget build(BuildContext context) {
    const title = 'Recent Inquiries';

    return Container(
      decoration: _softCardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xff253044),
                      ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => InquiryListScreen(
                        title: isDepartmentAdmin
                            ? 'View Assigned Inquiries'
                            : null,
                        subtitle: isDepartmentAdmin
                            ? 'All inquiries directed to your department.'
                            : null,
                      ),
                    ),
                  ),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              isDepartmentAdmin
                  ? 'Open an item to respond, update status, forward, or view student information.'
                  : 'Latest activity in your inquiry workspace.',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: const Color(0xff718096)),
            ),
            const SizedBox(height: 20),
            if (inquiries.isEmpty)
              _EmptyState(
                icon: Icons.inbox_outlined,
                title: 'No inquiries yet',
                message: isSuperAdmin
                    ? 'Recent inquiries from every department will appear here.'
                    : isDepartmentAdmin
                        ? 'Assigned department inquiries will appear here.'
                        : 'Your latest submitted inquiries will appear here.',
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
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
                                  color: const Color(0xff253044),
                                  fontWeight: FontWeight.w500,
                                ),
                        columns: [
                          const DataColumn(label: Text('Inquiry ID')),
                          if (isDepartmentAdmin)
                            const DataColumn(label: Text('Student')),
                          if (!isDepartmentAdmin)
                            const DataColumn(label: Text('Department')),
                          const DataColumn(label: Text('Subject')),
                          const DataColumn(label: Text('Status')),
                          const DataColumn(label: Text('Date Submitted')),
                          const DataColumn(label: Text('Action')),
                        ],
                        rows: inquiries
                            .map(
                              (inquiry) => DataRow(
                                cells: [
                                  DataCell(Text(
                                      'INQ-${inquiry.id.toString().padLeft(3, '0')}')),
                                  if (isDepartmentAdmin)
                                    DataCell(
                                        Text(inquiry.studentName ?? 'Student')),
                                  if (!isDepartmentAdmin)
                                    DataCell(Text(inquiry.departmentName ??
                                        'Department')),
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
                                  DataCell(
                                      _StatusBadge(status: inquiry.status)),
                                  DataCell(
                                      Text(_formatDate(inquiry.createdAt))),
                                  DataCell(
                                    FilledButton.tonalIcon(
                                      style: FilledButton.styleFrom(
                                        minimumSize: const Size(118, 46),
                                        textStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      onPressed: () =>
                                          Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => InquiryDetailScreen(
                                              inquiryId: inquiry.id),
                                        ),
                                      ),
                                      icon: const Icon(Icons.open_in_new,
                                          size: 18),
                                      label: Text(isDepartmentAdmin
                                          ? 'Manage'
                                          : 'View'),
                                    ),
                                  ),
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
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xfff8fbff),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffe3ebf5)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xffeef3ff),
            foregroundColor: const Color(0xff4f67d8),
            child: Icon(icon, size: 28),
          ),
          const SizedBox(height: 10),
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xff718096))),
        ],
      ),
    );
  }
}

String _label(String value) => value
    .split('_')
    .map((word) =>
        word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}')
    .join(' ');

int _count(Map<String, dynamic> counts, String key) {
  final value = counts[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}

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

BoxDecoration _softCardDecoration() {
  return BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: AppColors.border),
  );
}
