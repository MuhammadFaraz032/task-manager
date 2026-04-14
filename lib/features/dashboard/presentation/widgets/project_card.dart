import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/core/theme/themecolors.dart';
import 'package:task_manager/features/projects/domain/entities/project_entity.dart';
import 'package:task_manager/features/projects/presentation/bloc/project_bloc.dart';
import 'package:task_manager/features/projects/presentation/bloc/project_state.dart';

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
    const cardWidth = 260.0;
    const padding = 16.0;
    final centerOfScreen = screenWidth / 2;

    final projectState = context.read<ProjectBloc>().state;
    final projects = projectState is ProjectsLoaded
        ? projectState.projects.where((p) => !p.isDeleted).take(3).toList()
        : [];

    for (int i = 0; i < projects.length; i++) {
      final cardStart = i * (cardWidth + padding) - scrollOffset + 8;
      final cardCenter = cardStart + cardWidth / 2;
      if ((cardCenter - centerOfScreen).abs() < 100) {
        if (_centeredIndex != i) {
          setState(() => _centeredIndex = i);
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final projectState = context.watch<ProjectBloc>().state;

    List<ProjectEntity> recentProjects = [];
    if (projectState is ProjectsLoaded) {
      recentProjects = projectState.projects
          .where((p) => !p.isDeleted)
          .take(3)
          .toList();
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Projects',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/projects'),
              child: Text(
                'View All',
                style: TextStyle(
                  color: cs.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (recentProjects.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outline),
            ),
            child: Center(
              child: Text(
                'No projects yet.\nTap + to create one.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 200,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: recentProjects.length,
              itemBuilder: (context, index) {
                final project = recentProjects[index];
                final progress = project.totalTasks > 0
                    ? project.completedTasks / project.totalTasks
                    : 0.0;
                final isHighlighted = index == _centeredIndex;
                return Container(
                  width: 260,
                  margin: EdgeInsets.only(
                    right: index < recentProjects.length - 1 ? 16 : 0,
                  ),
                  child: ProjectCard(
                    title: project.name,
                    description: project.description.isEmpty ? 'No description' : project.description,
                    progress: progress,
                    category: _getPriorityLabel(project.priority),
                    categoryColor: _getPriorityColor(project.priority),
                    isHighlighted: isHighlighted,
                    onTap: () => context.push('/project/${project.id}'),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  String _getPriorityLabel(ProjectPriority priority) {
    switch (priority) {
      case ProjectPriority.high:
        return 'HIGH';
      case ProjectPriority.medium:
        return 'MED';
      case ProjectPriority.low:
        return 'LOW';
    }
  }

  Color _getPriorityColor(ProjectPriority priority) {
    switch (priority) {
      case ProjectPriority.high:
        return const Color(0xFFEF4444);
      case ProjectPriority.medium:
        return const Color(0xFFF59E0B);
      case ProjectPriority.low:
        return const Color(0xFF10B981);
    }
  }
}

class ProjectCard extends StatelessWidget {
  final String title;
  final String description;
  final double progress;
  final String category;
  final Color categoryColor;
  final bool isHighlighted;
  final VoidCallback onTap;

  const ProjectCard({
    super.key,
    required this.title,
    required this.description,
    required this.progress,
    required this.category,
    required this.categoryColor,
    this.isHighlighted = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(20),
        decoration: isHighlighted
            ? BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.brandGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              )
            : BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outline),
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
                    color: isHighlighted
                        ? Colors.white.withValues(alpha: 0.2)
                        : cs.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.folder_rounded,
                    color: isHighlighted
                        ? Colors.white
                        : cs.onSurface.withValues(alpha: 0.6),
                    size: 20,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? Colors.white.withValues(alpha: 0.2)
                        : categoryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: isHighlighted ? Colors.white : categoryColor,
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
                color: isHighlighted ? Colors.white : cs.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: isHighlighted
                    ? Colors.white.withValues(alpha: 0.7)
                    : cs.onSurface.withValues(alpha: 0.5),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isHighlighted
                        ? Colors.white.withValues(alpha: 0.7)
                        : cs.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isHighlighted ? Colors.white : cs.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? Colors.white.withValues(alpha: 0.2)
                        : cs.outline,
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: isHighlighted ? Colors.white : cs.primary,
                      borderRadius: BorderRadius.circular(32),
                    ),
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