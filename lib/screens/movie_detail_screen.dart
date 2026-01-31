import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import '../data/models/movie_detail.dart';
import '../data/services/movie_service.dart';
import '../controllers/rental_controller.dart';
import 'rent_movie_screen.dart';

class MovieDetailScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailScreen({super.key, required this.movieId});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final MovieService _movieService = MovieService();
  final RentalController _rentalController = Get.find<RentalController>();
  MovieDetail? _movieDetail;
  bool _isLoading = true;
  String? _error;
  bool _isMovieRented = false;

  @override
  void initState() {
    super.initState();
    print('[MOVIE_DETAIL] Screen initialized for movie ID: ${widget.movieId}');
    _loadMovieDetails();
  }

  Future<void> _loadMovieDetails() async {
    print('[MOVIE_DETAIL] Loading movie details for ID: ${widget.movieId}');
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final movieDetail = await _movieService.getMovieDetails(widget.movieId);
      final isRented = await _rentalController.checkIfMovieRented(
        widget.movieId,
      );

      print(
        '[MOVIE_DETAIL] Movie details loaded successfully: ${movieDetail.title}',
      );
      print('[MOVIE_DETAIL] Movie rented status: $isRented');

      setState(() {
        _movieDetail = movieDetail;
        _isMovieRented = isRented;
        _isLoading = false;
      });
    } catch (e) {
      print('[MOVIE_DETAIL] Failed to load movie details: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: _isLoading
          ? _buildLoadingState()
          : _error != null
          ? _buildErrorState()
          : _buildDetailContent(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator(color: Colors.amber));
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMovieDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailContent() {
    if (_movieDetail == null) return const SizedBox();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: const Color(0xFF1E293B),
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                _movieDetail!.backdropPath != null
                    ? CachedNetworkImage(
                        imageUrl: _movieDetail!.backdropUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: Colors.grey[800]),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[800],
                          child: const Icon(Icons.movie, color: Colors.grey),
                        ),
                      )
                    : Container(
                        color: Colors.grey[800],
                        child: const Icon(Icons.movie, color: Colors.grey),
                      ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        const Color(0xFF0F172A).withOpacity(0.7),
                        const Color(0xFF0F172A),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _movieDetail!.posterPath != null
                          ? CachedNetworkImage(
                              imageUrl: _movieDetail!.posterUrl,
                              width: 120,
                              height: 180,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 120,
                                height: 180,
                                color: Colors.grey[800],
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.amber,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 120,
                                height: 180,
                                color: Colors.grey[800],
                                child: const Icon(
                                  Icons.movie,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : Container(
                              width: 120,
                              height: 180,
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.movie,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _movieDetail!.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_movieDetail!.tagline != null &&
                              _movieDetail!.tagline!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                _movieDetail!.tagline!,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.black,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _movieDetail!.voteAverage.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  ' / 10',
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_movieDetail!.voteCount} votes',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        Icons.access_time,
                        'Runtime',
                        _movieDetail!.runtimeFormatted,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        Icons.calendar_today,
                        'Release',
                        _movieDetail!.releaseDate.isNotEmpty
                            ? _movieDetail!.releaseDate.substring(0, 4)
                            : 'N/A',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        Icons.trending_up,
                        'Status',
                        _movieDetail!.status,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        Icons.language,
                        'Language',
                        _movieDetail!.originalLanguage.toUpperCase(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isMovieRented
                        ? null
                        : () {
                            Get.to(
                              () => RentMovieScreen(
                                movieDetail: _movieDetail!,
                              ),
                            );
                          },
                    icon: Icon(
                      _isMovieRented
                          ? Icons.check_circle
                          : Icons.movie_filter,
                    ),
                    label: Text(
                      _isMovieRented
                          ? 'Already Rented'
                          : 'Rent This Movie',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isMovieRented
                          ? Colors.grey
                          : Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_movieDetail!.genres.isNotEmpty) ...[
                  const Text(
                    'Genres',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _movieDetail!.genres.map((genre) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.amber.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          genre.name,
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
                const Text(
                  'Overview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _movieDetail!.overview.isNotEmpty
                      ? _movieDetail!.overview
                      : 'No overview available.',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                if (_movieDetail!.budget > 0 || _movieDetail!.revenue > 0) ...[
                  const Text(
                    'Financial Information',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_movieDetail!.budget > 0)
                    _buildFinancialRow(
                      'Budget',
                      '\$${_formatNumber(_movieDetail!.budget)}',
                    ),
                  if (_movieDetail!.revenue > 0)
                    _buildFinancialRow(
                      'Revenue',
                      '\$${_formatNumber(_movieDetail!.revenue)}',
                    ),
                  const SizedBox(height: 24),
                ],
                if (_movieDetail!.productionCompanies.isNotEmpty) ...[
                  const Text(
                    'Production Companies',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._movieDetail!.productionCompanies.map((company) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.business,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              company.name,
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.amber, size: 24),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(2)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(2)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(2)}K';
    }
    return number.toString();
  }
}
