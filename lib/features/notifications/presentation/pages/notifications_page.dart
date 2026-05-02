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
    return '${diff.inDays}d ago';
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'task_assigned':
        return Icons.assignment_ind_outlined;
      case 'task_completed':
        return Icons.check_circle_outline;
      case 'comment_added':
        return Icons.comment_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NotificationError) {
            return Center(child: Text(state.message));
          }
          if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_off_outlined, size: 48),
                    SizedBox(height: 12),
                    Text('No notifications yet'),
                  ],
                ),
              );
            }
            final authState = context.read<AuthBloc>().state;
            final userId = authState is AuthAuthenticated ? authState.user.uid : '';
            return ListView.separated(
              itemCount: state.notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notif = state.notifications[index];
                return ListTile(
                  leading: Icon(_iconForType(notif.type)),
                  title: Text(
                    notif.message,
                    style: TextStyle(
                      fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(_timeAgo(notif.createdAt)),
                  tileColor: notif.isRead ? null : Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                  onTap: () async {
                    if (!notif.isRead) {
                      context.read<NotificationBloc>().add(
                            NotificationMarkReadRequested(userId, notif.id),
                          );
                    }

                    // Switch workspace if notification belongs to a different one
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

                    if (context.mounted) context.push('/task/${notif.taskId}');
                  },
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}