class FirestoreConstants {
  FirestoreConstants._();

  static const usersCollection = 'users';
  static const productsCollection = 'products';
  static const bookingsCollection = 'bookings';
  static const reviewsCollection = 'reviews';
  static const bannersCollection = 'banners';
  static const categoriesCollection = 'categories';
  static const appConfigCollection = 'app_config';
  static const wishlistSubcollection = 'wishlist';

  static const roleRenter = 'renter';
  static const roleAdmin = 'admin';

  static const statusPending = 'pending';
  static const statusConfirmed = 'confirmed';
  static const statusReadyForPickup = 'ready_for_pickup';
  static const statusPickedUp = 'picked_up';
  static const statusReturned = 'returned';
  static const statusCompleted = 'completed';
  static const statusCancelled = 'cancelled';

  static const statusOrder = [
    statusPending,
    statusConfirmed,
    statusReadyForPickup,
    statusPickedUp,
    statusReturned,
    statusCompleted,
  ];

  static String statusLabel(String status) {
    return switch (status) {
      'pending' => 'Menunggu',
      'confirmed' => 'Dikonfirmasi',
      'ready_for_pickup' => 'Siap Diambil',
      'picked_up' => 'Sudah Diambil',
      'returned' => 'Dikembalikan',
      'completed' => 'Selesai',
      'cancelled' => 'Dibatalkan',
      _ => status,
    };
  }
}
