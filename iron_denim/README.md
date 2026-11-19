# IRON DENIM (Flutter)

## Cara menjalankan
1. `flutter create iron_denim`
2. Salin ke dalam folder `iron_denim` yang baru dibuat (timpa jika diminta):
   - folder `lib/`
   - folder `assets/`
   - file `pubspec.yaml`
3. `flutter pub get`
4. `flutter run`

## Akun
- Admin: username `admin`, password `admin123` (ubah di `lib/state/app_state.dart`)
- Pelanggan: tombol "Lanjut sebagai Pelanggan"

Data (produk, stok, keranjang, favorit) disimpan lokal dengan shared_preferences.

## Gambar produk
- 15 produk awal (8 celana, 7 jaket) memakai gambar di `assets/images/products/p1.jpg` ... `p15.jpg`.
- Produk 11-15 otomatis ditambahkan satu kali ke data lama (produk yang sudah kamu ubah/hapus tidak ikut berubah).
- Untuk mengganti dengan foto asli: timpa file dengan nama yang sama, atau isi kolom "URL gambar" saat tambah produk
  (boleh URL `https://...` atau path aset `assets/images/products/namafile.jpg`).
- Data produk disimpan dengan kunci `products_v2`; jika sebelumnya app sudah dijalankan, data lama akan diganti seed baru.

## Menambahkan gambar produk sendiri (galeri / kamera)
- Login admin -> **Produk Baru**: ketuk kotak gambar untuk memilih foto dari galeri atau kamera.
- Untuk produk yang sudah ada: ketuk **gambar kecil** produk di daftar admin (ada ikon kamera) -> pilih galeri/kamera, atau "Hapus gambar".
- Foto disalin ke folder dokumen aplikasi (`product_images/`) dan tetap ada setelah aplikasi ditutup.
- Mendukung Android, iOS, desktop, dan **Flutter Web**. Di web, foto disimpan di penyimpanan browser (localStorage, ±5 MB), jadi foto otomatis diperkecil (maks. 800×1000); sekitar 20-an foto masih muat. Data hilang jika data situs di browser dihapus.

### Izin platform
- **iOS**: tambahkan di `ios/Runner/Info.plist`:
  ```xml
  <key>NSPhotoLibraryUsageDescription</key>
  <string>Untuk memilih foto produk</string>
  <key>NSCameraUsageDescription</key>
  <string>Untuk mengambil foto produk</string>
  ```
- **Android**: galeri tidak perlu izin tambahan. Untuk kamera, `image_picker` biasanya bekerja langsung; jika perangkat tertentu bermasalah, tambahkan `<uses-permission android:name="android.permission.CAMERA"/>` di `android/app/src/main/AndroidManifest.xml`.


## Tampilan mobile (v1.1)
- Layout ala aplikasi HP: navigasi bawah, kartu produk 2 kolom, halaman detail produk, checkout per halaman, riwayat pesanan.
- Di layar lebar (Chrome/desktop) tampilan otomatis dibatasi selebar HP; di HP asli memenuhi layar.
- Pelanggan: Beranda (cari + filter), Favorit, Keranjang (geser kiri untuk hapus), Akun (riwayat pesanan, keluar).
- Admin: ringkasan stok, cari/filter produk, tambah stok (form bawah), produk baru, hapus, ganti foto, daftar pesanan masuk.
- Struktur baru: `lib/widgets/` (komponen bersama), `lib/models/order.dart`, `lib/screens/product_detail_screen.dart`, `lib/screens/checkout_screen.dart`.

## Versi 1.2
- **Status pesanan:** Diproses -> Dikirim -> Selesai. Admin mengubah status di tab Pesanan (tombol "Kirim Pesanan" / "Tandai Selesai"). Pesanan bisa **Dibatalkan** selama belum selesai; stok produk **otomatis dikembalikan**. Pelanggan bisa membatalkan pesanannya sendiri selama masih "Diproses". Setiap pesanan punya riwayat status.
- **Edit produk:** tombol pensil di tiap produk (admin) untuk mengubah nama, kategori, harga, stok, deskripsi, dan foto. Jumlah di keranjang otomatis menyesuaikan jika stok dikurangi.
- **Tampilan mewah:** palet hitam-emas, font serif Playfair Display (lisensi OFL, di `assets/fonts/`), tombol dan garis hias emas.
- Data lama tetap aman: deskripsi produk bawaan terisi otomatis; pesanan lama dianggap "Diproses".

## Tampilan di Chrome (mockup HP)
Jalankan `flutter run -d chrome`: aplikasi tampil di dalam HP (bezel, dynamic island, status bar, tombol samping). Ukuran layar HP 390x844 dan otomatis mengecil jika jendela browser kurang tinggi. Di HP/emulator asli tampilan memenuhi layar tanpa bingkai. Kode bingkai ada di `lib/main.dart` (`_PhoneFrame`).
