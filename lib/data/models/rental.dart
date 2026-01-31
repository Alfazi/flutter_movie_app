class Rental {
  final String id;
  final int movieId;
  final String movieTitle;
  final String? posterPath;
  final DateTime rentalDate;
  final int rentalDays;
  final double totalPrice;
  final String userId;
  final RentalStatus status;

  Rental({
    required this.id,
    required this.movieId,
    required this.movieTitle,
    this.posterPath,
    required this.rentalDate,
    required this.rentalDays,
    required this.totalPrice,
    required this.userId,
    this.status = RentalStatus.active,
  });

  DateTime get returnDate => rentalDate.add(Duration(days: rentalDays));
  
  bool get isExpired => DateTime.now().isAfter(returnDate);

  factory Rental.fromJson(Map<String, dynamic> json) {
    return Rental(
      id: json['id'],
      movieId: json['movieId'],
      movieTitle: json['movieTitle'],
      posterPath: json['posterPath'],
      rentalDate: DateTime.parse(json['rentalDate']),
      rentalDays: json['rentalDays'],
      totalPrice: (json['totalPrice'] as num).toDouble(),
      userId: json['userId'],
      status: RentalStatus.values.firstWhere(
        (e) => e.toString() == 'RentalStatus.${json['status']}',
        orElse: () => RentalStatus.active,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movieId': movieId,
      'movieTitle': movieTitle,
      'posterPath': posterPath,
      'rentalDate': rentalDate.toIso8601String(),
      'rentalDays': rentalDays,
      'totalPrice': totalPrice,
      'userId': userId,
      'status': status.toString().split('.').last,
    };
  }

  Rental copyWith({
    String? id,
    int? movieId,
    String? movieTitle,
    String? posterPath,
    DateTime? rentalDate,
    int? rentalDays,
    double? totalPrice,
    String? userId,
    RentalStatus? status,
  }) {
    return Rental(
      id: id ?? this.id,
      movieId: movieId ?? this.movieId,
      movieTitle: movieTitle ?? this.movieTitle,
      posterPath: posterPath ?? this.posterPath,
      rentalDate: rentalDate ?? this.rentalDate,
      rentalDays: rentalDays ?? this.rentalDays,
      totalPrice: totalPrice ?? this.totalPrice,
      userId: userId ?? this.userId,
      status: status ?? this.status,
    );
  }
}

enum RentalStatus {
  active,
  expired,
  returned,
}
