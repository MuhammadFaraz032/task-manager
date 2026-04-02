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

  Future<void> deleteTask({
    required String taskId,
    required String deletedBy,
  });
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore _firestore;

  TaskRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> _tasksCollection(
      String workspaceId) {
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

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => TaskModel.fromFirestore(doc))
        .toList());
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
    final querySnapshot = await _firestore
        .collectionGroup('tasks')
        .where(FieldPath.documentId, isEqualTo: taskId)
        .get();

    if (querySnapshot.docs.isEmpty) throw Exception('Task not found');

    await querySnapshot.docs.first.reference.update({
      'title': title,
      'description': description,
      'priority': priority.name,
      'status': status.name,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate) : null,
      'checklist': checklist
          .map((item) => {
                'id': item.id,
                'title': item.title,
                'isCompleted': item.isCompleted,
              })
          .toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final updated = await querySnapshot.docs.first.reference.get();
    return TaskModel.fromFirestore(updated);
  }

  @override
  Future<TaskModel> toggleTask({
    required String taskId,
    required String completedBy,
  }) async {
    final querySnapshot = await _firestore
        .collectionGroup('tasks')
        .where(FieldPath.documentId, isEqualTo: taskId)
        .get();

    if (querySnapshot.docs.isEmpty) throw Exception('Task not found');

    final doc = querySnapshot.docs.first;
    final data = doc.data();
    final currentStatus = TaskStatus.values.firstWhere(
      (e) => e.name == data['status'],
      orElse: () => TaskStatus.todo,
    );

    final isCompleting = currentStatus != TaskStatus.completed;
    final newStatus =
        isCompleting ? TaskStatus.completed : TaskStatus.todo;

    await doc.reference.update({
      'status': newStatus.name,
      'completedBy': isCompleting ? completedBy : null,
      'completedAt': isCompleting
          ? FieldValue.serverTimestamp()
          : null,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // LEARNING: Update project completedTasks count
    final workspaceId = data['workspaceId'];
    final projectId = data['projectId'];

    if (projectId != null) {
      await _firestore
          .collection('workspaces')
          .doc(workspaceId)
          .collection('projects')
          .doc(projectId)
          .update({
        'completedTasks':
            FieldValue.increment(isCompleting ? 1 : -1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    final updated = await doc.reference.get();
    return TaskModel.fromFirestore(updated);
  }

  @override
  Future<void> deleteTask({
    required String taskId,
    required String deletedBy,
  }) async {
    final querySnapshot = await _firestore
        .collectionGroup('tasks')
        .where(FieldPath.documentId, isEqualTo: taskId)
        .get();

    if (querySnapshot.docs.isEmpty) return;

    final doc = querySnapshot.docs.first;
    final data = doc.data();
    final projectId = data['projectId'];
    final workspaceId = data['workspaceId'];

    await doc.reference.update({
      'isDeleted': true,
      'deletedBy': deletedBy,
      'deletedAt': FieldValue.serverTimestamp(),
    });

    // Decrement project task count if task belongs to project
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