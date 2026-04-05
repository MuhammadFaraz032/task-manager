import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager/features/projects/data/models/project_model.dart';
import 'package:task_manager/features/projects/domain/entities/project_entity.dart';
import 'package:uuid/uuid.dart';

abstract class ProjectRemoteDataSource {
  Stream<List<ProjectModel>> getProjects({required String workspaceId});

  Future<ProjectModel> createProject({
    required String name,
    required String description,
    required String workspaceId,
    required String createdBy,
    required ProjectPriority priority,
    DateTime? dueDate,
  });

  Future<ProjectModel> updateProject({
    required String projectId,
    required String workspaceId,
    required String name,
    required String description,
    required ProjectStatus status,
    required ProjectPriority priority,
    DateTime? dueDate,
  });

  Future<void> deleteProject({
    required String projectId,
    required String workspaceId,
    required String deletedBy,
  });
}

class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final FirebaseFirestore _firestore;

  ProjectRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  // LEARNING: Firestore path for projects
  // workspaces/{workspaceId}/projects/{projectId}
  CollectionReference<Map<String, dynamic>> _projectsCollection(
      String workspaceId) {
    return _firestore
        .collection('workspaces')
        .doc(workspaceId)
        .collection('projects');
  }

  @override
  Stream<List<ProjectModel>> getProjects({
    required String workspaceId,
  }) {
    // LEARNING: snapshots() returns a real time stream
    // every time Firestore data changes this stream
    // emits a new list automatically
    return _projectsCollection(workspaceId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProjectModel.fromFirestore(doc))
            .toList());
  }

  @override
  Future<ProjectModel> createProject({
    required String name,
    required String description,
    required String workspaceId,
    required String createdBy,
    required ProjectPriority priority,
    DateTime? dueDate,
  }) async {
    final projectId = const Uuid().v4();

    final project = ProjectModel(
      id: projectId,
      name: name,
      description: description,
      workspaceId: workspaceId,
      createdBy: createdBy,
      status: ProjectStatus.active,
      priority: priority,
      dueDate: dueDate,
      totalTasks: 0,
      completedTasks: 0,
      createdAt: DateTime.now(),
      isDeleted: false,
    );

    await _projectsCollection(workspaceId)
        .doc(projectId)
        .set(project.toMap());

    return project;
  }

  @override
Future<ProjectModel> updateProject({
  required String projectId,
  required String workspaceId,
  required String name,
  required String description,
  required ProjectStatus status,
  required ProjectPriority priority,
  DateTime? dueDate,
}) async {
  final ref = _projectsCollection(workspaceId).doc(projectId);
  await ref.update({
    'name': name,
    'description': description,
    'status': status.name,
    'priority': priority.name,
    'dueDate': dueDate != null ? Timestamp.fromDate(dueDate) : null,
    'updatedAt': FieldValue.serverTimestamp(),
  });
  final updated = await ref.get();
  return ProjectModel.fromFirestore(updated);
}

  @override
Future<void> deleteProject({
  required String projectId,
  required String workspaceId,
  required String deletedBy,
}) async {
  await _projectsCollection(workspaceId).doc(projectId).update({
    'isDeleted': true,
    'deletedBy': deletedBy,
    'deletedAt': FieldValue.serverTimestamp(),
  });
}
}