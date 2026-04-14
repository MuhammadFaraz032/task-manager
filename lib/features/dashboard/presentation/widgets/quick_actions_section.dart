import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/features/tasks/presentation/pages/add_task_page.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Navigate to projects page and open create modal
              context.push('/projects');
              // TODO: Auto-open create project bottom sheet
            },
            icon: const Icon(Icons.add_circle_rounded, size: 20),
            label: const Text('New Project'),
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
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
            icon: const Icon(Icons.bolt_rounded, size: 20),
            label: const Text('Quick Task'),
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.onSurface,
              foregroundColor: cs.surface,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }
}