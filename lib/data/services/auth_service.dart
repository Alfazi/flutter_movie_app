import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> signInWithEmailPassword(String email, String password) async {
    print('[AUTH_SERVICE] Signing in user: $email');
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('[AUTH_SERVICE] Sign in successful');
      print('   ├─ User ID: ${userCredential.user?.uid}');
      print('   ├─ Email: ${userCredential.user?.email}');
      print('   └─ Email verified: ${userCredential.user?.emailVerified}');
      
      if (userCredential.user != null) {
        return UserModel(
          id: userCredential.user!.uid,
          email: userCredential.user!.email!,
          displayName: userCredential.user!.displayName,
          createdAt: userCredential.user!.metadata.creationTime,
        );
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print('[AUTH_SERVICE] FirebaseAuthException: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('[AUTH_SERVICE] Unexpected error: $e');
      throw 'An unexpected error occurred';
    }
  }

  Future<UserModel?> registerWithEmailPassword(String email, String password) async {
    print('[AUTH_SERVICE] Registering new user: $email');
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('[AUTH_SERVICE] Registration successful');
      print('   ├─ User ID: ${userCredential.user?.uid}');
      print('   └─ Email: ${userCredential.user?.email}');
      
      if (userCredential.user != null) {
        return UserModel(
          id: userCredential.user!.uid,
          email: userCredential.user!.email!,
          displayName: userCredential.user!.displayName,
          createdAt: DateTime.now(),
        );
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print('[AUTH_SERVICE] FirebaseAuthException: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('[AUTH_SERVICE] Unexpected error: $e');
      throw 'An unexpected error occurred';
    }
  }

  // Sign out
  Future<void> signOut() async {
    print('[AUTH_SERVICE] Signing out user: ${currentUser?.email}');
    try {
      await _auth.signOut();
      print('[AUTH_SERVICE] Sign out successful');
    } catch (e) {
      print('[AUTH_SERVICE] Sign out error: $e');
      throw 'Failed to sign out';
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    print('[AUTH_SERVICE] Sending password reset email to: $email');
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('[AUTH_SERVICE] Password reset email sent');
    } on FirebaseAuthException catch (e) {
      print('[AUTH_SERVICE] FirebaseAuthException: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('[AUTH_SERVICE] Unexpected error: $e');
      throw 'An unexpected error occurred';
    }
  }

  // Handle auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password provided';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password should be at least 6 characters';
      case 'user-disabled':
        return 'This user account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled';
      case 'invalid-credential':
        return 'Invalid email or password';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}
