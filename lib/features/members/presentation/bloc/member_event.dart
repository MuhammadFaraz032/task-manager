import 'package:equatable/equatable.dart';

abstract class MemberEvent extends Equatable {
  const MemberEvent();

  @override
  List<Object?> get props => [];
}

class MembersLoadRequested extends MemberEvent {
  final String workspaceId;
  final List<String> memberIds;

  const MembersLoadRequested({
    required this.workspaceId,
    required this.memberIds,
  });

  @override
  List<Object?> get props => [workspaceId, memberIds];
}

class InviteUserRequested extends MemberEvent {
  final String workspaceId;
  final String email;
  final String invitedBy;

  const InviteUserRequested({
    required this.workspaceId,
    required this.email,
    required this.invitedBy,
  });

  @override
  List<Object?> get props => [workspaceId, email, invitedBy];
}

class AcceptInviteRequested extends MemberEvent {
  final String workspaceId;
  final String inviteId;
  final String userId;

  const AcceptInviteRequested({
    required this.workspaceId,
    required this.inviteId,
    required this.userId,
  });

  @override
  List<Object?> get props => [workspaceId, inviteId, userId];
}

class DeclineInviteRequested extends MemberEvent {
  final String workspaceId;
  final String inviteId;

  const DeclineInviteRequested({
    required this.workspaceId,
    required this.inviteId,
  });

  @override
  List<Object?> get props => [workspaceId, inviteId];
}

class PendingInvitesLoadRequested extends MemberEvent {
  final String userEmail;

  const PendingInvitesLoadRequested({required this.userEmail});

  @override
  List<Object?> get props => [userEmail];
}