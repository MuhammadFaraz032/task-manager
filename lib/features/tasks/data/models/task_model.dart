import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager/features/tasks/domain/entities/task_entity.dart';
import 'package:uuid/uuid.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    required super.description,
    required super.workspaceId,
    super.projectId,
    required super.createdBy,
    required super.priority,
    required super.status,
    super.dueDate,
    required super.checklist,
    required super.createdAt,
    super.updatedAt,
    super.completedAt,
    super.completedBy,
    super.isDeleted,
  });

  factory TaskModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return TaskModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      workspaceId: data['workspaceId'] ?? '',
      projectId: data['projectId'],
      createdBy: data['createdBy'] ?? '',
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == data['priority'],
        orElse: () => TaskPriority.none,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => TaskStatus.todo,
      ),
      dueDate: data['dueDate'] != null
          ? (data['dueDate'] as Timestamp).toDate()
          : null,
      checklist: (data['checklist'] as List<dynamic>? ?? [])
          .map((item) => ChecklistItem(
                id: item['id'] ?? const Uuid().v4(),
                title: item['title'] ?? '',
                isCompleted: item['isCompleted'] ?? false,
              ))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      completedBy: data['completedBy'],
      isDeleted: data['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'workspaceId': workspaceId,
      'projectId': projectId,
      'createdBy': createdBy,
      'priority': priority.name,
      'status': status.name,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'checklist': checklist
          .map((item) => {
                'id': item.id,
                'title': item.title,
                'isCompleted': item.isCompleted,
              })
          .toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'completedBy': completedBy,
      'isDeleted': isDeleted,
    };
  }
}