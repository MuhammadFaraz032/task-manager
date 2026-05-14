// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/core/theme/themecolors.dart';
import 'package:task_manager/core/utils/skeleton_loader.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_state.dart';
import 'package:task_manager/features/projects/domain/entities/project_entity.dart';
import 'package:task_manager/features/projects/presentation/bloc/project_bloc.dart';
import 'package:task_manager/features/projects/presentation/bloc/project_event.dart';
import 'package:task_manager/features/projects/presentation/bloc/project_state.dart';
import 'package:task_manager/features/workspace/presentation/cubit/workspace_cubit.dart';
import 'package:task_manager/features/workspace/presentation/cubit/workspace_state.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = ['All', 'Active', 'Completed'];

  @override
  void initState() {
    super.initState();
    // LEARNING: initState is the right place to fire
    // the initial data load event. We use
    // addPostFrameCallback to ensure the widget tree
    // is fully built before we read from context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProjects();
    });
  }

  void _loadProjects() {
    final workspaceState = context.read<WorkspaceCubit>().state;
    if (workspaceState is WorkspaceLoaded) {
      context.read<ProjectBloc>().add(
        ProjectsLoadRequested(workspaceId: workspaceState.workspace.id),
      );
    }
  }

  // LEARNING: Filter projects based on selected tab
  List<ProjectEntity> _filterProjects(List<ProjectEntity> projects) {
    switch (_selectedTab) {
      case 1:
        return projects.where((p) => p.status == ProjectStatus.active).toList();
      case 2:
        return projects
            .where((p) => p.status == ProjectStatus.completed)
            .toList();
      default:
        return projects;
    }
  }

  // Get color based on project priority
  Color _priorityColor(ProjectPriority priority, ColorScheme cs) {
    switch (priority) {
      case ProjectPriority.high:
        return const Color(0xFFF97316);
      case ProjectPriority.medium:
        return cs.secondary;
      case ProjectPriority.low:
        return cs.primary;
    }
  }

  // Format due date to human readable
  String _formatDueDate(DateTime? dueDate) {
    if (dueDate == null) return 'No due date';
    final now = DateTime.now();
    final diff = dueDate.difference(now).inDays;
    if (diff < 0) return 'Overdue';
    if (diff == 0) return 'Due today';
    if (diff == 1) return '1d left';
    if (diff < 7) return '${diff}d left';
    if (diff < 14) return '1w left';
    return '${(diff / 7).floor()}w left';
  }

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
              color: cs.surface,
              border: Border(bottom: BorderSide(color: cs.outline)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Column(
                children: [
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
                          _HeaderButton(icon: Icons.search_rounded, cs: cs),
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
                  SingleChildScrollView(
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
                                    : cs.onSurface.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Projects Grid
          Expanded(
            child: BlocBuilder<ProjectBloc, ProjectState>(
              builder: (context, state) {
                // Loading state
                if (state is ProjectLoading) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
                    child: ProjectsGridSkeleton(),
                  );
                }

                // Error state
                if (state is ProjectError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: cs.error,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          state.message,
                          style: TextStyle(color: cs.error),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _loadProjects,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                // Loaded state
                if (state is ProjectsLoaded) {
                  final filtered = _filterProjects(state.projects);
                  return Stack(
                    children: [
                      RefreshIndicator(
                        color: cs.primary,
                        onRefresh: () async => _loadProjects(),
                        child: filtered.isEmpty
                            ? _EmptyState(
                                cs: cs,
                                selectedTab: _selectedTab,
                                onAddProject: () =>
                                    _showAddProjectSheet(context),
                              )
                            : Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  12,
                                  12,
                                  80,
                                ),
                                child: GridView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 12,
                                        crossAxisSpacing: 12,
                                        childAspectRatio: 0.9,
                                      ),
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) {
                                    final project = filtered[index];
                                    return _ProjectCard(
                                      project: project,
                                      indicatorColor: _priorityColor(
                                        project.priority,
                                        cs,
                                      ),
                                      dueDate: _formatDueDate(project.dueDate),
                                      onTap: () =>
                                          context.go('/project/${project.id}'),
                                    );
                                  },
                                ),
                              ),
                      ),
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: GestureDetector(
                          onTap: () => _showAddProjectSheet(context),
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: AppColors.brandGradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: cs.primary.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                // Initial state — show loader while projects load
                return Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
                  child: ProjectsGridSkeleton(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddProjectSheet(BuildContext context) {
    final projectBloc = context.read<ProjectBloc>();
    final workspaceState = context.read<WorkspaceCubit>().state;
    final authState = context.read<AuthBloc>().state;
    final cs = Theme.of(context).colorScheme;

    // print('🔵 workspaceState: $workspaceState');
    // print('🔵 authState: $authState');

    if (workspaceState is! WorkspaceLoaded) {
      // print('❌ Workspace not loaded — returning');
      return;
    }
    if (authState is! AuthAuthenticated) {
      // print('❌ Auth not authenticated — returning');
      return;
    }

    // print('✅ Opening add project sheet');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: projectBloc,
        child: _AddProjectSheet(
          workspaceId: workspaceState.workspace.id,
          createdBy: authState.user.uid,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final ColorScheme cs;
  final int selectedTab;
  final VoidCallback onAddProject;

  const _EmptyState({
    required this.cs,
    required this.selectedTab,
    required this.onAddProject,
  });

  @override
  Widget build(BuildContext context) {
    final message = selectedTab == 1
        ? 'No active projects'
        : selectedTab == 2
        ? 'No completed projects'
        : 'No projects yet';

    final subtitle = selectedTab == 0
        ? 'Create your first project\nto get started'
        : 'Projects will appear here\nonce their status changes';

    // LEARNING: ListView with AlwaysScrollableScrollPhysics
    // is needed so RefreshIndicator works even
    // when content doesn't fill the screen
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.folder_outlined,
                  size: 40,
                  color: cs.primary.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),
              if (selectedTab == 0) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onAddProject,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Create Project'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// ADD PROJECT BOTTOM SHEET
// ─────────────────────────────────────────────
class _AddProjectSheet extends StatefulWidget {
  final String workspaceId;
  final String createdBy;

  const _AddProjectSheet({required this.workspaceId, required this.createdBy});

  @override
  State<_AddProjectSheet> createState() => _AddProjectSheetState();
}

class _AddProjectSheetState extends State<_AddProjectSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  ProjectPriority _selectedPriority = ProjectPriority.medium;
  DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocListener<ProjectBloc, ProjectState>(
      listener: (context, state) {
        if (state is ProjectsLoaded) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Project created!'),
              backgroundColor: cs.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        if (state is ProjectError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: cs.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.outline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  "New Project",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),

                const SizedBox(height: 24),

                /// Name
                _SheetLabel(label: "Project Name", cs: cs),
                const SizedBox(height: 8),
                _SheetTextField(
                  controller: _nameController,
                  hint: "e.g. Website Redesign",
                  cs: cs,
                ),

                const SizedBox(height: 16),

                /// Description
                _SheetLabel(label: "Description", cs: cs),
                const SizedBox(height: 8),
                _SheetTextField(
                  controller: _descController,
                  hint: "What is this project about?",
                  cs: cs,
                  maxLines: 3,
                ),

                const SizedBox(height: 16),

                /// Priority
                _SheetLabel(label: "Priority", cs: cs),
                const SizedBox(height: 8),
                Row(
                  children: ProjectPriority.values.map((priority) {
                    final isSelected = _selectedPriority == priority;
                    final color = priority == ProjectPriority.high
                        ? const Color(0xFFF97316)
                        : priority == ProjectPriority.medium
                        ? cs.secondary
                        : cs.primary;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedPriority = priority),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withValues(alpha: 0.15)
                              : cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? color : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          priority.name[0].toUpperCase() +
                              priority.name.substring(1),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? color : cs.onSurface,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                /// Due Date
                _SheetLabel(label: "Due Date (Optional)", cs: cs),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => _selectedDueDate = picked);
                    }
                  },
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: cs.onSurface.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectedDueDate != null
                              ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                              : 'Pick a due date',
                          style: TextStyle(
                            color: _selectedDueDate != null
                                ? cs.onSurface
                                : cs.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// Create Button
                BlocBuilder<ProjectBloc, ProjectState>(
                  builder: (context, state) {
                    final isLoading = state is ProjectLoading;
                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                // print('🔵 Create button tapped');
                                // print(
                                //   '🔵 Name: ${_nameController.text.trim()}',
                                // );
                                if (_nameController.text.trim().isEmpty) return;
                                // print('🔵 Firing ProjectCreateRequested');
                                context.read<ProjectBloc>().add(
                                  ProjectCreateRequested(
                                    name: _nameController.text.trim(),
                                    description: _descController.text.trim(),
                                    workspaceId: widget.workspaceId,
                                    createdBy: widget.createdBy,
                                    priority: _selectedPriority,
                                    dueDate: _selectedDueDate,
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                "Create Project",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHARED SHEET WIDGETS
// ─────────────────────────────────────────────
class _SheetLabel extends StatelessWidget {
  final String label;
  final ColorScheme cs;

  const _SheetLabel({required this.label, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: cs.onSurface.withValues(alpha: 0.6),
      ),
    );
  }
}

class _SheetTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ColorScheme cs;
  final int maxLines;

  const _SheetTextField({
    required this.controller,
    required this.hint,
    required this.cs,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: cs.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.4)),
        filled: true,
        fillColor: cs.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outline, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outline, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PROJECT CARD
// ─────────────────────────────────────────────
class _ProjectCard extends StatelessWidget {
  final ProjectEntity project;
  final Color indicatorColor;
  final String dueDate;
  final VoidCallback onTap;

  const _ProjectCard({
    required this.project,
    required this.indicatorColor,
    required this.dueDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
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
                        color: indicatorColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.more_horiz_rounded,
                  size: 14,
                  color: cs.onSurface.withValues(alpha: 0.4),
                ),
              ],
            ),

            /// Title
            Text(
              project.name,
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
                  '${project.completedTasks}/${project.totalTasks} tasks',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  dueDate,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),

            /// Progress Bar
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
                      widthFactor: project.progress,
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
// HEADER BUTTON
// ─────────────────────────────────────────────
class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final ColorScheme cs;

  const _HeaderButton({required this.icon, required this.cs});

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
        child: Icon(icon, size: 18, color: cs.onSurface.withValues(alpha: 0.6)),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FAB
// ─────────────────────────────────────────────
extension ProjectsFAB on ProjectsScreen {
  Widget buildFAB(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.brandGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
        onPressed: () {
          // FAB also opens add project sheet
          // but we need context from _ProjectsScreenState
          // so this is handled via the empty state button
        },
      ),
    );
  }
}
