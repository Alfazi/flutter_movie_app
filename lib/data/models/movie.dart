class Movie {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String overview;
  final double voteAverage;
  final int voteCount;
  final String releaseDate;
  final List<int> genreIds;
  final double popularity;
  final bool adult;
  final String originalLanguage;
  final String originalTitle;

  Movie({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.overview,
    required this.voteAverage,
    required this.voteCount,
    required this.releaseDate,
    required this.genreIds,
    required this.popularity,
    required this.adult,
    required this.originalLanguage,
    required this.originalTitle,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      overview: json['overview'] ?? '',
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
      releaseDate: json['release_date'] ?? '',
      genreIds: json['genre_ids'] != null
          ? List<int>.from(json['genre_ids'])
          : [],
      popularity: (json['popularity'] ?? 0).toDouble(),
      adult: json['adult'] ?? false,
      originalLanguage: json['original_language'] ?? '',
      originalTitle: json['original_title'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'overview': overview,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'release_date': releaseDate,
      'genre_ids': genreIds,
      'popularity': popularity,
      'adult': adult,
      'original_language': originalLanguage,
      'original_title': originalTitle,
    };
  }

  String get posterUrl =>
      posterPath != null ? 'https://image.tmdb.org/t/p/w500$posterPath' : '';

  String get backdropUrl => backdropPath != null
      ? 'https://image.tmdb.org/t/p/original$backdropPath'
      : '';
}
