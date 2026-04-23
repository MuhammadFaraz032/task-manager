import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/members/domain/usecases/get_workspace_members_usecase.dart';
import 'package:task_manager/features/members/presentation/bloc/member_event.dart';
import 'package:task_manager/features/members/presentation/bloc/member_state.dart';

class MemberBloc extends Bloc<MemberEvent, MemberState> {
  final GetWorkspaceMembersUseCase getWorkspaceMembersUseCase;

  MemberBloc({required this.getWorkspaceMembersUseCase}) : super(MemberInitial()) {
    on<MembersLoadRequested>(_onMembersLoadRequested);
  }

  Future<void> _onMembersLoadRequested(
    MembersLoadRequested event,
    Emitter<MemberState> emit,
  ) async {
    emit(MemberLoading());
    await emit.forEach(
      getWorkspaceMembersUseCase(
        workspaceId: event.workspaceId,
        memberIds: event.memberIds,
      ),
      onData: (members) => MembersLoaded(members),
      onError: (_, __) => const MemberError('Failed to load members'),
    );
  }
}