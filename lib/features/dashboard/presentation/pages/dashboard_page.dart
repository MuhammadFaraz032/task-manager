import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/core/widgets/app_bottom_navbar.dart';
import 'package:task_manager/core/widgets/coming_soon.dart';
import 'package:task_manager/features/auth/presentation/pages/profile_page.dart';
import 'package:task_manager/features/auth/presentation/pages/settings_page.dart';
import 'package:task_manager/features/dashboard/presentation/widgets/dashboard_app_bar.dart';
import 'package:task_manager/features/dashboard/presentation/widgets/greetings_section.dart';
import 'package:task_manager/features/dashboard/presentation/widgets/project_card.dart';
import 'package:task_manager/features/dashboard/presentation/widgets/quick_actions_section.dart';
import 'package:task_manager/features/dashboard/presentation/widgets/stat_card.dart';
import 'package:task_manager/features/dashboard/presentation/widgets/todays_focus_section.dart';
import 'package:task_manager/features/projects/presentation/bloc/project_bloc.dart';
import 'package:task_manager/features/projects/presentation/bloc/project_event.dart';
import 'package:task_manager/features/workspace/presentation/cubit/workspace_state.dart';
// import 'package:task_manager/features/projects/presentation/bloc/project_state.dart';
import 'package:task_manager/features/projects/presentation/pages/projects_page.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_event.dart';
// import 'package:task_manager/features/tasks/presentation/bloc/task_state.dart';
import 'package:task_manager/features/workspace/presentation/cubit/workspace_cubit.dart';

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

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final workspaceId = context.read<WorkspaceCubit>().currentWorkspaceId;
    if (workspaceId != null) {
      context.read<ProjectBloc>().add(
        ProjectsLoadRequested(workspaceId: workspaceId),
      );
      context.read<TaskBloc>().add(
        TasksLoadRequested(workspaceId: workspaceId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WorkspaceCubit, WorkspaceState>(
      listenWhen: (previous, current) => current is WorkspaceLoaded,
      listener: (context, state) => _loadData(),
      child: SafeArea(
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
      ),
    );
  }
}