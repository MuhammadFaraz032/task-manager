import 'package:equatable/equatable.dart';
import 'package:task_manager/features/members/domain/entities/member_entity.dart';

abstract class InviteState extends Equatable {
  const InviteState();

  @override
  List<Object?> get props => [];
}

class InviteInitial extends InviteState {}

class InviteLoading extends InviteState {}

class PendingInvitesLoaded extends InviteState {
  final List<InviteEntity> invites;

  const PendingInvitesLoaded(this.invites);

  @override
  List<Object?> get props => [invites];
}

class InviteSent extends InviteState {}

class InviteAccepted extends InviteState {}

class InviteDeclined extends InviteState {}

class InviteError extends InviteState {
  final String message;

  const InviteError(this.message);

  @override
  List<Object?> get props => [message];
}