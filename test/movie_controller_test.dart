import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:flutter_movie_api/controllers/movie_controller.dart';
import 'package:flutter_movie_api/data/services/movie_service.dart';
import 'test_helper.dart';

void main() {
  setUpAll(() async {
    await setupFirebaseForTests();
  });

  setUp(() {
    Get.testMode = true;
    // Initialize required services
    Get.put(MovieService());
  });

  tearDown(() {
    Get.reset();
  });

  group('MovieController Tests', () {
    test('MovieController initializes with empty movie list', () {
      final movieController = Get.put(MovieController());

      expect(movieController.movies, isEmpty);
      expect(movieController.isLoading.value, isFalse);
    });

    test('MovieController can be instantiated', () {
      final movieController = Get.put(MovieController());

      expect(movieController, isNotNull);
      expect(movieController, isA<MovieController>());
    });
  });
}
