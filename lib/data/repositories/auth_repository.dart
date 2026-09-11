import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';

class AuthRepository {
  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;

  AuthRepository({
    required FirebaseAuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService;

  User? get currentUser => _authService.currentUser;
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  Future<UserModel?> getCurrentUserModel() async {
    final user = currentUser;
    if (user == null) return null;
    final doc = await _firestoreService.getUser(user.uid);
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<UserModel> signInWithEmail(String email, String password) async {
    final result = await _authService.signInWithEmail(email, password);
    final doc = await _firestoreService.getUser(result.user!.uid);
    if (!doc.exists) throw Exception('Data pengguna tidak ditemukan');
    return UserModel.fromFirestore(doc);
  }

  Future<UserModel> signUpWithEmail(
    String email,
    String password,
    String name,
    String phone,
  ) async {
    final result = await _authService.signUpWithEmail(email, password);
    final userData = {
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': '',
      'role': 'renter',
    };
    await _firestoreService.createUser(result.user!.uid, userData);
    final doc = await _firestoreService.getUser(result.user!.uid);
    return UserModel.fromFirestore(doc);
  }

  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
