class MovieDetail {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String overview;
  final double voteAverage;
  final int voteCount;
  final String releaseDate;
  final List<Genre> genres;
  final int runtime;
  final String status;
  final int budget;
  final int revenue;
  final String? tagline;
  final List<ProductionCompany> productionCompanies;
  final double popularity;
  final bool adult;
  final String originalLanguage;

  MovieDetail({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.overview,
    required this.voteAverage,
    required this.voteCount,
    required this.releaseDate,
    required this.genres,
    required this.runtime,
    required this.status,
    required this.budget,
    required this.revenue,
    this.tagline,
    required this.productionCompanies,
    required this.popularity,
    required this.adult,
    required this.originalLanguage,
  });

  factory MovieDetail.fromJson(Map<String, dynamic> json) {
    return MovieDetail(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      overview: json['overview'] ?? '',
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
      releaseDate: json['release_date'] ?? '',
      genres: json['genres'] != null
          ? (json['genres'] as List).map((e) => Genre.fromJson(e)).toList()
          : [],
      runtime: json['runtime'] ?? 0,
      status: json['status'] ?? '',
      budget: json['budget'] ?? 0,
      revenue: json['revenue'] ?? 0,
      tagline: json['tagline'],
      productionCompanies: json['production_companies'] != null
          ? (json['production_companies'] as List)
                .map((e) => ProductionCompany.fromJson(e))
                .toList()
          : [],
      popularity: (json['popularity'] ?? 0).toDouble(),
      adult: json['adult'] ?? false,
      originalLanguage: json['original_language'] ?? '',
    );
  }

  String get posterUrl =>
      posterPath != null ? 'https://image.tmdb.org/t/p/w500$posterPath' : '';

  String get backdropUrl => backdropPath != null
      ? 'https://image.tmdb.org/t/p/original$backdropPath'
      : '';

  String get runtimeFormatted {
    final hours = runtime ~/ 60;
    final minutes = runtime % 60;
    return '${hours}h ${minutes}m';
  }
}

class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class ProductionCompany {
  final int id;
  final String name;
  final String? logoPath;
  final String originCountry;

  ProductionCompany({
    required this.id,
    required this.name,
    this.logoPath,
    required this.originCountry,
  });

  factory ProductionCompany.fromJson(Map<String, dynamic> json) {
    return ProductionCompany(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      logoPath: json['logo_path'],
      originCountry: json['origin_country'] ?? '',
    );
  }
}
