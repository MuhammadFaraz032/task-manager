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