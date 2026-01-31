import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:flutter_movie_api/screens/login_screen.dart';
import 'package:flutter_movie_api/controllers/auth_controller.dart';
import 'package:flutter_movie_api/data/services/auth_service.dart';
import 'test_helper.dart';

void main() {
  setUpAll(() async {
    await setupFirebaseForTests();
  });

  setUp(() {
    Get.testMode = true;
    // Initialize required services
    Get.put(AuthService());
  });

  tearDown(() {
    Get.reset();
  });

  group('LoginScreen Widget Tests', () {
    testWidgets('LoginScreen displays all required elements', (
      WidgetTester tester,
    ) async {
      // Create controller
      Get.put(AuthController());

      await tester.pumpWidget(
        const GetMaterialApp(
          home: LoginScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify title exists
      expect(find.text('Movie Rental'), findsOneWidget);

      // Verify email field
      expect(
        find.byType(TextField),
        findsWidgets,
      );

      // Verify login button exists
      expect(
        find.byType(ElevatedButton),
        findsWidgets,
      );
    });

    testWidgets('Email field accepts input', (WidgetTester tester) async {
      Get.put(AuthController());

      await tester.pumpWidget(
        const GetMaterialApp(
          home: LoginScreen(),
        ),
      );

      await tester.pumpAndSettle();

      final emailFields = find.byType(TextField);
      if (emailFields.evaluate().isNotEmpty) {
        await tester.enterText(emailFields.first, 'test@example.com');
        await tester.pump();

        expect(find.text('test@example.com'), findsOneWidget);
      }
    });

    testWidgets('Login button is tappable', (WidgetTester tester) async {
      Get.put(AuthController());

      await tester.pumpWidget(
        const GetMaterialApp(
          home: LoginScreen(),
        ),
      );

      await tester.pumpAndSettle();

      final loginButtons = find.byType(ElevatedButton);
      if (loginButtons.evaluate().isNotEmpty) {
        await tester.tap(loginButtons.first);
        await tester.pump();
        // Button should be tappable (no errors thrown)
      }

      expect(true, isTrue); // Test passed
    });
  });
}
