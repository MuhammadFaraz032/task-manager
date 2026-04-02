import 'package:equatable/equatable.dart';

enum ProjectStatus { active, completed, onHold }
enum ProjectPriority { low, medium, high }

class ProjectEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String workspaceId;
  final String createdBy;
  final ProjectStatus status;
  final ProjectPriority priority;
  final DateTime? dueDate;
  final int totalTasks;
  final int completedTasks;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;

  const ProjectEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.workspaceId,
    required this.createdBy,
    required this.status,
    required this.priority,
    this.dueDate,
    required this.totalTasks,
    required this.completedTasks,
    required this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
  });

  // LEARNING: progress is a computed property
  // it's derived from totalTasks and completedTasks
  // no need to store it in Firestore
  double get progress =>
      totalTasks == 0 ? 0 : completedTasks / totalTasks;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        workspaceId,
        createdBy,
        status,
        priority,
        dueDate,
        totalTasks,
        completedTasks,
        createdAt,
        updatedAt,
        isDeleted,
      ];
}