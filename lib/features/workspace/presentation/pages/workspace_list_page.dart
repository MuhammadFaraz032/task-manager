import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/features/members/presentation/bloc/invite_bloc.dart';
import 'package:task_manager/features/members/presentation/bloc/invite_state.dart';
// import 'package:task_manager/features/auth/presentation/bloc/auth_bloc.dart';
// import 'package:task_manager/features/auth/presentation/bloc/auth_state.dart';
import 'package:task_manager/features/workspace/domain/entities/workspace_entity.dart';
import 'package:task_manager/features/workspace/presentation/cubit/workspace_cubit.dart';
import 'package:task_manager/features/workspace/presentation/cubit/workspace_state.dart';

class WorkspaceListPage extends StatelessWidget {
  const WorkspaceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Workspaces'),
        actions: [
          BlocBuilder<InviteBloc, InviteState>(
            builder: (context, state) {
              final count =
                  state is PendingInvitesLoaded ? state.invites.length : 0;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.mail_outline_rounded),
                    onPressed: () => context.push('/invites'),
                  ),
                  if (count > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<WorkspaceCubit, WorkspaceState>(
        builder: (context, state) {
          if (state is WorkspaceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WorkspaceError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    size: 64,
                    color: cs.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Could not load workspaces',
                    style: TextStyle(
                      fontSize: 16,
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is WorkspaceLoaded) {
            final workspaces = state.allWorkspaces;
            final activeId = state.workspace.id;

            if (workspaces.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.workspaces_outlined,
                      size: 64,
                      color: cs.onSurface.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No workspaces found',
                      style: TextStyle(
                        fontSize: 16,
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: workspaces.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final workspace = workspaces[index];
                final isActive = workspace.id == activeId;
                return _WorkspaceCard(
                  workspace: workspace,
                  isActive: isActive,
                  onTap: () => context.push(
                    '/workspace/${workspace.id}',
                    extra: workspace,
                  ),
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

class _WorkspaceCard extends StatelessWidget {
  final WorkspaceEntity workspace;
  final bool isActive;
  final VoidCallback onTap;

  const _WorkspaceCard({
    required this.workspace,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? cs.primary : cs.outline,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isActive
                    ? cs.primary.withValues(alpha: 0.1)
                    : cs.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.workspaces_rounded,
                color: isActive ? cs.primary : cs.onSurface.withValues(alpha: 0.4),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workspace.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${workspace.members.length} member${workspace.members.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            if (isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Active',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                  ),
                ),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                color: cs.onSurface.withValues(alpha: 0.3),
              ),
          ],
        ),
      ),
    );
  }
}