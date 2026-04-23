import 'package:equatable/equatable.dart';

abstract class InviteEvent extends Equatable {
  const InviteEvent();

  @override
  List<Object?> get props => [];
}

class PendingInvitesLoadRequested extends InviteEvent {
  final String userEmail;

  const PendingInvitesLoadRequested({required this.userEmail});

  @override
  List<Object?> get props => [userEmail];
}

class InviteUserRequested extends InviteEvent {
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

class AcceptInviteRequested extends InviteEvent {
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

class DeclineInviteRequested extends InviteEvent {
  final String workspaceId;
  final String inviteId;

  const DeclineInviteRequested({
    required this.workspaceId,
    required this.inviteId,
  });

  @override
  List<Object?> get props => [workspaceId, inviteId];
}