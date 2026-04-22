import 'package:task_manager/features/auth/domain/entities/user_entity.dart';
import 'package:task_manager/features/members/data/datasources/member_remote_datasource.dart';
import 'package:task_manager/features/members/domain/entities/member_entity.dart';
import 'package:task_manager/features/members/domain/repositories/member_repository.dart';

class MemberRepositoryImpl implements MemberRepository {
  final MemberRemoteDataSource dataSource;

  MemberRepositoryImpl({required this.dataSource});

  @override
  Future<void> inviteUser({
    required String workspaceId,
    required String email,
    required String invitedBy,
  }) {
    return dataSource.inviteUser(
      workspaceId: workspaceId,
      email: email,
      invitedBy: invitedBy,
    );
  }

  @override
  Future<void> acceptInvite({
    required String workspaceId,
    required String inviteId,
    required String userId,
  }) {
    return dataSource.acceptInvite(
      workspaceId: workspaceId,
      inviteId: inviteId,
      userId: userId,
    );
  }

  @override
  Future<void> declineInvite({
    required String workspaceId,
    required String inviteId,
  }) {
    return dataSource.declineInvite(
      workspaceId: workspaceId,
      inviteId: inviteId,
    );
  }

  @override
  Stream<List<UserEntity>> getWorkspaceMembers({
    required String workspaceId,
    required List<String> memberIds,
  }) {
    return dataSource.getWorkspaceMembers(
      workspaceId: workspaceId,
      memberIds: memberIds,
    );
  }

  @override
  Stream<List<InviteEntity>> getPendingInvites({
    required String userEmail,
  }) {
    return dataSource.getPendingInvites(userEmail: userEmail);
  }
}