import 'package:get/get.dart';
import '../data/models/movie.dart';
import '../data/models/movie_detail.dart';
import '../data/services/movie_service.dart';

class MovieController extends GetxController {
  final MovieService _movieService = Get.find<MovieService>();

  final RxList<Movie> movies = <Movie>[].obs;
  final Rx<MovieDetail?> currentMovieDetail = Rx<MovieDetail?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxString searchQuery = ''.obs;

  Future<void> loadMovies({int page = 1, String? query}) async {
    print(
        '[MOVIE_CONTROLLER] Loading movies - Page: $page, Query: ${query ?? "(none)"}');

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = query != null && query.isNotEmpty
          ? await _movieService.searchMovies(query, page)
          : await _movieService.getPopularMovies(page);

      if (page == 1) {
        movies.value = response.results;
      } else {
        movies.addAll(response.results);
      }

      currentPage.value = response.page;
      totalPages.value = response.totalPages;
      searchQuery.value = query ?? '';

      print('[MOVIE_CONTROLLER] Loaded ${response.results.length} movies');
      print('   └─ Total movies in list: ${movies.length}');
    } catch (e) {
      print('[MOVIE_CONTROLLER] Error loading movies: $e');
      errorMessage.value = e.toString();
      try {
        Get.snackbar(
          'Error',
          'Failed to load movies',
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (_) {}
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreMovies() async {
    if (currentPage.value < totalPages.value && !isLoading.value) {
      print(
          '[MOVIE_CONTROLLER] Loading more movies - Next page: ${currentPage.value + 1}');
      await loadMovies(
        page: currentPage.value + 1,
        query: searchQuery.value.isEmpty ? null : searchQuery.value,
      );
    }
  }

  Future<void> searchMovies(String query) async {
    print('[MOVIE_CONTROLLER] Searching movies: "$query"');
    movies.clear();
    await loadMovies(page: 1, query: query);
  }

  Future<void> loadMovieDetail(int movieId) async {
    print('[MOVIE_CONTROLLER] Loading movie detail - ID: $movieId');

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final detail = await _movieService.getMovieDetails(movieId);
      currentMovieDetail.value = detail;

      print('[MOVIE_CONTROLLER] Movie detail loaded: ${detail.title}');
    } catch (e) {
      print('[MOVIE_CONTROLLER] Error loading movie detail: $e');
      errorMessage.value = e.toString();
      try {
        Get.snackbar(
          'Error',
          'Failed to load movie details',
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (_) {}
    } finally {
      isLoading.value = false;
    }
  }

  void clearSearch() {
    print('[MOVIE_CONTROLLER] Clearing search');
    searchQuery.value = '';
    movies.clear();
    loadMovies(page: 1);
  }
}
