import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String fullName;
  final String email;
  final String? photoUrl;
  final String? jobTitle;
  final String workspaceId;
  final DateTime createdAt;

  const UserEntity({
    required this.uid,
    required this.fullName,
    required this.email,
    this.photoUrl,
    this.jobTitle,
    required this.workspaceId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        uid,
        fullName,
        email,
        photoUrl,
        jobTitle,
        workspaceId,
        createdAt,
      ];
}