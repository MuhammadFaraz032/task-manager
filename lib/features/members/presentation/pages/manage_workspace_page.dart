import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_state.dart';
import 'package:task_manager/features/members/presentation/bloc/member_bloc.dart';
import 'package:task_manager/features/members/presentation/bloc/member_event.dart';
import 'package:task_manager/features/members/presentation/bloc/member_state.dart';
import 'package:task_manager/features/workspace/presentation/cubit/workspace_cubit.dart';
import 'package:task_manager/features/workspace/presentation/cubit/workspace_state.dart';

class ManageWorkspacePage extends StatefulWidget {
  const ManageWorkspacePage({super.key});

  @override
  State<ManageWorkspacePage> createState() => _ManageWorkspacePageState();
}

class _ManageWorkspacePageState extends State<ManageWorkspacePage> {
  @override
  void initState() {
    super.initState();
    _loadMembers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GoRouter.of(context).routerDelegate.addListener(_onRouteChange);
    });
  }

  void _onRouteChange() {
    if (mounted) _loadMembers();
  }

  @override
  void dispose() {
    GoRouter.of(context).routerDelegate.removeListener(_onRouteChange);
    super.dispose();
  }

  void _loadMembers() {
    final workspaceState = context.read<WorkspaceCubit>().state;
    final authState = context.read<AuthBloc>().state;
    if (workspaceState is WorkspaceLoaded) {
      context.read<MemberBloc>().add(
            MembersLoadRequested(
              workspaceId: workspaceState.workspace.id,
              memberIds: workspaceState.workspace.members,
            ),
          );
    }
    if (authState is AuthAuthenticated) {
      context.read<MemberBloc>().add(
            PendingInvitesLoadRequested(userEmail: authState.user.email),
          );
    }
  }

  void _showInviteSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<MemberBloc>(),
        child: const _InviteMemberSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Workspace'),
        actions: [
          BlocBuilder<MemberBloc, MemberState>(
            builder: (context, state) {
              final count = state is PendingInvitesLoaded
                  ? state.invites.length
                  : 0;
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showInviteSheet,
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Add Member'),
      ),
      body: BlocConsumer<MemberBloc, MemberState>(
         listener: (context, state) {
          if (state is InviteSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invite sent successfully')),
            );
            _loadMembers();
          }
          if (state is InviteAccepted || state is InviteDeclined) {
            _loadMembers();
          }
          // if (state is MemberError) {
          //   ScaffoldMessenger.of(
          //     context,
          //   ).showSnackBar(SnackBar(content: Text(state.message)));
          // }
        },
        builder: (context, state) {
          if (state is MemberLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MembersLoaded) {
            if (state.members.isEmpty) {
              return const Center(
                child: Text('No members yet. Invite someone!'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.members.length,
              itemBuilder: (context, index) {
                final member = state.members[index];
                final authState = context.read<AuthBloc>().state;
                final isMe =
                    authState is AuthAuthenticated &&
                    authState.user.uid == member.uid;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: Text(
                      member.fullName.isNotEmpty
                          ? member.fullName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text('${member.fullName}${isMe ? ' (You)' : ''}'),
                  subtitle: Text(member.email),
                  trailing: member.jobTitle != null
                      ? Text(
                          member.jobTitle!,
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      : null,
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

class _InviteMemberSheet extends StatefulWidget {
  const _InviteMemberSheet();

  @override
  State<_InviteMemberSheet> createState() => _InviteMemberSheetState();
}

class _InviteMemberSheetState extends State<_InviteMemberSheet> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendInvite() {
    if (!_formKey.currentState!.validate()) return;

    final workspaceState = context.read<WorkspaceCubit>().state;
    final authState = context.read<AuthBloc>().state;

    if (workspaceState is! WorkspaceLoaded) return;
    if (authState is! AuthAuthenticated) return;

    context.read<MemberBloc>().add(
      InviteUserRequested(
        workspaceId: workspaceState.workspace.id,
        email: _emailController.text.trim(),
        invitedBy: authState.user.uid,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invite Member',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the email address of the person you want to invite.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'example@email.com',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sendInvite,
                child: const Text('Send Invite'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
