// test/test_helper.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Setup Firebase for testing
Future<void> setupFirebaseForTests() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseMocks();
  await Firebase.initializeApp();
}

void setupFirebaseMocks() {
  FirebasePlatform.instance = FakeFirebasePlatform();
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
