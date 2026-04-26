import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager/features/tasks/data/models/comment_model.dart';
import 'package:task_manager/features/tasks/domain/entities/comment_entity.dart';

abstract class CommentRemoteDataSource {
  Stream<List<CommentEntity>> getComments({
    required String workspaceId,
    required String taskId,
  });

  Future<void> addComment({
    required String workspaceId,
    required String taskId,
    required String text,
    required String createdBy,
    required String createdByName,
  });

  Future<void> deleteComment({
    required String workspaceId,
    required String taskId,
    required String commentId,
  });
}

class CommentRemoteDataSourceImpl implements CommentRemoteDataSource {
  final FirebaseFirestore firestore;

  CommentRemoteDataSourceImpl({required this.firestore});

  CollectionReference _commentsRef(String workspaceId, String taskId) {
    return firestore
        .collection('workspaces')
        .doc(workspaceId)
        .collection('tasks')
        .doc(taskId)
        .collection('comments');
  }

  @override
  Stream<List<CommentEntity>> getComments({
    required String workspaceId,
    required String taskId,
  }) {
    return _commentsRef(workspaceId, taskId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommentModel.fromFirestore(doc))
            .toList());
  }

  @override
  Future<void> addComment({
    required String workspaceId,
    required String taskId,
    required String text,
    required String createdBy,
    required String createdByName,
  }) async {
    await _commentsRef(workspaceId, taskId).add({
      'text': text,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': Timestamp.now(),
    });
  }

  @override
  Future<void> deleteComment({
    required String workspaceId,
    required String taskId,
    required String commentId,
  }) async {
    await _commentsRef(workspaceId, taskId).doc(commentId).delete();
  }
}