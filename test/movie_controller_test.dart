import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_movie_api/controllers/movie_controller.dart';
import 'package:flutter_movie_api/data/services/movie_service.dart';
import 'package:flutter_movie_api/data/models/movie.dart';
import 'package:flutter_movie_api/data/models/movie_response.dart';
import 'package:flutter_movie_api/data/models/movie_detail.dart';

@GenerateMocks([MovieService])
import 'movie_controller_test.mocks.dart';

void main() {
  late MovieController movieController;
  late MockMovieService mockMovieService;

  setUp(() {
    // Initialize GetX
    Get.testMode = true;

    // Create mocks
    mockMovieService = MockMovieService();

    // Create controller
    movieController = MovieController();

    print('[TEST] ✅ MovieController test setup complete');
  });

  tearDown(() {
    Get.reset();
    print('[TEST] 🧹 MovieController test teardown complete');
  });

  group('MovieController Tests', () {
    test('Controller initializes with empty movies list', () {
      print('[TEST] 🧪 Testing initial state');

      expect(movieController.movies.isEmpty, true);
      expect(movieController.isLoading.value, false);
      expect(movieController.currentPage.value, 1);
      expect(movieController.searchQuery.value, '');

      print('[TEST] ✅ Initial state test passed');
    });

    test('loadMovies successfully loads popular movies', () async {
      print('[TEST] 🧪 Testing loadMovies with popular movies');

      final testMovies = [
        Movie(
          id: 1,
          title: 'Test Movie 1',
          overview: 'Test overview 1',
          voteAverage: 8.5,
          voteCount: 1000,
          releaseDate: '2024-01-01',
          genreIds: [28, 12],
          popularity: 100.0,
          adult: false,
          originalLanguage: 'en',
          originalTitle: 'Test Movie 1',
        ),
        Movie(
          id: 2,
          title: 'Test Movie 2',
          overview: 'Test overview 2',
          voteAverage: 7.5,
          voteCount: 800,
          releaseDate: '2024-01-02',
          genreIds: [35, 18],
          popularity: 90.0,
          adult: false,
          originalLanguage: 'en',
          originalTitle: 'Test Movie 2',
        ),
      ];

      final testResponse = MovieResponse(
        page: 1,
        results: testMovies,
        totalPages: 10,
        totalResults: 200,
      );

      when(
        mockMovieService.getPopularMovies(1),
      ).thenAnswer((_) async => testResponse);

      await movieController.loadMovies(page: 1);

      expect(movieController.movies.length, 2);
      expect(movieController.movies[0].title, 'Test Movie 1');
      expect(movieController.currentPage.value, 1);
      expect(movieController.totalPages.value, 10);
      expect(movieController.isLoading.value, false);

      print('[TEST] ✅ loadMovies test passed');
    });

    test('searchMovies filters movies by query', () async {
      print('[TEST] 🧪 Testing searchMovies');

      final testMovies = [
        Movie(
          id: 1,
          title: 'Action Movie',
          overview: 'Action-packed',
          voteAverage: 8.0,
          voteCount: 500,
          releaseDate: '2024-01-01',
          genreIds: [28],
          popularity: 80.0,
          adult: false,
          originalLanguage: 'en',
          originalTitle: 'Action Movie',
        ),
      ];

      final testResponse = MovieResponse(
        page: 1,
        results: testMovies,
        totalPages: 1,
        totalResults: 1,
      );

      when(
        mockMovieService.searchMovies('action', 1),
      ).thenAnswer((_) async => testResponse);

      await movieController.searchMovies('action');

      expect(movieController.movies.length, 1);
      expect(movieController.movies[0].title, 'Action Movie');
      expect(movieController.searchQuery.value, 'action');

      print('[TEST] ✅ searchMovies test passed');
    });

    test('loadMovieDetail loads specific movie details', () async {
      print('[TEST] 🧪 Testing loadMovieDetail');

      final testGenre = Genre(id: 28, name: 'Action');
      final testCompany = ProductionCompany(
        id: 1,
        name: 'Test Studio',
        logoPath: '/logo.jpg',
        originCountry: 'US',
      );

      final testDetail = MovieDetail(
        id: 1,
        title: 'Detailed Movie',
        overview: 'Detailed overview',
        posterPath: '/poster.jpg',
        backdropPath: '/backdrop.jpg',
        voteAverage: 8.5,
        voteCount: 1000,
        releaseDate: '2024-01-01',
        runtime: 120,
        budget: 50000000,
        revenue: 200000000,
        status: 'Released',
        tagline: 'Amazing movie',
        originalLanguage: 'en',
        genres: [testGenre],
        productionCompanies: [testCompany],
        adult: false,
        popularity: 100.0,
      );

      when(
        mockMovieService.getMovieDetails(1),
      ).thenAnswer((_) async => testDetail);

      await movieController.loadMovieDetail(1);

      expect(movieController.currentMovieDetail.value, isNotNull);
      expect(movieController.currentMovieDetail.value?.title, 'Detailed Movie');
      expect(movieController.currentMovieDetail.value?.runtime, 120);
      expect(movieController.isLoading.value, false);

      print('[TEST] ✅ loadMovieDetail test passed');
    });

    test('loadMoreMovies appends movies to existing list', () async {
      print('[TEST] 🧪 Testing loadMoreMovies');

      // Initial movies
      final initialMovies = [
        Movie(
          id: 1,
          title: 'Movie 1',
          overview: 'Overview 1',
          voteAverage: 8.0,
          voteCount: 100,
          releaseDate: '2024-01-01',
          genreIds: [28],
          popularity: 80.0,
          adult: false,
          originalLanguage: 'en',
          originalTitle: 'Movie 1',
        ),
      ];

      final initialResponse = MovieResponse(
        page: 1,
        results: initialMovies,
        totalPages: 2,
        totalResults: 40,
      );

      // Second page movies
      final moreMovies = [
        Movie(
          id: 2,
          title: 'Movie 2',
          overview: 'Overview 2',
          voteAverage: 7.5,
          voteCount: 90,
          releaseDate: '2024-01-02',
          genreIds: [35],
          popularity: 75.0,
          adult: false,
          originalLanguage: 'en',
          originalTitle: 'Movie 2',
        ),
      ];

      final moreResponse = MovieResponse(
        page: 2,
        results: moreMovies,
        totalPages: 2,
        totalResults: 40,
      );

      when(
        mockMovieService.getPopularMovies(1),
      ).thenAnswer((_) async => initialResponse);
      when(
        mockMovieService.getPopularMovies(2),
      ).thenAnswer((_) async => moreResponse);

      // Load initial page
      await movieController.loadMovies(page: 1);
      expect(movieController.movies.length, 1);

      // Load more movies
      await movieController.loadMoreMovies();
      expect(movieController.movies.length, 2);
      expect(movieController.currentPage.value, 2);

      print('[TEST] ✅ loadMoreMovies test passed');
    });

    test('clearSearch resets search and loads popular movies', () async {
      print('[TEST] 🧪 Testing clearSearch');

      // Set search query
      movieController.searchQuery.value = 'test';
      movieController.movies.value = [
        Movie(
          id: 1,
          title: 'Search Result',
          overview: 'Overview',
          voteAverage: 8.0,
          voteCount: 100,
          releaseDate: '2024-01-01',
          genreIds: [28],
          popularity: 80.0,
          adult: false,
          originalLanguage: 'en',
          originalTitle: 'Search Result',
        ),
      ];

      final testResponse = MovieResponse(
        page: 1,
        results: [],
        totalPages: 1,
        totalResults: 0,
      );

      when(
        mockMovieService.getPopularMovies(1),
      ).thenAnswer((_) async => testResponse);

      movieController.clearSearch();

      expect(movieController.searchQuery.value, '');
      expect(movieController.movies.isEmpty, true);

      print('[TEST] ✅ clearSearch test passed');
    });

    test('Error handling in loadMovies sets error message', () async {
      print('[TEST] 🧪 Testing error handling');

      when(
        mockMovieService.getPopularMovies(1),
      ).thenThrow(Exception('Network error'));

      await movieController.loadMovies(page: 1);

      expect(movieController.errorMessage.value, isNotEmpty);
      expect(movieController.isLoading.value, false);

      print('[TEST] ✅ Error handling test passed');
    });
  });
}
