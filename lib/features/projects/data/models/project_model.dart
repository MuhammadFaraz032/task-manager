import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager/features/projects/domain/entities/project_entity.dart';

class ProjectModel extends ProjectEntity {
  const ProjectModel({
    required super.id,
    required super.name,
    required super.description,
    required super.workspaceId,
    required super.createdBy,
    required super.status,
    required super.priority,
    super.dueDate,
    required super.totalTasks,
    required super.completedTasks,
    required super.createdAt,
    super.updatedAt,
    super.isDeleted,
  });

  factory ProjectModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ProjectModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      workspaceId: data['workspaceId'] ?? '',
      createdBy: data['createdBy'] ?? '',
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ProjectStatus.active,
      ),
      priority: ProjectPriority.values.firstWhere(
        (e) => e.name == data['priority'],
        orElse: () => ProjectPriority.medium,
      ),
      dueDate: data['dueDate'] != null
          ? (data['dueDate'] as Timestamp).toDate()
          : null,
      totalTasks: data['totalTasks'] ?? 0,
      completedTasks: data['completedTasks'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      isDeleted: data['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'workspaceId': workspaceId,
      'createdBy': createdBy,
      'status': status.name,
      'priority': priority.name,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'isDeleted': isDeleted,
    };
  }
}