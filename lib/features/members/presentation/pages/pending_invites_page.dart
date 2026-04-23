import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_state.dart';
import 'package:task_manager/features/members/domain/entities/member_entity.dart';
import 'package:task_manager/features/members/presentation/bloc/invite_bloc.dart';
import 'package:task_manager/features/members/presentation/bloc/invite_event.dart';
import 'package:task_manager/features/members/presentation/bloc/invite_state.dart';

class PendingInvitesPage extends StatefulWidget {
  const PendingInvitesPage({super.key});

  @override
  State<PendingInvitesPage> createState() => _PendingInvitesPageState();
}

class _PendingInvitesPageState extends State<PendingInvitesPage> {
  @override
  void initState() {
    super.initState();
    _loadInvites();
  }

  void _loadInvites() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<InviteBloc>().add(
            PendingInvitesLoadRequested(userEmail: authState.user.email),
          );
    }
  }

  void _accept(InviteEntity invite) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    context.read<InviteBloc>().add(
          AcceptInviteRequested(
            workspaceId: invite.invitedBy,
            inviteId: invite.id,
            userId: authState.user.uid,
          ),
        );
  }

  void _decline(InviteEntity invite) {
    context.read<InviteBloc>().add(
          DeclineInviteRequested(
            workspaceId: invite.invitedBy,
            inviteId: invite.id,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Invites'),
      ),
      body: BlocConsumer<InviteBloc, InviteState>(
        listener: (context, state) {
          if (state is InviteAccepted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invite accepted!')),
            );
            _loadInvites();
          }
          if (state is InviteDeclined) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invite declined')),
            );
            _loadInvites();
          }
          if (state is InviteError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is InviteLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is InviteError) {
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
                    'Could not load invites',
                    style: TextStyle(
                      fontSize: 16,
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _loadInvites,
                    child: const Text('Try again'),
                  ),
                ],
              ),
            );
          }

          if (state is PendingInvitesLoaded) {
            if (state.invites.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.mark_email_read_outlined,
                      size: 64,
                      color: cs.onSurface.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No pending invites',
                      style: TextStyle(
                        fontSize: 16,
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  //   TextButton(
                  //   onPressed: _loadInvites,
                  //   child: const Text('Try again'),
                  // ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.invites.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final invite = state.invites[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cs.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.workspaces_outlined,
                              color: cs.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Workspace Invite',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: cs.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'You have been invited to join a workspace',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: cs.onSurface.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _decline(invite),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: cs.error,
                                side: BorderSide(
                                  color: cs.error.withValues(alpha: 0.5),
                                ),
                              ),
                              child: const Text('Decline'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _accept(invite),
                              child: const Text('Accept'),
                            ),
                          ),
                        ],
                      ),
                    ],
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