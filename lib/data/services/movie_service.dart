import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/movie_response.dart';
import '../models/movie_detail.dart';

class MovieService {
  final DioClient _dioClient = DioClient();

  Future<MovieResponse> getPopularMovies(int page) async {
    print('🎬 [MOVIE_SERVICE] Fetching popular movies - Page: $page');
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.popularMovies,
        queryParameters: {'page': page, 'language': 'en-US'},
      );

      final movieResponse = MovieResponse.fromJson(response.data);
      print(
        '[MOVIE_SERVICE] Successfully fetched ${movieResponse.results.length} movies',
      );
      print('   ├─ Page: ${movieResponse.page}/${movieResponse.totalPages}');
      print('   └─ Total results: ${movieResponse.totalResults}');
      return movieResponse;
    } on DioException catch (e) {
      print('[MOVIE_SERVICE] DioException in getPopularMovies: ${e.message}');
      throw _dioClient.handleError(e);
    } catch (e) {
      print('[MOVIE_SERVICE] Unexpected error in getPopularMovies: $e');
      throw 'An unexpected error occurred: ${e.toString()}';
    }
  }

  Future<MovieResponse> searchMovies(String query, int page) async {
    print('🔍 [MOVIE_SERVICE] Searching movies - Query: "$query", Page: $page');
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.searchMovies,
        queryParameters: {'query': query, 'page': page, 'language': 'en-US'},
      );

      final movieResponse = MovieResponse.fromJson(response.data);
      print(
        '[MOVIE_SERVICE] Search completed: ${movieResponse.results.length} movies found',
      );
      print('   ├─ Query: "$query"');
      print('   ├─ Page: ${movieResponse.page}/${movieResponse.totalPages}');
      print('   └─ Total results: ${movieResponse.totalResults}');
      return movieResponse;
    } on DioException catch (e) {
      print('[MOVIE_SERVICE] DioException in searchMovies: ${e.message}');
      throw _dioClient.handleError(e);
    } catch (e) {
      print('[MOVIE_SERVICE] Unexpected error in searchMovies: $e');
      throw 'An unexpected error occurred: ${e.toString()}';
    }
  }

  Future<MovieDetail> getMovieDetails(int movieId) async {
    print('[MOVIE_SERVICE] Fetching movie details - ID: $movieId');
    try {
      final response = await _dioClient.dio.get(
        '${ApiConstants.movieDetails}/$movieId',
        queryParameters: {'language': 'en-US'},
      );

      final movieDetail = MovieDetail.fromJson(response.data);
      print('[MOVIE_SERVICE] Movie details loaded: ${movieDetail.title}');
      print('   ├─ Runtime: ${movieDetail.runtime} min');
      print('   ├─ Rating: ${movieDetail.voteAverage}/10');
      print('   └─ Budget: \$${movieDetail.budget}');
      return movieDetail;
    } on DioException catch (e) {
      print('[MOVIE_SERVICE] DioException in getMovieDetails: ${e.message}');
      throw _dioClient.handleError(e);
    } catch (e) {
      print('[MOVIE_SERVICE] Unexpected error in getMovieDetails: $e');
      throw 'An unexpected error occurred: ${e.toString()}';
    }
  }
}
