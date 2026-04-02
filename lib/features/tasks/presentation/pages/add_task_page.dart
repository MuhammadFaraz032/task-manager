import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/core/theme/themecolors.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_state.dart';
import 'package:task_manager/features/tasks/domain/entities/task_entity.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_event.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_state.dart';
import 'package:task_manager/features/workspace/presentation/cubit/workspace_cubit.dart';
import 'package:task_manager/features/workspace/presentation/cubit/workspace_state.dart';
import 'package:uuid/uuid.dart';

class AddTaskPage extends StatefulWidget {
  final String? projectId;

  const AddTaskPage({super.key, this.projectId});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController();
  final List<TextEditingController> _checklistControllers = [];

  TaskPriority _selectedPriority = TaskPriority.none;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final c in _checklistControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _saveTask(BuildContext context) {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a task title'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final workspaceState = context.read<WorkspaceCubit>().state;
    final authState = context.read<AuthBloc>().state;

    if (workspaceState is! WorkspaceLoaded) return;
    if (authState is! AuthAuthenticated) return;

    // Build checklist from controllers
    final checklist = _checklistControllers
        .where((c) => c.text.trim().isNotEmpty)
        .map((c) => ChecklistItem(
              id: const Uuid().v4(),
              title: c.text.trim(),
              isCompleted: false,
            ))
        .toList();

    context.read<TaskBloc>().add(
          TaskCreateRequested(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            workspaceId: workspaceState.workspace.id,
            createdBy: authState.user.uid,
            projectId: widget.projectId,
            priority: _selectedPriority,
            dueDate: _selectedDate,
            checklist: checklist,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocListener<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state is TaskOperationSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Task created!'),
              backgroundColor: cs.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        if (state is TaskError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: cs.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: cs.surface,
        body: Column(
          children: [
            /// Header
            _SheetHeader(cs: cs),

            /// Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Task Title
                    TextField(
                      controller: _titleController,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Task Title',
                        hintStyle: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface.withValues(alpha: 0.3),
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 4),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// Description
                    _SectionLabel(
                      icon: Icons.notes_rounded,
                      label: 'DESCRIPTION',
                      cs: cs,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 80),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _descriptionController,
                        maxLines: null,
                        style:
                            TextStyle(fontSize: 16, color: cs.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Add details about this task...',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: cs.onSurface.withValues(alpha: 0.4),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// Due Date
                    _SectionLabel(
                      icon: Icons.calendar_today_outlined,
                      label: 'DUE DATE',
                      cs: cs,
                    ),
                    const SizedBox(height: 12),
                    _DueDatePicker(
                      cs: cs,
                      selectedDate: _selectedDate,
                      onDateSelected: (date) =>
                          setState(() => _selectedDate = date),
                    ),

                    const SizedBox(height: 24),

                    /// Priority
                    _SectionLabel(
                      icon: Icons.flag_outlined,
                      label: 'PRIORITY',
                      cs: cs,
                    ),
                    const SizedBox(height: 12),
                    _PrioritySelector(
                      cs: cs,
                      selected: _selectedPriority,
                      onSelected: (val) =>
                          setState(() => _selectedPriority = val),
                    ),

                    const SizedBox(height: 24),

                    /// Checklist
                    _ChecklistSection(
                      cs: cs,
                      controllers: _checklistControllers,
                      onAddItem: () {
                        setState(() {
                          _checklistControllers
                              .add(TextEditingController());
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            /// Sticky Footer
            _StickyFooter(
              cs: cs,
              onSave: () => _saveTask(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHEET HEADER
// ─────────────────────────────────────────────
class _SheetHeader extends StatelessWidget {
  final ColorScheme cs;

  const _SheetHeader({required this.cs});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 48,
                height: 6,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: cs.outline,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: cs.primary,
                      ),
                    ),
                  ),
                  Text(
                    'New Task',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.45,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(width: 53),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SECTION LABEL
// ─────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme cs;

  const _SectionLabel({
    required this.icon,
    required this.label,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: cs.onSurface.withValues(alpha: 0.4)),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.7,
            color: cs.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// DUE DATE PICKER
// ─────────────────────────────────────────────
class _DueDatePicker extends StatelessWidget {
  final ColorScheme cs;
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateSelected;

  const _DueDatePicker({
    required this.cs,
    required this.selectedDate,
    required this.onDateSelected,
  });

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    return Wrap(
      spacing: 8,
      children: [
        _DateChip(
          cs: cs,
          label: 'Today',
          isSelected:
              selectedDate != null && _isSameDay(selectedDate!, now),
          onTap: () => onDateSelected(now),
        ),
        _DateChip(
          cs: cs,
          label: 'Tomorrow',
          isSelected: selectedDate != null &&
              _isSameDay(selectedDate!, tomorrow),
          onTap: () => onDateSelected(tomorrow),
        ),
        _DateChip(
          cs: cs,
          label: selectedDate != null &&
                  !_isSameDay(selectedDate!, now) &&
                  !_isSameDay(selectedDate!, tomorrow)
              ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
              : 'Pick Date',
          icon: Icons.calendar_month_rounded,
          isSelected: selectedDate != null &&
              !_isSameDay(selectedDate!, now) &&
              !_isSameDay(selectedDate!, tomorrow),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? now,
              firstDate: now,
              lastDate: DateTime(now.year + 2),
            );
            if (picked != null) onDateSelected(picked);
          },
        ),
      ],
    );
  }
}

class _DateChip extends StatelessWidget {
  final ColorScheme cs;
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _DateChip({
    required this.cs,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? cs.primary.withValues(alpha: 0.1)
              : cs.surfaceContainerHighest,
          border: Border.all(
            color: isSelected
                ? cs.primary.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected
                    ? cs.primary
                    : cs.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? cs.primary
                    : cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PRIORITY SELECTOR
// ─────────────────────────────────────────────
class _PrioritySelector extends StatelessWidget {
  final ColorScheme cs;
  final TaskPriority selected;
  final ValueChanged<TaskPriority> onSelected;

  const _PrioritySelector({
    required this.cs,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final priorities = [
      _PriorityOption(
        priority: TaskPriority.none,
        label: 'None',
        icon: Icons.remove_rounded,
        color: cs.onSurface.withValues(alpha: 0.4),
      ),
      _PriorityOption(
        priority: TaskPriority.low,
        label: 'Low',
        icon: Icons.arrow_downward_rounded,
        color: AppColors.success,
      ),
      _PriorityOption(
        priority: TaskPriority.medium,
        label: 'Med',
        icon: Icons.arrow_upward_rounded,
        color: AppColors.warning,
      ),
      _PriorityOption(
        priority: TaskPriority.high,
        label: 'High',
        icon: Icons.priority_high_rounded,
        color: cs.error,
      ),
    ];

    return Row(
      children: priorities
          .map(
            (p) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => onSelected(p.priority),
                  borderRadius: BorderRadius.circular(24),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 56,
                    decoration: BoxDecoration(
                      color: selected == p.priority
                          ? p.color.withValues(alpha: 0.1)
                          : cs.surfaceContainerHighest,
                      border: Border.all(
                        color: selected == p.priority
                            ? p.color.withValues(alpha: 0.3)
                            : Colors.transparent,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          p.icon,
                          size: 14,
                          color: selected == p.priority
                              ? p.color
                              : cs.onSurface.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          p.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: selected == p.priority
                                ? p.color
                                : cs.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _PriorityOption {
  final TaskPriority priority;
  final String label;
  final IconData icon;
  final Color color;

  const _PriorityOption({
    required this.priority,
    required this.label,
    required this.icon,
    required this.color,
  });
}

// ─────────────────────────────────────────────
// CHECKLIST SECTION
// ─────────────────────────────────────────────
class _ChecklistSection extends StatelessWidget {
  final ColorScheme cs;
  final List<TextEditingController> controllers;
  final VoidCallback onAddItem;

  const _ChecklistSection({
    required this.cs,
    required this.controllers,
    required this.onAddItem,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SectionLabel(
              icon: Icons.checklist_rounded,
              label: 'CHECKLIST',
              cs: cs,
            ),
            InkWell(
              onTap: onAddItem,
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  Icon(Icons.add_rounded, size: 14, color: cs.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Add Item',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...controllers.map(
          (controller) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              height: 46,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                border: Border.all(color: cs.outline),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: cs.onSurface.withValues(alpha: 0.3),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: TextStyle(
                        fontSize: 14,
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Checklist item...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: cs.onSurface.withValues(alpha: 0.3),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// STICKY FOOTER
// ─────────────────────────────────────────────
class _StickyFooter extends StatelessWidget {
  final ColorScheme cs;
  final VoidCallback onSave;

  const _StickyFooter({required this.cs, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        final isLoading = state is TaskLoading;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surface,
            border: Border(top: BorderSide(color: cs.outline)),
          ),
          child: SafeArea(
            top: false,
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.brandGradient,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Icon(Icons.add_rounded,
                        color: Colors.white, size: 20),
                label: const Text(
                  'Save Task',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}