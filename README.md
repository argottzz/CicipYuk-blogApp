# DOKUMEN SRS - BLOG APP

## Informasi Dokumen

| Keterangan          | Isi                                                  |
| ------------------- | ---------------------------------------------------- |
| Satuan Pendidikan   | SMK Taruna Bhakti                                    |
| Kompetensi Keahlian | Rekayasa Perangkat Lunak                             |
| Tahun Pelajaran     | 2026/2027                                            |
| Judul Tugas         | Merancang Sistem dengan Pembuatan Dokumen SRS        |
| Nama Sistem         | Blog App                                             |
| Platform            | Android, iOS, Web, dan Desktop yang didukung Flutter |
| Versi Dokumen       | 1.0                                                  |

Dokumen ini disusun berdasarkan implementasi project Flutter pada repository ini.
Bagian desain sistem manual pada Bab IV.1 sengaja dilewati sesuai instruksi tugas.

---

# BAB I PENDAHULUAN

## 1.1 Latar Belakang

Blog App adalah aplikasi pengelolaan artikel yang dibuat menggunakan Flutter.
Aplikasi ini digunakan untuk menampilkan, membuat, melihat, mengubah, dan
menghapus artikel melalui antarmuka mobile. Data artikel dan kategori disimpan
oleh backend REST API, sedangkan aplikasi Flutter berperan sebagai client.

Sebelum menggunakan aplikasi, pengelolaan artikel dapat menjadi kurang teratur
apabila dilakukan tanpa tampilan yang terpusat. Oleh karena itu dibutuhkan
aplikasi yang dapat membantu pengguna mengelola isi blog secara lebih mudah,
termasuk menyertakan gambar artikel dan informasi kategori.

## 1.2 Rumusan Masalah

1. Bagaimana menampilkan daftar artikel dari server dalam aplikasi Flutter?
2. Bagaimana pengguna dapat menambahkan artikel beserta kategori dan gambar?
3. Bagaimana pengguna dapat melihat isi lengkap, mengubah, dan menghapus artikel?
4. Bagaimana aplikasi menangani koneksi ke backend dan URL gambar artikel?
5. Bagaimana source code project dikelola menggunakan GitHub dan branching?

## 1.3 Tujuan Penulisan Dokumen

1. Mendokumentasikan kebutuhan dan ruang lingkup Blog App.
2. Menjelaskan metode pengembangan yang digunakan.
3. Menjelaskan fitur, data, alur bisnis, batasan, dan kebutuhan sistem.
4. Menjadi acuan untuk pengembangan, pengujian, dan presentasi kepada penguji.

---

# BAB II METODE PENGEMBANGAN

## 2.1 Metode Pengembangan

Metode yang digunakan adalah **Agile** dengan pengembangan bertahap dan
iteratif. Metode ini dipilih karena fitur aplikasi dapat dikerjakan per bagian,
misalnya daftar artikel, tambah artikel, detail artikel, edit artikel, dan hapus
artikel. Setiap bagian dapat diuji setelah selesai dan diperbaiki berdasarkan
hasil pengujian.

Tahapan pengembangan:

1. **Perencanaan** - menentukan tujuan, pengguna, fitur, dan kebutuhan API.
2. **Analisis kebutuhan** - mendefinisikan data artikel, kategori, dan aturan upload.
3. **Implementasi** - membuat halaman Flutter dan integrasi REST API.
4. **Pengujian** - memeriksa tampilan, validasi form, request API, dan respons error.
5. **Review dan perbaikan** - memperbaiki fitur berdasarkan hasil pengujian.
6. **Pemeliharaan** - mengelola perubahan melalui branch GitHub.

## 2.2 Jadwal Pengembangan Sistem

| Tahap | Kegiatan           | Hasil                                      |
| ----- | ------------------ | ------------------------------------------ |
| 1     | Perencanaan        | Tema dan tujuan Blog App                   |
| 2     | Analisis           | Daftar kebutuhan dan rancangan endpoint    |
| 3     | Implementasi dasar | Project Flutter dan halaman utama          |
| 4     | Integrasi API      | Daftar artikel dan kategori dari server    |
| 5     | Fitur CRUD         | Tambah, detail, edit, dan hapus artikel    |
| 6     | Upload gambar      | Pemilihan, validasi, dan pengiriman gambar |
| 7     | Pengujian          | Pemeriksaan alur normal dan error koneksi  |
| 8     | Dokumentasi        | SRS, README, dan lampiran screenshot       |

---

# BAB III ANALISIS KEBUTUHAN SISTEM

## 3.1 Nama Sistem

**Blog App** adalah aplikasi client Flutter untuk mengelola artikel blog
melalui REST API.

## 3.2 Latar Belakang Sistem

Sistem dibuat untuk menyediakan satu aplikasi yang dapat digunakan untuk
memantau dan mengelola artikel. Aplikasi mengambil data dari endpoint backend,
menyajikannya dalam bentuk daftar dan detail, serta menyediakan form untuk
menyimpan perubahan artikel.

## 3.3 Ruang Lingkup

### Deskripsi Sistem

Blog App memiliki halaman daftar artikel sebagai halaman awal. Dari halaman
tersebut pengguna dapat memuat ulang data, membuka detail artikel, menghapus
artikel, atau membuka form tambah artikel. Halaman detail menyediakan informasi
lengkap artikel serta tombol edit dan hapus.

Aplikasi berkomunikasi dengan backend menggunakan HTTP. Alamat backend dapat
diubah melalui `--dart-define=API_URL=http://IP:8000`. Nilai default yang
tersedia pada project adalah `http://10.2.14.97:8000`.

### Manfaat

1. Memudahkan pengguna membaca daftar artikel.
2. Mempercepat proses penambahan dan pembaruan artikel.
3. Menyediakan pengelolaan gambar artikel dari perangkat.
4. Membantu data artikel tetap terhubung dengan kategori dan penulis.
5. Menjadi client yang sederhana untuk backend pengelolaan blog.

## 3.4 Kebutuhan Fungsional

### 3.4.1 Fitur Utama

| ID   | Kebutuhan                                                                                         |
| ---- | ------------------------------------------------------------------------------------------------- |
| F-01 | Sistem menampilkan daftar artikel dari `GET /api/artikel`.                                        |
| F-02 | Sistem menyediakan tombol refresh untuk mengambil data terbaru.                                   |
| F-03 | Sistem menampilkan judul, kategori, ringkasan isi, dan gambar artikel.                            |
| F-04 | Pengguna dapat membuka detail artikel berdasarkan ID.                                             |
| F-05 | Pengguna dapat mengambil daftar kategori dari `GET /api/kategori`.                                |
| F-06 | Pengguna dapat menambahkan artikel melalui `POST /api/artikel` dengan multipart form.             |
| F-07 | Pengguna dapat mengubah artikel melalui `PUT /api/artikel/{id}`.                                  |
| F-08 | Pengguna dapat menghapus artikel melalui `DELETE /api/artikel/{id}`.                              |
| F-09 | Pengguna dapat memilih gambar dari galeri perangkat.                                              |
| F-10 | Sistem menolak gambar berukuran lebih dari 5 MB atau berekstensi selain JPG, JPEG, PNG, dan WEBP. |
| F-11 | Sistem menampilkan pesan berhasil atau gagal setelah operasi API.                                 |
| F-12 | Sistem menggunakan placeholder apabila gambar kosong atau gagal dimuat.                           |

### 3.4.2 Karakteristik Pengguna

| Pengguna              | Karakteristik                                | Hak akses                                          |
| --------------------- | -------------------------------------------- | -------------------------------------------------- |
| Pengelola artikel     | Memahami penggunaan dasar perangkat dan blog | Melihat, menambah, mengubah, dan menghapus artikel |
| Pembaca/pengguna umum | Membutuhkan informasi artikel                | Melihat daftar dan detail artikel                  |

Pada versi project ini belum terdapat login dan pembagian hak akses berbasis
akun. Akses operasi ditentukan oleh endpoint backend yang tersedia.

### 3.4.3 Kamus Data

#### Data Artikel

| Nama data           | Tipe    | Keterangan                        |
| ------------------- | ------- | --------------------------------- |
| `id` / `id_artikel` | Integer | Identitas unik artikel            |
| `judul_artikel`     | String  | Judul artikel                     |
| `isi_artikel`       | String  | Isi lengkap artikel               |
| `id_kategori`       | Integer | Identitas kategori artikel        |
| `nama_kategori`     | String  | Nama kategori yang ditampilkan    |
| `penulis_artikel`   | String  | Nama penulis artikel              |
| `gambar_artikel`    | String  | Nama file atau URL gambar artikel |

#### Data Kategori

| Nama data                | Tipe    | Keterangan              |
| ------------------------ | ------- | ----------------------- |
| `id` / `id_kategori`     | Integer | Identitas unik kategori |
| `nama_kategori` / `name` | String  | Nama kategori           |

#### Parameter Konfigurasi

| Nama data            | Tipe     | Keterangan                                                   |
| -------------------- | -------- | ------------------------------------------------------------ |
| `API_URL`            | String   | Alamat dasar REST API                                        |
| `gambarArtikelUrl()` | Function | Mengubah nama file gambar menjadi URL yang dapat ditampilkan |

### 3.4.4 User Interface

| Halaman        | Komponen dan fungsi                                                                         |
| -------------- | ------------------------------------------------------------------------------------------- |
| Daftar Artikel | App bar, refresh, daftar artikel, thumbnail, tombol hapus, dan tombol tambah                |
| Tambah Artikel | Input judul, dropdown kategori, input penulis, input isi, pemilih gambar, dan tombol simpan |
| Detail Artikel | Gambar, judul, kategori, penulis, isi artikel, tombol edit, dan tombol hapus                |
| Edit Artikel   | Form artikel dengan data awal, gambar lama, pemilih gambar baru, dan tombol update          |

### 3.4.5 Interaksi Antar Modul

1. `main.dart` menjalankan aplikasi dan membuka `PostListScreen`.
2. `home_page.dart` mengambil daftar artikel, menampilkan data, dan membuka halaman lain.
3. `add_post_page.dart` mengambil kategori lalu mengirim artikel baru dengan multipart request.
4. `detail_page.dart` mengambil satu artikel, atau memakai daftar artikel sebagai fallback jika endpoint detail gagal.
5. `edit_post_page.dart` mengambil kategori, mengisi form dari artikel terpilih, lalu mengirim pembaruan.
6. `api_config.dart` menyediakan alamat API dan pembentuk URL gambar untuk seluruh halaman.

### 3.4.6 Aliran Bisnis

1. Aplikasi dibuka dan meminta daftar artikel dari server.
2. Pengguna memilih salah satu artikel untuk melihat detail.
3. Pengguna dapat kembali, mengedit data, atau menghapus artikel.
4. Untuk menambah artikel, pengguna membuka tombol tambah.
5. Pengguna mengisi judul, kategori, penulis, isi, dan gambar opsional.
6. Sistem memvalidasi field wajib dan file gambar.
7. Sistem mengirim data ke backend dan menampilkan hasil operasi.
8. Setelah tambah, edit, atau hapus berhasil, daftar artikel dimuat kembali.

## 3.5 Kebutuhan Non-Fungsional

### 3.5.1 Kebutuhan Produk

1. Aplikasi harus dapat berjalan pada platform yang didukung Flutter.
2. Tampilan harus dapat digunakan pada ukuran layar perangkat yang berbeda.
3. Aplikasi harus menampilkan indikator atau pesan ketika data gagal dimuat.
4. Form harus menolak field wajib yang kosong.
5. Format gambar dibatasi JPG, JPEG, PNG, dan WEBP dengan ukuran maksimal 5 MB.
6. Komunikasi data menggunakan HTTP REST API berbentuk JSON dan multipart.

### 3.5.2 Kebutuhan Organisasi

1. Source code dikelola menggunakan Git dan disimpan di GitHub.
2. Perubahan fitur dikerjakan pada branch terpisah sebelum digabungkan.
3. Kode mengikuti struktur project Flutter dan pemeriksaan lint yang tersedia.
4. Setiap fitur utama diuji sebelum digunakan dalam demonstrasi.

### 3.5.3 Kebutuhan Eksternal

1. Backend REST API harus aktif dan dapat diakses oleh perangkat.
2. Perangkat membutuhkan koneksi jaringan ke alamat API.
3. Fitur gambar membutuhkan izin akses galeri atau media perangkat.
4. Flutter SDK, Dart SDK, dan package pada `pubspec.yaml` harus tersedia.
5. Backend harus menyediakan endpoint artikel, kategori, dan folder upload gambar.

## 3.6 Batasan Sistem

### 3.6.1 Batas Teknologi

1. Aplikasi dibangun menggunakan Flutter dan bahasa Dart.
2. Request jaringan menggunakan package `http`.
3. Pemilihan gambar menggunakan package `image_picker`.
4. Data tidak disimpan secara offline di dalam aplikasi.
5. Aplikasi bergantung pada format respons dan endpoint backend.

### 3.6.2 Batas Platform

1. Perangkat harus mendukung Flutter dan memiliki koneksi ke backend.
2. Alamat IP lokal harus dapat dijangkau dari perangkat penguji.
3. Pengaturan `API_URL` harus disesuaikan apabila alamat server berubah.
4. Tampilan dan kemampuan pemilihan gambar dapat berbeda antar platform.

### 3.6.3 Batas Regulasi

1. Data artikel dan gambar harus digunakan sesuai izin pemilik konten.
2. Pengguna bertanggung jawab atas isi artikel yang diunggah.
3. Repository tidak boleh menyimpan password, token, atau data pribadi sensitif.
4. Pengelolaan akses dan validasi akhir tetap menjadi tanggung jawab backend.

---

# BAB IV DEVELOPMENT

## 4.1 Desain System

Bagian desain system manual yang terdiri dari Activity Diagram, Use Case
Diagram, dan Class Diagram dilewati sesuai instruksi tugas.

## 4.2 Struktur Repository dan Branching GitHub

### Struktur Repository

```text
blog_app/
|- lib/
|  |- main.dart              # Entry point aplikasi
|  |- api_config.dart        # Konfigurasi API dan URL gambar
|  `- pages/
|     |- home_page.dart      # Daftar artikel
|     |- add_post_page.dart  # Tambah artikel
|     |- detail_page.dart    # Detail artikel
|     `- edit_post_page.dart  # Edit artikel
|- test/                     # Pengujian Flutter
|- android/                  # Konfigurasi platform Android
|- ios/                      # Konfigurasi platform iOS
|- web/                      # Konfigurasi platform Web
|- linux/, macos/, windows/  # Konfigurasi platform desktop
|- pubspec.yaml              # Dependensi dan metadata project
|- analysis_options.yaml     # Aturan analisis Dart
`- README.md                # Dokumentasi SRS project
```

### Branching GitHub

Branch yang digunakan atau direkomendasikan:

| Branch               | Fungsi                                                          |
| -------------------- | --------------------------------------------------------------- |
| `main`               | Menyimpan versi stabil yang siap dipresentasikan atau digunakan |
| `develop`            | Menggabungkan pekerjaan fitur sebelum masuk ke `main`           |
| `feature/nama-fitur` | Mengerjakan satu fitur, contohnya `feature/tambah-artikel`      |
| `fix/nama-masalah`   | Memperbaiki bug tertentu                                        |

Alur kerja:

1. Membuat branch fitur dari `develop`.
2. Mengimplementasikan fitur dan melakukan commit dengan pesan yang jelas.
3. Menguji fitur pada branch tersebut.
4. Membuat pull request ke `develop` untuk review.
5. Menggabungkan `develop` ke `main` setelah fitur stabil.
6. Memberi tag atau catatan versi apabila diperlukan.

---

# BAB V PENUTUP

## 5.1 Kesimpulan

Blog App merupakan aplikasi Flutter untuk mengelola artikel melalui REST API.
Sistem menyediakan fungsi utama berupa melihat daftar dan detail artikel,
menambah artikel, mengubah artikel, menghapus artikel, mengelola kategori,
serta mengunggah gambar dengan validasi format dan ukuran. Pengembangan
dilakukan secara iteratif menggunakan Agile, sedangkan source code dikelola
dengan GitHub dan branching.

Dokumen SRS ini menjelaskan kebutuhan sistem yang telah disesuaikan dengan
implementasi project saat ini. Backend REST API menjadi komponen eksternal yang
wajib aktif agar fitur data dapat digunakan secara penuh.

## 5.2 Lampiran

Lampiran berikut disiapkan untuk melengkapi dokumen saat pengumpulan atau
presentasi:

1. Screenshot halaman daftar artikel.
2. Screenshot halaman tambah artikel.
3. Screenshot halaman detail dan edit artikel.
4. Screenshot database atau respons API artikel dan kategori.
5. Screenshot repository GitHub dan daftar branch.
6. Tautan repository GitHub: **isi sesuai URL repository project**.
7. Dokumentasi hasil pengujian koneksi API dan upload gambar.

---

## Konfigurasi Menjalankan Project

Pastikan backend aktif, lalu jalankan project dengan alamat API yang sesuai:

```bash
flutter pub get
flutter run --dart-define=API_URL=http://IP_SERVER:8000
```

Jika tidak menggunakan `--dart-define`, aplikasi memakai alamat default yang
tercantum pada `lib/api_config.dart`.
