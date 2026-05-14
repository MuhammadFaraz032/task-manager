import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/workspace/domain/entities/workspace_entity.dart';
import 'package:task_manager/features/workspace/domain/usecases/create_workspace_usecase.dart';
import 'package:task_manager/features/workspace/domain/usecases/get_user_workspaces_usecase.dart';
import 'package:task_manager/features/workspace/domain/usecases/get_workspace_usecase.dart';
import 'package:task_manager/features/workspace/domain/usecases/set_active_workspace_usecase.dart';
import 'workspace_state.dart';

class WorkspaceCubit extends Cubit<WorkspaceState> {
  final CreateWorkspaceUseCase _createWorkspaceUseCase;
  final GetWorkspaceUseCase _getWorkspaceUseCase;
  final GetUserWorkspacesUseCase _getUserWorkspacesUseCase;
  final SetActiveWorkspaceUseCase _setActiveWorkspaceUseCase;

  WorkspaceCubit({
    required CreateWorkspaceUseCase createWorkspaceUseCase,
    required GetWorkspaceUseCase getWorkspaceUseCase,
    required GetUserWorkspacesUseCase getUserWorkspacesUseCase,
    required SetActiveWorkspaceUseCase setActiveWorkspaceUseCase,
  }) : _createWorkspaceUseCase = createWorkspaceUseCase,
       _getWorkspaceUseCase = getWorkspaceUseCase,
       _getUserWorkspacesUseCase = getUserWorkspacesUseCase,
       _setActiveWorkspaceUseCase = setActiveWorkspaceUseCase,
       super(const WorkspaceInitial());

  // Called after login — load existing workspace
  Future<void> loadWorkspace({
    required String ownerId,
    String? activeWorkspaceId,
  }) async {
    emit(const WorkspaceLoading());
    try {
      // Load all workspaces this user belongs to
      final raw = await _getUserWorkspacesUseCase.execute(userId: ownerId);

      // Fallback for existing users whose workspace predates members[] array
      final List<WorkspaceEntity> allWorkspaces;
      if (raw.isEmpty) {
        final owned = await _getWorkspaceUseCase.execute(ownerId: ownerId);
        if (owned == null) {
          emit(const WorkspaceError('Workspace not found'));
          return;
        }
        allWorkspaces = [owned];
      } else {
        allWorkspaces = raw;
      }

      // Use activeWorkspaceId if provided, otherwise fall back to owned workspace
      WorkspaceEntity active = allWorkspaces.first;
      for (final w in allWorkspaces) {
        if (activeWorkspaceId != null && w.id == activeWorkspaceId) {
          active = w;
          break;
        }
        if (activeWorkspaceId == null && w.ownerId == ownerId) {
          active = w;
          break;
        }
      }

      emit(WorkspaceLoaded(workspace: active, allWorkspaces: allWorkspaces));
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  // Called after register — create new workspace
  Future<void> createWorkspace({
    required String name,
    required String ownerId,
  }) async {
    emit(const WorkspaceLoading());
    try {
      // print('🔵 Creating workspace: $name for $ownerId');
      final workspace = await _createWorkspaceUseCase.execute(
        name: name,
        ownerId: ownerId,
      );
      // print('✅ Workspace created: ${workspace.id}');
      emit(WorkspaceLoaded(workspace: workspace, allWorkspaces: [workspace]));
    } catch (e) {
      // print('❌ Workspace error: $e');
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> switchWorkspace({
    required String userId,
    required String workspaceId,
  }) async {
    final current = state;
    if (current is! WorkspaceLoaded) return;

    final target =
        current.allWorkspaces.where((w) => w.id == workspaceId).firstOrNull ??
        current.allWorkspaces.first;

    // Persist the choice so it survives app restart
    try {
      await _setActiveWorkspaceUseCase.execute(
        userId: userId,
        workspaceId: workspaceId,
      );
    } catch (_) {
      // Firestore write failed — still switch in memory so UI doesn't hang
    }

    emit(
      WorkspaceLoaded(workspace: target, allWorkspaces: current.allWorkspaces),
    );
  }

  String? get currentWorkspaceId {
    final state = this.state;
    if (state is WorkspaceLoaded) return state.workspace.id;
    return null;
  }
}
