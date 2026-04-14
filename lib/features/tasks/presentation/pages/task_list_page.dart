import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/core/theme/themecolors.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_state.dart';
import 'package:task_manager/features/projects/presentation/bloc/project_bloc.dart';
import 'package:task_manager/features/projects/presentation/bloc/project_state.dart';
import 'package:task_manager/features/tasks/domain/entities/task_entity.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_event.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_state.dart';
import 'package:task_manager/features/tasks/presentation/pages/add_task_page.dart';
import 'package:task_manager/features/workspace/presentation/cubit/workspace_cubit.dart';
// import 'package:task_manager/features/workspace/presentation/cubit/workspace_cubit.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  int _selectedFilter = 0; // 0=All, 1=Standalone, 2=Project Tasks
  int _selectedTabIndex = 0; // 0=Todo, 1=Completed  ← ADD THIS LINE
  final List<String> _filters = ['All', 'Standalone', 'Project Tasks'];

  @override
  void initState() {
    super.initState();
    // _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasks();
      // GoRouter.of(context).routerDelegate.addListener(_onRouteChange);
    });
  }

  void _loadTasks() {
    // print('🟢 LOAD TASKS CALLED');
    final workspaceId = context.read<WorkspaceCubit>().currentWorkspaceId;
    // print('🟢 workspaceId = $workspaceId');
    if (workspaceId != null) {
      // print('🟢 Dispatching TasksLoadRequested');
      context.read<TaskBloc>().add(
        TasksLoadRequested(workspaceId: workspaceId),
      );
    }
  }

  // void _onRouteChange() {
  //   if (mounted) _loadTasks();
  // }

  @override
  void dispose() {
    // GoRouter.of(context).routerDelegate.removeListener(_onRouteChange);
    // _tabController.dispose();
    super.dispose();
  }

  Widget _buildTaskList(
    ColorScheme cs,
    TaskState taskState,
    List<TaskEntity> tasks,
    Map<String, String> projectNames,
  ) {
    if (taskState is TaskLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (tasks.isEmpty) {
      return _EmptyState(cs: cs);
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final projectName = task.projectId != null
            ? projectNames[task.projectId]
            : null;
        return _TaskCard(
          cs: cs,
          task: task,
          projectName: projectName,
          onToggle: () {
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthAuthenticated) {
              context.read<TaskBloc>().add(
                TaskToggleRequested(
                  taskId: task.id,
                  completedBy: authState.user.uid,
                ),
              );
            }
          },
          onTap: () => context.push('/task/${task.id}'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, taskState) {
        // Build project name lookup from ProjectBloc
        final projectState = context.watch<ProjectBloc>().state;
        final projectNames = <String, String>{};
        if (projectState is ProjectsLoaded) {
          for (final p in projectState.projects) {
            projectNames[p.id] = p.name;
          }
        }

        // Get tasks from state
        final allTasks = taskState is TasksLoaded
            ? taskState.tasks
            : <TaskEntity>[];

        // Apply dropdown filter (All / Standalone / Project Tasks)
        final dropdownFiltered = switch (_selectedFilter) {
          1 => allTasks.where((t) => t.projectId == null).toList(),
          2 => allTasks.where((t) => t.projectId != null).toList(),
          _ => List<TaskEntity>.from(allTasks),
        };

        // Apply tab filter (Todo / Completed)
        // Apply tab filter (Todo / Completed) using _selectedTabIndex
        final tabFiltered = _selectedTabIndex == 0
            ? dropdownFiltered
                  .where((t) => t.status == TaskStatus.todo)
                  .toList()
            : dropdownFiltered
                  .where((t) => t.status == TaskStatus.completed)
                  .toList();

        return Scaffold(
          backgroundColor: cs.background,
          body: SafeArea(
            child: Column(
              children: [
                _TasksHeader(
                  cs: cs,
                  selectedFilter: _selectedFilter,
                  filters: _filters,
                  onFilterChanged: (index) =>
                      setState(() => _selectedFilter = index),
                  selectedTabIndex: _selectedTabIndex,
                  onTabChanged: (index) =>
                      setState(() => _selectedTabIndex = index),
                ),
                Expanded(
                  child: _buildTaskList(
                    cs,
                    taskState,
                    tabFiltered,
                    projectNames,
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: _AddTaskFAB(cs: cs),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// HEADER WITH TABS
// ─────────────────────────────────────────────
// ─────────────────────────────────────────────
// HEADER WITH CUSTOM TABS
// ─────────────────────────────────────────────
class _TasksHeader extends StatelessWidget {
  final ColorScheme cs;
  final int selectedFilter;
  final List<String> filters;
  final ValueChanged<int> onFilterChanged;
  final int selectedTabIndex;
  final ValueChanged<int> onTabChanged;

  const _TasksHeader({
    required this.cs,
    required this.selectedFilter,
    required this.filters,
    required this.onFilterChanged,
    required this.selectedTabIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = ['Todo', 'Completed'];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(bottom: BorderSide(color: cs.outline)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Top row: Title + Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tasks',
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
                  _FilterDropdownButton(
                    cs: cs,
                    selectedIndex: selectedFilter,
                    filters: filters,
                    onSelected: onFilterChanged,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Custom Tab Bar (horizontal scrollable)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(tabs.length, (index) {
                final isSelected = selectedTabIndex == index;
                return GestureDetector(
                  onTap: () => onTabChanged(index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 24),
                    padding: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected ? cs.primary : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      tabs[index],
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
    );
  }
}

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

// // ─────────────────────────────────────────────
// // DROPDOWN FILTER
// // ─────────────────────────────────────────────

class _FilterDropdownButton extends StatelessWidget {
  final ColorScheme cs;
  final int selectedIndex;
  final List<String> filters;
  final ValueChanged<int> onSelected;

  const _FilterDropdownButton({
    required this.cs,
    required this.selectedIndex,
    required this.filters,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final activeFilter = filters[selectedIndex];
    
    return GestureDetector(
      onTap: () async {
        // Get the button's position on screen
        final RenderBox button = context.findRenderObject() as RenderBox;
        final Offset offset = button.localToGlobal(Offset.zero);
        
        final result = await showMenu<int>(
          context: context,
          position: RelativeRect.fromLTRB(
            offset.dx + button.size.width - 120, // Adjust dropdown position
            offset.dy + button.size.height,
            offset.dx,
            offset.dy,
          ),
          items: filters
              .asMap()
              .entries
              .map(
                (e) => PopupMenuItem<int>(
                  value: e.key,
                  child: Row(
                    children: [
                      if (e.key == selectedIndex)
                        Icon(Icons.check_rounded, size: 16, color: cs.primary)
                      else
                        const SizedBox(width: 16),
                      const SizedBox(width: 8),
                      Text(e.value),
                    ],
                  ),
                ),
              )
              .toList(),
        );
        if (result != null) onSelected(result);
      },
      // borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border.all(color: cs.outline),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_alt_outlined,
              size: 14,
              color: cs.primary,
            ),
            const SizedBox(width: 6),
            Text(
              activeFilter,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cs.primary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: cs.primary,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TASK CARD
// ─────────────────────────────────────────────
class _TaskCard extends StatelessWidget {
  final ColorScheme cs;
  final TaskEntity task;
  final String? projectName;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const _TaskCard({
    required this.cs,
    required this.task,
    required this.projectName,
    required this.onToggle,
    required this.onTap,
  });

  String get _priorityLabel {
    switch (task.priority) {
      case TaskPriority.high:
        return 'HIGH';
      case TaskPriority.medium:
        return 'MED';
      case TaskPriority.low:
        return 'LOW';
      case TaskPriority.none:
        return '';
    }
  }

  Color _priorityColor(ColorScheme cs) {
    switch (task.priority) {
      case TaskPriority.high:
        return const Color(0xFFEF4444);
      case TaskPriority.medium:
        return const Color(0xFFF59E0B);
      case TaskPriority.low:
        return const Color(0xFF10B981);
      case TaskPriority.none:
        return cs.outline;
    }
  }

  String get _dueDateLabel {
    if (task.dueDate == null) return '';
    final now = DateTime.now();
    final due = task.dueDate!;
    final diff = due.difference(DateTime(now.year, now.month, now.day)).inDays;
    if (diff < 0) return 'Overdue';
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    return '${due.day}/${due.month}';
  }

  Color _dueDateColor(ColorScheme cs) {
    if (task.dueDate == null) return cs.onSurface.withValues(alpha: 0.4);
    final label = _dueDateLabel;
    if (label == 'Overdue') return const Color(0xFFEF4444);
    if (label == 'Today') return const Color(0xFFF59E0B);
    return cs.onSurface.withValues(alpha: 0.4);
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.isCompleted;
    final priorityColor = _priorityColor(cs);
    final dueDateColor = _dueDateColor(cs);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCompleted ? cs.surface.withValues(alpha: 0.5) : cs.surface,
            border: Border.all(
              color: isCompleted ? cs.outline.withValues(alpha: 0.5) : cs.outline,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: isCompleted ? cs.primary : Colors.transparent,
                    border: Border.all(
                      color: isCompleted
                          ? cs.primary
                          : cs.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isCompleted
                      ? const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + Priority
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isCompleted
                                  ? cs.onSurface.withValues(alpha: 0.4)
                                  : cs.onSurface,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: cs.onSurface.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                        if (!isCompleted && _priorityLabel.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: priorityColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _priorityLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: priorityColor,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Project badge + Due date
                    Row(
                      children: [
                        if (task.projectId == null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person_rounded,
                                  size: 10,
                                  color: cs.primary.withValues(alpha: 0.7),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Standalone',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: cs.primary.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: cs.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  projectName ?? 'Project',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: cs.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const Spacer(),

                        if (task.dueDate != null)
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 11,
                                color: dueDateColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _dueDateLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: dueDateColor,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
  const _EmptyState({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.checklist_rounded,
              size: 32,
              color: cs.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks here',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first task',
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ADD TASK FAB
// ─────────────────────────────────────────────
class _AddTaskFAB extends StatelessWidget {
  final ColorScheme cs;
  const _AddTaskFAB({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: IconButton(
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            isDismissible: true,
            builder: (_) => Container(
              height: MediaQuery.of(context).size.height * 0.92,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: const AddTaskPage(),
            ),
          );
        },
      ),
    );
  }
}
