import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/workspace/domain/usecases/create_workspace_usecase.dart';
import 'package:task_manager/features/workspace/domain/usecases/get_workspace_usecase.dart';
import 'workspace_state.dart';

class WorkspaceCubit extends Cubit<WorkspaceState> {
  final CreateWorkspaceUseCase _createWorkspaceUseCase;
  final GetWorkspaceUseCase _getWorkspaceUseCase;

  WorkspaceCubit({
    required CreateWorkspaceUseCase createWorkspaceUseCase,
    required GetWorkspaceUseCase getWorkspaceUseCase,
  }) : _createWorkspaceUseCase = createWorkspaceUseCase,
       _getWorkspaceUseCase = getWorkspaceUseCase,
       super(const WorkspaceInitial());

  // Called after login — load existing workspace
  Future<void> loadWorkspace({required String ownerId}) async {
    emit(const WorkspaceLoading());
    try {
      // print('🔵 WorkspaceCubit loading workspace for: $ownerId');
      final workspace = await _getWorkspaceUseCase.execute(ownerId: ownerId);
      if (workspace != null) {
        // print('✅ WorkspaceCubit loaded: ${workspace.id}');
        emit(WorkspaceLoaded(workspace));
      } else {
        emit(const WorkspaceError('Workspace not found'));
      }
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
      emit(WorkspaceLoaded(workspace));
    } catch (e) {
      // print('❌ Workspace error: $e');
      emit(WorkspaceError(e.toString()));
    }
  }

  String? get currentWorkspaceId {
    final state = this.state;
    if (state is WorkspaceLoaded) return state.workspace.id;
    return null;
  }
}
