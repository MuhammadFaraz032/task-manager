import 'package:flutter/material.dart';
import 'package:task_manager/core/widgets/app_bottom_navbar.dart';
import 'package:task_manager/core/widgets/coming_soon.dart';
import 'package:task_manager/features/auth/presentation/pages/profile_page.dart';
import 'package:task_manager/features/auth/presentation/pages/settings_page.dart';
import 'package:task_manager/features/dashboard/presentation/widgets/dashboard_app_bar.dart';
import 'package:task_manager/features/dashboard/presentation/widgets/project_card.dart';
import 'package:task_manager/features/dashboard/presentation/widgets/quick_actions_section.dart';
import 'package:task_manager/features/dashboard/presentation/widgets/stat_card.dart';
import 'package:task_manager/features/dashboard/presentation/widgets/todays_focus_section.dart';
import 'package:task_manager/features/projects/presentation/pages/projects_page.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  late final PageController _pageController;
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardContent(),
    ProjectsScreen(),
    ComingSoon(pageName: "Tasks"),
    SettingsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: EdgeInsets.zero,
        children: const [
          DashboardAppBar(),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                GreetingSection(),
                SizedBox(height: 24),
                StatsGrid(),
                SizedBox(height: 24),
                RecentProjectsSection(),
                SizedBox(height: 24),
                QuickActionsSection(),
                SizedBox(height: 24),
                TodaysFocusSection(),
                SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GreetingSection extends StatelessWidget {
  const GreetingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF8B5CF6)],
          ).createShader(bounds),
          child: const Text(
            'Hello, Alex!',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurface.withOpacity(0.6),
            ),
            children: [
              const TextSpan(text: 'You have '),
              TextSpan(
                text: '5 tasks',
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: ' due today.'),
            ],
          ),
        ),
      ],
    );
  }
}