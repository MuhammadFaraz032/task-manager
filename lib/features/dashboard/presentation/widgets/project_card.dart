import 'package:flutter/material.dart';
import 'package:task_manager/core/theme/themecolors.dart';

class RecentProjectsSection extends StatefulWidget {
  const RecentProjectsSection({super.key});

  @override
  State<RecentProjectsSection> createState() => _RecentProjectsSectionState();
}

class _RecentProjectsSectionState extends State<RecentProjectsSection> {
  final ScrollController _scrollController = ScrollController();
  int _centeredIndex = 0;
  static const int _projectCount = 2;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateCenteredIndex);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateCenteredIndex);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateCenteredIndex() {
    if (!_scrollController.hasClients) return;
    final screenWidth = MediaQuery.of(context).size.width;
    final scrollOffset = _scrollController.offset;
    const cardWidth = 260.0;
    const padding = 16.0;
    final centerOfScreen = screenWidth / 2;

    for (int i = 0; i < _projectCount; i++) {
      final cardStart = i * (cardWidth + padding) - scrollOffset + 8;
      final cardCenter = cardStart + cardWidth / 2;
      if ((cardCenter - centerOfScreen).abs() < 100) {
        if (_centeredIndex != i) {
          setState(() => _centeredIndex = i);
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Projects',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: TextStyle(
                  color: cs.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: _projectCount,
            itemBuilder: (context, index) {
              final isHighlighted = index == _centeredIndex;
              return Container(
                width: 260,
                margin: EdgeInsets.only(
                  right: index < _projectCount - 1 ? 16 : 0,
                ),
                child: ProjectCard(
                  icon: index == 0 ? Icons.animation : Icons.campaign,
                  category: index == 0 ? 'Design' : 'Marketing',
                  title: index == 0 ? 'Mobile App UI' : 'Launch Strategy',
                  description: index == 0
                      ? 'Redesigning the onboarding flow'
                      : 'Q4 social media campaign',
                  progress: index == 0 ? 0.75 : 0.3,
                  categoryColor: index == 0 ? null : AppColors.warning,
                  isHighlighted: isHighlighted,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ProjectCard extends StatelessWidget {
  final IconData icon;
  final String category;
  final String title;
  final String description;
  final double progress;
  final Color? categoryColor;
  final bool isHighlighted;

  const ProjectCard({
    super.key,
    required this.icon,
    required this.category,
    required this.title,
    required this.description,
    required this.progress,
    this.categoryColor,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(20),
      decoration: isHighlighted
          ? BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.brandGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            )
          : BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outline),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isHighlighted
                      ? Colors.white.withOpacity(0.2)
                      : cs.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isHighlighted
                      ? Colors.white
                      : cs.onSurface.withOpacity(0.6),
                  size: 20,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isHighlighted
                      ? Colors.white.withOpacity(0.2)
                      : (categoryColor ?? AppColors.warning).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: isHighlighted
                        ? Colors.white
                        : (categoryColor ?? AppColors.warning),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isHighlighted ? Colors.white : cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: isHighlighted
                  ? Colors.white.withOpacity(0.7)
                  : cs.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isHighlighted
                      ? Colors.white.withOpacity(0.7)
                      : cs.onSurface.withOpacity(0.4),
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isHighlighted ? Colors.white : cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 6,
                decoration: BoxDecoration(
                  color: isHighlighted
                      ? Colors.white.withOpacity(0.2)
                      : cs.outline,
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: isHighlighted ? Colors.white : cs.primary,
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}