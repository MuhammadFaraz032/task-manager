import 'package:flutter/material.dart';
import 'package:task_manager/projects/projectview.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            /// Header - Top Navigation Bar
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.background.withOpacity(0.8),
                border: Border(bottom: BorderSide(color: colorScheme.outline)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                    child: Column(
                      children: [
                        /// Top Row with Title and Icons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Projects",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.75,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: colorScheme.surface.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.search,
                                    size: 18,
                                    color: colorScheme.onSurface.withOpacity(
                                      0.6,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: colorScheme.surface.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.filter_list,
                                    size: 16,
                                    color: colorScheme.onSurface.withOpacity(
                                      0.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        /// Tabs
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildTab(context, "All", isActive: true),
                              const SizedBox(width: 24),
                              _buildTab(context, "Active"),
                              const SizedBox(width: 24),
                              _buildTab(context, "Completed"),
                              const SizedBox(width: 24),
                              // _buildTab(context, "Archived"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// Projects Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.9,
                  children: [
                    _buildProjectCard(
                      context,
                      title: "Website Redesign",
                      progress: 0.66,
                      tasks: "12/18",
                      dueDate: "5d left",
                      indicatorColor: colorScheme.primary,
                    ),
                    _buildProjectCard(
                      context,
                      title: "Mobile App Q4",
                      progress: 0.40,
                      tasks: "8/20",
                      dueDate: "12d left",
                      indicatorColor: colorScheme.secondary,
                    ),
                    _buildProjectCard(
                      context,
                      title: "Brand Identity",
                      progress: 0.75,
                      tasks: "15/20",
                      dueDate: "8d left",
                      indicatorColor: const Color(0xFFF97316),
                    ),
                    _buildProjectCard(
                      context,
                      title: "Marketing Kit",
                      progress: 0.16,
                      tasks: "4/24",
                      dueDate: "2w left",
                      indicatorColor: colorScheme.primary,
                    ),
                    _buildProjectCard(
                      context,
                      title: "User Research",
                      progress: 0.62,
                      tasks: "13/21",
                      dueDate: "10d left",
                      indicatorColor: colorScheme.secondary,
                    ),
                    _buildProjectCard(
                      context,
                      title: "Launch Event",
                      progress: 0.45,
                      tasks: "9/20",
                      dueDate: "2w left",
                      indicatorColor: const Color(0xFFF97316),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorScheme.primary, colorScheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.3),
              blurRadius: 25,
              offset: const Offset(0, 20),
            ),
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(Icons.add, color: Colors.white, size: 24),
          onPressed: () {
            // Handle add project
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildTab(
    BuildContext context,
    String label, {
    bool isActive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: isActive
            ? Border(bottom: BorderSide(color: colorScheme.primary, width: 2))
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          color: isActive
              ? colorScheme.primary
              : colorScheme.onSurface.withOpacity(0.4),
        ),
      ),
    );
  }

  Widget _buildProjectCard(
    BuildContext context, {
    required String title,
    required double progress,
    required String tasks,
    required String dueDate,
    required Color indicatorColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => const ProjectDetailScreen(),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(0.5),
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// Top row with indicator and menu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 32,
                  height: 8,
                  decoration: BoxDecoration(
                    color: indicatorColor,
                    borderRadius: BorderRadius.circular(9999),
                    boxShadow: [
                      BoxShadow(
                        color: indicatorColor.withOpacity(0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.more_horiz,
                  size: 14,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// Project Title
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 24),

            /// Tasks and Due Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "$tasks tasks",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                Text(
                  dueDate,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            /// Progress Bar
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 6,
                  decoration: BoxDecoration(
                    color: colorScheme.outline,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
                Container(
                  width: double.infinity * progress,
                  height: 6,
                  decoration: BoxDecoration(
                    color: indicatorColor,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
