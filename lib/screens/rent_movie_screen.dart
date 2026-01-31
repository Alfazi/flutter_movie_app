import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/rental_controller.dart';
import '../data/models/movie_detail.dart';

class RentMovieScreen extends StatefulWidget {
  final MovieDetail movieDetail;

  const RentMovieScreen({super.key, required this.movieDetail});

  @override
  State<RentMovieScreen> createState() => _RentMovieScreenState();
}

class _RentMovieScreenState extends State<RentMovieScreen> {
  final RentalController _rentalController = Get.find<RentalController>();
  int _selectedDays = 1;
  final double _pricePerDay = 5000;

  @override
  Widget build(BuildContext context) {
    final totalPrice = _pricePerDay * _selectedDays;
    final returnDate = DateTime.now().add(Duration(days: _selectedDays));

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Rent Movie'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  if (widget.movieDetail.posterPath != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        'https://image.tmdb.org/t/p/w200${widget.movieDetail.posterPath}',
                        width: 80,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.movieDetail.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.movieDetail.releaseDate.split('-')[0]} • ${widget.movieDetail.runtime} min',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              widget.movieDetail.voteAverage.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Rental Duration',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDurationOptions(),
                  const SizedBox(height: 16),
                  _buildCustomDurationSlider(),
                ],
              ),
            ),

            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                    'Rental Duration',
                    '$_selectedDays ${_selectedDays == 1 ? 'Day' : 'Days'}',
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    'Price per Day',
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(_pricePerDay),
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    'Return Date',
                    DateFormat('dd MMM yyyy').format(returnDate),
                  ),
                  const Divider(height: 24, color: Colors.white24),
                  _buildSummaryRow(
                    'Total Price',
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(totalPrice),
                    isTotal: true,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(() => ElevatedButton(
                onPressed: _rentalController.isLoading.value ? null : _handleRent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _rentalController.isLoading.value
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                )
                    : Text(
                  'Rent for ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(totalPrice)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationOptions() {
    return Row(
      children: [
        _buildDurationChip(1),
        const SizedBox(width: 8),
        _buildDurationChip(3),
        const SizedBox(width: 8),
        _buildDurationChip(7),
        const SizedBox(width: 8),
        _buildDurationChip(14),
      ],
    );
  }

  Widget _buildDurationChip(int days) {
    final isSelected = _selectedDays == days;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedDays = days;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.amber : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.amber : Colors.white.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              Text(
                '$days',
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                days == 1 ? 'Day' : 'Days',
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDurationSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Or select custom duration',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        Slider(
          value: _selectedDays.toDouble(),
          min: 1,
          max: 30,
          divisions: 29,
          activeColor: Colors.amber,
          inactiveColor: Colors.white24,
          label: '$_selectedDays ${_selectedDays == 1 ? 'day' : 'days'}',
          onChanged: (value) {
            setState(() {
              _selectedDays = value.toInt();
            });
          },
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.amber : Colors.white70,
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? Colors.amber : Colors.white,
            fontSize: isTotal ? 20 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _handleRent() async {
    final success = await _rentalController.rentMovie(
      movieId: widget.movieDetail.id,
      movieTitle: widget.movieDetail.title,
      posterPath: widget.movieDetail.posterPath,
      rentalDays: _selectedDays,
    );

    if (success) {
      Get.back();
      Get.snackbar(
        'Success',
        'Movie rented successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );}
  }
}
