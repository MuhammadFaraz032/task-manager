import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager/features/auth/domain/entities/user_entity.dart';

// LEARNING: Model extends Entity
// Entity = pure Dart, no dependencies
// Model = knows about Firestore, can
// convert to/from JSON for storage
class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.fullName,
    required super.email,
    super.photoUrl,
    super.jobTitle,
    required super.workspaceId,
    required super.createdAt,
  });

  // LEARNING: fromFirestore converts raw
  // Firestore document data into a UserModel
  factory UserModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      uid: doc.id,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      jobTitle: data['jobTitle'],
      workspaceId: data['workspaceId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // LEARNING: toMap converts UserModel
  // into a Map for storing in Firestore
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'photoUrl': photoUrl,
      'jobTitle': jobTitle ?? '',
      'workspaceId': workspaceId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}