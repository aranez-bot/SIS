import 'package:flutter/material.dart';

import '../services/api_service.dart';

class SuperadminUsersScreen extends StatefulWidget {
  const SuperadminUsersScreen({super.key});

  @override
  State<SuperadminUsersScreen> createState() => _SuperadminUsersScreenState();
}

class _SuperadminUsersScreenState extends State<SuperadminUsersScreen> {
  final _api = ApiService();
  List<dynamic> _users = [];
  List<dynamic> _departments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final response = await _api.get('/superadmin/users');
    if (!mounted) return;
    setState(() {
      _users = response['data'] ?? [];
      _departments = response['departments'] ?? [];
      _loading = false;
    });
  }

  Future<void> _saveUser([Map<String, dynamic>? user]) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _UserDialog(user: user, departments: _departments),
    );

    if (result == null) return;
    if (user == null) {
      await _api.post('/superadmin/users', result);
    } else {
      await _api.put('/superadmin/users/${user['id']}', result);
    }
    await _load();
  }

  Future<void> _toggleUser(Map<String, dynamic> user) async {
    await _api.patch('/superadmin/users/${user['id']}/status', {});
    await _load();
  }

  Future<void> _deleteUser(Map<String, dynamic> user) async {
    final confirmed = await _confirm('Delete ${user['name']}?');
    if (!confirmed) return;
    await _api.delete('/superadmin/users/${user['id']}');
    await _load();
  }

  Future<bool> _confirm(String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Confirm action'),
            content: Text(message),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Continue')),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final totalUsers = _users.length;
    final activeUsers =
        _users.where((item) => item['is_active'] == true).length;
    final departmentHeads =
        _users.where((item) => item['user_type'] == 'department_admin').length;
    final students =
        _users.where((item) => item['user_type'] == 'student').length;

    return _SuperadminScaffold(
      title: 'User and Admin Accounts',
      subtitle:
          'Add, edit, deactivate, or delete users and assign department admins.',
      action: FilledButton.icon(
        style: FilledButton.styleFrom(
          minimumSize: const Size(146, 48),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: () => _saveUser(),
        icon: const Icon(Icons.add),
        label: const Text('Add Account'),
      ),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AccountSummaryStrip(
                  items: [
                    _AccountSummaryData(
                        label: 'Total accounts',
                        value: '$totalUsers',
                        icon: Icons.people_alt_outlined,
                        color: const Color(0xff4f67d8)),
                    _AccountSummaryData(
                        label: 'Active users',
                        value: '$activeUsers',
                        icon: Icons.verified_user_outlined,
                        color: const Color(0xff4c9a73)),
                    _AccountSummaryData(
                        label: 'Department heads',
                        value: '$departmentHeads',
                        icon: Icons.business_center_outlined,
                        color: const Color(0xff4fa7a1)),
                    _AccountSummaryData(
                        label: 'Students',
                        value: '$students',
                        icon: Icons.school_outlined,
                        color: const Color(0xffc48a3a)),
                  ],
                ),
                const SizedBox(height: 18),
                _UsersTable(
                  users: _users,
                  onEdit: (item) => _saveUser(Map<String, dynamic>.from(item)),
                  onToggle: (item) =>
                      _toggleUser(Map<String, dynamic>.from(item)),
                  onDelete: (item) =>
                      _deleteUser(Map<String, dynamic>.from(item)),
                ),
              ],
            ),
    );
  }
}

class _AccountSummaryData {
  const _AccountSummaryData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class _AccountSummaryStrip extends StatelessWidget {
  const _AccountSummaryStrip({required this.items});

  final List<_AccountSummaryData> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1120
            ? 4
            : constraints.maxWidth >= 680
                ? 2
                : 1;
        final width = (constraints.maxWidth - ((columns - 1) * 12)) / columns;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items
              .map((item) => SizedBox(
                  width: width, child: _AccountSummaryTile(item: item)))
              .toList(),
        );
      },
    );
  }
}

class _AccountSummaryTile extends StatelessWidget {
  const _AccountSummaryTile({required this.item});

  final _AccountSummaryData item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _softPanelDecoration(),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: item.color.withValues(alpha: 0.12),
            foregroundColor: item.color,
            child: Icon(item.icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: item.color, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(item.label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Color(0xff718096), fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UsersTable extends StatelessWidget {
  const _UsersTable({
    required this.users,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  final List<dynamic> users;
  final ValueChanged<Map<String, dynamic>> onEdit;
  final ValueChanged<Map<String, dynamic>> onToggle;
  final ValueChanged<Map<String, dynamic>> onDelete;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(28),
        decoration: _softPanelDecoration(),
        child: const Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Color(0xffeef3ff),
              foregroundColor: Color(0xff4f67d8),
              child: Icon(Icons.people_outline),
            ),
            SizedBox(height: 12),
            Text('No accounts yet',
                style: TextStyle(fontWeight: FontWeight.w800)),
            SizedBox(height: 4),
            Text('Created user and admin accounts will appear here.',
                style: TextStyle(color: Color(0xff718096))),
          ],
        ),
      );
    }

    return Container(
      decoration: _softPanelDecoration(),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          dividerThickness: 0.6,
          headingRowColor: WidgetStateProperty.all(const Color(0xfff6f9fd)),
          headingTextStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: const Color(0xff526074),
                fontWeight: FontWeight.w800,
              ),
          dataTextStyle: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: const Color(0xff344054)),
          columns: const [
            DataColumn(label: Text('Account')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Role')),
            DataColumn(label: Text('Department')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: users
              .map(
                (item) => DataRow(
                  cells: [
                    DataCell(_AccountNameCell(item: item)),
                    DataCell(Text(item['email'] ?? '')),
                    DataCell(_RoleChip(role: item['user_type'] ?? '')),
                    DataCell(Text(item['department']?['name'] ?? '-')),
                    DataCell(
                        _AccountStatusChip(active: item['is_active'] == true)),
                    DataCell(
                      Row(
                        children: [
                          _TableActionButton(
                            tooltip: 'Edit',
                            icon: Icons.edit_outlined,
                            color: const Color(0xff4f67d8),
                            onPressed: () =>
                                onEdit(Map<String, dynamic>.from(item)),
                          ),
                          _TableActionButton(
                            tooltip: item['is_active'] == true
                                ? 'Deactivate'
                                : 'Activate',
                            icon: item['is_active'] == true
                                ? Icons.block
                                : Icons.check_circle_outline,
                            color: item['is_active'] == true
                                ? const Color(0xffc48a3a)
                                : const Color(0xff4c9a73),
                            onPressed: () =>
                                onToggle(Map<String, dynamic>.from(item)),
                          ),
                          _TableActionButton(
                            tooltip: 'Delete',
                            icon: Icons.delete_outline,
                            color: const Color(0xffc75b68),
                            onPressed: () =>
                                onDelete(Map<String, dynamic>.from(item)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _AccountNameCell extends StatelessWidget {
  const _AccountNameCell({required this.item});

  final dynamic item;

  @override
  Widget build(BuildContext context) {
    final name = item['name']?.toString() ?? '';
    final identifier = item['user_identifier']?.toString();

    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xffeef3ff),
          foregroundColor: const Color(0xff4f67d8),
          child: Text(name.isEmpty ? 'U' : name[0].toUpperCase()),
        ),
        const SizedBox(width: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              if (identifier != null && identifier.isNotEmpty)
                Text('ID: $identifier',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Color(0xff718096), fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final color = switch (role) {
      'super_admin' => const Color(0xff4f67d8),
      'department_admin' => const Color(0xff4fa7a1),
      _ => const Color(0xff718096),
    };

    return Chip(
      label: Text(_label(role)),
      backgroundColor: color.withValues(alpha: 0.12),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w800),
      side: BorderSide.none,
    );
  }
}

class _AccountStatusChip extends StatelessWidget {
  const _AccountStatusChip({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xff4c9a73) : const Color(0xffc75b68);

    return Chip(
      avatar: Icon(
          active ? Icons.check_circle_outline : Icons.pause_circle_outline,
          size: 17,
          color: color),
      label: Text(active ? 'Active' : 'Inactive'),
      backgroundColor: color.withValues(alpha: 0.12),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w800),
      side: BorderSide.none,
    );
  }
}

class _TableActionButton extends StatelessWidget {
  const _TableActionButton({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: IconButton(
        tooltip: tooltip,
        style: IconButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.10),
          foregroundColor: color,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: Icon(icon),
        onPressed: onPressed,
      ),
    );
  }
}

BoxDecoration _softPanelDecoration() {
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

class SuperadminDepartmentsScreen extends StatefulWidget {
  const SuperadminDepartmentsScreen({super.key});

  @override
  State<SuperadminDepartmentsScreen> createState() =>
      _SuperadminDepartmentsScreenState();
}

class _SuperadminDepartmentsScreenState
    extends State<SuperadminDepartmentsScreen> {
  final _api = ApiService();
  List<dynamic> _departments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final response = await _api.get('/superadmin/departments');
    if (!mounted) return;
    setState(() {
      _departments = response['data'] ?? [];
      _loading = false;
    });
  }

  Future<void> _saveDepartment([Map<String, dynamic>? department]) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _DepartmentDialog(department: department),
    );

    if (result == null) return;
    if (department == null) {
      await _api.post('/superadmin/departments', result);
    } else {
      await _api.put('/superadmin/departments/${department['id']}', result);
    }
    await _load();
  }

  Future<void> _deleteDepartment(Map<String, dynamic> department) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete department?'),
            content: Text(
                'Delete ${department['name']}? Departments with inquiries cannot be deleted.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete')),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;
    await _api.delete('/superadmin/departments/${department['id']}');
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final totalDepartments = _departments.length;
    final activeDepartments =
        _departments.where((item) => item['is_active'] == true).length;
    final totalAdmins = _departments.fold<int>(
        0, (sum, item) => sum + _asInt(item['admins_count']));
    final totalInquiries = _departments.fold<int>(
        0, (sum, item) => sum + _asInt(item['inquiries_count']));

    return _SuperadminScaffold(
      title: 'Departments',
      subtitle:
          'Add, edit, deactivate, or remove departments included in the inquiry system.',
      action: FilledButton.icon(
        style: FilledButton.styleFrom(
          minimumSize: const Size(164, 48),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: () => _saveDepartment(),
        icon: const Icon(Icons.add_business),
        label: const Text('Add Department'),
      ),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AccountSummaryStrip(
                  items: [
                    _AccountSummaryData(
                        label: 'Departments',
                        value: '$totalDepartments',
                        icon: Icons.business_outlined,
                        color: const Color(0xff4f67d8)),
                    _AccountSummaryData(
                        label: 'Active',
                        value: '$activeDepartments',
                        icon: Icons.verified_outlined,
                        color: const Color(0xff4c9a73)),
                    _AccountSummaryData(
                        label: 'Admins',
                        value: '$totalAdmins',
                        icon: Icons.manage_accounts_outlined,
                        color: const Color(0xff4fa7a1)),
                    _AccountSummaryData(
                        label: 'Inquiries',
                        value: '$totalInquiries',
                        icon: Icons.inbox_outlined,
                        color: const Color(0xffc48a3a)),
                  ],
                ),
                const SizedBox(height: 18),
                _DepartmentsTable(
                  departments: _departments,
                  onEdit: (item) =>
                      _saveDepartment(Map<String, dynamic>.from(item)),
                  onDelete: (item) =>
                      _deleteDepartment(Map<String, dynamic>.from(item)),
                ),
              ],
            ),
    );
  }
}

class _DepartmentsTable extends StatelessWidget {
  const _DepartmentsTable({
    required this.departments,
    required this.onEdit,
    required this.onDelete,
  });

  final List<dynamic> departments;
  final ValueChanged<Map<String, dynamic>> onEdit;
  final ValueChanged<Map<String, dynamic>> onDelete;

  @override
  Widget build(BuildContext context) {
    if (departments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(28),
        decoration: _softPanelDecoration(),
        child: const Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Color(0xffeef3ff),
              foregroundColor: Color(0xff4f67d8),
              child: Icon(Icons.business_outlined),
            ),
            SizedBox(height: 12),
            Text('No departments yet',
                style: TextStyle(fontWeight: FontWeight.w800)),
            SizedBox(height: 4),
            Text('Created departments will appear here.',
                style: TextStyle(color: Color(0xff718096))),
          ],
        ),
      );
    }

    return Container(
      decoration: _softPanelDecoration(),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          dividerThickness: 0.6,
          headingRowColor: WidgetStateProperty.all(const Color(0xfff6f9fd)),
          headingTextStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: const Color(0xff526074),
                fontWeight: FontWeight.w800,
              ),
          dataTextStyle: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: const Color(0xff344054)),
          columns: const [
            DataColumn(label: Text('Department')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Admins')),
            DataColumn(label: Text('Inquiries')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: departments
              .map(
                (item) => DataRow(
                  cells: [
                    DataCell(_DepartmentNameCell(item: item)),
                    DataCell(Text(item['email'] ?? '')),
                    DataCell(Text('${item['admins_count'] ?? 0}')),
                    DataCell(Text('${item['inquiries_count'] ?? 0}')),
                    DataCell(
                        _AccountStatusChip(active: item['is_active'] == true)),
                    DataCell(
                      Row(
                        children: [
                          _TableActionButton(
                            tooltip: 'Edit',
                            icon: Icons.edit_outlined,
                            color: const Color(0xff4f67d8),
                            onPressed: () =>
                                onEdit(Map<String, dynamic>.from(item)),
                          ),
                          _TableActionButton(
                            tooltip: 'Delete',
                            icon: Icons.delete_outline,
                            color: const Color(0xffc75b68),
                            onPressed: () =>
                                onDelete(Map<String, dynamic>.from(item)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _DepartmentNameCell extends StatelessWidget {
  const _DepartmentNameCell({required this.item});

  final dynamic item;

  @override
  Widget build(BuildContext context) {
    final name = item['name']?.toString() ?? '';
    final description = item['description']?.toString();

    return Row(
      children: [
        const CircleAvatar(
          radius: 18,
          backgroundColor: Color(0xffeef3ff),
          foregroundColor: Color(0xff4f67d8),
          child: Icon(Icons.business_outlined, size: 18),
        ),
        const SizedBox(width: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 240),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              if (description != null && description.isNotEmpty)
                Text(description,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Color(0xff718096), fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}

class SuperadminAnalyticsScreen extends StatefulWidget {
  const SuperadminAnalyticsScreen({super.key});

  @override
  State<SuperadminAnalyticsScreen> createState() =>
      _SuperadminAnalyticsScreenState();
}

class _SuperadminAnalyticsScreenState extends State<SuperadminAnalyticsScreen> {
  final _api = ApiService();
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final response = await _api.get('/superadmin/analytics');
    if (!mounted) return;
    setState(() => _data = response);
  }

  @override
  Widget build(BuildContext context) {
    final summary = _data?['summary'] ?? {};
    final departments = (_data?['departments'] ?? []) as List<dynamic>;

    return _SuperadminScaffold(
      title: 'Reports and Analytics',
      subtitle: 'System totals, response time, and department performance.',
      child: _data == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AccountSummaryStrip(
                  items: [
                    _AccountSummaryData(
                        label: 'Total inquiries',
                        value: '${summary['total_inquiries'] ?? 0}',
                        icon: Icons.inbox_outlined,
                        color: const Color(0xff4f67d8)),
                    _AccountSummaryData(
                        label: 'Pending',
                        value: '${summary['pending_inquiries'] ?? 0}',
                        icon: Icons.hourglass_top_outlined,
                        color: const Color(0xffc48a3a)),
                    _AccountSummaryData(
                        label: 'Resolved',
                        value: '${summary['resolved_inquiries'] ?? 0}',
                        icon: Icons.check_circle_outline,
                        color: const Color(0xff4c9a73)),
                    _AccountSummaryData(
                      label: 'Avg. response',
                      value: summary['average_response_time'] == null
                          ? '-'
                          : '${summary['average_response_time']} hrs',
                      icon: Icons.schedule_outlined,
                      color: const Color(0xff4fa7a1),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _DepartmentPerformanceTable(departments: departments),
              ],
            ),
    );
  }
}

class _DepartmentPerformanceTable extends StatelessWidget {
  const _DepartmentPerformanceTable({required this.departments});

  final List<dynamic> departments;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _softPanelDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Department Performance',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xff253044))),
            const SizedBox(height: 4),
            const Text(
                'Compare inquiry volume and resolution progress across departments.',
                style: TextStyle(color: Color(0xff718096))),
            const SizedBox(height: 14),
            if (departments.isEmpty)
              const Text('No department performance data yet.')
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  dividerThickness: 0.6,
                  headingRowColor:
                      WidgetStateProperty.all(const Color(0xfff6f9fd)),
                  headingTextStyle:
                      Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: const Color(0xff526074),
                            fontWeight: FontWeight.w800,
                          ),
                  columns: const [
                    DataColumn(label: Text('Department')),
                    DataColumn(label: Text('Total')),
                    DataColumn(label: Text('Pending')),
                    DataColumn(label: Text('Resolved')),
                    DataColumn(label: Text('Resolution')),
                  ],
                  rows: departments.map(
                    (item) {
                      final total = _asInt(item['total']);
                      final resolved = _asInt(item['resolved']);
                      final rate =
                          total == 0 ? 0 : ((resolved / total) * 100).round();

                      return DataRow(
                        cells: [
                          DataCell(Text(item['name'] ?? '',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800))),
                          DataCell(Text('$total')),
                          DataCell(Text('${item['pending'] ?? 0}')),
                          DataCell(Text('$resolved')),
                          DataCell(_MiniProgress(
                              value: rate, color: const Color(0xff4c9a73))),
                        ],
                      );
                    },
                  ).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MiniProgress extends StatelessWidget {
  const _MiniProgress({required this.value, required this.color});

  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: value / 100,
                minHeight: 8,
                color: color,
                backgroundColor: color.withValues(alpha: 0.12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('$value%',
              style: TextStyle(color: color, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class SuperadminSimpleDataScreen extends StatefulWidget {
  const SuperadminSimpleDataScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.endpoint,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String endpoint;
  final IconData icon;

  @override
  State<SuperadminSimpleDataScreen> createState() =>
      _SuperadminSimpleDataScreenState();
}

class _SuperadminSimpleDataScreenState
    extends State<SuperadminSimpleDataScreen> {
  final _api = ApiService();
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final response = await _api.get(widget.endpoint);
    if (!mounted) return;
    setState(() => _data = response);
  }

  @override
  Widget build(BuildContext context) {
    return _SuperadminScaffold(
      title: widget.title,
      subtitle: widget.subtitle,
      action: IconButton.filledTonal(
          onPressed: _load, icon: const Icon(Icons.refresh)),
      child: _data == null
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (widget.endpoint.endsWith('/roles')) {
      final roles = Map<String, dynamic>.from(_data?['data'] ?? {});
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: roles.entries
            .map(
              (entry) => SizedBox(
                width: 360,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.key,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 10),
                        for (final permission in entry.value)
                          ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.check_circle_outline,
                                size: 18),
                            title: Text('$permission'),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      );
    }

    if (widget.endpoint.endsWith('/settings')) {
      final settings = Map<String, dynamic>.from(_data?['data'] ?? {});
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: settings.entries
            .map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_label(entry.key),
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final item in entry.value)
                          Chip(label: Text(_label('$item')))
                      ],
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      );
    }

    if (widget.endpoint.endsWith('/audit-logs')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _JsonSection(title: 'Recent Users', items: _data?['users'] ?? []),
          _JsonSection(
              title: 'Recent Inquiry Updates',
              items: _data?['inquiries'] ?? []),
          _JsonSection(
              title: 'Recent Notifications',
              items: _data?['notifications'] ?? []),
        ],
      );
    }

    final summary = Map<String, dynamic>.from(_data?['summary'] ?? {});
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: summary.entries
              .map((entry) => _MetricTile(
                  label: _label(entry.key), value: '${entry.value}'))
              .toList(),
        ),
        const SizedBox(height: 18),
        Text('Latest Backup Snapshot',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text('Generated at: ${_data?['generated_at'] ?? '-'}'),
        const SizedBox(height: 12),
        const Text(
            'Backup data is available through the secured superadmin API endpoint.'),
      ],
    );
  }
}

class _UserDialog extends StatefulWidget {
  const _UserDialog({required this.departments, this.user});

  final List<dynamic> departments;
  final Map<String, dynamic>? user;

  @override
  State<_UserDialog> createState() => _UserDialogState();
}

class _UserDialogState extends State<_UserDialog> {
  late final TextEditingController _name;
  late final TextEditingController _identifier;
  late final TextEditingController _email;
  late final TextEditingController _password;
  late String _userType;
  int? _departmentId;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _name = TextEditingController(text: user?['name'] ?? '');
    _identifier = TextEditingController(text: user?['user_identifier'] ?? '');
    _email = TextEditingController(text: user?['email'] ?? '');
    _password = TextEditingController();
    _userType = user?['user_type'] ?? 'student';
    _departmentId = user?['department_id'];
    _isActive = user?['is_active'] ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.user == null ? 'Add Account' : 'Edit Account'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 10),
              TextField(
                  controller: _identifier,
                  decoration:
                      const InputDecoration(labelText: 'ID / Identifier')),
              const SizedBox(height: 10),
              TextField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _userType,
                decoration: const InputDecoration(labelText: 'Role'),
                items: const [
                  DropdownMenuItem(value: 'student', child: Text('Student')),
                  DropdownMenuItem(
                      value: 'department_admin',
                      child: Text('Department Admin')),
                  DropdownMenuItem(
                      value: 'super_admin', child: Text('Superadmin')),
                ],
                onChanged: (value) =>
                    setState(() => _userType = value ?? 'student'),
              ),
              if (_userType == 'department_admin') ...[
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  initialValue: widget.departments
                          .any((item) => item['id'] == _departmentId)
                      ? _departmentId
                      : null,
                  decoration: const InputDecoration(labelText: 'Department'),
                  items: widget.departments
                      .map((item) => DropdownMenuItem(
                          value: item['id'] as int,
                          child: Text(item['name'] ?? '')))
                      .toList(),
                  onChanged: (value) => _departmentId = value,
                ),
              ],
              const SizedBox(height: 10),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(
                    labelText:
                        widget.user == null ? 'Password' : 'New password'),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active account'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final password = _password.text.trim();
            Navigator.pop(context, {
              'name': _name.text.trim(),
              'user_identifier': _identifier.text.trim().isEmpty
                  ? null
                  : _identifier.text.trim(),
              'email': _email.text.trim(),
              'user_type': _userType,
              'department_id':
                  _userType == 'department_admin' ? _departmentId : null,
              'password': password.isEmpty ? null : password,
              'password_confirmation': password.isEmpty ? null : password,
              'is_active': _isActive,
            });
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _DepartmentDialog extends StatefulWidget {
  const _DepartmentDialog({this.department});

  final Map<String, dynamic>? department;

  @override
  State<_DepartmentDialog> createState() => _DepartmentDialogState();
}

class _DepartmentDialogState extends State<_DepartmentDialog> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _description;
  late final TextEditingController _phone;
  late final TextEditingController _officeHours;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final department = widget.department;
    _name = TextEditingController(text: department?['name'] ?? '');
    _email = TextEditingController(text: department?['email'] ?? '');
    _description =
        TextEditingController(text: department?['description'] ?? '');
    _phone = TextEditingController(text: department?['phone'] ?? '');
    _officeHours =
        TextEditingController(text: department?['office_hours'] ?? '');
    _isActive = department?['is_active'] ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.department == null ? 'Add Department' : 'Edit Department'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 10),
              TextField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 10),
              TextField(
                  controller: _description,
                  decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 10),
              TextField(
                  controller: _phone,
                  decoration: const InputDecoration(labelText: 'Phone')),
              const SizedBox(height: 10),
              TextField(
                  controller: _officeHours,
                  decoration: const InputDecoration(labelText: 'Office hours')),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active department'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.pop(context, {
            'name': _name.text.trim(),
            'email': _email.text.trim(),
            'description': _description.text.trim(),
            'phone': _phone.text.trim(),
            'office_hours': _officeHours.text.trim(),
            'is_active': _isActive,
          }),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _SuperadminScaffold extends StatelessWidget {
  const _SuperadminScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    this.action,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f7fb),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xfffbfcff), Color(0xfff3f8fb), Color(0xffeef4fb)],
          ),
        ),
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
                      Text(title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.82),
                            height: 1.42),
                      ),
                    ],
                  );

                  if (constraints.maxWidth < 720) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        heading,
                        if (action != null) ...[
                          const SizedBox(height: 18),
                          action!,
                        ],
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: heading),
                      if (action != null) ...[
                        const SizedBox(width: 18),
                        action!,
                      ],
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 22),
            child,
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

class _JsonSection extends StatelessWidget {
  const _JsonSection({required this.title, required this.items});

  final String title;
  final List<dynamic> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          if (items.isEmpty)
            const Text('No records found.')
          else
            for (final item in items)
              Card(
                child: ListTile(
                  title: Text(item['title'] ??
                      item['subject'] ??
                      item['name'] ??
                      'Record #${item['id']}'),
                  subtitle: Text(item['message'] ??
                      item['email'] ??
                      item['status'] ??
                      item['created_at'] ??
                      ''),
                ),
              ),
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

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}
