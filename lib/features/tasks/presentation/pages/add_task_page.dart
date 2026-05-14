import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/core/theme/themecolors.dart';
import 'package:task_manager/features/auth/domain/entities/user_entity.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_state.dart';
import 'package:task_manager/features/members/presentation/bloc/member_bloc.dart';
import 'package:task_manager/features/members/presentation/bloc/member_event.dart';
import 'package:task_manager/features/members/presentation/bloc/member_state.dart';
import 'package:task_manager/features/tasks/domain/entities/task_entity.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_event.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_state.dart';
import 'package:task_manager/features/workspace/presentation/cubit/workspace_cubit.dart';
import 'package:task_manager/features/workspace/presentation/cubit/workspace_state.dart';
import 'package:uuid/uuid.dart';

class AddTaskPage extends StatefulWidget {
  final String? projectId;
  final TaskEntity? task; // if provided → edit mode

  const AddTaskPage({super.key, this.projectId, this.task});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _assigneeController = TextEditingController();
  final List<TextEditingController> _checklistControllers = [];

  TaskPriority _selectedPriority = TaskPriority.none;
  DateTime? _selectedDate;
  UserEntity? _selectedAssignee;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _loadMembers();
    _prefillIfEditing();
  }

  void _prefillIfEditing() {
    final task = widget.task;
    if (task == null) return;

    _titleController.text = task.title;
    _descriptionController.text = task.description;
    _selectedPriority = task.priority;
    _selectedDate = task.dueDate;

    // Pre-fill checklist controllers
    for (final item in task.checklist) {
      final controller = TextEditingController(text: item.title);
      _checklistControllers.add(controller);
    }
  }

  void _loadMembers() {
    final workspaceState = context.read<WorkspaceCubit>().state;
    if (workspaceState is WorkspaceLoaded) {
      context.read<MemberBloc>().add(
        MembersLoadRequested(
          workspaceId: workspaceState.workspace.id,
          memberIds: workspaceState.workspace.members,
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assigneeController.dispose();
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

    if (_isEditing) {
      // Edit mode — preserve existing checklist completion state
      final existingChecklist = widget.task!.checklist;
      final updatedChecklist = _checklistControllers
          .where((c) => c.text.trim().isNotEmpty)
          .toList()
          .asMap()
          .entries
          .map((entry) {
            final index = entry.key;
            final controller = entry.value;
            // Keep existing isCompleted if item existed before
            final existing = index < existingChecklist.length
                ? existingChecklist[index]
                : null;
            return ChecklistItem(
              id: existing?.id ?? const Uuid().v4(),
              title: controller.text.trim(),
              isCompleted: existing?.isCompleted ?? false,
            );
          })
          .toList();

      context.read<TaskBloc>().add(
        TaskUpdateRequested(
          taskId: widget.task!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _selectedPriority,
          status: widget.task!.status,
          dueDate: _selectedDate,
          checklist: updatedChecklist,
          assignedTo: _selectedAssignee?.uid ?? widget.task!.assignedTo,
        ),
      );
    } else {
      // Create mode
      final checklist = _checklistControllers
          .where((c) => c.text.trim().isNotEmpty)
          .map(
            (c) => ChecklistItem(
              id: const Uuid().v4(),
              title: c.text.trim(),
              isCompleted: false,
            ),
          )
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
          assignedTo: _selectedAssignee?.uid,
        ),
      );
    }
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
              content: Text(_isEditing ? 'Task updated!' : 'Task created!'),
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
            _SheetHeader(cs: cs, isEditing: _isEditing),
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
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Task Title',
                        hintStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface.withValues(alpha: 0.3),
                        ),
                        filled: true,
                        fillColor: cs.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: cs.outline, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: cs.outline, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: cs.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
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
                    TextField(
                      controller: _descriptionController,
                      maxLines: 4,
                      style: TextStyle(fontSize: 16, color: cs.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Add details about this task...',
                        hintStyle: TextStyle(
                          fontSize: 16,
                          color: cs.onSurface.withValues(alpha: 0.4),
                        ),
                        filled: true,
                        fillColor: cs.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: cs.outline, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: cs.outline, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: cs.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// Assign To
                    _SectionLabel(
                      icon: Icons.person_outline_rounded,
                      label: 'ASSIGN TO',
                      cs: cs,
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<MemberBloc, MemberState>(
                      builder: (context, state) {
                        final members = state is MembersLoaded
                            ? state.members
                            : <UserEntity>[];

                        // Pre-fill assignee name if editing
                        if (_isEditing &&
                            _selectedAssignee == null &&
                            widget.task!.assignedTo != null &&
                            _assigneeController.text.isEmpty) {
                          try {
                            final existing = members.firstWhere(
                              (m) => m.uid == widget.task!.assignedTo,
                            );
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() {
                                  _selectedAssignee = existing;
                                  _assigneeController.text =
                                      '${existing.fullName} (${existing.email})';
                                });
                              }
                            });
                          } catch (_) {}
                        }

                        return _AssigneeSearchField(
                          cs: cs,
                          controller: _assigneeController,
                          members: members,
                          selectedAssignee: _selectedAssignee,
                          onAssigneeSelected: (member) {
                            setState(() {
                              _selectedAssignee = member;
                              _assigneeController.text = member != null
                                  ? '${member.fullName} (${member.email})'
                                  : '';
                            });
                          },
                        );
                      },
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
                          _checklistControllers.add(TextEditingController());
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            _StickyFooter(
              cs: cs,
              isEditing: _isEditing,
              onSave: () => _saveTask(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ASSIGNEE SEARCH FIELD
// ─────────────────────────────────────────────
class _AssigneeSearchField extends StatefulWidget {
  final ColorScheme cs;
  final TextEditingController controller;
  final List<UserEntity> members;
  final UserEntity? selectedAssignee;
  final ValueChanged<UserEntity?> onAssigneeSelected;

  const _AssigneeSearchField({
    required this.cs,
    required this.controller,
    required this.members,
    required this.selectedAssignee,
    required this.onAssigneeSelected,
  });

  @override
  State<_AssigneeSearchField> createState() => _AssigneeSearchFieldState();
}

class _AssigneeSearchFieldState extends State<_AssigneeSearchField> {
  List<UserEntity> _filtered = [];
  bool _showDropdown = false;

  void _onChanged(String query) {
    if (query.isEmpty || widget.selectedAssignee != null) {
      setState(() {
        _filtered = [];
        _showDropdown = false;
      });
      return;
    }

    final results = widget.members
        .where(
          (m) =>
              m.email.toLowerCase().contains(query.toLowerCase()) ||
              m.fullName.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    setState(() {
      _filtered = results;
      _showDropdown = results.isNotEmpty;
    });
  }

  void _selectMember(UserEntity member) {
    widget.onAssigneeSelected(member);
    setState(() {
      _showDropdown = false;
      _filtered = [];
    });
  }

  void _clearSelection() {
    widget.onAssigneeSelected(null);
    widget.controller.clear();
    setState(() {
      _showDropdown = false;
      _filtered = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.cs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: widget.controller,
            readOnly: widget.selectedAssignee != null,
            onChanged: _onChanged,
            style: TextStyle(fontSize: 15, color: cs.onSurface),
            decoration: InputDecoration(
              hintText: 'Search by name or email...',
              hintStyle: TextStyle(
                fontSize: 15,
                color: cs.onSurface.withValues(alpha: 0.4),
              ),
              prefixIcon: widget.selectedAssignee != null
                  ? CircleAvatar(
                      radius: 14,
                      backgroundColor: cs.primaryContainer,
                      child: Text(
                        widget.selectedAssignee!.fullName.isNotEmpty
                            ? widget.selectedAssignee!.fullName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: cs.onPrimaryContainer,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.search_rounded,
                      color: cs.onSurface.withValues(alpha: 0.4),
                    ),
              suffixIcon: widget.selectedAssignee != null
                  ? IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                      onPressed: _clearSelection,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),

        if (_showDropdown)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outline),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: cs.outline),
              itemBuilder: (context, index) {
                final member = _filtered[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: cs.primaryContainer,
                    child: Text(
                      member.fullName.isNotEmpty
                          ? member.fullName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                  ),
                  title: Text(member.fullName),
                  subtitle: Text(
                    member.email,
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  onTap: () => _selectMember(member),
                );
              },
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// SHEET HEADER
// ─────────────────────────────────────────────
class _SheetHeader extends StatelessWidget {
  final ColorScheme cs;
  final bool isEditing;

  const _SheetHeader({required this.cs, required this.isEditing});

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    isEditing ? 'Edit Task' : 'New Task',
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
          isSelected: selectedDate != null && _isSameDay(selectedDate!, now),
          onTap: () => onDateSelected(now),
        ),
        _DateChip(
          cs: cs,
          label: 'Tomorrow',
          isSelected:
              selectedDate != null && _isSameDay(selectedDate!, tomorrow),
          onTap: () => onDateSelected(tomorrow),
        ),
        _DateChip(
          cs: cs,
          label:
              selectedDate != null &&
                  !_isSameDay(selectedDate!, now) &&
                  !_isSameDay(selectedDate!, tomorrow)
              ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
              : 'Pick Date',
          icon: Icons.calendar_month_rounded,
          isSelected:
              selectedDate != null &&
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              borderRadius: BorderRadius.circular(4),
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
  final bool isEditing;
  final VoidCallback onSave;

  const _StickyFooter({
    required this.cs,
    required this.isEditing,
    required this.onSave,
  });

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
                    : Icon(
                        isEditing ? Icons.save_outlined : Icons.add_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                label: Text(
                  isEditing ? 'Save Changes' : 'Save Task',
                  style: const TextStyle(
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
