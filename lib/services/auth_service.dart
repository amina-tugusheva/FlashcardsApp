import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final email = user.email;
    if (email == null) return;

    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  Future<void> deleteAccount({
    required String password,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final email = user.email;
    if (email == null) return;

    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    await user.reauthenticateWithCredential(credential);
    await user.delete();
  }


  Future<bool> isUsernameUnique(String username) async {
    final snapshot = await _firestore
        .collection('Users')
        .where('имя пользователя', isEqualTo: username.trim())
        .limit(1)
        .get();

    return snapshot.docs.isEmpty;
  }

  Future<UserCredential> registerWithEmailAndPassword({
    required String username,
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await userCredential.user!.sendEmailVerification();

    await _firestore.collection('Users').doc(userCredential.user!.uid).set({
      'имя пользователя': username.trim(),
      'email': userCredential.user!.email,
      'emailVerified': false,
    });

    return userCredential;
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> sendPasswordReset({
    required String email,
  }) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }


  String getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Этот email уже используется';
      case 'weak-password':
        return 'Пароль слишком слабый';
      case 'invalid-email':
        return 'Неверный формат email';
      case 'user-not-found':
        return 'Пользователь не найден';
      case 'wrong-password':
        return 'Неверный пароль';
      default:
        return 'Ошибка: $code';
    }
  }
  
  String getResetErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Неверный email';
      case 'user-not-found':
        return 'Пользователь не найден';
      default:
        return 'Ошибка: $code';
    }
  }
}