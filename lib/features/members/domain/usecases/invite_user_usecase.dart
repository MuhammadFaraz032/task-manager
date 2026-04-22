import 'package:task_manager/features/members/domain/repositories/member_repository.dart';

class InviteUserUseCase {
  final MemberRepository repository;

  InviteUserUseCase(this.repository);

  Future<void> call({
    required String workspaceId,
    required String email,
    required String invitedBy,
  }) {
    return repository.inviteUser(
      workspaceId: workspaceId,
      email: email,
      invitedBy: invitedBy,
    );
  }
}