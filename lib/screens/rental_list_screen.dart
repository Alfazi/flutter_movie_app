import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/rental_controller.dart';
import '../controllers/auth_controller.dart';
import '../data/models/rental.dart';

class RentalListScreen extends StatefulWidget {
  const RentalListScreen({super.key});

  @override
  State<RentalListScreen> createState() => _RentalListScreenState();
}

class _RentalListScreenState extends State<RentalListScreen> {
  final RentalController _rentalController = Get.find<RentalController>();
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _rentalController.loadRentals();
    _rentalController.loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text('My Rentals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsSection(),
          Expanded(
            child: Obx(() {
              if (_rentalController.rentals.isEmpty) {
                return _buildEmptyState();
              }
              return _buildRentalList();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Obx(() {
      final stats = _rentalController.stats.value;
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Rentals',
                    '${stats['total'] ?? 0}',
                    Icons.movie_outlined,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Active',
                    '${stats['active'] ?? 0}',
                    Icons.play_circle_outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Returned',
                    '${stats['returned'] ?? 0}',
                    Icons.check_circle_outline,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Total Spent',
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format((stats['totalSpent'] ?? 0)),
                    Icons.payments_outlined,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.amber, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_outlined,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No rentals yet',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start renting movies to see them here',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Browse Movies'),
          ),
        ],
      ),
    );
  }

  Widget _buildRentalList() {
    return Obx(() => ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _rentalController.rentals.length,
      itemBuilder: (context, index) {
        final rental = _rentalController.rentals[index];
        return _buildRentalCard(rental);
      },
    ));
  }

  Widget _buildRentalCard(Rental rental) {
    final statusColor = _getStatusColor(rental.status);
    final statusIcon = _getStatusIcon(rental.status);
    final isActive = rental.status == RentalStatus.active;
    final daysRemaining = rental.returnDate.difference(DateTime.now()).inDays;

    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: () {
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (rental.posterPath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: 'https://image.tmdb.org/t/p/w200${rental.posterPath}',
                    width: 60,
                    height: 90,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.white10,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.white10,
                      child: const Icon(Icons.movie, color: Colors.white30),
                    ),
                  ),
                )
              else
                Container(
                  width: 60,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.movie, color: Colors.white30),
                ),
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rental.movieTitle,
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
                        Icon(statusIcon, color: statusColor, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          rental.status.toString().split('.').last.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Rented: ${DateFormat('dd MMM yyyy').format(rental.rentalDate)}',
                    ),
                    const SizedBox(height: 4),
                    _buildInfoRow(
                      Icons.event,
                      'Return: ${DateFormat('dd MMM yyyy').format(rental.returnDate)}',
                    ),
                    if (isActive && daysRemaining >= 0) ...[
                      const SizedBox(height: 4),
                      _buildInfoRow(
                        Icons.access_time,
                        '$daysRemaining ${daysRemaining == 1 ? 'day' : 'days'} remaining',
                        color: daysRemaining <= 2 ? Colors.orange : Colors.white70,
                      ),
                    ],
                    const SizedBox(height: 4),
                    _buildInfoRow(
                      Icons.payments,
                      NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(rental.totalPrice),
                      color: Colors.amber,
                    ),
                  ],
                ),
              ),
              
              if (isActive)
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        _showReturnDialog(rental);
                      },
                      icon: const Icon(Icons.assignment_return),
                      color: Colors.amber,
                      tooltip: 'Return Movie',
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color ?? Colors.white70),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: color ?? Colors.white70,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(RentalStatus status) {
    switch (status) {
      case RentalStatus.active:
        return Colors.green;
      case RentalStatus.expired:
        return Colors.red;
      case RentalStatus.returned:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(RentalStatus status) {
    switch (status) {
      case RentalStatus.active:
        return Icons.play_circle;
      case RentalStatus.expired:
        return Icons.error;
      case RentalStatus.returned:
        return Icons.check_circle;
    }
  }

  void _showReturnDialog(Rental rental) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Return Movie',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to return "${rental.movieTitle}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _rentalController.returnRental(rental.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            child: const Text('Return'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _authController.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
