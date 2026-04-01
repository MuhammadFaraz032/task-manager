import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_manager/features/auth/data/models/user_model.dart';

// LEARNING: Abstract class defines the contract

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
  });

  Future<void> logout();

  Stream<UserModel?> get authStateChanges;

  Future<UserModel?> getCurrentUser();

  // NEW
  Future<UserModel> updateUser({
    required String uid,
    required String fullName,
    required String jobTitle,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final doc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();
      return UserModel.fromFirestore(doc);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final credential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;
      await user.updateDisplayName(fullName);
      final userModel = UserModel(
        uid: user.uid,
        fullName: fullName,
        email: email,
        photoUrl: null,
        jobTitle: '',
        workspaceId: '',
        createdAt: DateTime.now(),
      );
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toMap());
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  @override
  Future<UserModel> updateUser({
    required String uid,
    required String fullName,
    required String jobTitle,
  }) async {
    try {
      // LEARNING: update() only changes specified fields
      // set() would overwrite the entire document
      await _firestore.collection('users').doc(uid).update({
        'fullName': fullName,
        'jobTitle': jobTitle,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Also update Firebase Auth display name
      await _firebaseAuth.currentUser?.updateDisplayName(fullName);

      // Fetch and return updated document
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No account found with this email');
      case 'wrong-password':
        return Exception('Incorrect password');
      case 'invalid-credential':
        return Exception('Invalid email or password');
      case 'user-disabled':
        return Exception('This account has been disabled');
      case 'too-many-requests':
        return Exception('Too many attempts. Please try again later');
      case 'email-already-in-use':
        return Exception('An account already exists with this email');
      case 'weak-password':
        return Exception('Password is too weak. Use at least 6 characters');
      case 'invalid-email':
        return Exception('Invalid email address');
      case 'network-request-failed':
        return Exception('No internet connection');
      default:
        return Exception(e.message ?? 'Something went wrong. Please try again');
    }
  }
}