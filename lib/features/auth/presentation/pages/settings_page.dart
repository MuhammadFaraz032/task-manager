import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/core/theme/theme_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40, top: 20),
        child: Column(
          children: [
            /// Profile Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
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
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white24,
                      child: CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person_rounded,
                          size: 36,
                          color: cs.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      // TODO: Replace with AuthBloc user name
                      "Alex Johnson",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      // TODO: Replace with AuthBloc user email
                      "alex.johnson@email.com",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// Preferences
            _SectionTitle(title: "PREFERENCES", cs: cs),
            _SectionContainer(
              cs: cs,
              children: [
                _ToggleTile(
                  cs: cs,
                  icon: Icons.dark_mode_rounded,
                  title: "Dark Mode",
                  value: isDark,
                  onChanged: (_) =>
                      context.read<ThemeCubit>().toggleTheme(),
                ),
                Divider(color: cs.outline, height: 1),
                _NavTile(
                  cs: cs,
                  icon: Icons.notifications_rounded,
                  title: "Notifications",
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// Workspace
            _SectionTitle(title: "WORKSPACE", cs: cs),
            _SectionContainer(
              cs: cs,
              children: [
                _NavTile(
                  cs: cs,
                  icon: Icons.work_rounded,
                  title: "Manage Workspace",
                  subtitle: "Active",
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// Information
            _SectionTitle(title: "INFORMATION", cs: cs),
            _SectionContainer(
              cs: cs,
              children: [
                _NavTile(
                  cs: cs,
                  icon: Icons.info_outline_rounded,
                  title: "About App",
                  subtitle: "Version 1.0.0",
                ),
                Divider(color: cs.outline, height: 1),
                _NavTile(
                  cs: cs,
                  icon: Icons.privacy_tip_outlined,
                  title: "Privacy Policy",
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// Logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: InkWell(
                onTap: () {
                  // TODO: AuthBloc logout event in Step 5
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: cs.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: cs.error.withOpacity(0.3),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: cs.error,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              "App version 1.0.0 • Built with Flutter",
              style: TextStyle(
                fontSize: 11,
                color: cs.onSurface.withOpacity(0.4),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final ColorScheme cs;

  const _SectionTitle({required this.title, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 0, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: cs.onSurface.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}

class _SectionContainer extends StatelessWidget {
  final List<Widget> children;
  final ColorScheme cs;

  const _SectionContainer({
    required this.children,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outline),
        ),
        child: Column(children: children),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final ColorScheme cs;
  final IconData icon;
  final String title;
  final String? subtitle;

  const _NavTile({
    required this.cs,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: cs.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  color: cs.onSurface,
                ),
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurface.withOpacity(0.4),
                ),
              ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: cs.onSurface.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final ColorScheme cs;
  final IconData icon;
  final String title;
  final bool value;
  final Function(bool) onChanged;

  const _ToggleTile({
    required this.cs,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 15, color: cs.onSurface),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: cs.primary,
          ),
        ],
      ),
    );
  }
}