<div align="center">

# 🏕️ Teman Outdoor

**Platform Rental Alat Camping & Outdoor — Makassar**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![GetX](https://img.shields.io/badge/State%20Management-GetX-8A2BE2)](https://pub.dev/packages/get)
[![Firebase](https://img.shields.io/badge/Backend-Firebase-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![Cloudinary](https://img.shields.io/badge/Media-Cloudinary-3448C5?logo=cloudinary&logoColor=white)](https://cloudinary.com)
[![OneSignal](https://img.shields.io/badge/Push-OneSignal-E54B4D)](https://onesignal.com)
![Status](https://img.shields.io/badge/Status-Draft%20v1.0-gray)

[![Download APK](https://img.shields.io/badge/Download%20APK-Google%20Drive-4285F4?logo=google-drive&logoColor=white)](https://drive.google.com/file/d/1PFHGMlUlnriST4zT2cJiY-RTDLgDmKOh/view?usp=sharing)

**Katalog digital · Booking mandiri · Panel admin in-app — pengganti DM Instagram & brosur.**

</div>

---

## 📌 Ringkasan

Aplikasi mobile **Teman Outdoor** menghubungkan penyewa alat camping di Makassar dengan **satu toko rental**. Penyewa bisa:

- 🧭 Menelusuri katalog & cek ketersediaan stok secara real-time
- 🗓️ Booking mandiri dengan pilihan tanggal & durasi sewa
- 💵 Bayar **cash / QRIS** saat pickup di toko
- ⭐ Memberi rating & ulasan setelah pengembalian
- ⚙️ Admin mengelola produk, order, dan ulasan dari dalam aplikasi

---

## 🛠️ Teknologi

| Lapisan | Teknologi | Peran |
|---|---|---|
| **Frontend** | Flutter (Android · iOS · Web · Desktop) | Aplikasi multi-platform |
| **State & Routing** | GetX | State management, routing, dependency injection |
| **Backend** | Firebase Auth | Registrasi/login email + password |
| | Cloud Firestore | Penyimpanan data, security rules, transaksi client |
| | Firebase Analytics *(opsional)* | Tracking instalasi & funnel |
| **Media** | Cloudinary | Upload foto produk & ulasan |
| **Notifikasi** | OneSignal | Push notification (opsional) |
| **UI Pendukung** | google_fonts · ionicons · cached_network_image · intl · fluttertoast · loading_indicator | Tampilan & pengalaman pengguna |

> 💡 **Tanpa Cloud Functions** — logika stok, `totalBooked`, dan agregasi rating memakai **transaksi client-side**; konfigurasi di `.env`, `firestore.rules`, dan `firestore.indexes.json`.

---

## 📂 Struktur Folder (`lib/`)

```
lib/
├── core/        # 🎨 Tema, warna, route + guard admin, konstanta,
│                #    util (Rupiah/tanggal/responsif), widget reuse
├── data/        # 🗃️ Model, service (Firebase/Cloudinary/OneSignal),
│                #    repository (auth, product, booking, review, wishlist)
├── features/    # 📱 Fitur per domain (lihat di bawah)
├── main.dart    # 🚀 Entry point
└── firebase_options.dart
```

### Fitur per Domain

| Path | Konten |
|---|---|
| `features/auth/` | Splash, login, register, session persist |
| `features/home/` | Banner, kategori, rekomendasi & item baru |
| `features/catalog/` | Grid katalog, search, filter, sort, pagination |
| `features/product_detail/` | Galeri, spesifikasi, cek ketersediaan, harga otomatis |
| `features/booking/` | Bottom sheet pilih tanggal & durasi, ringkasan total |
| `features/orders/` | Riwayat pesanan, timeline status, batalkan order |
| `features/wishlist/` | Simpan & akses cepat item favorit |
| `features/reviews/` | Rating bintang 1–5, ulasan + foto |
| `features/profile/` | Edit profil, kontak admin, logout |
| `features/admin/` | Dashboard, CRUD produk, manajemen order & ulasan |

---

## 💥 Dampak Nyata untuk Teman Outdoor

| Dampak | Hasil |
|---|---|
| 🚫 **Bebas bottleneck manual** | Katalog, harga, & stok transparan; penyewa booking mandiri tanpa DM/brosur; rules + transaksi mencegah overbooking |
| ⚡ **Operasional admin lebih cepat** | Panel in-app: CRUD inventaris, ubah status order, kelola ulasan; respons order ≤ 2 jam |
| 📈 **Revenue & retensi meningkat** | Funnel detail → booking, wishlist & riwayat mendorong repeat order, rating jadi social proof |
| 💰 **Efisiensi modal** | Booking terstruktur + dashboard statistik → antisipasi permintaan, alat tidak menganggur |
| 🏆 **Keunggulan kompetitif** | Platform terpusat pertama di Makassar vs kompetitor manual; siap scale (multi-toko, Midtrans/QRIS) di v1.1 |

---
