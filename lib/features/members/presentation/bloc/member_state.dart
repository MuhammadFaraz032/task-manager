import 'package:equatable/equatable.dart';
import 'package:task_manager/features/auth/domain/entities/user_entity.dart';

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

class MemberError extends MemberState {
  final String message;

  const MemberError(this.message);

  @override
  List<Object?> get props => [message];
}