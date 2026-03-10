import 'package:flutter/material.dart';

class TodaysFocusSection extends StatelessWidget {
  const TodaysFocusSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Focus",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            Text(
              // TODO: Replace with DateTime.now() via intl
              'Today',
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const TaskItem(
          title: 'Review UI components',
          subtitle: 'Project: Mobile App UI',
          time: '10:00 AM',
        ),
        const SizedBox(height: 12),
        const TaskItem(
          title: 'Team Sync Meeting',
          subtitle: 'Google Meet',
          time: '11:30 AM',
        ),
      ],
    );
  }
}

class TaskItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final bool isCompleted;

  const TaskItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.time,
    this.isCompleted = false,
  });

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
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              border: Border.all(
                color: isCompleted
                    ? cs.primary
                    : cs.onSurface.withOpacity(0.3),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
              color: isCompleted
                  ? cs.primary.withOpacity(0.1)
                  : Colors.transparent,
            ),
            child: isCompleted
                ? Icon(Icons.check_rounded, color: cs.primary, size: 16)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: cs.background,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: cs.outline),
            ),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: cs.onSurface.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}