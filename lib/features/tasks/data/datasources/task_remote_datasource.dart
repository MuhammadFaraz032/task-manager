import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager/features/tasks/data/models/task_model.dart';
import 'package:task_manager/features/tasks/domain/entities/task_entity.dart';
import 'package:uuid/uuid.dart';

abstract class TaskRemoteDataSource {
  Stream<List<TaskModel>> getTasks({
    required String workspaceId,
    String? projectId,
  });

  Future<TaskModel> createTask({
    required String title,
    required String description,
    required String workspaceId,
    required String createdBy,
    String? projectId,
    required TaskPriority priority,
    DateTime? dueDate,
    required List<ChecklistItem> checklist,
  });

  Future<TaskModel> updateTask({
    required String taskId,
    required String title,
    required String description,
    required TaskPriority priority,
    required TaskStatus status,
    DateTime? dueDate,
    required List<ChecklistItem> checklist,
  });

  Future<TaskModel> toggleTask({
    required String taskId,
    required String completedBy,
  });

  Future<void> deleteTask({required String taskId, required String deletedBy});
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore _firestore;

  TaskRemoteDataSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> _tasksCollection(
    String workspaceId,
  ) {
    return _firestore
        .collection('workspaces')
        .doc(workspaceId)
        .collection('tasks');
  }

  @override
  Stream<List<TaskModel>> getTasks({
    required String workspaceId,
    String? projectId,
  }) {
    Query<Map<String, dynamic>> query = _tasksCollection(workspaceId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true);

    // LEARNING: If projectId is provided filter by project
    // If null return all tasks in workspace (standalone tasks)
    if (projectId != null) {
      query = query.where('projectId', isEqualTo: projectId);
    }

    return query.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList(),
    );
  }

  @override
  Future<TaskModel> createTask({
    required String title,
    required String description,
    required String workspaceId,
    required String createdBy,
    String? projectId,
    required TaskPriority priority,
    DateTime? dueDate,
    required List<ChecklistItem> checklist,
  }) async {
    final taskId = const Uuid().v4();

    final task = TaskModel(
      id: taskId,
      title: title,
      description: description,
      workspaceId: workspaceId,
      projectId: projectId,
      createdBy: createdBy,
      priority: priority,
      status: TaskStatus.todo,
      dueDate: dueDate,
      checklist: checklist,
      createdAt: DateTime.now(),
      isDeleted: false,
    );

    await _tasksCollection(workspaceId).doc(taskId).set(task.toMap());

    // LEARNING: If task belongs to a project
    // increment the project's totalTasks count
    if (projectId != null) {
      await _firestore
          .collection('workspaces')
          .doc(workspaceId)
          .collection('projects')
          .doc(projectId)
          .update({
            'totalTasks': FieldValue.increment(1),
            'updatedAt': FieldValue.serverTimestamp(),
          });
    }

    return task;
  }

  Future<DocumentReference<Map<String, dynamic>>> _getTaskRef(
    String taskId,
  ) async {
    // LEARNING: collectionGroup with FieldPath.documentId
    // does not work with custom UUID document IDs
    // Instead we use collectionGroup without documentId filter
    // then access the reference directly
    final querySnapshot = await _firestore
        .collectionGroup('tasks')
        .where('isDeleted', isEqualTo: false)
        .get();

    // Find by matching document ID manually
    final doc = querySnapshot.docs.firstWhere(
      (doc) => doc.id == taskId,
      orElse: () => throw Exception('Task not found'),
    );

    return doc.reference;
  }

  @override
  Future<TaskModel> updateTask({
    required String taskId,
    required String title,
    required String description,
    required TaskPriority priority,
    required TaskStatus status,
    DateTime? dueDate,
    required List<ChecklistItem> checklist,
  }) async {
    final ref = await _getTaskRef(taskId);

    await ref.update({
      'title': title,
      'description': description,
      'priority': priority.name,
      'status': status.name,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate) : null,
      'checklist': checklist
          .map(
            (item) => {
              'id': item.id,
              'title': item.title,
              'isCompleted': item.isCompleted,
            },
          )
          .toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final updated = await ref.get();
    return TaskModel.fromFirestore(updated);
  }

  @override
  Future<TaskModel> toggleTask({
    required String taskId,
    required String completedBy,
  }) async {
    final ref = await _getTaskRef(taskId);
    final snapshot = await ref.get();
    final data = snapshot.data()!;

    final currentStatus = TaskStatus.values.firstWhere(
      (e) => e.name == data['status'],
      orElse: () => TaskStatus.todo,
    );

    final isCompleting = currentStatus != TaskStatus.completed;
    final newStatus = isCompleting ? TaskStatus.completed : TaskStatus.todo;

    await ref.update({
      'status': newStatus.name,
      'completedBy': isCompleting ? completedBy : null,
      'completedAt': isCompleting ? FieldValue.serverTimestamp() : null,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Update project completedTasks count
    final workspaceId = data['workspaceId'];
    final projectId = data['projectId'];

    if (projectId != null) {
      await _firestore
          .collection('workspaces')
          .doc(workspaceId)
          .collection('projects')
          .doc(projectId)
          .update({
            'completedTasks': FieldValue.increment(isCompleting ? 1 : -1),
            'updatedAt': FieldValue.serverTimestamp(),
          });
    }

    final updated = await ref.get();
    return TaskModel.fromFirestore(updated);
  }

  @override
  Future<void> deleteTask({
    required String taskId,
    required String deletedBy,
  }) async {
    final ref = await _getTaskRef(taskId);
    final snapshot = await ref.get();
    final data = snapshot.data()!;

    await ref.update({
      'isDeleted': true,
      'deletedBy': deletedBy,
      'deletedAt': FieldValue.serverTimestamp(),
    });

    // Decrement project task count
    final projectId = data['projectId'];
    final workspaceId = data['workspaceId'];

    if (projectId != null) {
      await _firestore
          .collection('workspaces')
          .doc(workspaceId)
          .collection('projects')
          .doc(projectId)
          .update({
            'totalTasks': FieldValue.increment(-1),
            'updatedAt': FieldValue.serverTimestamp(),
          });
    }
  }
}
