import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import '../data/models/movie.dart';
import '../data/services/movie_service.dart';
import 'movie_detail_screen.dart';
import 'rental_list_screen.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

enum SortOption {
  popularityDesc('Most Popular ↓', 'Most Popular First'),
  popularityAsc('Least Popular ↑', 'Least Popular First'),
  ratingDesc('Highest Rating ↓', 'Highest Rated First'),
  ratingAsc('Lowest Rating ↑', 'Lowest Rated First'),
  releaseDateDesc('Release Date ↓', 'Newest First'),
  releaseDateAsc('Release Date ↑', 'Oldest First'),
  titleAsc('Title A-Z', 'Alphabetical'),
  titleDesc('Title Z-A', 'Reverse Alphabetical');

  final String label;
  final String description;
  const SortOption(this.label, this.description);
}

class _MovieListScreenState extends State<MovieListScreen> {
  final MovieService _movieService = MovieService();
  final PagingController<int, Movie> _pagingController = PagingController(
    firstPageKey: 1,
  );
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  bool _isSearching = false;
  SortOption _currentSort = SortOption.popularityDesc;

  @override
  void initState() {
    super.initState();
    print('[MOVIE_LIST] Screen initialized');
    _pagingController.addPageRequestListener((pageKey) {
      print('[MOVIE_LIST] Page request listener triggered - Page: $pageKey');
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    print('[MOVIE_LIST] Fetching page $pageKey');
    print(
      '   ├─ Search query: "${_searchQuery.isEmpty ? "(empty - showing popular)" : _searchQuery}"',
    );
    print('   └─ Sort: ${_currentSort.label}');
    try {
      final movieResponse = _searchQuery.isEmpty
          ? await _movieService.getPopularMovies(pageKey)
          : await _movieService.searchMovies(_searchQuery, pageKey);

      var sortedResults = List<Movie>.from(movieResponse.results);
      print('[MOVIE_LIST] Applying sort: ${_currentSort.label}');
      _applySorting(sortedResults);

      final isLastPage = pageKey >= movieResponse.totalPages;
      print(
        '[MOVIE_LIST] Page status: ${isLastPage ? "Last page" : "More pages available"}',
      );

      if (isLastPage) {
        _pagingController.appendLastPage(sortedResults);
        print(
          '[MOVIE_LIST] Appended last page with ${sortedResults.length} movies',
        );
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(sortedResults, nextPageKey);
        print(
          '[MOVIE_LIST] Appended page with ${sortedResults.length} movies, next page: $nextPageKey',
        );
      }
    } catch (error) {
      print('[MOVIE_LIST] Error fetching page $pageKey: $error');
      _pagingController.error = error;
    }
  }

  void _applySorting(List<Movie> movies) {
    switch (_currentSort) {
      case SortOption.popularityDesc:
        movies.sort((a, b) => b.popularity.compareTo(a.popularity));
        break;
      case SortOption.popularityAsc:
        movies.sort((a, b) => a.popularity.compareTo(b.popularity));
        break;
      case SortOption.ratingDesc:
        movies.sort((a, b) => b.voteAverage.compareTo(a.voteAverage));
        break;
      case SortOption.ratingAsc:
        movies.sort((a, b) => a.voteAverage.compareTo(b.voteAverage));
        break;
      case SortOption.releaseDateDesc:
        movies.sort((a, b) => b.releaseDate.compareTo(a.releaseDate));
        break;
      case SortOption.releaseDateAsc:
        movies.sort((a, b) => a.releaseDate.compareTo(b.releaseDate));
        break;
      case SortOption.titleAsc:
        movies.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOption.titleDesc:
        movies.sort((a, b) => b.title.compareTo(a.title));
        break;
    }
  }

  void _changeSortOption(SortOption newSort) {
    print('[MOVIE_LIST] Changing sort option');
    print('   ├─ From: ${_currentSort.label}');
    print('   └─ To: ${newSort.label}');
    setState(() {
      _currentSort = newSort;
      _pagingController.refresh();
    });
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      Icon(Icons.sort, color: Colors.amber),
                      SizedBox(width: 12),
                      Text(
                        'Sort Movies By',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.grey),
                ...SortOption.values.map((option) {
                  final isSelected = _currentSort == option;
                  return ListTile(
                    leading: Icon(
                      _getSortIcon(option),
                      color: isSelected ? Colors.amber : Colors.grey,
                    ),
                    title: Text(
                      option.label,
                      style: TextStyle(
                        color: isSelected ? Colors.amber : Colors.white,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      option.description,
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.amber)
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      _changeSortOption(option);
                    },
                  );
                }).toList(),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getSortIcon(SortOption option) {
    switch (option) {
      case SortOption.popularityDesc:
      case SortOption.popularityAsc:
        return Icons.trending_up;
      case SortOption.ratingDesc:
      case SortOption.ratingAsc:
        return Icons.star;
      case SortOption.releaseDateDesc:
      case SortOption.releaseDateAsc:
        return Icons.calendar_today;
      case SortOption.titleAsc:
      case SortOption.titleDesc:
        return Icons.sort_by_alpha;
    }
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
      _pagingController.refresh();
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 80,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF1E293B),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(
                left: 16,
                bottom: 16,
                right: 16,
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      _isSearching ? 'Search Movies' : 'Movie Database',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Get.to(() => const RentalListScreen());
                    },
                    child: const Icon(
                      Icons.movie_filter,
                      color: Colors.amber,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isSearching = !_isSearching;
                        if (!_isSearching) {
                          _searchController.clear();
                          _performSearch('');
                        }
                      });
                    },
                    child: Icon(
                      _isSearching ? Icons.close : Icons.search,
                      size: 24,
                    ),
                  ),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFF1E293B), const Color(0xFF334155)],
                  ),
                ),
              ),
            ),
          ),
          if (_isSearching)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search for movies...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onSubmitted: _performSearch,
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    _getSortIcon(_currentSort),
                    color: Colors.amber,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sorted by: ${_currentSort.label}',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _showSortOptions,
                    icon: const Icon(Icons.tune, size: 16, color: Colors.amber),
                    label: const Text(
                      'Change',
                      style: TextStyle(color: Colors.amber, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          PagedSliverList<int, Movie>(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<Movie>(
              itemBuilder: (context, movie, index) =>
                  _buildMovieCard(context, movie),
              firstPageErrorIndicatorBuilder: (context) =>
                  _buildErrorIndicator(),
              newPageErrorIndicatorBuilder: (context) => _buildErrorIndicator(),
              firstPageProgressIndicatorBuilder: (context) =>
                  _buildLoadingIndicator(),
              newPageProgressIndicatorBuilder: (context) =>
                  _buildLoadingIndicator(),
              noItemsFoundIndicatorBuilder: (context) => _buildNoItemsFound(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieCard(BuildContext context, Movie movie) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailScreen(movieId: movie.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: movie.posterPath != null
                  ? CachedNetworkImage(
                      imageUrl: movie.posterUrl,
                      width: 120,
                      height: 180,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 120,
                        height: 180,
                        color: Colors.grey[800],
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.amber),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 120,
                        height: 180,
                        color: Colors.grey[800],
                        child: const Icon(Icons.movie, color: Colors.grey),
                      ),
                    )
                  : Container(
                      width: 120,
                      height: 180,
                      color: Colors.grey[800],
                      child: const Icon(Icons.movie, color: Colors.grey),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.grey,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          movie.releaseDate.isNotEmpty
                              ? movie.releaseDate.substring(0, 4)
                              : 'N/A',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          movie.voteAverage.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${movie.voteCount})',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movie.overview,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorIndicator() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              _pagingController.error.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _pagingController.refresh(),
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

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(color: Colors.amber),
      ),
    );
  }

  Widget _buildNoItemsFound() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, color: Colors.grey, size: 60),
            const SizedBox(height: 16),
            const Text(
              'No movies found',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty
                  ? 'No popular movies available'
                  : 'Try searching for something else',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
