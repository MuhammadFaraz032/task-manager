import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager/features/auth/domain/entities/user_entity.dart';
import 'package:task_manager/features/members/data/models/member_model.dart';
import 'package:task_manager/features/members/domain/entities/member_entity.dart';

abstract class MemberRemoteDataSource {
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

class MemberRemoteDataSourceImpl implements MemberRemoteDataSource {
  final FirebaseFirestore firestore;

  MemberRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> inviteUser({
    required String workspaceId,
    required String email,
    required String invitedBy,
  }) async {
    await firestore
        .collection('workspaces')
        .doc(workspaceId)
        .collection('invites')
        .add({
      'email': email,
      'invitedBy': invitedBy,
      'status': 'pending',
      'createdAt': Timestamp.now(),
    });
  }

  @override
  Future<void> acceptInvite({
    required String workspaceId,
    required String inviteId,
    required String userId,
  }) async {
    final batch = firestore.batch();

    final inviteRef = firestore
        .collection('workspaces')
        .doc(workspaceId)
        .collection('invites')
        .doc(inviteId);

    final workspaceRef =
        firestore.collection('workspaces').doc(workspaceId);

    batch.update(inviteRef, {'status': 'accepted'});
    batch.update(workspaceRef, {
      'members': FieldValue.arrayUnion([userId]),
    });

    await batch.commit();

    // Add workspace to user's workspaces[] array
    // so it appears in their workspace list
    await firestore.collection('users').doc(userId).update({
      'workspaces': FieldValue.arrayUnion([workspaceId]),
    });
  }

  @override
  Future<void> declineInvite({
    required String workspaceId,
    required String inviteId,
  }) async {
    await firestore
        .collection('workspaces')
        .doc(workspaceId)
        .collection('invites')
        .doc(inviteId)
        .update({'status': 'declined'});
  }

  @override
  Stream<List<UserEntity>> getWorkspaceMembers({
    required String workspaceId,
    required List<String> memberIds,
  }) {
    if (memberIds.isEmpty) {
      return Stream.value([]);
    }

    return firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: memberIds)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data();
              return UserEntity(
                uid: doc.id,
                fullName: data['fullName'] as String,
                email: data['email'] as String,
                photoUrl: data['photoUrl'] as String?,
                jobTitle: data['jobTitle'] as String?,
                workspaceId: data['workspaceId'] as String,
                createdAt: (data['createdAt'] as Timestamp).toDate(),
              );
            })
            .toList());
  }

  @override
  Stream<List<InviteEntity>> getPendingInvites({
    required String userEmail,
  }) {
    return firestore
        .collectionGroup('invites')
        .where('email', isEqualTo: userEmail)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InviteModel.fromFirestore(doc))
            .toList());
  }
}