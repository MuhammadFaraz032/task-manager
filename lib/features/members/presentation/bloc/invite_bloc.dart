import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/members/domain/usecases/accept_invite_usecase.dart';
import 'package:task_manager/features/members/domain/usecases/decline_invite_usecase.dart';
import 'package:task_manager/features/members/domain/usecases/get_pending_invites_usecase.dart';
import 'package:task_manager/features/members/domain/usecases/invite_user_usecase.dart';
import 'package:task_manager/features/members/presentation/bloc/invite_event.dart';
import 'package:task_manager/features/members/presentation/bloc/invite_state.dart';

class InviteBloc extends Bloc<InviteEvent, InviteState> {
  final GetPendingInvitesUseCase getPendingInvitesUseCase;
  final InviteUserUseCase inviteUserUseCase;
  final AcceptInviteUseCase acceptInviteUseCase;
  final DeclineInviteUseCase declineInviteUseCase;

  InviteBloc({
    required this.getPendingInvitesUseCase,
    required this.inviteUserUseCase,
    required this.acceptInviteUseCase,
    required this.declineInviteUseCase,
  }) : super(InviteInitial()) {
    on<PendingInvitesLoadRequested>(_onPendingInvitesLoadRequested);
    on<InviteUserRequested>(_onInviteUserRequested);
    on<AcceptInviteRequested>(_onAcceptInviteRequested);
    on<DeclineInviteRequested>(_onDeclineInviteRequested);
  }

  Future<void> _onPendingInvitesLoadRequested(
    PendingInvitesLoadRequested event,
    Emitter<InviteState> emit,
  ) async {
    emit(InviteLoading());
    await emit.forEach(
      getPendingInvitesUseCase(userEmail: event.userEmail),
      onData: (invites) => PendingInvitesLoaded(invites),
      onError: (_, __) => const InviteError('Failed to load invites'),
    );
  }

  Future<void> _onInviteUserRequested(
    InviteUserRequested event,
    Emitter<InviteState> emit,
  ) async {
    emit(InviteLoading());
    try {
      await inviteUserUseCase(
        workspaceId: event.workspaceId,
        email: event.email,
        invitedBy: event.invitedBy,
      );
      emit(InviteSent());
    } catch (e) {
      emit(InviteError(e.toString()));
    }
  }

  Future<void> _onAcceptInviteRequested(
    AcceptInviteRequested event,
    Emitter<InviteState> emit,
  ) async {
    try {
      await acceptInviteUseCase(
        workspaceId: event.workspaceId,
        inviteId: event.inviteId,
        userId: event.userId,
      );
      emit(InviteAccepted());
    } catch (e) {
      emit(InviteError(e.toString()));
    }
  }

  Future<void> _onDeclineInviteRequested(
    DeclineInviteRequested event,
    Emitter<InviteState> emit,
  ) async {
    try {
      await declineInviteUseCase(
        workspaceId: event.workspaceId,
        inviteId: event.inviteId,
      );
      emit(InviteDeclined());
    } catch (e) {
      emit(InviteError(e.toString()));
    }
  }
}