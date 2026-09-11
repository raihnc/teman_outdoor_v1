# PRD — Teman Outdoor: Rental Alat Camping Makassar

> **Versi**: 1.0 · **Tanggal**: 2026-09-10 · **Status**: Draft
> **Platform**: Flutter (Android + iOS) · **Backend**: Firebase · **Status Management**: GetX


---

## 1. Ringkasan Eksekutif

### Pernyataan Masalah

Pendaki dan penggemar outdoor di Makassar tidak memiliki platform terpusat untuk menyewa alat camping berkualitas. Proses saat ini bergantung pada rekomendasi mulut ke mulut, DM Instagram, atau Brosur fisik — yang menghasilkan **visibility rendah** bagi pemilik rental dan **pengalaman buruk** bagi penyewa (ketidakjelasan harga, ketersediaan stok, dan mekanisme pengambilan).

### Solusi yang Diusulkan

**Teman Outdoor** — aplikasi mobile yang menghubungkan penyewa alat camping di Makassar dengan satu toko rental. Penyewa bisa menelusuri katalog, memeriksa ketersediaan, melakukan booking, dan melakukan pembayaran cash saat pengambilan di toko. Admin mengelola semua data (produk, order, ulasan) melalui panel admin khusus di dalam aplikasi.

### Kriteria Keberhasilan

| KPI | Target | Metrik |
|-----|--------|--------|
| Akuisisi pengguna | 500 pemasangan dalam 3 bulan pertama | Firebase Analytics — `install` events |
| Konversi booking | ≥ 25% dari pengguna yang membuka detail produk | Funnel: `view_product` → `create_booking` |
| Retensi pengguna | ≥ 30% pengguna kembali dalam 14 hari | Firebase Analytics — retention cohort |
| Waktu respons order | ≤ 2 jam (jam operasional 08:00–21:00 WITA) | Admin dashboard — order timestamp delta |
| Rating rata-rata | ≥ 4.5 / 5.0 | Firestore collection `reviews` |

---

## 2. Pengalaman Pengguna & Fungsitalitas

### Persona Pengguna

| Persona | Deskripsi | Kebutuhan Utama |
|---------|-----------|-----------------|
| **Penyewa (Renter)** | Mahasiswa/pekerja Makassar (18–35 th), suka camping/hiking, budget-conscious | Katalog lengkap, harga transparan, booking mudah |
| **Admin/Toko** | Pemilik toko rental, mengelola produk dan order secara manual | CRUD produk, kelola status order, lihat ulasan |

### Cerita Pengguna (User Stories)

#### S1 — Autentikasi Pengguna
> **As a** penyewa,
> **I want to** mendaftar dan masuk menggunakan email + password atau Google Sign-In,
> **so that** saya bisa melakukan booking tanpa perlu verifikasi manual.

**Kriteria Penerimaan:**
- [ ] Registrasi dengan email + password (minimal 6 karakter)
- [ ] Login dengan email + password
- [ ] Password reset via email
- [ ] Session persist (tidak perlu login ulang setiap buka app)
- [ ] Data user tersimpan di Firestore collection `users` dengan field: `uid`, `name`, `email`, `phone`, `photoUrl`, `role` (`renter`/`admin`), `createdAt`
- [ ] Profile screen menampilkan data user dari Firestore

#### S2 — Halaman Beranda
> **As a** penyewa,
> **I want to** melihat halaman beranda dengan banner promosi, kategori populer, dan rekomendasi alat,
> **so that** saya bisa cepat menemukan alat yang saya butuhkan.

**Kriteria Penerimaan:**
- [ ] Carousel banner (maks 5 gambar) — data dari Firestore `banners`
- [ ] Horizontal scroll kategori chips (Tenda, Sleeping Bag, Kompor, dll)
- [ ] Section "Popular Items" — 6 item terlaris
- [ ] Section "Baru Ditambahkan" — 6 item terbaru
- [ ] Search bar di bagian atas → navigasi ke halaman pencarian
- [ ] Bottom navigation: Home, Kategori, Pesanan, Profil
- [ ] Shimmer loading state saat data belum loaded

#### S3 — Katalog & Pencarian
> **As a** penyewa,
> **I want to** menelusuri seluruh alat rental berdasarkan kategori, pencarian, atau urutan harga,
> **so that** saya bisa membandingkan dan memilih alat yang tepat.

**Kriteria Penerimaan:**
- [ ] Grid layout 2 kolom untuk item katalog
- [ ] Setiap card menampilkan: gambar utama (Cloudinary URL), nama, harga/hari, badge stok
- [ ] Filter by kategori (chips/tabs)
- [ ] Search by nama alat (Firestore `orderBy` + client-side filter)
- [ ] Sort: Harga rendah→tinggi, tinggi→rendah, terbaru, terlaris
- [ ] Infinite scroll / pagination (limit 20 per page)
- [ ] Badge "Stok Habis" untuk item tidak tersedia
- [ ] Empty state dengan ilustrasi jika hasil pencarian kosong

#### S4 — Detail Produk
> **As a** penyewa,
> **I want to** melihat detail lengkap alat (gambar, deskripsi, harga, spesifikasi, ulasan),
> **so that** saya bisa memutuskan untuk menyewa.

**Kriteria Penerimaan:**
- [ ] Image carousel (swipeable) — semua foto dari field `images[]`
- [ ] Nama produk, deskripsi lengkap
- [ ] Harga per hari (Rp format Indonesia) — **default: 1 hari**
- [ ] Spesifikasi: berat, kapasitas, warna, kondisi
- [ ] Stok tersedia: `stock` field — tampilkan jumlah
- [ ] Tombol "Sewa Sekarang" → bottom sheet pilih tanggal & durasi
- [ ] Tombol "Tambah ke Wishlist" (love icon)
- [ ] Section ulasan: rating bintang, komentar, foto (jika ada)
- [ ] Rata-rata rating + jumlah total ulasan

#### S5 — Booking / Pemesanan
> **As a** penyewa,
> **I want to** melakukan pemesanan dengan memilih tanggal pengambilan dan durasi sewa,
> **so that** alat disiapkan saat saya datang ke toko.

**Kriteria Penerimaan:**
- [ ] Bottom sheet / screen booking:
  - Pilih tanggal pengambilan (date picker, minimal hari ini + 1)
  - Pilih durasi: 1 hari / 2 hari / 3 hari / 5 hari / 7 hari / Custom
  - Jumlah unit (jika stok > 1)
- [ ] Ringkasan booking: item, tanggal, durasi, total harga
- [ ] Total = `pricePerDay × duration × quantity`
- [ ] Catatan tambahan (opsional, max 200 karakter)
- [ ] Konfirmasi booking → buat document di Firestore `bookings`
- [ ] Status awal: `pending`
- [ ] Notifikasi push ke admin (OneSignal) saat booking baru
- [ ] Booking tersedia di tab "Pesanan" pengguna

#### S6 — Manajemen Pesanan (Penyewa)
> **As a** penyewa,
> **I want to** melihat riwayat dan status pesanan saya,
> **so that** saya tahu kapan harus datang ke toko.

**Kriteria Penerimaan:**
- [ ] Tab Pesanan: filter "Aktif" dan "Riwayat"
- [ ] Setiap card order menampilkan: nama item, tanggal, status, total
- [ ] Status: `pending` → `confirmed` → `ready_for_pickup` → `picked_up` → `returned` → `completed` / `cancelled`
- [ ] Detail order: info lengkap + status timeline
- [ ] Bisa membatalkan pesanan jika status `pending` atau `confirmed`
- [ ] Tombol "Sudah Diambil" muncul saat status `ready_for_pickup`
- [ ] Tombol "Kembalikan" muncul saat status `picked_up`

#### S7 — Ulasan & Rating
> **As a** penyewa,
> **I want to** memberikan ulasan dan rating setelah pengembalian alat,
> **so that** saya bisa membantu penyewa lain memilih alat yang bagus.

**Kriteria Penerimaan:**
- [ ] Form ulasan muncul setelah order status `completed`
- [ ] Rating: 1–5 bintang (wajib)
- [ ] Teks komentar (opsional, max 500 karakter)
- [ ] Foto ulasan (opsional, maks 3 foto via Cloudinary)
- [ ] Ulasan tersimpan di Firestore `reviews` dengan field: `bookingId`, `userId`, `itemId`, `rating`, `comment`, `photos[]`, `createdAt`
- [ ] Rata-rata rating di detail produk otomatis ter-update

#### S8 — Wishlist
> **As a** penyewa,
> **I want to** menyimpan item favorit ke wishlist,
> **so that** saya bisa cepat mengaksesnya nanti.

**Kriteria Penerimaan:**
- [ ] Toggle wishlist di detail produk (love icon filled/outline)
- [ ] Wishlist tersimpan di subcollection `users/{uid}/wishlist` atau field `wishlistItems[]`
- [ ] Halaman Wishlist: grid item tersimpan
- [ ] Bisa langsung booking dari halaman Wishlist

#### S9 — Profil Pengguna
> **As a** penyewa,
> **I want to** mengelola profil saya (nama, telepon, foto),
> **so that** data saya benar untuk keperluan booking.

**Kriteria Penerimaan:**
- [ ] Lihat & edit: nama, nomor telepon, foto profil (upload via Cloudinary)
- [ ] Logout
- [ ] Info aplikasi: versi, kontak admin, alamat toko
- [ ] Tombol "Hubungi Admin" → WhatsApp deep link (opsional, v1.1)

#### S10 — Panel Admin (dalam Aplikasi)
> **As a** admin/toko,
> **I want to** mengelola produk, order, dan melihat ulasan dari dalam aplikasi,
> **so that** saya tidak perlu akses Firebase console.

**Kriteria Penerimaan:**
- [ ] Role-based access: hanya user dengan `role: 'admin'` yang bisa mengakses
- [ ] **Manajemen Produk:**
  - List semua produk dengan search
  - Tambah produk: nama, deskripsi, harga/hari, stok, kategori, foto (upload Cloudinary), spesifikasi
  - Edit produk
  - Nonaktifkan/hapus produk (soft delete: `isActive: false`)
- [ ] **Manajemen Order:**
  - List semua order, filter by status
  - Ubah status order (manual: pending → confirmed → ready_for_pickup → picked_up → returned → completed / cancelled)
  - Detail order: info penyewa, item, total, catatan
- [ ] **Manajemen Banner:**
  - Tambah/edit/hapus banner (gambar Cloudinary, link/aksi)
- [ ] **Dashboard Ringkas (opsional v1.1):**
  - Jumlah order hari ini, total revenue bulan ini, rating rata-rata
- [ ] **Kelola Ulasan:**
  - Lihat semua ulasan
  - Hapus ulasan yang tidak pantas

### Bukan Tujuan (Out of Scope v1.0)

- ❌ Payment gateway online (Midtrans, Xendit, QRIS) — cash only
- ❌ Sistem antar-jemput (delivery) — self pickup only
- ❌ Multi-vendor/marketplace
- ❌ Chat real-time antar pengguna dan admin
- ❌ Peta lokasi toko (Google Maps integration) — v1.1
- ❌ Push notification untuk reminder pengembalian — v1.1
- ❌ Sistem promo/coupon — v1.1
- ❌ Web admin panel — admin di dalam mobile app
- ❌ Multi-bahasa (hanya Bahasa Indonesia)
- ❌ Offline mode / caching offline

---

## 3. Spesifikasi Teknis

### 3.1 Tinjauan Arsitektur

```
┌──────────────────────────────────────────────────────┐
│                    Flutter App                        │
├──────────────────────────────────────────────────────┤
│  UI Layer (GetX View + Widget)                       │
│  ├─ features/                                        │
│  │   ├─ auth/          (views, controllers)          │
│  │   ├─ home/          (views, controllers)          │
│  │   ├─ catalog/       (views, controllers)          │
│  │   ├─ product_detail/(views, controllers)          │
│  │   ├─ booking/       (views, controllers)          │
│  │   ├─ orders/        (views, controllers)          │
│  │   ├─ wishlist/      (views, controllers)          │
│  │   ├─ reviews/       (views, controllers)          │
│  │   ├─ profile/       (views, controllers)          │
│  │   └─ admin/         (views, controllers)          │
│  ├─ core/                (theme, widgets, routes,    │
│  │                        constants, utils)           │
│  └─ data/                (models, services,          │
│                           repositories)              │
├──────────────────────────────────────────────────────┤
│  Data Layer                                          │
│  ├─ services/                                       │
│  │   ├─ firebase_auth_service.dart                   │
│  │   ├─ firestore_service.dart                       │
│  │   └─ cloudinary_service.dart                      │
│  ├─ repositories/                                    │
│  │   ├─ auth_repository.dart                         │
│  │   ├─ product_repository.dart                      │
│  │   ├─ booking_repository.dart                      │
│  │   ├─ review_repository.dart                       │
│  │   ├─ wishlist_repository.dart                     │
│  │   └─ banner_repository.dart                       │
│  └─ models/                                         │
│      ├─ user_model.dart                              │
│      ├─ product_model.dart                           │
│      ├─ booking_model.dart                           │
│      ├─ review_model.dart                            │
│      └─ banner_model.dart                            │
└──────────────────────────────────────────────────────┘
          │                    │
          ▼                    ▼
┌─────────────────┐  ┌─────────────────┐
│  Firebase        │  │  Cloudinary      │
│  ├─ Auth         │  │  Upload images   │
│  ├─ Firestore    │  │
│  └─ Analytics    │  │                  │
└─────────────────┘  └─────────────────┘
```

### 3.2 Struktur Project (Featured-First + GetX)

```
lib/
├── main.dart
├── firebase_options.dart
│
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── product_model.dart
│   │   ├── booking_model.dart
│   │   ├── review_model.dart
│   │   ├── banner_model.dart
│   │   └── category_model.dart
│   ├── services/
│   │   ├── firebase_auth_service.dart
│   │   ├── firestore_service.dart
│   │   └── cloudinary_service.dart
│   └── repositories/
│       ├── auth_repository.dart
│       ├── product_repository.dart
│       ├── booking_repository.dart
│       ├── review_repository.dart
│       ├── wishlist_repository.dart
│       └── banner_repository.dart
│
├── core/
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── app_colors.dart
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── firestore_constants.dart
│   ├── routes/
│   │   ├── app_routes.dart
│   │   └── app_pages.dart
│   ├── widgets/
│   │   ├── product_card.dart
│   │   ├── custom_button.dart
│   │   ├── custom_text_field.dart
│   │   ├── shimmer_loading.dart
│   │   ├── empty_state.dart
│   │   ├── star_rating.dart
│   │   └── status_badge.dart
│   └── utils/
│       ├── currency_formatter.dart
│       └── date_formatter.dart
│
└── features/
    ├── auth/
    │   ├── views/
    │   │   ├── login_view.dart
    │   │   ├── register_view.dart
    │   │   └── forgot_password_view.dart
    │   └── controllers/
    │       └── auth_controller.dart
    ├── home/
    │   ├── views/
    │   │   └── home_view.dart
    │   └── controllers/
    │       └── home_controller.dart
    ├── catalog/
    │   ├── views/
    │   │   ├── catalog_view.dart
    │   │   └── search_view.dart
    │   └── controllers/
    │       └── catalog_controller.dart
    ├── product_detail/
    │   ├── views/
    │   │   └── product_detail_view.dart
    │   └── controllers/
    │       └── product_detail_controller.dart
    ├── booking/
    │   ├── views/
    │   │   ├── booking_sheet.dart
    │   │   └── booking_confirmation_view.dart
    │   └── controllers/
    │       └── booking_controller.dart
    ├── orders/
    │   ├── views/
    │   │   ├── orders_view.dart
    │   │   └── order_detail_view.dart
    │   └── controllers/
    │       └── orders_controller.dart
    ├── wishlist/
    │   ├── views/
    │   │   └── wishlist_view.dart
    │   └── controllers/
    │       └── wishlist_controller.dart
    ├── reviews/
    │   ├── views/
    │   │   └── review_form_view.dart
    │   └── controllers/
    │       └── review_controller.dart
    ├── profile/
    │   ├── views/
    │   │   ├── profile_view.dart
    │   │   └── edit_profile_view.dart
    │   └── controllers/
    │       └── profile_controller.dart
    └── admin/
        ├── views/
        │   ├── admin_dashboard_view.dart
        │   ├── admin_product_list_view.dart
        │   ├── admin_product_form_view.dart
        │   ├── admin_order_list_view.dart
        │   ├── admin_order_detail_view.dart
        │   └── admin_banner_view.dart
        └── controllers/
            ├── admin_product_controller.dart
            ├── admin_order_controller.dart
            └── admin_banner_controller.dart
```

### 3.3 Skema Firestore Database

```
firestore/
├── users/{uid}
│   ├── name: string
│   ├── email: string
│   ├── phone: string
│   ├── photoUrl: string
│   ├── role: "renter" | "admin"
│   ├── wishlistItems: [productId, ...]   ← array for simple queries
│   └── createdAt: timestamp
│
├── products/{productId}
│   ├── name: string
│   ├── description: string
│   ├── pricePerDay: number              ← Rupiah integer (e.g. 50000)
│   ├── category: string                 ← "tenda", "sleeping_bag", "kompor", dll
│   ├── images: [cloudinaryUrl, ...]
│   ├── thumbnailUrl: string             ← first image
│   ├── stock: number
│   ├── specs: map {
│   │     weight: string,                ← "2.5 kg"
│   │     capacity: string,              ← "4 orang"
│   │     color: string,
│   │     condition: string              ← "baru", "bekas", "bagus"
│   │   }
│   ├── averageRating: number            ← computed, updated on new review
│   ├── totalReviews: number
│   ├── totalBooked: number              ← for popularity ranking
│   ├── isActive: boolean
│   ├── createdAt: timestamp
│   └── updatedAt: timestamp
│
├── categories/{categoryId}
│   ├── name: string
│   ├── icon: string                     ← icon identifier
│   ├── sortOrder: number
│   └── isActive: boolean
│
├── bookings/{bookingId}
│   ├── userId: reference → users
│   ├── userName: string                 ← denormalized
│   ├── userPhone: string                ← denormalized
│   ├── productId: reference → products
│   ├── productName: string              ← denormalized
│   ├── productThumbnail: string         ← denormalized
│   ├── pricePerDay: number              ← snapshot at booking time
│   ├── pickupDate: timestamp
│   ├── returnDate: timestamp
│   ├── duration: number                 ← days
│   ├── quantity: number
│   ├── totalPrice: number               ← pricePerDay × duration × quantity
│   ├── note: string
│   ├── status: "pending" | "confirmed" | "ready_for_pickup" |
│   │          "picked_up" | "returned" | "completed" | "cancelled"
│   ├── statusHistory: array<{
│   │     status: string,
│   │     timestamp: timestamp,
│   │     updatedBy: string              ← uid
│   │   }>
│   ├── reviewed: boolean
│   ├── createdAt: timestamp
│   └── updatedAt: timestamp
│
├── reviews/{reviewId}
│   ├── userId: reference → users
│   ├── userName: string                 ← denormalized
│   ├── userPhotoUrl: string             ← denormalized
│   ├── productId: reference → products
│   ├── bookingId: reference → bookings
│   ├── rating: number                   ← 1-5
│   ├── comment: string
│   ├── photos: [cloudinaryUrl, ...]     ← max 3
│   └── createdAt: timestamp
│
├── banners/{bannerId}
│   ├── imageUrl: string
│   ├── title: string
│   ├── linkType: "product" | "category" | "none"
│   ├── linkValue: string                ← productId or categoryId
│   ├── isActive: boolean
│   └── sortOrder: number
│
└── app_config/{configId}
    ├── storeName: string
    ├── storeAddress: string
    ├── storePhone: string
    ├── operatingHours: string
    └── version: number
```

### 3.4 Titik Integrasi

| Layanan | Paket | Fungsi |
|---------|-------|--------|
| Firebase Auth | `firebase_auth: ^5.7.0` | Email/password, Google Sign-In, password reset |
| Cloud Firestore | `cloud_firestore: ^5.6.12` | Semua data (users, products, bookings, reviews, banners) |
| Cloudinary | `cloudinary_public: ^0.23.1` | Upload & serve semua gambar (produk, banner, profil, ulasan) |
| OneSignal | `onesignal_flutter: ^5.0.0` | Push notification: booking baru → admin, status update → penyewa |
| Google Fonts | `google_fonts: ^6.2.1` | Tipografi premium (Plus Jakarta Sans) |
| Cached Network Image | `cached_network_image: ^3.4.1` | Image caching untuk performa |
| Shimmer | `shimmer: ^3.0.0` | Loading placeholder animasi |
| Carousel Slider | `carousel_slider: ^5.1.1` | Banner & image carousel di detail produk |
| Image Picker | `image_picker: ^1.2.3` | Pick foto untuk profil, ulasan, produk (admin) |

### 3.5 Design System & UI

| Token | Nilai |
|-------|-------|
| **Primary Color** | `#2D6A4F` (Hutan hijau — tema outdoor) |
| **Secondary Color** | `#D4A373` (Earth tone — warm accent) |
| **Surface** | `#FAFAF8` (Warm off-white) |
| **Background** | `#FFFFFF` |
| **Text Primary** | `#1A1A1A` |
| **Text Secondary** | `#6B7280` |
| **Error** | `#DC2626` |
| **Success** | `#16A34A` |
| **Font Family** | Plus Jakarta Sans (via Google Fonts) |
| **Border Radius** | Cards: 16px, Buttons: 12px, Chips: 20px (full) |
| **Elevation** | Subtle shadow (0, 2, 8) rgba(0,0,0,0.08) |
| **Bottom Nav** | 4 tab: Home, Kategori, Pesanan, Profil |
| **Transitions** | `Curves.easeOutCubic`, 300ms default |

### 3.6 Routing & Navigation (GetX)

```dart
abstract class AppRoutes {
  // Public
  static const splash     = '/splash';
  static const login      = '/login';
  static const register   = '/register';
  static const forgotPass = '/forgot-password';

  // Main (with bottom nav)
  static const main       = '/main';
  static const home       = '/home';
  static const catalog    = '/catalog';
  static const orders     = '/orders';
  static const profile    = '/profile';

  // Detail & Actions
  static const productDetail  = '/product/:id';
  static const bookingConfirm = '/booking-confirm';
  static const orderDetail    = '/order/:id';
  static const editProfile    = '/edit-profile';
  static const wishlist       = '/wishlist';
  static const search         = '/search';

  // Admin
  static const adminDashboard    = '/admin/dashboard';
  static const adminProductList  = '/admin/products';
  static const adminProductForm  = '/admin/products/form';
  static const adminOrderList    = '/admin/orders';
  static const adminOrderDetail  = '/admin/orders/:id';
  static const adminBannerList   = '/admin/banners';
}
```

### 3.7 Keamanan & Privasi

- **Firestore Security Rules**: Hanya admin yang bisa write ke `products`, `banners`, `categories`. Penyewa hanya bisa write ke `bookings` (own user), `reviews` (own user), `users/{own uid}`.
- **Cloudinary Upload**: Unsigned upload preset (folder: `teman_outdoor/`) — images only, max 5MB per file.
- **Role Checking**: Setiap request admin dicek `role` field di Firestore. Controller admin melakukan check `GetX.find<AuthController>().user.role == 'admin'` sebelum load data.
- **No Sensitive Data**: Tidak ada data kartu kredit/banking. Cash only.
- **Phone Number**: Hanya untuk koordinasi pickup, bukan disimpan untuk verifikasi.

---

## 4. Alur Data Booking (End-to-End)

```
Penyewa                         Firestore                     Admin
  │                                │                            │
  ├─ Buka Detail Produk ──────────►│                            │
  │  ◄──── product data ──────────┤                            │
  │                                │                            │
  ├─ Pilih tanggal + durasi ──────►│                            │
  ├─ "Konfirmasi Booking" ────────►│                            │
  │  → create booking(doc) ───────►│                            │
  │  → status: "pending"           │──── Push Notif ───────────►│
  │                                │                            │
  │                                │◄──── Admin: "Confirm" ─────┤
  │                                │  → status: "confirmed"     │
  │  ◄──── Push: "Dikonfirmasi" ──┤                            │
  │                                │                            │
  │                                │◄──── Admin: "Ready" ───────┤
  │                                │  → status: "ready_for_pickup"
  │  ◄──── Push: "Siap Diambil" ──┤                            │
  │                                │                            │
  ├─ Datang ke toko ──────────────►│                            │
  ├─ "Sudah Diambil" ─────────────►│  → status: "picked_up"    │
  │                                │                            │
  │ ... masa sewa berlalu ...      │                            │
  │                                │                            │
  ├─ Kembalikan alat ke toko ─────►│                            │
  ├─ "Kembalikan" ────────────────►│  → status: "returned"     │
  │                                │                            │
  │                                │◄──── Admin: "Complete" ────┤
  │                                │  → status: "completed"     │
  ├─ Form Ulasan ─────────────────►│  → create review(doc)      │
  │  → rating + comment + foto     │  → update product.rating  │
```

---

## 5. Risiko & Peta Jalan

### 5.1 Peluncuran Bertahap

| Versi | Cakupan | Target |
|-------|---------|--------|
| **v1.0 (MVP)** | Auth (email), Home, Katalog, Detail, Booking, Orders, Wishlist, Ulasan, Profil, Admin CRUD | Bulan 1–2 |
| **v1.1** | Peta lokasi toko, Push notification reminder, Promo/coupon, Rating dashboard admin | Bulan 3 |
| **v2.0** | Multi-vendor, Payment gateway, Delivery/antar-jemput, Chat in-app | Bulan 4–6 |

### 5.2 Risiko Teknis

| Risiko | Probabilitas | Dampak | Mitigasi |
|--------|-------------|--------|----------|
| Cloudinary free tier limit (25 credits/bulan) | Medium | Gambar tidak bisa di-upload | Upgrade ke plan bayar; compress images sebelum upload |
| Firestore read/write cost naik | Medium | Biaya membengkak | Denormalisasi data order; pagination ketat; index yang tepat |
| OneSignal delay/not delivered | Low | Admin tidak terima notif booking | Fallback: tampilkan booking baru di admin dashboard real-time |
| User tidak memahami alur booking | Medium | Booking incomplete | Onboarding tooltip + status tracking visual di orders |
| Admin lupa update status order | High | Penyewa bingung | Auto-reminder via push: "Order #xxx belum diupdate" |

### 5.3 Dependensi Kritis

- Firebase project harus aktif dengan Firestore dan Auth enabled
- Cloudinary account terdaftar (unsigned upload preset: `teman_outdoor`)
- OneSignal app terdaftar (Firebase Cloud Messaging integration)
- Package name Android: `com.temanoutdoor.app` (pastikan google-services.json cocok)

---

## 6. Asumsi & Defaults

- **Currency**: Semua harga dalam Rupiah (IDR), format `Rp 50.000/hari`
- **Default Rental Duration**: 1 hari (penyewa bisa pilih lebih)
- **Max Photos per Review**: 3 foto
- **Max Banner**: 5 banner aktif
- **Image Format**: JPG/WebP, max 5MB per file, resize otomatis via Cloudinary (max width 1080px)
- **Offline**: Tidak didukung di v1.0 — semua operasi membutuhkan koneksi internet
- **Admin Account**: Dibuat manual via Firebase Console dengan `role: 'admin'` di Firestore
- **Bahasa**: Hanya Bahasa Indonesia
- **Timezone**: WITA (Asia/Makassar)

---

## 7. Metrik & Monitoring

| Metrik | Tool | Frekuensi |
|--------|------|-----------|
| Daily Active Users | Firebase Analytics | Real-time |
| Booking funnel conversion | Firebase Analytics (custom events) | Harian |
| Crash rate | Firebase Crashlytics | Real-time |
| Firestore read/write ops | Firebase Console → Usage | Harian |
| Cloudinary bandwidth | Cloudinary Dashboard | Mingguan |
| Avg order response time | Manual tracking via Firestore timestamp | Mingguan |

---

*PRD ini adalah living document. Perubahan akan dicatat di versi berikutnya.*
