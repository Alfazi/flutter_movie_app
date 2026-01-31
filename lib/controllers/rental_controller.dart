import 'package:get/get.dart';
import '../data/models/rental.dart';
import '../data/services/rental_service.dart';
import 'auth_controller.dart';

class RentalController extends GetxController {
  final RentalService _rentalService = Get.find<RentalService>();
  final AuthController _authController = Get.find<AuthController>();

  final RxList<Rental> rentals = <Rental>[].obs;
  final RxList<Rental> activeRentals = <Rental>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<Map<String, dynamic>> stats = Rx<Map<String, dynamic>>({});

  @override
  void onInit() {
    super.onInit();
    print('[RENTAL_CONTROLLER] Initializing');
    if (_authController.isLoggedIn) {
      loadRentals();
      loadStats();
    }
  }

  void loadRentals() {
    final userId = _authController.user?.uid;
    if (userId == null) {
      print('[RENTAL_CONTROLLER] No user logged in');
      return;
    }

    print('[RENTAL_CONTROLLER] Loading rentals for user: $userId');

    _rentalService.getUserRentals(userId).listen((rentalList) {
      rentals.value = rentalList;
      print('[RENTAL_CONTROLLER] Loaded ${rentalList.length} rental(s)');
    }, onError: (error) {
      print('[RENTAL_CONTROLLER] Error loading rentals: $error');
      Get.snackbar(
        'Error',
        'Failed to load rentals',
        snackPosition: SnackPosition.BOTTOM,
      );
    });
  }

  void loadActiveRentals() {
    final userId = _authController.user?.uid;
    if (userId == null) return;

    print('[RENTAL_CONTROLLER] Loading active rentals for user: $userId');

    _rentalService.getActiveRentals(userId).listen((rentalList) {
      activeRentals.value = rentalList;
      print('[RENTAL_CONTROLLER] Loaded ${rentalList.length} active rental(s)');
    });
  }

  Future<void> loadStats() async {
    final userId = _authController.user?.uid;
    if (userId == null) return;

    print('[RENTAL_CONTROLLER] Loading rental statistics');

    try {
      final statistics = await _rentalService.getRentalStats(userId);
      stats.value = statistics;
      print('[RENTAL_CONTROLLER] Stats loaded');
    } catch (e) {
      print('[RENTAL_CONTROLLER] Error loading stats: $e');
    }
  }

  Future<bool> rentMovie({
    required int movieId,
    required String movieTitle,
    String? posterPath,
    required int rentalDays,
  }) async {
    final userId = _authController.user?.uid;
    if (userId == null) {
      print('[RENTAL_CONTROLLER] No user logged in');
      Get.snackbar(
        'Error',
        'Please login to rent movies',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    print('[RENTAL_CONTROLLER] Renting movie: $movieTitle');
    print('   ├─ Movie ID: $movieId');
    print('   ├─ Rental Days: $rentalDays');
    print('   └─ User ID: $userId');

    try {
      isLoading.value = true;

      // Check if movie is already rented
      final isAlreadyRented =
          await _rentalService.isMovieRented(movieId, userId);
      if (isAlreadyRented) {
        print('[RENTAL_CONTROLLER] Movie already rented');
        Get.snackbar(
          'Already Rented',
          'You have already rented this movie',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      await _rentalService.createRental(
        movieId: movieId,
        movieTitle: movieTitle,
        posterPath: posterPath,
        rentalDays: rentalDays,
        userId: userId,
      );

      print('[RENTAL_CONTROLLER] Movie rented successfully');

      Get.snackbar(
        'Success',
        'Movie rented successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );

      loadRentals();
      loadStats();

      return true;
    } catch (e) {
      print('[RENTAL_CONTROLLER] Error renting movie: $e');
      Get.snackbar(
        'Error',
        'Failed to rent movie: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> returnRental(String rentalId) async {
    print('[RENTAL_CONTROLLER] Returning rental: $rentalId');

    try {
      isLoading.value = true;

      await _rentalService.returnRental(rentalId);

      print('[RENTAL_CONTROLLER] Rental returned successfully');

      Get.snackbar(
        'Success',
        'Movie returned successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );

      loadRentals();
      loadStats();
    } catch (e) {
      print('[RENTAL_CONTROLLER] Error returning rental: $e');
      Get.snackbar(
        'Error',
        'Failed to return movie: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> checkIfMovieRented(int movieId) async {
    final userId = _authController.user?.uid;
    if (userId == null) return false;

    return await _rentalService.isMovieRented(movieId, userId);
  }

  int get totalRentals => stats.value['total'] ?? 0;
  int get activeRentalsCount => stats.value['active'] ?? 0;
  double get totalSpent => (stats.value['totalSpent'] ?? 0).toDouble();
}
