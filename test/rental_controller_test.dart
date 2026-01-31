import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
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

  group('RentalController Tests', () {
    test('RentalController initializes with empty rentals list', () {
      // Setup auth controller first
      Get.put(AuthController());
      final rentalController = Get.put(RentalController());

      expect(rentalController.rentals, isEmpty);
      expect(rentalController.isLoading.value, isFalse);
    });

    test('RentalController activeRentals returns only active rentals', () {
      Get.put(AuthController());
      final rentalController = Get.put(RentalController());

      // Initially should be empty
      expect(rentalController.activeRentals, isEmpty);
    });

    test('RentalController totalRentals returns correct count', () {
      Get.put(AuthController());
      final rentalController = Get.put(RentalController());

      expect(rentalController.totalRentals, equals(0));
    });

    test('RentalController activeRentalsCount returns correct count', () {
      Get.put(AuthController());
      final rentalController = Get.put(RentalController());

      expect(rentalController.activeRentalsCount, equals(0));
    });

    test('RentalController totalSpent returns 0 when no rentals', () {
      Get.put(AuthController());
      final rentalController = Get.put(RentalController());

      expect(rentalController.totalSpent, equals(0.0));
    });

    test('RentalController stats returns empty map initially', () {
      Get.put(AuthController());
      final rentalController = Get.put(RentalController());

      expect(rentalController.stats.value, isEmpty);
    });
  });
}
