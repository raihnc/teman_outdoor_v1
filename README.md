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

## Catatan Integrasi

- Firebase: Auth + Firestore langsung dari repository (collection:
  `users`, `tools`, `bookings`, `reviews`, `wishlists`).
- QRIS statis: ganti placeholder ikon QR di `payment_view.dart` dengan URL
  gambar QR dari Cloudinary.
- Foto alat untuk now via URL; integrasi upload Cloudinary menyusul.
- OneSignal/Cloudinary/loading_indicator sudah ada di pubspec (aktivasi backend menyusul).
