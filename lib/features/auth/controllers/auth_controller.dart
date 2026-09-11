import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/utils/toast.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;

  AuthController(this._authRepository);

  final isLoading = false.obs;
  final user = Rxn<UserModel>();
  final isInitialized = false.obs;

  bool get isLoggedIn => user.value != null;
  bool get isAdmin => user.value?.isAdmin ?? false;

  @override
  void onInit() {
    super.onInit();
    _initAuth();
  }

  void _initAuth() {
    _authRepository.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null) {
        await _fetchUserModel();
      } else {
        user.value = null;
      }
      isInitialized.value = true;
    });
  }

  Future<void> _fetchUserModel() async {
    try {
      user.value = await _authRepository.getCurrentUserModel();
    } catch (e) {
      user.value = null;
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    isLoading.value = true;
    try {
      user.value = await _authRepository.signInWithEmail(email, password);
      Get.offAllNamed('/main');
    } catch (e) {
      showToast(e.toString(), type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUpWithEmail(
    String email,
    String password,
    String name,
    String phone,
  ) async {
    isLoading.value = true;
    try {
      await _authRepository.signUpWithEmail(email, password, name, phone);
      await _authRepository.signOut();
      Get.offAllNamed('/login');
      showToast('Akun berhasil dibuat, silakan masuk', type: ToastType.success);
    } catch (e) {
      showToast(e.toString(), type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword(String email) async {
    isLoading.value = true;
    try {
      await _authRepository.resetPassword(email);
      showToast('Email reset password telah dikirim', type: ToastType.success);
    } catch (e) {
      showToast(e.toString(), type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    user.value = null;
    Get.offAllNamed('/login');
  }

  void requireAuth(VoidCallback onAuthenticated) {
    if (isLoggedIn) {
      onAuthenticated();
    } else {
      Get.toNamed('/login');
    }
  }
}
