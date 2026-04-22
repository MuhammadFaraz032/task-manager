import 'package:equatable/equatable.dart';

class MemberEntity extends Equatable {
  final String uid;
  final String fullName;
  final String email;
  final String? photoUrl;
  final String? jobTitle;

  const MemberEntity({
    required this.uid,
    required this.fullName,
    required this.email,
    this.photoUrl,
    this.jobTitle,
  });

  @override
  List<Object?> get props => [uid, fullName, email, photoUrl, jobTitle];
}

class InviteEntity extends Equatable {
  final String id;
  final String email;
  final String invitedBy;
  final String status; // pending | accepted | declined
  final DateTime createdAt;

  const InviteEntity({
    required this.id,
    required this.email,
    required this.invitedBy,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, invitedBy, status, createdAt];
}