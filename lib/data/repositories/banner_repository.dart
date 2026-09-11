import '../models/banner_model.dart';
import '../services/firestore_service.dart';

class BannerRepository {
  final FirestoreService _firestoreService;

  BannerRepository(this._firestoreService);

  Future<List<BannerModel>> getActiveBanners() async {
    final snapshot = await _firestoreService.getActiveBanners();
    return snapshot.docs
        .map((doc) => BannerModel.fromFirestore(doc))
        .toList();
  }

  Future<void> createBanner(Map<String, dynamic> data) async {
    await _firestoreService.createBanner(data);
  }

  Future<void> updateBanner(String id, Map<String, dynamic> data) async {
    await _firestoreService.updateBanner(id, data);
  }

  Future<void> deleteBanner(String id) async {
    await _firestoreService.deleteBanner(id);
  }
}
