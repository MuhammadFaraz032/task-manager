import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: cs.surface,
          // LEARNING: Border.all affects all sides.
          // Border() constructor lets you style each side independently.
          // We only want a top border here — so we use Border() not Border.all()
          border: Border(
            top: BorderSide(color: cs.outline),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context,
              icon: Icons.grid_view_rounded,
              label: 'Dashboard',
              index: 0,
              cs: cs,
            ),
            _buildNavItem(
              context,
              icon: Icons.folder_open_rounded,
              label: 'Projects',
              index: 1,
              cs: cs,
            ),
            _buildNavItem(
              context,
              icon: Icons.check_circle_outline_rounded,
              label: 'Tasks',
              index: 2,
              cs: cs,
            ),
            _buildNavItem(
              context,
              icon: Icons.settings_rounded,
              label: 'Settings',
              index: 3,
              cs: cs,
            ),
            _buildNavItem(
              context,
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              index: 4,
              cs: cs,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required ColorScheme cs,
  }) {
    final isSelected = currentIndex == index;

    return InkWell(
      // LEARNING: InkWell gives Material ripple feedback on tap.
      // GestureDetector has no visual feedback — always use InkWell
      // for tappable UI elements so users know their tap registered.
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // LEARNING: AnimatedContainer smoothly transitions
            // between selected and unselected states.
            // duration controls how fast the animation plays.
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                // LEARNING: Only show background pill on selected item.
                // withOpacity(0) is fully transparent — cleaner than
                // using null or conditional color.
                color: isSelected
                    ? cs.primary.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                // LEARNING: Use colorScheme for selected/unselected
                // states so it adapts to both dark and light themes.
                color: isSelected
                    ? cs.primary
                    : cs.onSurface.withValues(alpha: 0.4),
                size: 22,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? cs.primary
                    : cs.onSurface.withValues(alpha: 0.4),
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}