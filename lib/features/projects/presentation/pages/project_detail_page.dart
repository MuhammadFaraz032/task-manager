import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/core/theme/themecolors.dart';
import 'package:task_manager/features/tasks/presentation/pages/add_task_page.dart';

class ProjectDetailScreen extends StatelessWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, this.projectId = ''});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              /// Sticky Header
              SliverAppBar(
                pinned: true,
                floating: false,
                backgroundColor: cs.background,
                elevation: 0,
                toolbarHeight: 64,
                // LEARNING: automaticallyImplyLeading: false removes
                // the default back button so we can build our own.
                automaticallyImplyLeading: false,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: cs.outline)),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              InkWell(
                                // LEARNING: context.pop() is go_router's
                                // way of going back. Equivalent to
                                // Navigator.pop() but works with go_router.
                                onTap: () => context.pop(),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: cs.surface,
                                    border: Border.all(color: cs.outline),
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_ios_rounded,
                                    color: cs.primary,
                                    size: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                // TODO: Replace with project name from ProjectBloc
                                "Website Redesign",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.45,
                                  color: cs.onSurface,
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: cs.surface,
                                border: Border.all(color: cs.outline),
                              ),
                              child: Icon(
                                Icons.more_vert_rounded,
                                color: cs.onSurface,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              /// Content
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    /// Progress Card
                    _ProgressCard(cs: cs),

                    const SizedBox(height: 32),

                    /// Active Tasks
                    _TaskSection(cs: cs),
                  ]),
                ),
              ),
            ],
          ),

          /// Bottom Add Task Button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _AddTaskButton(cs: cs),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PROGRESS CARD
// ─────────────────────────────────────────────
class _ProgressCard extends StatelessWidget {
  final ColorScheme cs;

  const _ProgressCard({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.2),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          /// Decorative circles
          Positioned(
            right: -64,
            top: -64,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -48,
            bottom: -48,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          /// Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Project Progress",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        // TODO: Replace with ProjectBloc data
                        "66%",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.trending_up_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "12/18 tasks completed",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  Text(
                    "5 days left",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // LEARNING: FractionallySizedBox for progress bar
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: 0.66,
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white,
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
    );
  }
}

// ─────────────────────────────────────────────
// TASK SECTION
// ─────────────────────────────────────────────
class _TaskSection extends StatelessWidget {
  final ColorScheme cs;

  const _TaskSection({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Active Tasks Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Active Tasks",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: cs.outline),
              ),
              child: Text(
                "3 tasks",
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurface.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // TODO: Replace with TaskBloc data
        _TaskTile(
          cs: cs,
          title: "Design System Documentation",
          priority: "High",
          priorityColor: cs.error,
          dueDate: "Overdue",
          dueDateColor: cs.error,
        ),
        const SizedBox(height: 12),
        _TaskTile(
          cs: cs,
          title: "User Testing Sessions",
          priority: "Medium",
          priorityColor: AppColors.warning,
          dueDate: "Tomorrow",
          dueDateColor: cs.onSurface.withOpacity(0.4),
        ),
        const SizedBox(height: 12),
        _TaskTile(
          cs: cs,
          title: "Homepage Wireframes",
          priority: "Low",
          priorityColor: cs.primary,
          dueDate: "Nov 30",
          dueDateColor: cs.onSurface.withOpacity(0.4),
        ),

        const SizedBox(height: 24),

        /// Completed Tasks Header
        Text(
          "Completed Tasks",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: cs.onSurface.withOpacity(0.4),
          ),
        ),

        const SizedBox(height: 12),

        _TaskTile(cs: cs, title: "Brand Identity System", isCompleted: true),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// TASK TILE
// ─────────────────────────────────────────────
class _TaskTile extends StatelessWidget {
  final ColorScheme cs;
  final String title;
  final String? priority;
  final Color? priorityColor;
  final String? dueDate;
  final Color? dueDateColor;
  final bool isCompleted;

  const _TaskTile({
    required this.cs,
    required this.title,
    this.priority,
    this.priorityColor,
    this.dueDate,
    this.dueDateColor,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted ? cs.surface.withOpacity(0.5) : cs.surface,
        border: Border.all(
          color: isCompleted ? cs.outline.withOpacity(0.5) : cs.outline,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Checkbox
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? cs.primary : Colors.transparent,
              border: Border.all(
                color: isCompleted ? cs.primary : cs.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: isCompleted
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 12)
                : null,
          ),

          const SizedBox(width: 12),

          /// Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isCompleted
                              ? cs.onSurface.withOpacity(0.5)
                              : cs.onSurface,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    if (priority != null && !isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (priorityColor ?? cs.primary).withOpacity(
                            0.15,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          priority!.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: priorityColor ?? cs.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (!isCompleted && dueDate != null)
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: dueDateColor ?? cs.onSurface.withOpacity(0.4),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dueDate!,
                        style: TextStyle(
                          fontSize: 12,
                          color: dueDateColor ?? cs.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  )
                else if (isCompleted)
                  Text(
                    "DONE",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: cs.onSurface.withOpacity(0.4),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ADD TASK BUTTON
// ─────────────────────────────────────────────
class _AddTaskButton extends StatelessWidget {
  final ColorScheme cs;

  const _AddTaskButton({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            cs.background.withOpacity(0),
            cs.background.withOpacity(0.9),
            cs.background,
          ],
        ),
      ),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cs.primary, cs.secondary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          // onPressed: () {
          //   // TODO: Show add task bottom sheet

          // },
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
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
          label: const Text(
            "Add New Task",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
