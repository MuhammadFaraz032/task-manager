import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        children: [
          /// Header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: cs.background,
              border: Border(
                bottom: BorderSide(color: cs.outline),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Column(
                children: [
                  /// Title Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Projects",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.75,
                          color: cs.onSurface,
                        ),
                      ),
                      Row(
                        children: [
                          _HeaderButton(
                            icon: Icons.search_rounded,
                            cs: cs,
                          ),
                          const SizedBox(width: 8),
                          _HeaderButton(
                            icon: Icons.filter_list_rounded,
                            cs: cs,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  /// Tabs
                  // LEARNING: We keep tabs as a StatefulWidget
                  // so selected tab state is managed locally.
                  // FilterCubit will replace this in Phase 2.
                  const _ProjectTabs(),
                ],
              ),
            ),
          ),

          /// Projects Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                // TODO: Replace with ProjectBloc data
                itemCount: _mockProjects.length,
                itemBuilder: (context, index) {
                  final project = _mockProjects[index];
                  return _ProjectCard(
                    title: project['title'] as String,
                    progress: project['progress'] as double,
                    tasks: project['tasks'] as String,
                    dueDate: project['dueDate'] as String,
                    indicatorColor: project['color'] as Color,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MOCK DATA
// LEARNING: Mock data lives close to the widget
// that uses it. When ProjectBloc is wired up,
// we delete this list and replace with BLoC state.
// ─────────────────────────────────────────────
const List<Map<String, dynamic>> _mockProjects = [
  {
    'title': 'Website Redesign',
    'progress': 0.66,
    'tasks': '12/18',
    'dueDate': '5d left',
    'color': Color(0xFF2563EB),
  },
  {
    'title': 'Mobile App Q4',
    'progress': 0.40,
    'tasks': '8/20',
    'dueDate': '12d left',
    'color': Color(0xFF8B5CF6),
  },
  {
    'title': 'Brand Identity',
    'progress': 0.75,
    'tasks': '15/20',
    'dueDate': '8d left',
    'color': Color(0xFFF97316),
  },
  {
    'title': 'Marketing Kit',
    'progress': 0.16,
    'tasks': '4/24',
    'dueDate': '2w left',
    'color': Color(0xFF2563EB),
  },
  {
    'title': 'User Research',
    'progress': 0.62,
    'tasks': '13/21',
    'dueDate': '10d left',
    'color': Color(0xFF8B5CF6),
  },
  {
    'title': 'Launch Event',
    'progress': 0.45,
    'tasks': '9/20',
    'dueDate': '2w left',
    'color': Color(0xFFF97316),
  },
];

// ─────────────────────────────────────────────
// HEADER BUTTON
// ─────────────────────────────────────────────
class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final ColorScheme cs;

  const _HeaderButton({
    required this.icon,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: cs.surface,
          border: Border.all(color: cs.outline),
        ),
        child: Icon(
          icon,
          size: 18,
          color: cs.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PROJECT TABS
// LEARNING: Tabs have their own selected state
// so they are a StatefulWidget. Kept private (_)
// because nothing outside this file needs it.
// ─────────────────────────────────────────────
class _ProjectTabs extends StatefulWidget {
  const _ProjectTabs();

  @override
  State<_ProjectTabs> createState() => _ProjectTabsState();
}

class _ProjectTabsState extends State<_ProjectTabs> {
  int _selectedTab = 0;
  final List<String> _tabs = ['All', 'Active', 'Completed'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = index),
            child: Container(
              margin: const EdgeInsets.only(right: 24),
              padding: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected
                        ? cs.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                _tabs[index],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: isSelected
                      ? cs.primary
                      : cs.onSurface.withOpacity(0.4),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PROJECT CARD
// ─────────────────────────────────────────────
class _ProjectCard extends StatelessWidget {
  final String title;
  final double progress;
  final String tasks;
  final String dueDate;
  final Color indicatorColor;

  const _ProjectCard({
    required this.title,
    required this.progress,
    required this.tasks,
    required this.dueDate,
    required this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => context.go('/project/temp'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border.all(color: cs.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// Top row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 32,
                  height: 8,
                  decoration: BoxDecoration(
                    color: indicatorColor,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: indicatorColor.withOpacity(0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.more_horiz_rounded,
                  size: 14,
                  color: cs.onSurface.withOpacity(0.4),
                ),
              ],
            ),

            /// Title
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            /// Tasks + Due date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$tasks tasks',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface.withOpacity(0.5),
                  ),
                ),
                Text(
                  dueDate,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),

            /// Progress Bar
            // LEARNING: FractionallySizedBox is the correct way
            // to render percentage-based widths inside a Column.
            // double.infinity * progress = infinity (bug).
            // FractionallySizedBox uses widthFactor (0.0 to 1.0).
            Column(
              children: [
                const SizedBox(height: 4),
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 6,
                      decoration: BoxDecoration(
                        color: cs.outline,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: indicatorColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FAB — Floating Action Button
// ─────────────────────────────────────────────
extension ProjectsFAB on ProjectsScreen {
  Widget buildFAB(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.add_rounded,
            color: Colors.white, size: 24),
        onPressed: () {
          // TODO: Show add project bottom sheet
        },
      ),
    );
  }
}