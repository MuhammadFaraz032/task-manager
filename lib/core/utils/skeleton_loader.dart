import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STAT CARD SKELETON — for dashboard stats grid
// ─────────────────────────────────────────────
class StatCardSkeleton extends StatelessWidget {
  const StatCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 40, height: 40, borderRadius: 12),
          SizedBox(height: 12),
          SkeletonBox(width: 60, height: 24),
          SizedBox(height: 6),
          SkeletonBox(width: 80, height: 14),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PROJECT CARD SKELETON — for projects grid
// ─────────────────────────────────────────────
class ProjectCardSkeleton extends StatelessWidget {
  const ProjectCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SkeletonBox(width: 32, height: 8, borderRadius: 999),
          SkeletonBox(width: double.infinity, height: 18),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SkeletonBox(width: 60, height: 12),
                  SkeletonBox(width: 40, height: 12),
                ],
              ),
              SizedBox(height: 8),
              SkeletonBox(width: double.infinity, height: 6, borderRadius: 999),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TASK CARD SKELETON — for task list
// ─────────────────────────────────────────────
class TaskCardSkeleton extends StatelessWidget {
  const TaskCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 24, height: 24, borderRadius: 8),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: double.infinity, height: 16),
                SizedBox(height: 8),
                Row(
                  children: [
                    SkeletonBox(width: 70, height: 12, borderRadius: 999),
                    Spacer(),
                    SkeletonBox(width: 50, height: 12, borderRadius: 999),
                  ],
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
// STATS GRID SKELETON — 4 cards in a grid
// ─────────────────────────────────────────────
class StatsGridSkeleton extends StatelessWidget {
  const StatsGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        StatCardSkeleton(),
        StatCardSkeleton(),
        StatCardSkeleton(),
        StatCardSkeleton(),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// PROJECTS GRID SKELETON — 4 project cards
// ─────────────────────────────────────────────
class ProjectsGridSkeleton extends StatelessWidget {
  const ProjectsGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.9,
      children: const [
        ProjectCardSkeleton(),
        ProjectCardSkeleton(),
        ProjectCardSkeleton(),
        ProjectCardSkeleton(),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// TASK LIST SKELETON — 5 task rows
// ─────────────────────────────────────────────
class TaskListSkeleton extends StatelessWidget {
  const TaskListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: const [
        TaskCardSkeleton(),
        TaskCardSkeleton(),
        TaskCardSkeleton(),
        TaskCardSkeleton(),
        TaskCardSkeleton(),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// DASHBOARD SKELETON — full page
// ─────────────────────────────────────────────
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        children: [
          // AppBar skeleton
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border(bottom: BorderSide(color: cs.outline)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SkeletonBox(width: 40, height: 40, borderRadius: 32),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 80, height: 12),
                        SizedBox(height: 4),
                        SkeletonBox(width: 100, height: 14),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    SkeletonBox(width: 40, height: 40, borderRadius: 20),
                    SizedBox(width: 8),
                    SkeletonBox(width: 40, height: 40, borderRadius: 20),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
              children: [
                // Greeting skeleton
                const SkeletonBox(width: 200, height: 32),
                const SizedBox(height: 8),
                const SkeletonBox(width: 160, height: 16),
                const SizedBox(height: 24),

                // Stats grid skeleton
                Row(
                  children: const [
                    Expanded(child: _StatCardSkeleton()),
                    SizedBox(width: 12),
                    Expanded(child: _StatCardSkeleton()),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Expanded(child: _StatCardSkeleton()),
                    SizedBox(width: 12),
                    Expanded(child: _StatCardSkeleton()),
                  ],
                ),
                const SizedBox(height: 24),

                // Recent projects section header
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonBox(width: 140, height: 18),
                    SkeletonBox(width: 60, height: 14),
                  ],
                ),
                const SizedBox(height: 12),

                // Recent projects horizontal scroll skeleton
                SizedBox(
                  height: 200,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      _ProjectCardSkeletonWide(),
                      SizedBox(width: 16),
                      _ProjectCardSkeletonWide(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Quick actions skeleton
                Row(
                  children: const [
                    Expanded(
                      child: SkeletonBox(
                        width: double.infinity,
                        height: 52,
                        borderRadius: 12,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: SkeletonBox(
                        width: double.infinity,
                        height: 52,
                        borderRadius: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Today's focus header
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonBox(width: 120, height: 18),
                    SkeletonBox(width: 80, height: 14),
                  ],
                ),
                const SizedBox(height: 16),

                // Today's focus task skeletons
                const _TaskItemSkeleton(),
                const SizedBox(height: 12),
                const _TaskItemSkeleton(),
                const SizedBox(height: 12),
                const _TaskItemSkeleton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// INTERNAL SKELETON PIECES
// ─────────────────────────────────────────────
class _StatCardSkeleton extends StatelessWidget {
  const _StatCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 60, height: 12),
          SizedBox(height: 6),
          SkeletonBox(width: 48, height: 28),
          SizedBox(height: 6),
          SkeletonBox(width: 80, height: 12),
        ],
      ),
    );
  }
}

class _ProjectCardSkeletonWide extends StatelessWidget {
  const _ProjectCardSkeletonWide();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonBox(width: 40, height: 40, borderRadius: 8),
              SkeletonBox(width: 40, height: 20, borderRadius: 4),
            ],
          ),
          SizedBox(height: 16),
          SkeletonBox(width: 160, height: 20),
          SizedBox(height: 8),
          SkeletonBox(width: double.infinity, height: 14),
          SizedBox(height: 4),
          SkeletonBox(width: 120, height: 14),
          SizedBox(height: 16),
          SkeletonBox(width: double.infinity, height: 6, borderRadius: 999),
        ],
      ),
    );
  }
}

class _TaskItemSkeleton extends StatelessWidget {
  const _TaskItemSkeleton();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline),
      ),
      child: const Row(
        children: [
          SkeletonBox(width: 24, height: 24, borderRadius: 4),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: double.infinity, height: 14),
                SizedBox(height: 6),
                SkeletonBox(width: 100, height: 12),
              ],
            ),
          ),
          SizedBox(width: 12),
          SkeletonBox(width: 48, height: 24, borderRadius: 4),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// WORKSPACE LIST SKELETON
// ─────────────────────────────────────────────
class WorkspaceListSkeleton extends StatelessWidget {
  const WorkspaceListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outline),
        ),
        child: const Row(
          children: [
            SkeletonBox(width: 44, height: 44, borderRadius: 10),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 140, height: 15),
                  SizedBox(height: 6),
                  SkeletonBox(width: 80, height: 12),
                ],
              ),
            ),
            SkeletonBox(width: 24, height: 24, borderRadius: 12),
          ],
        ),
      ),
    );
  }
}
