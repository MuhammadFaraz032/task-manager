import 'package:task_manager/features/auth/domain/entities/user_entity.dart';
import 'package:task_manager/features/members/domain/repositories/member_repository.dart';

class GetWorkspaceMembersUseCase {
  final MemberRepository repository;

  GetWorkspaceMembersUseCase(this.repository);

  Stream<List<UserEntity>> call({
    required String workspaceId,
    required List<String> memberIds,
  }) {
    return repository.getWorkspaceMembers(
      workspaceId: workspaceId,
      memberIds: memberIds,
    );
  }
}