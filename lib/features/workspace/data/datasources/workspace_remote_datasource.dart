import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager/features/workspace/data/models/workspace_model.dart';
import 'package:uuid/uuid.dart';

abstract class WorkspaceRemoteDataSource {
  Future<WorkspaceModel> createWorkspace({
    required String name,
    required String ownerId,
  });

  Future<WorkspaceModel?> getWorkspace({
    required String ownerId,
  });

  Future<void> updateWorkspaceId({
    required String userId,
    required String workspaceId,
  });
}

class WorkspaceRemoteDataSourceImpl implements WorkspaceRemoteDataSource {
  final FirebaseFirestore _firestore;

  WorkspaceRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<WorkspaceModel> createWorkspace({
    required String name,
    required String ownerId,
  }) async {
    // LEARNING: We generate our own ID using uuid
    // so we know the workspaceId before writing to Firestore
    // This lets us update the user document in the same operation
    final workspaceId = const Uuid().v4();

    final workspace = WorkspaceModel(
      id: workspaceId,
      name: name,
      ownerId: ownerId,
      members: [ownerId],
      createdAt: DateTime.now(),
    );

    // Write workspace document
    await _firestore
        .collection('workspaces')
        .doc(workspaceId)
        .set(workspace.toMap());

    // Update user document with workspaceId
    await updateWorkspaceId(
      userId: ownerId,
      workspaceId: workspaceId,
    );

    return workspace;
  }

  @override
  Future<WorkspaceModel?> getWorkspace({
    required String ownerId,
  }) async {
    final query = await _firestore
        .collection('workspaces')
        .where('ownerId', isEqualTo: ownerId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    return WorkspaceModel.fromFirestore(query.docs.first);
  }

  @override
  Future<void> updateWorkspaceId({
    required String userId,
    required String workspaceId,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .update({'workspaceId': workspaceId});
  }
}