import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_state.dart';
import 'package:task_manager/features/workspace/presentation/cubit/workspace_cubit.dart';
import 'package:task_manager/features/workspace/presentation/cubit/workspace_state.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<NotificationBloc>().add(
            NotificationsLoadRequested(authState.user.uid),
          );
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return '${(diff.inDays / 30).floor()}mo ago';
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'task_assigned':
        return Icons.person_add_alt_1;
      case 'task_completed':
        return Icons.task_alt;
      case 'comment_added':
        return Icons.chat_bubble_outline;
      default:
        return Icons.notifications_none;
    }
  }

  Color _iconColor(String type, ColorScheme cs) {
    switch (type) {
      case 'task_assigned':
        return cs.primary;
      case 'task_completed':
        return cs.primary;
      case 'comment_added':
        return cs.secondary;
      default:
        return cs.primary;
    }
  }

  String _getTypeDisplayName(String type) {
    switch (type) {
      case 'task_assigned':
        return 'ASSIGNED';
      case 'task_completed':
        return 'COMPLETED';
      case 'comment_added':
        return 'COMMENT';
      default:
        return type.replaceAll('_', ' ').toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            context.go('/dashboard');
          },
          child: Scaffold(
            backgroundColor: cs.background,
            appBar: AppBar(
              backgroundColor: cs.background,
              elevation: 0,
              title: Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              actions: [
                if (state is NotificationsLoaded &&
                    state.notifications.any((n) => !n.isRead))
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: TextButton.icon(
                      onPressed: () {
                        final authState = context.read<AuthBloc>().state;
                        if (authState is AuthAuthenticated) {
                          for (final notif in state.notifications
                              .where((n) => !n.isRead)) {
                            context.read<NotificationBloc>().add(
                                  NotificationMarkReadRequested(
                                      authState.user.uid, notif.id),
                                );
                          }
                        }
                      },
                      icon: Icon(Icons.done_all,
                          size: 18, color: cs.primary),
                      label: Text(
                        'Mark all read',
                        style: TextStyle(color: cs.primary),
                      ),
                    ),
                  ),
              ],
            ),
            body: Builder(
              builder: (context) {
                if (state is NotificationLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: cs.primary),
                        const SizedBox(height: 16),
                        Text(
                          'Loading notifications...',
                          style: TextStyle(
                              color: cs.onSurface.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  );
                }

                if (state is NotificationError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 64,
                            color: cs.error.withValues(alpha: 0.6)),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: TextStyle(color: cs.error),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            final authState =
                                context.read<AuthBloc>().state;
                            if (authState is AuthAuthenticated) {
                              context.read<NotificationBloc>().add(
                                    NotificationsLoadRequested(
                                        authState.user.uid),
                                  );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.primary,
                            foregroundColor: cs.onPrimary,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is NotificationsLoaded) {
                  if (state.notifications.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.notifications_off_outlined,
                              size: 64,
                              color: cs.onSurface.withValues(alpha: 0.3),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No notifications yet',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "When you receive notifications, they'll appear here",
                            style: TextStyle(
                              color: cs.onSurface.withValues(alpha: 0.5),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  final authState = context.read<AuthBloc>().state;
                  final userId = authState is AuthAuthenticated
                      ? authState.user.uid
                      : '';

                  // Group notifications by date
                  final now = DateTime.now();
                  final today = state.notifications
                      .where((n) =>
                          n.createdAt.day == now.day &&
                          n.createdAt.month == now.month &&
                          n.createdAt.year == now.year)
                      .toList();
                  final yesterday = state.notifications
                      .where((n) =>
                          n.createdAt.day ==
                              now.subtract(const Duration(days: 1)).day &&
                          !today.contains(n))
                      .toList();
                  final older = state.notifications
                      .where(
                          (n) => !today.contains(n) && !yesterday.contains(n))
                      .toList();

                  final sections = <String, List<dynamic>>{
                    if (today.isNotEmpty) 'Today': today,
                    if (yesterday.isNotEmpty) 'Yesterday': yesterday,
                    if (older.isNotEmpty) 'Older': older,
                  };

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    children: [
                      for (final entry in sections.entries) ...[
                        _buildSectionHeader(entry.key, cs),
                        for (final notif in entry.value)
                          _buildNotificationCard(
                              notif, userId, context, cs),
                      ]
                    ],
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: cs.onSurface.withValues(alpha: 0.5),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
      dynamic notif, String userId, BuildContext context, ColorScheme cs) {
    final color = _iconColor(notif.type, cs);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notif.isRead
            ? cs.surface
            : color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: notif.isRead
              ? cs.outline
              : color.withValues(alpha: 0.2),
        ),
        boxShadow: notif.isRead
            ? null
            : [
                BoxShadow(
                  color: color.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          if (!notif.isRead) {
            context.read<NotificationBloc>().add(
                  NotificationMarkReadRequested(userId, notif.id),
                );
          }

          if (notif.workspaceId != null) {
            final workspaceState = context.read<WorkspaceCubit>().state;
            final currentId = workspaceState is WorkspaceLoaded
                ? workspaceState.workspace.id
                : null;

            if (currentId != notif.workspaceId) {
              await context.read<WorkspaceCubit>().switchWorkspace(
                    userId: userId,
                    workspaceId: notif.workspaceId!,
                  );
            }
          }

          if (context.mounted) {
            context.push('/task/${notif.taskId}');
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        _iconForType(notif.type),
                        color: color,
                        size: 26,
                      ),
                    ),
                    if (!notif.isRead)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: cs.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _getTypeDisplayName(notif.type),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: color,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Text(
                          _timeAgo(notif.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notif.message,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: notif.isRead
                            ? FontWeight.w400
                            : FontWeight.w600,
                        color: notif.isRead
                            ? cs.onSurface.withValues(alpha: 0.6)
                            : cs.onSurface,
                        height: 1.4,
                      ),
                    ),
                    if (!notif.isRead) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.touch_app_outlined,
                            size: 11,
                            color: cs.primary.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Tap to view details',
                            style: TextStyle(
                              fontSize: 11,
                              color: cs.primary.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}