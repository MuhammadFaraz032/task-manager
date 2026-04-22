import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/members/domain/usecases/accept_invite_usecase.dart';
import 'package:task_manager/features/members/domain/usecases/decline_invite_usecase.dart';
import 'package:task_manager/features/members/domain/usecases/get_pending_invites_usecase.dart';
import 'package:task_manager/features/members/domain/usecases/get_workspace_members_usecase.dart';
import 'package:task_manager/features/members/domain/usecases/invite_user_usecase.dart';
import 'package:task_manager/features/members/presentation/bloc/member_event.dart';
import 'package:task_manager/features/members/presentation/bloc/member_state.dart';

class MemberBloc extends Bloc<MemberEvent, MemberState> {
  final GetWorkspaceMembersUseCase getWorkspaceMembersUseCase;
  final InviteUserUseCase inviteUserUseCase;
  final AcceptInviteUseCase acceptInviteUseCase;
  final DeclineInviteUseCase declineInviteUseCase;
  final GetPendingInvitesUseCase getPendingInvitesUseCase;

  StreamSubscription? _membersSubscription;
  StreamSubscription? _invitesSubscription;

  MemberBloc({
    required this.getWorkspaceMembersUseCase,
    required this.inviteUserUseCase,
    required this.acceptInviteUseCase,
    required this.declineInviteUseCase,
    required this.getPendingInvitesUseCase,
  }) : super(MemberInitial()) {
    on<MembersLoadRequested>(_onMembersLoadRequested);
    on<InviteUserRequested>(_onInviteUserRequested);
    on<AcceptInviteRequested>(_onAcceptInviteRequested);
    on<DeclineInviteRequested>(_onDeclineInviteRequested);
    on<PendingInvitesLoadRequested>(_onPendingInvitesLoadRequested);
  }

  Future<void> _onMembersLoadRequested(
    MembersLoadRequested event,
    Emitter<MemberState> emit,
  ) async {
    emit(MemberLoading());
    await _membersSubscription?.cancel();
    await emit.forEach(
      getWorkspaceMembersUseCase(
        workspaceId: event.workspaceId,
        memberIds: event.memberIds,
      ),
      onData: (members) => MembersLoaded(members),
      onError: (_, __) => const MemberError('Failed to load members'),
    );
  }

  Future<void> _onInviteUserRequested(
    InviteUserRequested event,
    Emitter<MemberState> emit,
  ) async {
    try {
      await inviteUserUseCase(
        workspaceId: event.workspaceId,
        email: event.email,
        invitedBy: event.invitedBy,
      );
      emit(InviteSent());
    } catch (e) {
      emit(MemberError(e.toString()));
    }
  }

  Future<void> _onAcceptInviteRequested(
    AcceptInviteRequested event,
    Emitter<MemberState> emit,
  ) async {
    try {
      await acceptInviteUseCase(
        workspaceId: event.workspaceId,
        inviteId: event.inviteId,
        userId: event.userId,
      );
      emit(InviteAccepted());
    } catch (e) {
      emit(MemberError(e.toString()));
    }
  }

  Future<void> _onDeclineInviteRequested(
    DeclineInviteRequested event,
    Emitter<MemberState> emit,
  ) async {
    try {
      await declineInviteUseCase(
        workspaceId: event.workspaceId,
        inviteId: event.inviteId,
      );
      emit(InviteDeclined());
    } catch (e) {
      emit(MemberError(e.toString()));
    }
  }

  Future<void> _onPendingInvitesLoadRequested(
    PendingInvitesLoadRequested event,
    Emitter<MemberState> emit,
  ) async {
    emit(MemberLoading());
    await _invitesSubscription?.cancel();
    await emit.forEach(
      getPendingInvitesUseCase(userEmail: event.userEmail),
      onData: (invites) => PendingInvitesLoaded(invites),
      onError: (_, __) => const MemberError('Failed to load invites'),
    );
  }

  @override
  Future<void> close() {
    _membersSubscription?.cancel();
    _invitesSubscription?.cancel();
    return super.close();
  }
}