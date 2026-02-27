import 'package:flutter/material.dart';
import 'package:task_manager/core/widgets/comingsoon.dart';
import 'package:task_manager/dashboard/bottomnavbar.dart';
import 'package:task_manager/settings/settingspage.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  late final PageController _pageController;
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    MainContent(),
    ComingSoon(pageName: "Projects"),
    ComingSoon(pageName: "Tasks"),
    // ComingSoon(pageName: "Settings"),
    SettingsScreen(),
    ComingSoon(pageName: "Profile"),
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
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: _pages,
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

class TopAppBar extends StatelessWidget {
  const TopAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF101622) : const Color(0xFFF6F6F8))
            .withOpacity(0.8),
        borderRadius: BorderRadius.zero,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1F68EF), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(2),
                child: ClipOval(
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBbnr28stu46FbCXTVTsrdXB6Sqb_9NKsZLS6p08cFG7YHSQuLLFj5e4pPFGNWOPEElIo6Eya8V_L_UiW2nfgwvZwoMAFJJjPfppevwsdnKDnKCIMt_8P3RZA7z9bccPl0yKePHM59lQzrn98lXXHPHUdkCjJg1P8mUDmBtwQz3769vleWCfBemDUa7cxk9EpyzdpkdvP4aPys1_AXRdHgjOYbhdiRV3gxH2elmmdHgjcgfKlaJfdQ6D8cF5PvMX2qUGOmlirE81sM',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    'Alex Johnson',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.grey.shade900,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? Colors.grey.shade800
                      : Colors.grey.shade200.withOpacity(0.5),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.search,
                    size: 22,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                  ),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 8),
              Stack(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200.withOpacity(0.5),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.notifications,
                        size: 22,
                        color: isDark
                            ? Colors.grey.shade300
                            : Colors.grey.shade600,
                      ),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red.shade500,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF101622)
                              : const Color(0xFFF6F6F8),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MainContent extends StatelessWidget {
  const MainContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        const SizedBox(height: 8),
        const GreetingSection(),
        const SizedBox(height: 24),
        const StatsGrid(),
        const SizedBox(height: 24),
        const RecentProjectsSection(),
        const SizedBox(height: 16),
        const QuickActionsSection(),
        const SizedBox(height: 24),
        const TodaysFocusSection(),
        const SizedBox(height: 100), // Space for bottom nav
      ],
    );
  }
}

class GreetingSection extends StatelessWidget {
  const GreetingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF1F68EF), Color(0xFF8B5CF6)],
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
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              children: const [
                TextSpan(text: 'You have '),
                TextSpan(
                  text: '5 tasks',
                  style: TextStyle(
                    color: Color(0xFF1F68EF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(text: ' due today.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              title: 'Total',
              value: '12',
              bottomText: '+2 new',
              bottomTextColor: Colors.green.shade500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              title: 'Pending',
              value: '08',
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                width: double.infinity,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.67,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.amber.shade500,
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              title: 'Done',
              value: '45',
              bottomText: 'Top 5%',
              bottomTextColor: const Color(0xFF1F68EF),
            ),
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? bottomText;
  final Color? bottomTextColor;
  final Widget? child;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.bottomText,
    this.bottomTextColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.grey.shade700.withOpacity(0.5)
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey.shade900,
            ),
          ),
          if (bottomText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                bottomText!,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: bottomTextColor,
                ),
              ),
            ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class RecentProjectsSection extends StatefulWidget {
  const RecentProjectsSection({super.key});

  @override
  State<RecentProjectsSection> createState() => _RecentProjectsSectionState();
}

class _RecentProjectsSectionState extends State<RecentProjectsSection> {
  final ScrollController _scrollController = ScrollController();
  int _centeredIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateCenteredIndex);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateCenteredIndex);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateCenteredIndex() {
    if (!_scrollController.hasClients) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final scrollOffset = _scrollController.offset;
    final cardWidth = 260.0; // Card width
    final padding = 16.0; // Gap between cards

    // Calculate which card is most centered
    final centerOfScreen = screenWidth / 2;

    for (int i = 0; i < 2; i++) {
      // We have 2 cards
      final cardStart =
          i * (cardWidth + padding) -
          scrollOffset +
          8; // +8 for initial padding
      final cardCenter = cardStart + cardWidth / 2;

      if ((cardCenter - centerOfScreen).abs() < 100) {
        // Threshold for "centered"
        if (_centeredIndex != i) {
          setState(() {
            _centeredIndex = i;
          });
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Projects',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFF1F68EF),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: 2,
            itemBuilder: (context, index) {
              // First card is gradient when centered, second is always regular for demo
              // In real app, you'd have multiple cards and highlight based on _centeredIndex
              final isHighlighted = index == _centeredIndex;

              if (index == 0) {
                return Container(
                  width: 260,
                  margin: const EdgeInsets.only(right: 16),
                  child: ProjectCard(
                    type: isHighlighted
                        ? ProjectCardType.featured
                        : ProjectCardType.regular,
                    icon: Icons.animation,
                    category: 'Design',
                    title: 'Mobile App UI',
                    description: 'Redesigning the onboarding flow',
                    progress: 0.75,
                    isHighlighted: isHighlighted,
                  ),
                );
              } else {
                return Container(
                  width: 260,
                  child: ProjectCard(
                    type: isHighlighted
                        ? ProjectCardType.featured
                        : ProjectCardType.regular,
                    icon: Icons.campaign,
                    category: 'Marketing',
                    title: 'Launch Strategy',
                    description: 'Q4 social media campaign',
                    progress: 0.3,
                    categoryColor: Colors.amber,
                    isHighlighted: isHighlighted,
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

enum ProjectCardType { featured, regular }

class ProjectCard extends StatelessWidget {
  final ProjectCardType type;
  final IconData icon;
  final String category;
  final String title;
  final String description;
  final double progress;
  final Color? categoryColor;
  final bool isHighlighted;

  const ProjectCard({
    super.key,
    required this.type,
    required this.icon,
    required this.category,
    required this.title,
    required this.description,
    required this.progress,
    this.categoryColor,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine if card should show gradient (when highlighted)
    final bool useGradient = isHighlighted;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: useGradient
          ? BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1F68EF), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1F68EF).withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            )
          : BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.grey.shade700.withOpacity(0.5)
                    : Colors.grey.shade200,
              ),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: useGradient
                      ? Colors.white.withOpacity(0.2)
                      : isDark
                      ? Colors.grey.shade700
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: useGradient
                      ? Colors.white
                      : isDark
                      ? Colors.grey.shade300
                      : Colors.grey.shade600,
                  size: 20,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: useGradient
                      ? Colors.white.withOpacity(0.2)
                      : (categoryColor?.withOpacity(0.1) ??
                            Colors.amber.shade100),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: useGradient
                        ? Colors.white
                        : (categoryColor ?? Colors.amber.shade600),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: useGradient
                  ? Colors.white
                  : (isDark ? Colors.white : Colors.grey.shade900),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: useGradient
                  ? Colors.white.withOpacity(0.7)
                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade500),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: useGradient
                          ? Colors.white.withOpacity(0.7)
                          : (isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade400),
                    ),
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: useGradient
                          ? Colors.white
                          : (isDark
                                ? Colors.grey.shade300
                                : Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                height: 6,
                decoration: BoxDecoration(
                  color: useGradient
                      ? Colors.white.withOpacity(0.2)
                      : (isDark ? Colors.grey.shade700 : Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: useGradient
                          ? Colors.white
                          : const Color(0xFF1F68EF),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: useGradient
                          ? [
                              const BoxShadow(
                                color: Colors.white,
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_circle, size: 20),
              label: const Text('New Project'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F68EF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: const Color(0xFF1F68EF).withOpacity(0.25),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.bolt, size: 20),
              label: const Text('Quick Task'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : Colors.grey.shade900,
                foregroundColor: isDark ? Colors.grey.shade900 : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TodaysFocusSection extends StatelessWidget {
  const TodaysFocusSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Focus",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.grey.shade900,
                ),
              ),
              Text(
                'Oct 24, 2023',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TaskItem(
            title: 'Review UI components',
            subtitle: 'Project: Mobile App UI',
            time: '10:00 AM',
          ),
          const SizedBox(height: 12),
          TaskItem(
            title: 'Team Sync Meeting',
            subtitle: 'Google Meet',
            time: '11:30 AM',
            isCompleted: false,
          ),
        ],
      ),
    );
  }
}

class TaskItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final bool isCompleted;

  const TaskItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.time,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800.withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.grey.shade700.withOpacity(0.3)
              : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              border: Border.all(
                color: isCompleted
                    ? const Color(0xFF1F68EF)
                    : (isDark ? Colors.grey.shade600 : Colors.grey.shade300),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: isCompleted
                ? const Icon(Icons.check, color: Color(0xFF1F68EF), size: 16)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.grey.shade900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
