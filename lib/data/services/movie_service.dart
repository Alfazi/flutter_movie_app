import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/movie_response.dart';
import '../models/movie_detail.dart';

class MovieService {
  final DioClient _dioClient = DioClient();

  Future<MovieResponse> getPopularMovies(int page) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.popularMovies,
        queryParameters: {'page': page, 'language': 'en-US'},
      );

      return MovieResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _dioClient.handleError(e);
    } catch (e) {
      throw 'An unexpected error occurred: ${e.toString()}';
    }
  }

  Future<MovieResponse> searchMovies(String query, int page) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.searchMovies,
        queryParameters: {'query': query, 'page': page, 'language': 'en-US'},
      );

      return MovieResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _dioClient.handleError(e);
    } catch (e) {
      throw 'An unexpected error occurred: ${e.toString()}';
    }
  }

  Future<MovieDetail> getMovieDetails(int movieId) async {
    try {
      final response = await _dioClient.dio.get(
        '${ApiConstants.movieDetails}/$movieId',
        queryParameters: {'language': 'en-US'},
      );

      return MovieDetail.fromJson(response.data);
    } on DioException catch (e) {
      throw _dioClient.handleError(e);
    } catch (e) {
      throw 'An unexpected error occurred: ${e.toString()}';
    }
  }
}
