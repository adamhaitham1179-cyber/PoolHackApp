
import 'package:flutter/material.dart';

const Color adminBg = Color(0xFF101026);
const Color adminPanel = Color(0xFF20203D);
const Color adminPurple = Color(0xFF8B5CF6);
const Color adminCyan = Color(0xFF36D9E8);

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final searchController = TextEditingController();

  final List<Map<String, dynamic>> users = [
    {
      'username': 'Player001',
      'status': 'ACTIVE',
      'days': 20,
    },
    {
      'username': 'Player002',
      'status': 'EXPIRED',
      'days': 0,
    },
    {
      'username': 'Player003',
      'status': 'DISABLED',
      'days': 12,
    },
    {
      'username': 'Player004',
      'status': 'ACTIVE',
      'days': 5,
    },
  ];

  String filter = 'ALL';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredUsers {
    final query = searchController.text.toLowerCase();

    return users.where((user) {
      final matchesName =
          user['username'].toString().toLowerCase().contains(query);
      final matchesStatus =
          filter == 'ALL' || user['status'] == filter;

      return matchesName && matchesStatus;
    }).toList();
  }

  int countStatus(String status) =>
      users.where((u) => u['status'] == status).length;

  void notify(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color statusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return Colors.greenAccent;
      case 'EXPIRED':
        return Colors.orangeAccent;
      default:
        return Colors.redAccent;
    }
  }

  void changeStatus(Map<String, dynamic> user) {
    final current = user['status'] as String;

    setState(() {
      if (current == 'ACTIVE') {
        user['status'] = 'DISABLED';
      } else {
        user['status'] = 'ACTIVE';
      }
    });

    notify('Updated ${user['username']} to ${user['status']}');
  }

  void extendDemoSubscription(Map<String, dynamic> user) {
    setState(() {
      user['days'] = (user['days'] as int) + 30;
      user['status'] = 'ACTIVE';
    });

    notify('Demo: added 30 days to ${user['username']}');
  }

  void showUserDetails(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: adminPanel,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user['username'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text('Status: ${user['status']}'),
            const SizedBox(height: 10),
            Text('Demo subscription: ${user['days']} days'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  extendDemoSubscription(user);
                },
                icon: const Icon(Icons.add_alarm),
                label: const Text('Add 30 demo days'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  changeStatus(user);
                },
                icon: const Icon(Icons.toggle_on),
                label: Text(
                  user['status'] == 'ACTIVE'
                      ? 'Disable demo account'
                      : 'Activate demo account',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget statCard(
    String title,
    int value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: adminPanel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 16),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: adminBg,
      appBar: AppBar(
        backgroundColor: adminBg,
        title: const Text(
          'ADMIN CENTER',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh demo dashboard',
            onPressed: () {
              setState(() {});
              notify('Dashboard refreshed');
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6339C7), Color(0xFF29245B)],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.admin_panel_settings, size: 36),
                  SizedBox(height: 14),
                  Text(
                    'Welcome, Admin',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text('Independent demo dashboard'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'OVERVIEW',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.35,
              children: [
                statCard(
                  'Total demo users',
                  users.length,
                  Icons.people_alt_outlined,
                  adminCyan,
                ),
                statCard(
                  'Active',
                  countStatus('ACTIVE'),
                  Icons.check_circle_outline,
                  Colors.greenAccent,
                ),
                statCard(
                  'Expired',
                  countStatus('EXPIRED'),
                  Icons.timer_off_outlined,
                  Colors.orangeAccent,
                ),
                statCard(
                  'Disabled',
                  countStatus('DISABLED'),
                  Icons.block_outlined,
                  Colors.redAccent,
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Text(
              'DEMO USER DIRECTORY',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search username...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: adminPanel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: filter,
              decoration: InputDecoration(
                labelText: 'Filter status',
                filled: true,
                fillColor: adminPanel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'ALL', child: Text('All users')),
                DropdownMenuItem(value: 'ACTIVE', child: Text('Active')),
                DropdownMenuItem(value: 'EXPIRED', child: Text('Expired')),
                DropdownMenuItem(value: 'DISABLED', child: Text('Disabled')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => filter = value);
                }
              },
            ),
            const SizedBox(height: 12),
            if (filteredUsers.isEmpty)
              const Padding(
                padding: EdgeInsets.all(28),
                child: Center(child: Text('No matching demo users')),
              ),
            ...filteredUsers.map((user) {
              final status = user['status'] as String;

              return Card(
                color: adminPanel,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  onTap: () => showUserDetails(user),
                  leading: CircleAvatar(
                    backgroundColor: adminPurple.withValues(alpha: 0.2),
                    child: const Icon(
                      Icons.person_outline,
                      color: adminCyan,
                    ),
                  ),
                  title: Text(
                    user['username'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${user['days']} demo days remaining'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        status,
                        style: TextStyle(
                          color: statusColor(status),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 18),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            const Text(
              'DEMO ONLY — changes are stored in memory and reset when the app restarts.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
