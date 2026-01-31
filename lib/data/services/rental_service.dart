import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rental.dart';

class RentalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'rentals';

  Future<Rental> createRental({
    required int movieId,
    required String movieTitle,
    String? posterPath,
    required int rentalDays,
    required String userId,
  }) async {
    print('[RENTAL_SERVICE] Creating rental for movie: $movieTitle');
    print('   ├─ Movie ID: $movieId');
    print('   ├─ Rental Days: $rentalDays');
    print('   ├─ User ID: $userId');
    
    try {
      const pricePerDay = 5000.0;
      final totalPrice = pricePerDay * rentalDays;
      
      final rental = Rental(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        movieId: movieId,
        movieTitle: movieTitle,
        posterPath: posterPath,
        rentalDate: DateTime.now(),
        rentalDays: rentalDays,
        totalPrice: totalPrice,
        userId: userId,
        status: RentalStatus.active,
      );

      await _firestore.collection(_collection).doc(rental.id).set(rental.toJson());
      
      print('[RENTAL_SERVICE] Rental created successfully');
      print('   ├─ Rental ID: ${rental.id}');
      print('   ├─ Total Price: Rp ${totalPrice.toStringAsFixed(0)}');
      print('   └─ Return Date: ${rental.returnDate}');
      
      return rental;
    } catch (e) {
      print('[RENTAL_SERVICE] Error creating rental: $e');
      throw 'Failed to create rental: $e';
    }
  }

  Stream<List<Rental>> getUserRentals(String userId) {
    print('[RENTAL_SERVICE] Getting rentals for user: $userId');
    
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('rentalDate', descending: true)
        .snapshots()
        .map((snapshot) {
      final rentals = snapshot.docs
          .map((doc) => Rental.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      
      print('[RENTAL_SERVICE] Found ${rentals.length} rental(s)');
      for (var rental in rentals) {
        print('   ├─ ${rental.movieTitle} - ${rental.status.toString().split('.').last}');
      }
      
      return rentals;
    });
  }

  Stream<List<Rental>> getActiveRentals(String userId) {
    print('[RENTAL_SERVICE] Getting active rentals for user: $userId');
    
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .orderBy('rentalDate', descending: true)
        .snapshots()
        .map((snapshot) {
      final rentals = snapshot.docs
          .map((doc) => Rental.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      
      print('[RENTAL_SERVICE] Found ${rentals.length} active rental(s)');
      
      return rentals;
    });
  }

  Future<void> updateRentalStatus(String rentalId, RentalStatus status) async {
    print('[RENTAL_SERVICE] Updating rental status');
    print('   ├─ Rental ID: $rentalId');
    print('   └─ New Status: ${status.toString().split('.').last}');
    
    try {
      await _firestore.collection(_collection).doc(rentalId).update({
        'status': status.toString().split('.').last,
      });
      
      print('[RENTAL_SERVICE] Rental status updated successfully');
    } catch (e) {
      print('[RENTAL_SERVICE] Error updating rental status: $e');
      throw 'Failed to update rental: $e';
    }
  }

  Future<void> returnRental(String rentalId) async {
    print('[RENTAL_SERVICE] Returning rental: $rentalId');
    await updateRentalStatus(rentalId, RentalStatus.returned);
  }

  Future<bool> isMovieRented(int movieId, String userId) async {
    print('[RENTAL_SERVICE] Checking if movie $movieId is rented by user $userId');
    
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('movieId', isEqualTo: movieId)
          .where('status', isEqualTo: 'active')
          .get();

      final isRented = snapshot.docs.isNotEmpty;
      print('[RENTAL_SERVICE] Movie rented: $isRented');
      
      return isRented;
    } catch (e) {
      print('[RENTAL_SERVICE] Error checking rental: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getRentalStats(String userId) async {
    print('[RENTAL_SERVICE] Getting rental statistics for user: $userId');
    
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      final rentals = snapshot.docs
          .map((doc) => Rental.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      final activeCount = rentals.where((r) => r.status == RentalStatus.active).length;
      final totalSpent = rentals.fold<double>(0, (previousValue, r) => previousValue + r.totalPrice);
      
      final stats = {
        'total': rentals.length,
        'active': activeCount,
        'returned': rentals.where((r) => r.status == RentalStatus.returned).length,
        'expired': rentals.where((r) => r.status == RentalStatus.expired).length,
        'totalSpent': totalSpent,
      };
      
      print('[RENTAL_SERVICE] Rental Statistics:');
      print('   ├─ Total Rentals: ${stats['total']}');
      print('   ├─ Active: ${stats['active']}');
      print('   ├─ Returned: ${stats['returned']}');
      print('   ├─ Expired: ${stats['expired']}');
      print('   └─ Total Spent: Rp ${stats['totalSpent']}');
      
      return stats;
    } catch (e) {
      print('[RENTAL_SERVICE] Error getting stats: $e');
      return {
        'total': 0,
        'active': 0,
        'returned': 0,
        'expired': 0,
        'totalSpent': 0.0,
      };
    }
  }
}
