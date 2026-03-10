import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/core/theme/themecolors.dart';

class TaskDetailPage extends StatefulWidget {
  final String taskId;

  const TaskDetailPage({
    super.key,
    this.taskId = '',
  });

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  // TODO: Replace with TaskBloc state
  final List<_SubtaskItem> _subtasks = [
    _SubtaskItem(title: 'Audit component library', isCompleted: true),
    _SubtaskItem(title: 'Document color tokens', isCompleted: true),
    _SubtaskItem(title: 'Review typography scale', isCompleted: true),
    _SubtaskItem(title: 'Flag legacy styles', isCompleted: false),
    _SubtaskItem(title: 'Write migration guide', isCompleted: false),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final completedCount = _subtasks.where((s) => s.isCompleted).length;
    final progress = _subtasks.isEmpty
        ? 0.0
        : completedCount / _subtasks.length;

    return Scaffold(
      backgroundColor: cs.background,
      body: Column(
        children: [
          /// ── Header ───────────────────────────────────
          _TaskDetailHeader(cs: cs),

          /// ── Scrollable Content ───────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Hero Card
                  _HeroCard(cs: cs),

                  const SizedBox(height: 16),

                  /// Description
                  _DescriptionSection(cs: cs),

                  const SizedBox(height: 16),

                  /// Progress + Checklist
                  _ChecklistSection(
                    cs: cs,
                    subtasks: _subtasks,
                    progress: progress,
                    completedCount: completedCount,
                    onToggle: (index) {
                      setState(() {
                        _subtasks[index].isCompleted =
                            !_subtasks[index].isCompleted;
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
// SUBTASK ITEM MODEL
// ─────────────────────────────────────────────
class _SubtaskItem {
  String title;
  bool isCompleted;

  _SubtaskItem({required this.title, required this.isCompleted});
}

// ─────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────
class _TaskDetailHeader extends StatelessWidget {
  final ColorScheme cs;

  const _TaskDetailHeader({required this.cs});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 53,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cs.background.withOpacity(0.8),
          border: Border(bottom: BorderSide(color: cs.outline)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// Back Button
            InkWell(
              onTap: () => context.pop(),
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_back_ios_rounded,
                    size: 14,
                    color: cs.primary,
                  ),
                  Text(
                    'Tasks',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: cs.primary,
                    ),
                  ),
                ],
              ),
            ),

            /// Title + Subtitle
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  // TODO: Replace with project name from TaskBloc
                  'WEBSITE REDESIGN',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: cs.onSurface.withOpacity(0.4),
                  ),
                ),
                Text(
                  // TODO: Replace with task title from TaskBloc
                  'Design System Audit',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),

            /// More Options
            InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(8),
              child: Icon(
                Icons.more_horiz_rounded,
                size: 20,
                color: cs.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HERO CARD — title, due date, priority badge
// ─────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final ColorScheme cs;

  const _HeroCard({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          /// Decorative blur circle
          Positioned(
            right: -63,
            top: -63,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: AppColors.brandGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Title Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      // TODO: Replace with TaskBloc data
                      'Design System Audit',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  /// Completion Checkbox
                  Container(
                    width: 28,
                    height: 28,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: cs.onSurface.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// Chips Row
              Row(
                children: [
                  /// Due Date Chip
                  _InfoChip(
                    icon: Icons.calendar_today_rounded,
                    label: 'DUE NOV 28, 2024',
                    backgroundColor: cs.surface,
                    borderColor: cs.outline,
                    textColor: cs.onSurface.withOpacity(0.7),
                    iconColor: cs.onSurface.withOpacity(0.4),
                  ),

                  const SizedBox(width: 8),

                  /// Priority Badge
                  _InfoChip(
                    icon: Icons.flag_rounded,
                    label: 'MEDIUM PRIORITY',
                    backgroundColor: AppColors.warning.withOpacity(0.1),
                    borderColor: AppColors.warning.withOpacity(0.3),
                    textColor: AppColors.warning,
                    iconColor: AppColors.warning,
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color iconColor;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DESCRIPTION SECTION
// ─────────────────────────────────────────────
class _DescriptionSection extends StatelessWidget {
  final ColorScheme cs;

  const _DescriptionSection({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DESCRIPTION',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: cs.onSurface.withOpacity(0.4),
            ),
          ),

          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border.all(color: cs.outline),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              // TODO: Replace with TaskBloc data
              'Complete a comprehensive audit of the current design system components, identifying inconsistencies in spacing, color usage, and typography across all mobile screens. Ensure all legacy styles are flagged.',
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: cs.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CHECKLIST SECTION — progress bar + subtasks
// ─────────────────────────────────────────────
class _ChecklistSection extends StatelessWidget {
  final ColorScheme cs;
  final List<_SubtaskItem> subtasks;
  final double progress;
  final int completedCount;
  final ValueChanged<int> onToggle;

  const _ChecklistSection({
    required this.cs,
    required this.subtasks,
    required this.progress,
    required this.completedCount,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CHECKLIST',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: cs.onSurface.withOpacity(0.4),
                ),
              ),
              Text(
                '$completedCount/${subtasks.length} completed',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// Progress Bar
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 8,
                decoration: BoxDecoration(
                  color: cs.outline,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.brandGradient,
                    ),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withOpacity(0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// Subtask List
          ...subtasks.asMap().entries.map((entry) {
            final index = entry.key;
            final subtask = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => onToggle(index),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    border: Border.all(color: cs.outline),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      /// Checkbox
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: subtask.isCompleted
                              ? cs.primary
                              : Colors.transparent,
                          border: Border.all(
                            color: cs.onSurface.withOpacity(0.3),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: subtask.isCompleted
                            ? const Icon(
                                Icons.check_rounded,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),

                      const SizedBox(width: 12),

                      /// Label
                      Text(
                        subtask.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: subtask.isCompleted
                              ? cs.onSurface.withOpacity(0.4)
                              : cs.onSurface.withOpacity(0.9),
                          decoration: subtask.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: cs.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STICKY FOOTER — Mark Complete + Edit + Delete
// ─────────────────────────────────────────────
class _StickyFooter extends StatelessWidget {
  final ColorScheme cs;

  const _StickyFooter({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: BoxDecoration(
        color: cs.background.withOpacity(0.8),
        border: Border(top: BorderSide(color: cs.outline)),
      ),
      child: Row(
        children: [
          /// Mark Complete
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: cs.primary,
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
                  // TODO: TaskBloc ToggleTask event
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                icon: const Icon(
                  Icons.check_rounded,
                  size: 15,
                  color: Colors.white,
                ),
                label: const Text(
                  'Complete',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          /// Edit Button
          _FooterIconButton(
            icon: Icons.edit_rounded,
            backgroundColor: cs.surface,
            borderColor: cs.outline,
            iconColor: cs.onSurface.withOpacity(0.7),
            onTap: () {
              // TODO: Navigate to edit task
            },
          ),

          const SizedBox(width: 12),

          /// Delete Button
          _FooterIconButton(
            icon: Icons.delete_outline_rounded,
            backgroundColor: cs.error.withOpacity(0.1),
            borderColor: cs.error.withOpacity(0.2),
            iconColor: cs.error,
            onTap: () {
              // TODO: TaskBloc SoftDeleteTask event
            },
          ),
        ],
      ),
    );
  }
}

class _FooterIconButton extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _FooterIconButton({
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );
  }
}