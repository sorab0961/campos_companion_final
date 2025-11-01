import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/theme.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../models/timetable_model.dart';
import '../../widgets/loading_indicator.dart';
import '../profile/profile_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final dbService = Provider.of<DatabaseService>(context);
    final userId = authService.getCurrentUser()?.id ?? '';

    final List<Widget> _screens = [
      // Notice Board (Notices)
      StreamBuilder<List<Map<String, dynamic>>>(
        stream: dbService.getNotices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const LoadingIndicator();
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          final notices = snapshot.data ?? [];
          return ListView.builder(
            itemCount: notices.length,
            itemBuilder: (context, index) {
              final item = notices[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ExpansionTile(
                  title: Text(item['title']),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(item['content']),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      // Time Table (Timetable)
      StreamBuilder<List<TimetableModel>>(
        stream: dbService.getTimetables(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const LoadingIndicator();
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          final timetables = snapshot.data ?? [];
          return ListView.builder(
            itemCount: timetables.length,
            itemBuilder: (context, index) {
              final item = timetables[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(item.subject),
                  subtitle: Text(item.time),
                ),
              );
            },
          );
        },
      ),
      // Material (Materials)
      StreamBuilder<List<Map<String, dynamic>>>(
        stream: dbService.getMaterials(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const LoadingIndicator();
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          final materials = snapshot.data ?? [];
          return ListView.builder(
            itemCount: materials.length,
            itemBuilder: (context, index) {
              final item = materials[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(item['title']),
                  subtitle: Text(item['description'] ?? ''),
                  trailing: item['link'] != null
                      ? IconButton(
                          icon: const Icon(Icons.link),
                          onPressed: () => launchUrl(Uri.parse(item['link'])),
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: _screens[_selectedIndex],
        key: ValueKey<int>(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          color: Color(0xFF2F2F2F), // dark background
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.announcement, "Notice Board", 0),
            _buildNavItem(Icons.calendar_month, "Time Table", 1),
            _buildNavItem(Icons.layers, "Material", 2),
            _buildNavItem(Icons.person, "Profile", 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.accent.withOpacity(0.2)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 28,
              color: isSelected ? AppTheme.accent : Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? AppTheme.accent : Colors.white70,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
