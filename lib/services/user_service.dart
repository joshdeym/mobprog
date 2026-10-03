import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  UserService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return getUserData();
  }

  Future<Map<String, dynamic>> createAccount({
    required String firstName,
    required String lastName,
    required int age,
    required String contactNo,
    required String username,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user!;
    await user.updateDisplayName(username.trim());
    await _firestore.collection('users').doc(user.uid).set({
      'fName': firstName.trim(),
      'lName': lastName.trim(),
      'age': age,
      'contactNo': contactNo.trim(),
      'username': username.trim(),
      'email': email.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return getUserData();
  }

  Future<Map<String, dynamic>> getUserData() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    final snapshot = await _firestore.collection('users').doc(user.uid).get();
    return {
      ...?snapshot.data(),
      'uid': user.uid,
      'email': user.email ?? '',
      'username': snapshot.data()?['username'] ?? user.displayName ?? '',
    };
  }

  Future<bool> isLoggedIn() async => _auth.currentUser != null;

  Future<void> updateUsername({required String username}) async {
    final user = _requireCurrentUser();
    final cleanedUsername = username.trim();
    await user.updateDisplayName(cleanedUsername);
    await _firestore.collection('users').doc(user.uid).set({
      'username': cleanedUsername,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> resetPasswordForCurrentPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _requireCurrentUser();
    final email = user.email;
    if (email == null) throw StateError('The signed-in account has no email.');
    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> deleteAccount({required String currentPassword}) async {
    final user = _requireCurrentUser();
    final email = user.email;
    if (email == null) throw StateError('The signed-in account has no email.');
    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await _firestore.collection('users').doc(user.uid).delete();
    await user.delete();
  }

  Future<void> signOut() => _auth.signOut();

  User _requireCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) throw StateError('No user is currently signed in.');
    return user;
  }
}
