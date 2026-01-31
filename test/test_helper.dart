// test/test_helper.dart
import 'dart:async';

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Setup Firebase for testing
Future<void> setupFirebaseForTests() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseMocks();
  await Firebase.initializeApp();
}

void setupFirebaseMocks() {
  FirebasePlatform.instance = FakeFirebasePlatform();
  FirebaseAuthPlatform.instance = FakeFirebaseAuthPlatform();
}

class FakeFirebasePlatform extends FirebasePlatform {
  FakeFirebasePlatform() : super();

  static final Map<String, FirebaseAppPlatform> _apps = {};

  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    if (_apps.containsKey(name)) {
      return _apps[name]!;
    }
    final app = FakeFirebaseApp(name);
    _apps[name] = app;
    return app;
  }

  @override
  List<FirebaseAppPlatform> get apps {
    return _apps.values.toList();
  }

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    final appName = name ?? defaultFirebaseAppName;
    if (_apps.containsKey(appName)) {
      return _apps[appName]!;
    }
    final app = FakeFirebaseApp(
      appName,
      options: options ??
          const FirebaseOptions(
            apiKey: 'test-api-key',
            appId: 'test-app-id',
            messagingSenderId: 'test-sender-id',
            projectId: 'test-project-id',
          ),
    );
    _apps[appName] = app;
    return app;
  }
}

class FakeFirebaseApp extends FirebaseAppPlatform {
  FakeFirebaseApp(String name, {FirebaseOptions? options})
      : super(name, options ?? _testOptions);

  static const FirebaseOptions _testOptions = FirebaseOptions(
    apiKey: 'test-api-key',
    appId: 'test-app-id',
    messagingSenderId: 'test-sender-id',
    projectId: 'test-project-id',
  );

  @override
  Future<void> delete() async {
    return;
  }

  @override
  Future<void> setAutomaticDataCollectionEnabled(bool enabled) async {
    return;
  }

  @override
  Future<void> setAutomaticResourceManagementEnabled(bool enabled) async {
    return;
  }
}

class FakeFirebaseAuthPlatform extends FirebaseAuthPlatform {
  FakeFirebaseAuthPlatform() : super();

  @override
  FirebaseAuthPlatform delegateFor({required FirebaseApp app}) {
    return this;
  }

  @override
  FirebaseAuthPlatform setInitialValues({
    PigeonUserDetails? currentUser,
    String? languageCode,
  }) {
    return this;
  }

  @override
  Stream<UserPlatform?> authStateChanges() {
    return Stream<UserPlatform?>.value(null);
  }

  @override
  Stream<UserPlatform?> idTokenChanges() {
    return Stream<UserPlatform?>.value(null);
  }

  @override
  Stream<UserPlatform?> userChanges() {
    return Stream<UserPlatform?>.value(null);
  }

  @override
  Future<UserCredentialPlatform> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return FakeUserCredential();
  }

  @override
  Future<UserCredentialPlatform> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return FakeUserCredential();
  }

  @override
  Future<void> signOut() async {
    return;
  }

  @override
  UserPlatform? get currentUser => null;
}

class FakeUserCredential extends UserCredentialPlatform {
  FakeUserCredential() : super(auth: FakeFirebaseAuthPlatform());

  @override
  UserPlatform? get user => null;
}
