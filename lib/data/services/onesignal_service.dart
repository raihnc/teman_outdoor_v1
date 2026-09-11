import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../../core/constants/app_constants.dart';

/// Pembungkus OneSignal SDK. Semua method no-op jika ONESIGNAL_APP_ID
/// kosong, sehingga aplikasi tetap berjalan tanpa konfigurasi push.
class OneSignalService {
  OneSignalService._();

  static bool _initialized = false;

  static Future<void> initialize() async {
    final appId = AppConstants.onesignalAppId;
    if (appId.isEmpty || _initialized) return;
    OneSignal.initialize(appId);
    _initialized = true;
  }

  /// Panggil setelah login. Menautkan perangkat ke uid Firebase agar
  /// notifikasi bisa di-target per user.
  static Future<void> login(String externalUserId) async {
    if (!_initialized) return;
    await OneSignal.login(externalUserId);
    await OneSignal.Notifications.requestPermission(true);
  }

  /// Tag role dipakai untuk segmentasi admin vs renter di dashboard OneSignal.
  static Future<void> setRoleTag(String role) async {
    if (!_initialized) return;
    await OneSignal.User.addTagWithKey('role', role);
  }

  static Future<void> logout() async {
    if (!_initialized) return;
    await OneSignal.User.removeTag('role');
    await OneSignal.logout();
  }
}
