import 'package:task_manager/features/members/domain/repositories/member_repository.dart';

class AcceptInviteUseCase {
  final MemberRepository repository;

  AcceptInviteUseCase(this.repository);

  Future<void> call({
    required String workspaceId,
    required String inviteId,
    required String userId,
  }) {
    return repository.acceptInvite(
      workspaceId: workspaceId,
      inviteId: inviteId,
      userId: userId,
    );
  }
}