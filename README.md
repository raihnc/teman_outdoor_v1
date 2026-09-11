# Teman Outdoor — Rental Alat Outdoor Makassar

Aplikasi Flutter (GetX) untuk rental alat camping/outdoor di Makassar.
Frontend dibangun sesuai PRD: katalog, booking, QRIS/tunai, wishlist,
rating, dan panel admin — dengan tema outdoor (hijau hutan, terracotta, cream),
responsif (mobile → tablet/desktop), dan animasi halus.

## Run

```bash
flutter pub get
flutter run
```

## Struktur

```
lib/
├── app/
│   ├── bindings/          # GetX dependency injection
│   ├── controllers/       # Auth, Catalog, Detail, Booking, Wishlist, Admin
│   ├── routes/            # Route name & definitions
│   └── theme/             # AppColors, AppTheme, breakpoints
├── core/
│   ├── constants/         # Konstanta, formatter Rupiah/tanggal, validators
│   └── widgets/           # ToolCard, StarRating, PrimaryButton, skeleton, dll
├── data/
│   ├── models/            # User, Tool, Booking, Review, Wishlist, PaymentMethod
│   └── repositories/      # Auth, Catalog, Booking, Wishlist, Review, Admin
└── ui/
    ├── splash/ auth/ home/ detail/ booking/ bookings/ wishlist/ profile/ admin/
```

## Status Frontend (per PRD)

- US-01 Registrasi & Login (email + password, verifikasi, pesan error ID)
- US-02 Katalog: grid responsif, search, filter kategori, skeleton loading
- US-03 Detail alat: galeri swipe, spesifikasi, pilih tanggal, cek ketersediaan, total auto
- US-04 & 05 Booking + Checkout: ringkasan, QRIS/Tunai, instruksi pembayaran
- US-06 & 07 Pickup & pengembalian: info toko, QR bukti booking, timeline status
- US-08 Rating & ulasan (bintang 1–5, maks 500 karakter)
- US-09 Wishlist (toggle hati, halaman wishlist)
- US-10 Admin: dashboard statistik, kelola status order, CRUD inventaris, kelola ulasan

## Backend (Firebase + Cloudinary + OneSignal)

Tanpa Cloud Functions — semua logika memakai Firestore rules + transaction
client (stok, `totalBooked`, agregasi rating), dan notifikasi real-time v1.0
menggunakan Firestore streams (fallback resmi PRD §5.2).

### Setup sekali saja

1. **Firebase**: aktifkan Authentication (Email/Password) + Cloud Firestore.
   Pastikan `android/app/google-services.json` & `lib/firebase_options.dart`
   cocok dengan project (`firebase init`).
2. **Cloudinary**: buat unsigned upload preset `teman_outdoor` (folder
   `teman_outdoor/`, JPG/WebP, max 5MB). Isi `CLOUDINARY_CLOUD_NAME` &
   `CLOUDINARY_UPLOAD_PRESET` di `.env` (lihat `.env.example`).
3. **OneSignal** (opsional untuk push ke device): daftarkan app, isi
   `ONESIGNAL_APP_ID` di `.env`. Jika kosong, OneSignal nonaktif dan app
   tetap berjalan normal. `external user id` = Firebase UID, tag `role`
   (`renter`/`admin`) disinkronkan otomatis saat login/logout.
4. **Admin account**: buat manual di Firebase Console → Authentication →
   tambah user → Firestore `users/{uid}` dengan `role: 'admin'`.

### Deploy rules & indexes

```bash
firebase login
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

### Integritas data (transaction client)

- Booking: transaction menulis booking `pending` + stok berkurang +
  `totalBooked` naik; stok dikembalikan saat cancel/returned.
- Ulasan: transaction menulis review + update `averageRating`/`totalReviews`
  produk + `booking.reviewed = true`.
- Real-time: daftar order renter & admin otomatis sinkron via stream;
  admin mendapat toast "Booking baru" untuk order `pending` baru.
- Security rules membatasi renter: update produk hanya pada agregat
  (stok/rating/popularitas), transisi booking hanya sesuai alur PRD.
