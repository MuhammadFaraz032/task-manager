import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/core/theme/themecolors.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  // LEARNING: Controllers in StatefulWidget — never in build()
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<TextEditingController> _checklistControllers = [
    TextEditingController(text: 'Draft outline'),
    TextEditingController(text: 'Review with team'),
  ];

  String _selectedProject = 'Website Redesign';
  String _selectedPriority = 'low';  // none, low, medium, high, critical
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      body: Column(
        children: [
          /// ── Handle + Header ──────────────────────────
          _SheetHeader(cs: cs),

          /// ── Scrollable Content ───────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Task Title Input
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
                        color: cs.onSurface.withOpacity(0.3),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// ── Description ──────────────────────
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
                      color: cs.surface.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: null,
                      style: TextStyle(
                        fontSize: 16,
                        color: cs.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Add details about this task...',
                        hintStyle: TextStyle(
                          fontSize: 16,
                          color: cs.onSurface.withOpacity(0.4),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// ── Project Selector ─────────────────
                  _SectionLabel(
                    icon: Icons.folder_outlined,
                    label: 'PROJECT',
                    cs: cs,
                  ),
                  const SizedBox(height: 8),
                  _ProjectDropdown(
                    cs: cs,
                    selectedProject: _selectedProject,
                    onChanged: (val) =>
                        setState(() => _selectedProject = val ?? _selectedProject),
                  ),

                  const SizedBox(height: 24),

                  /// ── Due Date Picker ───────────────────
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

                  /// ── Priority Selector ─────────────────
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

                  /// ── Checklist ─────────────────────────
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

          /// ── Sticky Footer ─────────────────────────────
          _StickyFooter(cs: cs),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHEET HEADER — handle + title + cancel
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
            /// Drag Handle
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

            /// Title Row
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// Cancel Button
                  InkWell(
                    onTap: () => context.pop(),
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

                  /// Title
                  Text(
                    'New Task',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.45,
                      color: cs.onSurface,
                    ),
                  ),

                  /// Spacer to balance layout
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
// SECTION LABEL — icon + uppercase text
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
        Icon(icon, size: 16, color: cs.onSurface.withOpacity(0.4)),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.7,
            color: cs.onSurface.withOpacity(0.4),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// PROJECT DROPDOWN
// ─────────────────────────────────────────────
class _ProjectDropdown extends StatelessWidget {
  final ColorScheme cs;
  final String selectedProject;
  final ValueChanged<String?> onChanged;

  // TODO: Replace with ProjectBloc data
  static const List<String> _projects = [
    'Website Redesign',
    'Mobile App Q4',
    'Brand Identity',
    'Marketing Kit',
    'No Project',
  ];

  const _ProjectDropdown({
    required this.cs,
    required this.selectedProject,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedProject,
          isExpanded: true,
          dropdownColor: cs.surface,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: cs.onSurface.withOpacity(0.4),
          ),
          style: TextStyle(
            fontSize: 16,
            color: cs.onSurface,
          ),
          items: _projects
              .map((p) => DropdownMenuItem(
                    value: p,
                    child: Text(p),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DUE DATE PICKER — Today / Tomorrow / Pick Date
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

  String _label() {
    if (selectedDate == null) return 'Today';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final d = DateTime(
        selectedDate!.year, selectedDate!.month, selectedDate!.day);
    if (d == today) return 'Today';
    if (d == tomorrow) return 'Tomorrow';
    return '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    return Wrap(
      spacing: 8,
      children: [
        /// Today
        _DateChip(
          cs: cs,
          label: 'Today',
          isSelected: selectedDate == null ||
              _isSameDay(selectedDate!, now),
          onTap: () => onDateSelected(now),
        ),

        /// Tomorrow
        _DateChip(
          cs: cs,
          label: 'Tomorrow',
          isSelected: selectedDate != null &&
              _isSameDay(selectedDate!, tomorrow),
          onTap: () => onDateSelected(tomorrow),
        ),

        /// Pick Date
        _DateChip(
          cs: cs,
          label: selectedDate != null &&
                  !_isSameDay(selectedDate!, now) &&
                  !_isSameDay(selectedDate!, tomorrow)
              ? _label()
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
              builder: (context, child) => Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: cs,
                ),
                child: child!,
              ),
            );
            if (picked != null) onDateSelected(picked);
          },
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
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
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? cs.primary.withOpacity(0.1)
              : cs.surface,
          border: Border.all(
            color: isSelected
                ? cs.primary.withOpacity(0.3)
                : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14,
                  color: isSelected
                      ? cs.primary
                      : cs.onSurface.withOpacity(0.6)),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? cs.primary
                    : cs.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PRIORITY SELECTOR — None / Low / Medium / High / Critical
// ─────────────────────────────────────────────
class _PrioritySelector extends StatelessWidget {
  final ColorScheme cs;
  final String selected;
  final ValueChanged<String> onSelected;

  const _PrioritySelector({
    required this.cs,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final priorities = [
      _PriorityOption(
          key: 'none',
          label: 'None',
          icon: Icons.remove_rounded,
          color: cs.onSurface.withOpacity(0.4)),
      _PriorityOption(
          key: 'low',
          label: 'Low',
          icon: Icons.arrow_downward_rounded,
          color: AppColors.success),
      _PriorityOption(
          key: 'medium',
          label: 'Med',
          icon: Icons.arrow_upward_rounded,
          color: AppColors.warning),
      _PriorityOption(
          key: 'high',
          label: 'High',
          icon: Icons.priority_high_rounded,
          color: cs.error),
    ];

    return Row(
      children: priorities
          .map((p) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => onSelected(p.key),
                    borderRadius: BorderRadius.circular(24),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 56,
                      decoration: BoxDecoration(
                        color: selected == p.key
                            ? p.color.withOpacity(0.1)
                            : cs.surface,
                        border: Border.all(
                          color: selected == p.key
                              ? p.color.withOpacity(0.3)
                              : Colors.transparent,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(p.icon,
                              size: 14,
                              color: selected == p.key
                                  ? p.color
                                  : cs.onSurface.withOpacity(0.4)),
                          const SizedBox(height: 4),
                          Text(
                            p.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: selected == p.key
                                  ? p.color
                                  : cs.onSurface.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _PriorityOption {
  final String key;
  final String label;
  final IconData icon;
  final Color color;

  const _PriorityOption({
    required this.key,
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
        /// Header row
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
                  Icon(Icons.add_rounded,
                      size: 14, color: cs.primary),
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

        /// Checklist Items
        ...controllers.map((controller) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                height: 46,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surface.withOpacity(0.3),
                  border: Border.all(color: cs.outline),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    /// Checkbox
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: cs.onSurface.withOpacity(0.3),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// Text Input
                    Expanded(
                      child: TextField(
                        controller: controller,
                        style: TextStyle(
                          fontSize: 14,
                          color: cs.onSurface.withOpacity(0.6),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Checklist item...',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: cs.onSurface.withOpacity(0.3),
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
            )),

        const SizedBox(height: 32),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// STICKY FOOTER — Save Task Button
// ─────────────────────────────────────────────
class _StickyFooter extends StatelessWidget {
  final ColorScheme cs;

  const _StickyFooter({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.background.withOpacity(0.8),
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
                color: cs.primary.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: TaskBloc AddTask event
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            icon: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 20,
            ),
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
  }
}