import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/core/theme/themecolors.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_state.dart';
import 'package:task_manager/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:task_manager/features/notifications/presentation/bloc/notification_state.dart';

class DashboardAppBar extends StatelessWidget {
  const DashboardAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: cs.background,
        border: Border(bottom: BorderSide(color: cs.outline)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: const LinearGradient(
                    colors: AppColors.brandGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(2),
                child: ClipOval(
                  child: Container(
                    color: cs.surface,
                    child: Icon(
                      Icons.person,
                      color: cs.onSurface.withValues(alpha: 0.6),
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  String displayName = 'User';
                  if (state is AuthAuthenticated) {
                    displayName = state.user.fullName.split(' ').first;
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          Row(
            children: [
              _ActionButton(icon: Icons.search_rounded, onTap: () {}, cs: cs),
              const SizedBox(width: 8),
              _NotificationButton(cs: cs),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme cs;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: cs.surface,
          border: Border.all(color: cs.outline),
        ),
        child: Icon(icon, size: 20, color: cs.onSurface.withValues(alpha: 0.6)),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final ColorScheme cs;

  const _NotificationButton({required this.cs});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        int unreadCount = 0;
        if (state is NotificationsLoaded) {
          unreadCount = state.notifications.where((n) => !n.isRead).length;
        }

        return Stack(
          children: [
            InkWell(
              onTap: () => context.push('/notifications'),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.surface,
                  border: Border.all(color: cs.outline),
                ),
                child: Icon(
                  Icons.notifications_rounded,
                  size: 20,
                  color: cs.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: cs.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.surface, width: 1.5),
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}