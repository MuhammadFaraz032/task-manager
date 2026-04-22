import 'package:equatable/equatable.dart';
import 'package:task_manager/features/auth/domain/entities/user_entity.dart';
import 'package:task_manager/features/members/domain/entities/member_entity.dart';

abstract class MemberState extends Equatable {
  const MemberState();

  @override
  List<Object?> get props => [];
}

class MemberInitial extends MemberState {}

class MemberLoading extends MemberState {}

class MembersLoaded extends MemberState {
  final List<UserEntity> members;

  const MembersLoaded(this.members);

  @override
  List<Object?> get props => [members];
}

class PendingInvitesLoaded extends MemberState {
  final List<InviteEntity> invites;

  const PendingInvitesLoaded(this.invites);

  @override
  List<Object?> get props => [invites];
}

class InviteSent extends MemberState {}

class InviteAccepted extends MemberState {}

class InviteDeclined extends MemberState {}

class MemberError extends MemberState {
  final String message;

  const MemberError(this.message);

  @override
  List<Object?> get props => [message];
}