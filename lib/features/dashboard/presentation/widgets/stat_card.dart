import 'package:flutter/material.dart';
import 'package:task_manager/core/theme/themecolors.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Total',
            value: '12',
            bottomText: '+2 new',
            bottomTextColor: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: 'Pending',
            value: '08',
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              width: double.infinity,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outline,
                borderRadius: BorderRadius.circular(32),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.67,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: 'Done',
            value: '45',
            bottomText: 'Top 5%',
            bottomTextColor: cs.primary,
          ),
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? bottomText;
  final Color? bottomTextColor;
  final Widget? child;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.bottomText,
    this.bottomTextColor,
    this.child,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: cs.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          if (bottomText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                bottomText!,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: bottomTextColor,
                ),
              ),
            ),
          if (child != null) child!,
        ],
      ),
    );
  }
}