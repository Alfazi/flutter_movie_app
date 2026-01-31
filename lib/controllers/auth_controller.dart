import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/services/auth_service.dart';
import '../data/models/user_model.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final Rx<User?> _firebaseUser = Rx<User?>(null);
  final Rx<UserModel?> _userModel = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  User? get user => _firebaseUser.value;
  UserModel? get userModel => _userModel.value;
  bool get isLoggedIn => _firebaseUser.value != null;

  @override
  void onInit() {
    super.onInit();
    print('[AUTH_CONTROLLER] Initializing');
    _firebaseUser.bindStream(_authService.authStateChanges);
    ever(_firebaseUser, _setInitialScreen);
  }

  void _setInitialScreen(User? user) {
    if (user == null) {
      print('[AUTH_CONTROLLER] User logged out, navigating to login');
      if (Get.currentRoute != '/login') {
        Get.offAllNamed('/login');
      }
    } else {
      print('[AUTH_CONTROLLER] User logged in: ${user.email}');
      _userModel.value = UserModel(
        id: user.uid,
        email: user.email!,
        displayName: user.displayName,
        createdAt: user.metadata.creationTime,
      );
      if (Get.currentRoute != '/home') {
        Get.offAllNamed('/home');
      }
    }
  }

  Future<void> signIn(String email, String password) async {
    print('[AUTH_CONTROLLER] Signing in: $email');
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final userModel = await _authService.signInWithEmailPassword(
        email,
        password,
      );

      if (userModel != null) {
        _userModel.value = userModel;
        _firebaseUser.value = FirebaseAuth.instance.currentUser;
        print('[AUTH_CONTROLLER] Sign in successful, navigating to home');
        Get.snackbar(
          'Success',
          'Welcome back!',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.offAllNamed('/home');
      }
    } catch (e) {
      print('[AUTH_CONTROLLER] Sign in error: $e');
      errorMessage.value = e.toString();
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(String email, String password) async {
    print('[AUTH_CONTROLLER] Registering: $email');
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final userModel = await _authService.registerWithEmailPassword(
        email,
        password,
      );

      if (userModel != null) {
        _userModel.value = userModel;
        print('[AUTH_CONTROLLER] Registration successful');
        Get.snackbar(
          'Success',
          'Account created successfully!',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('[AUTH_CONTROLLER] Registration error: $e');
      errorMessage.value = e.toString();
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    print('[AUTH_CONTROLLER] Signing out');
    try {
      await _authService.signOut();
      _userModel.value = null;
      print('[AUTH_CONTROLLER] Sign out successful');
    } catch (e) {
      print('[AUTH_CONTROLLER] Sign out error: $e');
      Get.snackbar(
        'Error',
        'Failed to sign out',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> resetPassword(String email) async {
    print('[AUTH_CONTROLLER] Resetting password for: $email');
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _authService.resetPassword(email);

      print('[AUTH_CONTROLLER] Password reset email sent');
      Get.snackbar(
        'Success',
        'Password reset email sent',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('[AUTH_CONTROLLER] Password reset error: $e');
      errorMessage.value = e.toString();
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
