class ApiConstants {
  static const String apiKey = String.fromEnvironment(
    'TMDB_API_KEY'
  );
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const String imageOriginalUrl = 'https://image.tmdb.org/t/p/original';
  static const String popularMovies = '/movie/popular';
  static const String searchMovies = '/search/movie';
  static const String movieDetails = '/movie';
}
