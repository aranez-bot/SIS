import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/inquiry_provider.dart';
import 'screens/conversation_history_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/department_admin_screens.dart';
import 'screens/faq_screen.dart';
import 'screens/inquiry_form_screen.dart';
import 'screens/inquiry_list_screen.dart';
import 'screens/login_screen.dart';
import 'screens/mobile_app_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/superadmin_screens.dart';

void main() {
  runApp(const InquiryApp());
}

class InquiryApp extends StatelessWidget {
  const InquiryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..restoreSession()),
        ChangeNotifierProxyProvider<AuthProvider, InquiryProvider>(
          create: (_) => InquiryProvider(),
          update: (_, auth, inquiries) => inquiries!..setToken(auth.token),
        ),
      ],
      child: MaterialApp(
        title: 'Inquiry System',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff2563eb)),
          scaffoldBackgroundColor: const Color(0xfff6f8fb),
          fontFamily: 'Roboto',
          useMaterial3: true,
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 1,
            shadowColor: const Color(0xff0f172a).withValues(alpha: 0.08),
            surfaceTintColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          inputDecorationTheme:
              const InputDecorationTheme(border: OutlineInputBorder()),
        ),
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return auth.isAuthenticated ? const ShellScreen() : const LoginScreen();
  }
}

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;
  bool _sidebarExpanded = true;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;
    final destinations = _destinationsFor(auth.user?.userType);
    final selectedIndex = _index >= destinations.length ? 0 : _index;
    final mobileDestinations =
        destinations.where((destination) => destination.showOnMobile).toList();
    final selectedMobileDestination = destinations[selectedIndex];
    final mobileSelectedIndex = mobileDestinations.indexWhere(
        (destination) => destination.label == selectedMobileDestination.label);

    return Scaffold(
      body: isDesktop
          ? Row(
              children: [
                _DesktopSidebar(
                  destinations: destinations,
                  selectedIndex: selectedIndex,
                  expanded: _sidebarExpanded,
                  onToggle: () =>
                      setState(() => _sidebarExpanded = !_sidebarExpanded),
                  onDestinationSelected: (value) =>
                      setState(() => _index = value),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: destinations[selectedIndex].screen),
              ],
            )
          : destinations[selectedIndex].screen,
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              selectedIndex: mobileSelectedIndex < 0 ? 0 : mobileSelectedIndex,
              onDestinationSelected: (value) {
                final destination = mobileDestinations[value];
                setState(() => _index = destinations
                    .indexWhere((item) => item.label == destination.label));
              },
              destinations: mobileDestinations
                  .map((destination) => NavigationDestination(
                      icon: Icon(destination.icon),
                      label: destination.mobileLabel))
                  .toList(),
            ),
    );
  }

  List<_ShellDestination> _destinationsFor(String? userType) {
    if (userType == 'super_admin') {
      return const [
        _ShellDestination(
          icon: Icons.dashboard_outlined,
          label: 'Dashboard',
          mobileLabel: 'Dashboard',
          screen: DashboardScreen(),
        ),
        _ShellDestination(
          icon: Icons.manage_accounts_outlined,
          label: 'User and Admin Accounts',
          mobileLabel: 'Users',
          screen: SuperadminUsersScreen(),
        ),
        _ShellDestination(
          icon: Icons.business_outlined,
          label: 'Departments',
          mobileLabel: 'Departments',
          screen: SuperadminDepartmentsScreen(),
        ),
        _ShellDestination(
          icon: Icons.table_view_outlined,
          label: 'All Inquiries',
          mobileLabel: 'Inquiries',
          screen: InquiryListScreen(),
        ),
        _ShellDestination(
          icon: Icons.analytics_outlined,
          label: 'Reports and Analytics',
          mobileLabel: 'Reports',
          screen: SuperadminAnalyticsScreen(),
        ),
        _ShellDestination(
          icon: Icons.tune_outlined,
          label: 'Settings',
          mobileLabel: 'Settings',
          screen: SettingsScreen(),
        ),
        _ShellDestination(
          icon: Icons.receipt_long_outlined,
          label: 'Audit Logs',
          mobileLabel: 'Logs',
          screen: SuperadminSimpleDataScreen(
            title: 'Audit Logs',
            subtitle:
                'Tracks login records, inquiry updates, deleted records, and admin actions.',
            endpoint: '/superadmin/audit-logs',
            icon: Icons.receipt_long_outlined,
          ),
        ),
      ];
    }

    if (userType == 'department_admin') {
      return const [
        _ShellDestination(
          icon: Icons.dashboard_outlined,
          label: 'Dashboard',
          mobileLabel: 'Dashboard',
          screen: DashboardScreen(),
        ),
        _ShellDestination(
          icon: Icons.inbox_outlined,
          label: 'Manage Inquiries',
          mobileLabel: 'Manage',
          screen: InquiryListScreen(
            title: 'Manage Inquiries',
            subtitle:
                'Review assigned inquiries, send responses, and keep student requests moving.',
            showCategoryFilter: false,
          ),
          showOnMobile: false,
        ),
        _ShellDestination(
          icon: Icons.forum_outlined,
          label: 'Conversation History',
          mobileLabel: 'History',
          screen: ConversationHistoryScreen(),
        ),
        _ShellDestination(
          icon: Icons.analytics_outlined,
          label: 'Department Reports',
          mobileLabel: 'Reports',
          screen: DepartmentReportsScreen(),
        ),
        _ShellDestination(
          icon: Icons.settings_outlined,
          label: 'Settings',
          mobileLabel: 'Settings',
          screen: SettingsScreen(),
        ),
      ];
    }

    return const [
      _ShellDestination(
        icon: Icons.dashboard_outlined,
        label: 'Dashboard',
        mobileLabel: 'Dashboard',
        screen: DashboardScreen(),
      ),
      _ShellDestination(
        icon: Icons.history_outlined,
        label: 'My Inquiries',
        mobileLabel: 'Inquiries',
        screen: InquiryListScreen(),
      ),
      _ShellDestination(
        icon: Icons.add_circle_outline,
        label: 'New Inquiry',
        mobileLabel: 'New',
        screen: InquiryFormScreen(),
      ),
      _ShellDestination(
        icon: Icons.notifications_outlined,
        label: 'Activity',
        mobileLabel: 'Activity',
        screen: NotificationsScreen(),
      ),
      _ShellDestination(
        icon: Icons.help_outline,
        label: 'Help & FAQ',
        mobileLabel: 'Help',
        screen: FaqScreen(),
        showOnMobile: false,
      ),
      _ShellDestination(
        icon: Icons.android_outlined,
        label: 'Download APK',
        mobileLabel: 'APK',
        screen: MobileAppScreen(),
      ),
      _ShellDestination(
        icon: Icons.settings_outlined,
        label: 'Settings',
        mobileLabel: 'Settings',
        screen: SettingsScreen(),
      ),
    ];
  }
}

class _ShellDestination {
  const _ShellDestination({
    required this.icon,
    required this.label,
    required this.mobileLabel,
    required this.screen,
    this.showOnMobile = true,
  });

  final IconData icon;
  final String label;
  final String mobileLabel;
  final Widget screen;
  final bool showOnMobile;
}

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({
    required this.destinations,
    required this.selectedIndex,
    required this.expanded,
    required this.onToggle,
    required this.onDestinationSelected,
  });

  final List<_ShellDestination> destinations;
  final int selectedIndex;
  final bool expanded;
  final VoidCallback onToggle;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isSuperAdmin = auth.user?.userType == 'super_admin';
    final isDepartmentAdmin = auth.user?.userType == 'department_admin';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: expanded ? 318 : 78,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xffffffff), Color(0xfff7faff), Color(0xfff1f7f9)],
        ),
        border: const Border(right: BorderSide(color: Color(0xffe1e9f4))),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff202838).withValues(alpha: 0.06),
            blurRadius: 30,
            offset: const Offset(8, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SidebarHeader(
                expanded: expanded,
                name: auth.user?.name ?? 'Student',
                detail: auth.user?.userIdentifier?.isNotEmpty == true
                    ? 'ID: ${auth.user!.userIdentifier}'
                    : (auth.user?.email ?? ''),
                roleLabel: isSuperAdmin
                    ? 'System Administration'
                    : isDepartmentAdmin
                        ? 'Department Workspace'
                        : 'Student Workspace',
                onToggle: onToggle,
              ),
              if (expanded && (isSuperAdmin || isDepartmentAdmin))
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 18, 12, 8),
                  child: Text(
                    isDepartmentAdmin ? 'Department Tools' : 'Administration',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: const Color(0xff7a879a),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var index = 0; index < destinations.length; index++)
                        _SidebarItem(
                          selected: selectedIndex == index,
                          expanded: expanded,
                          icon: destinations[index].icon,
                          label: destinations[index].label,
                          superadminStyle: isSuperAdmin,
                          onTap: () => onDestinationSelected(index),
                        ),
                    ],
                  ),
                ),
              ),
              _SidebarItem(
                selected: false,
                expanded: expanded,
                icon: Icons.logout,
                label: 'Logout',
                superadminStyle: isSuperAdmin,
                onTap: auth.logout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader({
    required this.expanded,
    required this.name,
    required this.detail,
    required this.roleLabel,
    required this.onToggle,
  });

  final bool expanded;
  final String name;
  final String detail;
  final String roleLabel;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    if (!expanded) {
      return Column(
        children: [
          IconButton(
            tooltip: 'Open sidebar',
            onPressed: onToggle,
            icon: const Icon(Icons.menu),
          ),
          const SizedBox(height: 12),
          CircleAvatar(
            backgroundColor: const Color(0xffeef3ff),
            foregroundColor: const Color(0xff4f67d8),
            child: Text(name.isEmpty ? 'U' : name[0].toUpperCase()),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff4f67d8), Color(0xff5db4a8)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff4f67d8).withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                foregroundColor: Colors.white,
                child: Text(name.isEmpty ? 'U' : name[0].toUpperCase()),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Inquiry System',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              IconButton(
                tooltip: 'Collapse sidebar',
                onPressed: onToggle,
                color: Colors.white,
                icon: const Icon(Icons.menu_open),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            roleLabel,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800),
          ),
          Text(
            detail,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.76), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.selected,
    required this.expanded,
    required this.icon,
    required this.label,
    required this.superadminStyle,
    required this.onTap,
  });

  final bool selected;
  final bool expanded;
  final IconData icon;
  final String label;
  final bool superadminStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = superadminStyle
        ? const Color(0xff4f67d8)
        : Theme.of(context).colorScheme.primary;
    final activeTint =
        superadminStyle ? const Color(0xffeef3ff) : const Color(0xffdbeafe);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Tooltip(
        message: expanded ? '' : label,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.symmetric(
                horizontal: expanded ? 12 : 10, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? activeTint : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: selected
                      ? activeColor.withValues(alpha: 0.16)
                      : Colors.transparent),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.09),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment:
                  expanded ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: selected ? activeColor : const Color(0xfff4f7fb),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon,
                      color: selected ? Colors.white : const Color(0xff667085),
                      size: 20),
                ),
                if (expanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? activeColor : const Color(0xff344054),
                        fontWeight:
                            selected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
