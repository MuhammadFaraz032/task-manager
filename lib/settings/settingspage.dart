import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/core/theme/theme_cubit.dart';

// Add these extension methods to make your theme colors easily accessible
extension ThemeColors on BuildContext {
  Color get primaryColor => Theme.of(this).colorScheme.primary;
  Color get secondaryColor => Theme.of(this).colorScheme.secondary;
  Color get surfaceColor => Theme.of(this).colorScheme.surface;
  Color get errorColor => Theme.of(this).colorScheme.error;
  Color get textPrimary => Theme.of(this).colorScheme.onSurface;
  Color get textSecondary => Theme.of(this).colorScheme.onSurface.withOpacity(0.6);
  Color get textDisabled => Theme.of(this).colorScheme.onSurface.withOpacity(0.38);
  Color get borderColor => Theme.of(this).colorScheme.outline;
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40, top: 20),
          child: Column(
            children: [
              /// =======================
              /// PROFILE CARD
              /// =======================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  height: 212,
                  width: MediaQuery.of(context).size.width-40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        context.primaryColor,
                        context.secondaryColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: context.primaryColor.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.white24,
                        child: CircleAvatar(
                          radius: 44,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, size: 40, color: Color(0xFF2563EB)),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Alex Johnson",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "alex.johnson@email.com",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// =======================
              /// PREFERENCES
              /// =======================
              _sectionTitle(context, "PREFERENCES"),

              _sectionContainer(
                context,
                children: [
                  _toggleTile(
                    context,
                    icon: Icons.dark_mode,
                    title: "Dark Mode",
                    value: isDark,
                    onChanged: (_) {
                      context.read<ThemeCubit>().toggleTheme();
                    },
                  ),

                  Divider(color: context.borderColor, height: 1),

                  _navTile(
                    context,
                    icon: Icons.notifications,
                    title: "Notifications",
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// =======================
              /// WORKSPACE
              /// =======================
              _sectionTitle(context, "WORKSPACE"),

              _sectionContainer(
                context,
                children: [
                  _navTile(
                    context,
                    icon: Icons.work,
                    title: "Manage Workspace",
                    subtitle: "Active",
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// =======================
              /// INFORMATION
              /// =======================
              _sectionTitle(context, "INFORMATION"),

              _sectionContainer(
                context,
                children: [
                  _navTile(
                    context,
                    icon: Icons.info_outline,
                    title: "About App",
                    subtitle: "Version 1.0.0",
                  ),
                  Divider(color: context.borderColor, height: 1),
                  _navTile(
                    context,
                    icon: Icons.privacy_tip_outlined,
                    title: "Privacy Policy",
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// =======================
              /// LOGOUT
              /// =======================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: InkWell(
                  onTap: () {
                    // Handle logout
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: context.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Logout",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: context.errorColor,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                "App version 1.0.0 • Built with Flutter",
                style: TextStyle(
                  fontSize: 10,
                  color: context.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// =======================
  /// REUSABLE WIDGETS
  /// =======================

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 0, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            color: context.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _sectionContainer(BuildContext context,
      {required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.borderColor,
            width: 0.5,
          ),
        ),
        child: Column(children: children),
      ),
    );
  }

  Widget _navTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return InkWell(
      onTap: () {
        // Handle navigation
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: context.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 18, color: context.primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: context.textPrimary,
                ),
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: context.textSecondary,
                ),
              ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right,
                size: 18, color: context.textDisabled),
          ],
        ),
      ),
    );
  }

  Widget _toggleTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 18, color: context.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: context.textPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: context.primaryColor,
          ),
        ],
      ),
    );
  }
}