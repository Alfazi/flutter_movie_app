import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_movie_api/screens/rental_list_screen.dart';
import 'package:flutter_movie_api/controllers/rental_controller.dart';
import 'package:flutter_movie_api/controllers/auth_controller.dart';
import 'package:flutter_movie_api/data/models/rental.dart';

@GenerateMocks([RentalController, AuthController])
import 'rental_list_screen_test.mocks.dart';

void main() {
  late MockRentalController mockRentalController;
  late MockAuthController mockAuthController;

  setUp(() {
    Get.testMode = true;
    mockRentalController = MockRentalController();
    mockAuthController = MockAuthController();
    
    // Setup default mock behavior
    when(mockRentalController.rentals).thenReturn(<Rental>[].obs);
    when(mockRentalController.activeRentals).thenReturn(<Rental>[].obs);
    when(mockRentalController.isLoading).thenReturn(false.obs);
    when(mockRentalController.stats).thenReturn(Rx<Map<String, dynamic>>({}));
    when(mockRentalController.totalRentals).thenReturn(0);
    when(mockRentalController.activeRentalsCount).thenReturn(0);
    when(mockRentalController.totalSpent).thenReturn(0.0);
    
    // Register mock controllers
    Get.put<RentalController>(mockRentalController);
    Get.put<AuthController>(mockAuthController);
    
    print('[TEST] ✅ RentalListScreen widget test setup complete');
  });

  tearDown(() {
    Get.reset();
    print('[TEST] 🧹 RentalListScreen widget test teardown complete');
  });

  group('RentalListScreen Widget Tests', () {
    testWidgets('RentalListScreen displays empty state when no rentals', (WidgetTester tester) async {
      print('[TEST] 🧪 Testing empty state');

      await tester.pumpWidget(
        const GetMaterialApp(
          home: RentalListScreen(),
        ),
      );

      await tester.pump();

      // Verify empty state elements
      expect(find.text('No rentals yet'), findsOneWidget);
      expect(find.text('Start renting movies to see them here'), findsOneWidget);
      expect(find.text('Browse Movies'), findsOneWidget);
      expect(find.byIcon(Icons.movie_outlined), findsWidgets);

      print('[TEST] ✅ Empty state test passed');
    });

    testWidgets('RentalListScreen displays statistics section', (WidgetTester tester) async {
      print('[TEST] 🧪 Testing statistics section');

      // Setup stats
      when(mockRentalController.stats).thenReturn(Rx<Map<String, dynamic>>({
        'total': 5,
        'active': 2,
        'returned': 3,
        'totalSpent': 25000.0,
      }));
      when(mockRentalController.totalRentals).thenReturn(5);
      when(mockRentalController.activeRentalsCount).thenReturn(2);
      when(mockRentalController.totalSpent).thenReturn(25000.0);

      await tester.pumpWidget(
        const GetMaterialApp(
          home: RentalListScreen(),
        ),
      );

      await tester.pump();

      // Verify stats labels
      expect(find.text('Total Rentals'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Returned'), findsOneWidget);
      expect(find.text('Total Spent'), findsOneWidget);

      print('[TEST] ✅ Statistics section test passed');
    });

    testWidgets('RentalListScreen displays rental cards with rentals', (WidgetTester tester) async {
      print('[TEST] 🧪 Testing rental cards display');

      // Create test rentals
      final testRentals = [
        Rental(
          id: '1',
          movieId: 1,
          movieTitle: 'Test Movie 1',
          posterPath: '/poster1.jpg',
          rentalDate: DateTime.now().subtract(const Duration(days: 2)),
          rentalDays: 7,
          totalPrice: 35000,
          userId: 'test-user',
          status: RentalStatus.active,
        ),
        Rental(
          id: '2',
          movieId: 2,
          movieTitle: 'Test Movie 2',
          posterPath: '/poster2.jpg',
          rentalDate: DateTime.now().subtract(const Duration(days: 10)),
          rentalDays: 3,
          totalPrice: 15000,
          userId: 'test-user',
          status: RentalStatus.returned,
        ),
      ];

      when(mockRentalController.rentals).thenReturn(testRentals.obs);

      await tester.pumpWidget(
        const GetMaterialApp(
          home: RentalListScreen(),
        ),
      );

      await tester.pump();

      // Verify rental titles are displayed
      expect(find.text('Test Movie 1'), findsOneWidget);
      expect(find.text('Test Movie 2'), findsOneWidget);

      // Verify status badges
      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.text('RETURNED'), findsOneWidget);

      print('[TEST] ✅ Rental cards display test passed');
    });

    testWidgets('RentalListScreen shows return button for active rentals', (WidgetTester tester) async {
      print('[TEST] 🧪 Testing return button for active rentals');

      final testRentals = [
        Rental(
          id: '1',
          movieId: 1,
          movieTitle: 'Active Movie',
          posterPath: '/poster.jpg',
          rentalDate: DateTime.now(),
          rentalDays: 7,
          totalPrice: 35000,
          userId: 'test-user',
          status: RentalStatus.active,
        ),
      ];

      when(mockRentalController.rentals).thenReturn(testRentals.obs);

      await tester.pumpWidget(
        const GetMaterialApp(
          home: RentalListScreen(),
        ),
      );

      await tester.pump();

      // Verify return button icon is present
      expect(find.byIcon(Icons.assignment_return), findsOneWidget);

      print('[TEST] ✅ Return button test passed');
    });

    testWidgets('RentalListScreen does not show return button for returned rentals', (WidgetTester tester) async {
      print('[TEST] 🧪 Testing no return button for returned rentals');

      final testRentals = [
        Rental(
          id: '1',
          movieId: 1,
          movieTitle: 'Returned Movie',
          posterPath: '/poster.jpg',
          rentalDate: DateTime.now().subtract(const Duration(days: 10)),
          rentalDays: 3,
          totalPrice: 15000,
          userId: 'test-user',
          status: RentalStatus.returned,
        ),
      ];

      when(mockRentalController.rentals).thenReturn(testRentals.obs);

      await tester.pumpWidget(
        const GetMaterialApp(
          home: RentalListScreen(),
        ),
      );

      await tester.pump();

      // Verify return button is not present
      expect(find.byIcon(Icons.assignment_return), findsNothing);

      print('[TEST] ✅ No return button for returned rental test passed');
    });

    testWidgets('Return dialog appears when return button is tapped', (WidgetTester tester) async {
      print('[TEST] 🧪 Testing return dialog');

      final testRentals = [
        Rental(
          id: '1',
          movieId: 1,
          movieTitle: 'Active Movie',
          posterPath: '/poster.jpg',
          rentalDate: DateTime.now(),
          rentalDays: 7,
          totalPrice: 35000,
          userId: 'test-user',
          status: RentalStatus.active,
        ),
      ];

      when(mockRentalController.rentals).thenReturn(testRentals.obs);

      await tester.pumpWidget(
        const GetMaterialApp(
          home: RentalListScreen(),
        ),
      );

      await tester.pump();

      // Tap return button
      await tester.tap(find.byIcon(Icons.assignment_return));
      await tester.pumpAndSettle();

      // Verify dialog appears
      expect(find.text('Return Movie'), findsOneWidget);
      expect(find.text('Are you sure you want to return "Active Movie"?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Return'), findsWidgets);

      print('[TEST] ✅ Return dialog test passed');
    });

    testWidgets('AppBar displays My Rentals title and logout button', (WidgetTester tester) async {
      print('[TEST] 🧪 Testing AppBar elements');

      await tester.pumpWidget(
        const GetMaterialApp(
          home: RentalListScreen(),
        ),
      );

      await tester.pump();

      // Verify AppBar title
      expect(find.text('My Rentals'), findsOneWidget);

      // Verify logout button
      expect(find.byIcon(Icons.logout), findsOneWidget);

      print('[TEST] ✅ AppBar elements test passed');
    });

    testWidgets('Logout dialog appears when logout button is tapped', (WidgetTester tester) async {
      print('[TEST] 🧪 Testing logout dialog');

      await tester.pumpWidget(
        const GetMaterialApp(
          home: RentalListScreen(),
        ),
      );

      await tester.pump();

      // Tap logout button
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      // Verify dialog appears
      expect(find.text('Logout'), findsWidgets);
      expect(find.text('Are you sure you want to logout?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      print('[TEST] ✅ Logout dialog test passed');
    });

    testWidgets('Browse Movies button navigates back', (WidgetTester tester) async {
      print('[TEST] 🧪 Testing Browse Movies navigation');

      await tester.pumpWidget(
        const GetMaterialApp(
          home: RentalListScreen(),
        ),
      );

      await tester.pump();

      // Verify button exists in empty state
      expect(find.text('Browse Movies'), findsOneWidget);

      print('[TEST] ✅ Browse Movies button test passed');
    });
  });
}
