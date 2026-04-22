import 'package:task_manager/features/members/domain/repositories/member_repository.dart';

class DeclineInviteUseCase {
  final MemberRepository repository;

  DeclineInviteUseCase(this.repository);

  Future<void> call({
    required String workspaceId,
    required String inviteId,
  }) {
    return repository.declineInvite(
      workspaceId: workspaceId,
      inviteId: inviteId,
    );
  }
}