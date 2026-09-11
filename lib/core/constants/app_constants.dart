import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  AppConstants._();

  static const appName = 'Teman Outdoor';
  static const appVersion = '1.0.0';

  static const defaultPageSize = 20;
  static const maxReviewPhotos = 3;
  static const maxNoteLength = 200;
  static const maxReviewLength = 500;
  static const imageMaxWidth = 1080;
  static const imageMaxSizeBytes = 5 * 1024 * 1024;

  static String get cloudinaryCloudName =>
      dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? 'sstlrolu';
  static String get cloudinaryUploadPreset =>
      dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? 'teman_outdoor';

  static String get onesignalAppId =>
      dotenv.env['ONESIGNAL_APP_ID'] ?? 'cde7dd4d-a2d8-4c25-b622-0685c1ddae65';

  static const storeName = 'Teman Outdoor Makassar';
  static const storeAddress =
      'Jl. Sukaria 5 No.25, Tamamaung, Kec. Panakukkang, Kota Makassar, Sulawesi Selatan 90231';
  static const storePhone = '+62 822-6787-1211';
  static const operatingHours = '08:00 - 23:30 WITA';
}
