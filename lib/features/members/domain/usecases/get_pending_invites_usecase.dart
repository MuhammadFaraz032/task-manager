import 'package:task_manager/features/members/domain/entities/member_entity.dart';
import 'package:task_manager/features/members/domain/repositories/member_repository.dart';

class GetPendingInvitesUseCase {
  final MemberRepository repository;

  GetPendingInvitesUseCase(this.repository);

  Stream<List<InviteEntity>> call({required String userEmail}) {
    return repository.getPendingInvites(userEmail: userEmail);
  }
}