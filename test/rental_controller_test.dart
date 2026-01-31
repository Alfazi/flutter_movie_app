import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_movie_api/controllers/rental_controller.dart';
import 'package:flutter_movie_api/controllers/auth_controller.dart';
import 'package:flutter_movie_api/data/services/rental_service.dart';
import 'package:flutter_movie_api/data/models/rental.dart';
import 'package:firebase_auth/firebase_auth.dart';

@GenerateMocks([RentalService, AuthController, User])
import 'rental_controller_test.mocks.dart';

void main() {
  late RentalController rentalController;
  late MockRentalService mockRentalService;
  late MockAuthController mockAuthController;
  late MockUser mockUser;

  setUp(() {
    // Initialize GetX
    Get.testMode = true;
    
    // Create mocks
    mockRentalService = MockRentalService();
    mockAuthController = MockAuthController();
    mockUser = MockUser();
    
    // Setup default auth behavior
    when(mockAuthController.user).thenReturn(mockUser);
    when(mockAuthController.isLoggedIn).thenReturn(true);
    when(mockUser.uid).thenReturn('test-user-id');
    
    // Register mock auth controller
    Get.put<AuthController>(mockAuthController);
    
    // Create controller
    rentalController = RentalController();
    
    print('[TEST] ✅ RentalController test setup complete');
  });

  tearDown(() {
    Get.reset();
    print('[TEST] 🧹 RentalController test teardown complete');
  });

  group('RentalController Tests', () {
    test('Controller initializes with empty rentals', () {
      print('[TEST] 🧪 Testing initial state');
      
      expect(rentalController.rentals.isEmpty, true);
      expect(rentalController.activeRentals.isEmpty, true);
      expect(rentalController.isLoading.value, false);
      
      print('[TEST] ✅ Initial state test passed');
    });

    test('rentMovie creates a new rental successfully', () async {
      print('[TEST] 🧪 Testing rentMovie method');
      
      final testRental = Rental(
        id: '123',
        movieId: 1,
        movieTitle: 'Test Movie',
        posterPath: '/test.jpg',
        rentalDate: DateTime.now(),
        rentalDays: 3,
        totalPrice: 15000,
        userId: 'test-user-id',
        status: RentalStatus.active,
      );

      // Setup mocks
      when(mockRentalService.isMovieRented(any, any))
          .thenAnswer((_) async => false);
      when(mockRentalService.createRental(
        movieId: anyNamed('movieId'),
        movieTitle: anyNamed('movieTitle'),
        posterPath: anyNamed('posterPath'),
        rentalDays: anyNamed('rentalDays'),
        userId: anyNamed('userId'),
      )).thenAnswer((_) async => testRental);

      // Mock the loadRentals and loadStats methods
      // Since these call the service, we need to mock them
      
      final result = await rentalController.rentMovie(
        movieId: 1,
        movieTitle: 'Test Movie',
        posterPath: '/test.jpg',
        rentalDays: 3,
      );

      expect(result, true);
      print('[TEST] ✅ rentMovie test passed');
    });

    test('rentMovie fails when movie is already rented', () async {
      print('[TEST] 🧪 Testing rentMovie with already rented movie');

      // Setup mock to return true (movie already rented)
      when(mockRentalService.isMovieRented(any, any))
          .thenAnswer((_) async => true);

      final result = await rentalController.rentMovie(
        movieId: 1,
        movieTitle: 'Test Movie',
        rentalDays: 3,
      );

      expect(result, false);
      verify(mockRentalService.isMovieRented(1, 'test-user-id')).called(1);
      
      print('[TEST] ✅ Already rented test passed');
    });

    test('rentMovie fails when user is not logged in', () async {
      print('[TEST] 🧪 Testing rentMovie without authentication');

      // Setup mock to return null user
      when(mockAuthController.user).thenReturn(null);

      final result = await rentalController.rentMovie(
        movieId: 1,
        movieTitle: 'Test Movie',
        rentalDays: 3,
      );

      expect(result, false);
      verifyNever(mockRentalService.createRental(
        movieId: anyNamed('movieId'),
        movieTitle: anyNamed('movieTitle'),
        posterPath: anyNamed('posterPath'),
        rentalDays: anyNamed('rentalDays'),
        userId: anyNamed('userId'),
      ));
      
      print('[TEST] ✅ No authentication test passed');
    });

    test('checkIfMovieRented returns correct status', () async {
      print('[TEST] 🧪 Testing checkIfMovieRented method');

      when(mockRentalService.isMovieRented(1, 'test-user-id'))
          .thenAnswer((_) async => true);
      when(mockRentalService.isMovieRented(2, 'test-user-id'))
          .thenAnswer((_) async => false);

      final isRented1 = await rentalController.checkIfMovieRented(1);
      final isRented2 = await rentalController.checkIfMovieRented(2);

      expect(isRented1, true);
      expect(isRented2, false);
      
      print('[TEST] ✅ checkIfMovieRented test passed');
    });

    test('Rental statistics getters return correct values', () {
      print('[TEST] 🧪 Testing rental statistics getters');

      rentalController.stats.value = {
        'total': 10,
        'active': 3,
        'returned': 7,
        'expired': 0,
        'totalSpent': 50000.0,
      };

      expect(rentalController.totalRentals, 10);
      expect(rentalController.activeRentalsCount, 3);
      expect(rentalController.totalSpent, 50000.0);
      
      print('[TEST] ✅ Statistics getters test passed');
    });

    test('Rental statistics getters handle empty stats', () {
      print('[TEST] 🧪 Testing statistics with empty data');

      rentalController.stats.value = {};

      expect(rentalController.totalRentals, 0);
      expect(rentalController.activeRentalsCount, 0);
      expect(rentalController.totalSpent, 0.0);
      
      print('[TEST] ✅ Empty statistics test passed');
    });
  });
}
