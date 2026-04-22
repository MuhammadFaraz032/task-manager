import 'package:task_manager/features/members/domain/entities/member_entity.dart';
import 'package:task_manager/features/auth/domain/entities/user_entity.dart';

abstract class MemberRepository {
  Future<void> inviteUser({
    required String workspaceId,
    required String email,
    required String invitedBy,
  });

  Future<void> acceptInvite({
    required String workspaceId,
    required String inviteId,
    required String userId,
  });

  Future<void> declineInvite({
    required String workspaceId,
    required String inviteId,
  });

  Stream<List<UserEntity>> getWorkspaceMembers({
    required String workspaceId,
    required List<String> memberIds,
  });

  Stream<List<InviteEntity>> getPendingInvites({
    required String userEmail,
  });
}