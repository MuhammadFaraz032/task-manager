import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final String id;
  final String text;
  final String createdBy;
  final String createdByName;
  final DateTime createdAt;

  const CommentEntity({
    required this.id,
    required this.text,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, text, createdBy, createdByName, createdAt];
}