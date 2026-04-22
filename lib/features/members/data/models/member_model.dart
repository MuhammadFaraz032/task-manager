import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:task_manager/features/auth/domain/entities/user_entity.dart';
import 'package:task_manager/features/members/domain/entities/member_entity.dart';

class InviteModel extends InviteEntity {
  const InviteModel({
    required super.id,
    required super.email,
    required super.invitedBy,
    required super.status,
    required super.createdAt,
  });

  factory InviteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InviteModel(
      id: doc.id,
      email: data['email'] as String,
      invitedBy: data['invitedBy'] as String,
      status: data['status'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'invitedBy': invitedBy,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}