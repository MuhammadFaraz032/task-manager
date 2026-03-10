import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/core/theme/themecolors.dart';
import 'package:task_manager/features/tasks/presentation/pages/add_task_page.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Today', 'Standalone', 'By Project'];

  // TODO: Replace with TaskBloc data
  final List<_TaskData> _tasks = [
    _TaskData(
      title: 'Design System Audit',
      projectName: 'Website Redesign',
      projectColor: Color(0xFF2563EB),
      priority: 'HIGH',
      priorityColor: Color(0xFFEF4444),
      dueDate: 'Overdue',
      dueDateColor: Color(0xFFEF4444),
      isStandalone: false,
      isCompleted: false,
    ),
    _TaskData(
      title: 'Submit Timesheet',
      projectName: null,
      projectColor: null,
      priority: 'MED',
      priorityColor: Color(0xFFF59E0B),
      dueDate: 'Today',
      dueDateColor: Color(0xFFF59E0B),
      isStandalone: true,
      isCompleted: false,
    ),
    _TaskData(
      title: 'User Testing Sessions',
      projectName: 'Mobile App Q4',
      projectColor: Color(0xFF8B5CF6),
      priority: 'MED',
      priorityColor: Color(0xFFF59E0B),
      dueDate: 'Tomorrow',
      dueDateColor: null,
      isStandalone: false,
      isCompleted: false,
    ),
    _TaskData(
      title: 'Call the Client',
      projectName: null,
      projectColor: null,
      priority: 'HIGH',
      priorityColor: Color(0xFFEF4444),
      dueDate: 'Today',
      dueDateColor: Color(0xFFF59E0B),
      isStandalone: true,
      isCompleted: false,
    ),
    _TaskData(
      title: 'Homepage Wireframes',
      projectName: 'Website Redesign',
      projectColor: Color(0xFF2563EB),
      priority: 'LOW',
      priorityColor: Color(0xFF10B981),
      dueDate: 'Nov 30',
      dueDateColor: null,
      isStandalone: false,
      isCompleted: false,
    ),
    _TaskData(
      title: 'Buy Office Supplies',
      projectName: null,
      projectColor: null,
      priority: 'LOW',
      priorityColor: Color(0xFF10B981),
      dueDate: 'Dec 1',
      dueDateColor: null,
      isStandalone: true,
      isCompleted: true,
    ),
    _TaskData(
      title: 'Brand Identity System',
      projectName: 'Brand Identity',
      projectColor: Color(0xFFF97316),
      priority: 'LOW',
      priorityColor: Color(0xFF10B981),
      dueDate: 'Done',
      dueDateColor: null,
      isStandalone: false,
      isCompleted: true,
    ),
  ];

  List<_TaskData> get _filteredTasks {
    switch (_selectedFilter) {
      case 1: // Today
        return _tasks
            .where(
              (t) =>
                  !t.isCompleted &&
                  (t.dueDate == 'Today' || t.dueDate == 'Overdue'),
            )
            .toList();
      case 2: // Standalone
        return _tasks.where((t) => t.isStandalone).toList();
      case 3: // By Project
        return _tasks.where((t) => !t.isStandalone).toList();
      default: // All
        return _tasks;
    }
  }

  List<_TaskData> get _pendingTasks =>
      _filteredTasks.where((t) => !t.isCompleted).toList();

  List<_TaskData> get _completedTasks =>
      _filteredTasks.where((t) => t.isCompleted).toList();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      body: SafeArea(
        child: Column(
          children: [
            /// ── Header ───────────────────────────────
            _TasksHeader(cs: cs),

            /// ── Filter Chips ─────────────────────────
            _FilterChips(
              cs: cs,
              filters: _filters,
              selectedIndex: _selectedFilter,
              onSelected: (index) => setState(() => _selectedFilter = index),
            ),

            /// ── Task List ────────────────────────────
            Expanded(
              child: _filteredTasks.isEmpty
                  ? _EmptyState(cs: cs)
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      children: [
                        /// Standalone section header
                        if (_selectedFilter == 0 &&
                            _pendingTasks.any((t) => t.isStandalone)) ...[
                          _SectionHeader(
                            cs: cs,
                            label: 'STANDALONE',
                            count: _pendingTasks
                                .where((t) => t.isStandalone)
                                .length,
                          ),
                          const SizedBox(height: 8),
                          ..._pendingTasks
                              .where((t) => t.isStandalone)
                              .map(
                                (task) => _TaskCard(
                                  cs: cs,
                                  task: task,
                                  onToggle: () => setState(
                                    () => task.isCompleted = !task.isCompleted,
                                  ),
                                ),
                              ),
                          const SizedBox(height: 16),
                        ],

                        /// Project tasks section header
                        if (_selectedFilter == 0 &&
                            _pendingTasks.any((t) => !t.isStandalone)) ...[
                          _SectionHeader(
                            cs: cs,
                            label: 'PROJECT TASKS',
                            count: _pendingTasks
                                .where((t) => !t.isStandalone)
                                .length,
                          ),
                          const SizedBox(height: 8),
                          ..._pendingTasks
                              .where((t) => !t.isStandalone)
                              .map(
                                (task) => _TaskCard(
                                  cs: cs,
                                  task: task,
                                  onToggle: () => setState(
                                    () => task.isCompleted = !task.isCompleted,
                                  ),
                                ),
                              ),
                          const SizedBox(height: 16),
                        ],

                        /// Filtered view — no section split
                        if (_selectedFilter != 0) ...[
                          ..._pendingTasks.map(
                            (task) => _TaskCard(
                              cs: cs,
                              task: task,
                              onToggle: () => setState(
                                () => task.isCompleted = !task.isCompleted,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        /// Completed Section
                        if (_completedTasks.isNotEmpty) ...[
                          _SectionHeader(
                            cs: cs,
                            label: 'COMPLETED',
                            count: _completedTasks.length,
                          ),
                          const SizedBox(height: 8),
                          ..._completedTasks.map(
                            (task) => _TaskCard(
                              cs: cs,
                              task: task,
                              onToggle: () => setState(
                                () => task.isCompleted = !task.isCompleted,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),

      /// FAB — Add Task
      floatingActionButton: _AddTaskFAB(cs: cs),
    );
  }
}

// ─────────────────────────────────────────────
// TASK DATA MODEL — temporary until TaskBloc
// ─────────────────────────────────────────────
class _TaskData {
  final String title;
  final String? projectName;
  final Color? projectColor;
  final String priority;
  final Color priorityColor;
  final String dueDate;
  final Color? dueDateColor;
  final bool isStandalone;
  bool isCompleted;

  _TaskData({
    required this.title,
    required this.projectName,
    required this.projectColor,
    required this.priority,
    required this.priorityColor,
    required this.dueDate,
    required this.dueDateColor,
    required this.isStandalone,
    required this.isCompleted,
  });
}

// ─────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────
class _TasksHeader extends StatelessWidget {
  final ColorScheme cs;

  const _TasksHeader({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      decoration: BoxDecoration(
        color: cs.background,
        border: Border(bottom: BorderSide(color: cs.outline)),
      ),
      child: Column(
        children: [
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
                  _HeaderButton(icon: Icons.filter_list_rounded, cs: cs),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
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
        child: Icon(icon, size: 18, color: cs.onSurface.withOpacity(0.6)),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FILTER CHIPS
// ─────────────────────────────────────────────
class _FilterChips extends StatelessWidget {
  final ColorScheme cs;
  final List<String> filters;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _FilterChips({
    required this.cs,
    required this.filters,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: cs.background,
        border: Border(bottom: BorderSide(color: cs.outline)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => onSelected(index),
              borderRadius: BorderRadius.circular(999),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? cs.primary.withOpacity(0.1) : cs.surface,
                  border: Border.all(
                    color: isSelected
                        ? cs.primary.withOpacity(0.3)
                        : cs.outline,
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  filters[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? cs.primary
                        : cs.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SECTION HEADER
// ─────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final ColorScheme cs;
  final String label;
  final int count;

  const _SectionHeader({
    required this.cs,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: cs.onSurface.withOpacity(0.4),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: cs.outline),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cs.onSurface.withOpacity(0.4),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// TASK CARD
// ─────────────────────────────────────────────
class _TaskCard extends StatelessWidget {
  final ColorScheme cs;
  final _TaskData task;
  final VoidCallback onToggle;

  const _TaskCard({
    required this.cs,
    required this.task,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          // TODO: context.go('/task/${task.id}')
          context.go('/task/temp');
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: task.isCompleted ? cs.surface.withOpacity(0.5) : cs.surface,
            border: Border.all(
              color: task.isCompleted
                  ? cs.outline.withOpacity(0.5)
                  : cs.outline,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Checkbox
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: task.isCompleted ? cs.primary : Colors.transparent,
                    border: Border.all(
                      color: task.isCompleted
                          ? cs.primary
                          : cs.primary.withOpacity(0.3),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: task.isCompleted
                      ? const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),

              const SizedBox(width: 12),

              /// Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Title + Priority
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: task.isCompleted
                                  ? cs.onSurface.withOpacity(0.4)
                                  : cs.onSurface,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: cs.onSurface.withOpacity(0.4),
                            ),
                          ),
                        ),
                        if (!task.isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: task.priorityColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              task.priority,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: task.priorityColor,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    /// Project badge + Due date
                    Row(
                      children: [
                        /// Project badge (or standalone label)
                        if (task.isStandalone)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: cs.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person_rounded,
                                  size: 10,
                                  color: cs.primary.withOpacity(0.7),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Personal',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: cs.primary.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (task.projectName != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: task.projectColor!.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: task.projectColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  task.projectName!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: task.projectColor,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const Spacer(),

                        /// Due date
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 11,
                              color:
                                  task.dueDateColor ??
                                  cs.onSurface.withOpacity(0.4),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              task.dueDate,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color:
                                    task.dueDateColor ??
                                    cs.onSurface.withOpacity(0.4),
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
              color: cs.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.checklist_rounded,
              size: 32,
              color: cs.primary.withOpacity(0.5),
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
              color: cs.onSurface.withOpacity(0.4),
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
            color: cs.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
        onPressed: () {
          // TODO: Show AddTaskPage as bottom sheet
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
