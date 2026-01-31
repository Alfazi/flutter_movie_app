import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:flutter_movie_api/screens/rental_list_screen.dart';
import 'package:flutter_movie_api/controllers/rental_controller.dart';
import 'package:flutter_movie_api/controllers/auth_controller.dart';
import 'package:flutter_movie_api/data/services/auth_service.dart';
import 'package:flutter_movie_api/data/services/rental_service.dart';
import 'test_helper.dart';

void main() {
  setUpAll(() async {
    await setupFirebaseForTests();
  });

  setUp(() {
    Get.testMode = true;
    // Initialize required services
    Get.put(AuthService());
    Get.put(RentalService());
  });

  tearDown(() {
    Get.reset();
  });

  group('RentalListScreen Widget Tests', () {
    testWidgets('RentalListScreen displays app bar with title', (
      WidgetTester tester,
    ) async {
      // Setup controllers
      Get.put(AuthController());
      Get.put(RentalController());

      await tester.pumpWidget(
        const GetMaterialApp(
          home: RentalListScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify app bar exists
      expect(find.byType(AppBar), findsOneWidget);

      // Verify title
      expect(find.text('My Rentals'), findsOneWidget);
    });

    testWidgets('RentalListScreen shows scaffold structure', (
      WidgetTester tester,
    ) async {
      Get.put(AuthController());
      Get.put(RentalController());

      await tester.pumpWidget(
        const GetMaterialApp(
          home: RentalListScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Should show scaffold
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('RentalListScreen renders without errors', (
      WidgetTester tester,
    ) async {
      Get.put(AuthController());
      Get.put(RentalController());

      await tester.pumpWidget(
        const GetMaterialApp(
          home: RentalListScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify screen renders
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('RentalListScreen has logout button', (
      WidgetTester tester,
    ) async {
      Get.put(AuthController());
      Get.put(RentalController());

      await tester.pumpWidget(
        const GetMaterialApp(
          home: RentalListScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Look for logout icon or button
      final logoutIcons = find.byIcon(Icons.logout);
      expect(logoutIcons, findsWidgets);
    });
  });
}
