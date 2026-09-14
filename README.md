# CicipYuk Blog App - Dokumentasi Lengkap

Aplikasi Flutter untuk baca, tambah, edit, dan hapus artikel kuliner.
Data TIDAK disimpan di HP, tapi di server (backend) via REST API.

Alur besar:

```text
Aplikasi Flutter <--> REST API (HTTP) <--> Server <--> Database
```

---

## 1. Struktur Folder `lib/`

```text
lib/
├── main.dart               # Pintu masuk aplikasi
├── api_config.dart         # Alamat server + helper
└── pages/
    ├── home_page.dart      # Halaman utama: daftar artikel
    ├── detail_page.dart    # Halaman detail + tombol hapus
    ├── add_post_page.dart  # Halaman form tambah
    └── edit_post_page.dart # Halaman form edit
```

| File | Isi | Tugas |
|------|-----|-------|
| `main.dart` | `BlogApp` | Jalan pertama kali, atur tema, font, dan halaman awal |
| `api_config.dart` | `apiBaseUrl` + 7 fungsi bantuan | Simpan 1 alamat server agar tidak tulis ulang IP di semua file |
| `home_page.dart` | `PostListScreen` | Ambil dan tampilkan semua artikel |
| `detail_page.dart` | `PostDetailScreen` | Tampilkan 1 artikel, bisa hapus dan pindah ke edit |
| `add_post_page.dart` | `AddPostPage` | Form tambah artikel baru |
| `edit_post_page.dart` | `EditPostPage` | Form edit artikel lama |

---

## 2. Penjelasan Tiap File

### 2.1 `main.dart` - Pintu Masuk

```dart
void main() {
  runApp(const BlogApp());
}
```

- `BlogApp` adalah `StatelessWidget` karena tidak punya data yang berubah. Isinya cuma tema.
- Mengatur warna dasar `#FFF9F0`, warna utama `#F28C28`, font `Plus Jakarta Sans`.
- `home: const PostListScreen()` artinya aplikasi langsung buka halaman daftar artikel.

### 2.2 `api_config.dart` - Otak Koneksi API

Ini file paling penting untuk soal "link API dari mana?".

```dart
const String apiBaseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://10.2.8.213:8000',
);
```

- `apiBaseUrl` = alamat dasar backend. Cuma ditulis 1x di sini.
- Semua halaman lain tinggal pakai: `'$apiBaseUrl/api/artikel'`.
- Kalau IP server ganti, tidak perlu edit 4 file, cukup ganti 1 nilai ini atau pakai `--dart-define` (lihat bab 4).

Fungsi bantuan di file ini:

1. `gambarArtikelUrl(gambar)` - backend kadang kirim `ramen.jpg`, kadang `uploads/ramen.jpg`, kadang URL penuh. Fungsi ini ubah semuanya jadi URL yang bisa dibuka `Image.network`. Contoh:
   - Input: `ramen.jpg` -> Output: `http://10.2.8.213:8000/uploads/ramen.jpg`
   - Input: `http://.../ramen.jpg` -> dibiarkan apa adanya.
2. `parseKategoriId()` / `parsePenerbitId()` - ID kadang datang sebagai `int`, `String "3"`, atau `Map {id:3}`. Fungsi ini samakan jadi `int`.
3. `kategoriName()` / `penerbitName()` - ambil nama walaupun nama field beda (`nama_kategori` atau `name`).
4. `mediaTypeForImage()` - tentukan `image/jpeg`, `image/png`, `image/webp` saat upload.
5. `pesanErrorBackend(body)` - ubah error JSON Laravel `{message, errors}` jadi teks manusiawi untuk `SnackBar`.

### 2.3 `pages/home_page.dart` - Daftar Artikel

Widget: `PostListScreen` (`StatefulWidget` karena daftar bisa loading / error / berubah).

Fungsi utama `getArtikel()`:

```dart
final response = await http.get(Uri.parse('$apiBaseUrl/api/artikel'));
dynamic body = jsonDecode(response.body);
```

Langkahnya:
1. `isLoading = true`, tampilkan spinner.
2. `GET /api/artikel`, tunggu max 15 detik.
3. `jsonDecode` ubah teks JSON jadi `List` atau `Map`.
4. Simpan ke `List<dynamic> artikel` pakai `setState`.
5. `pilihTampilan()` pilih 1 dari 4: loading / error / kosong / daftar.

Tiap kartu di-tap:

```dart
Navigator.push(context, MaterialPageRoute(
  builder: (_) => PostDetailScreen(postId: id)
)).then((_) => getArtikel()); // refresh saat kembali
```

### 2.4 `pages/detail_page.dart` - Detail + Hapus

Widget: `PostDetailScreen(postId)`.

- `getDetail()` coba 2 cara:
  1. `GET /api/artikel/{id}` -> kalau berhasil langsung pakai.
  2. Kalau gagal, `GET /api/artikel` semua lalu cari yang ID-nya sama (fallback).
- `hapusArtikel()`:
  ```dart
  await http.delete(Uri.parse('$apiBaseUrl/api/artikel/$id'));
  ```
  Sukses jika status `200` / `204`, lalu `Navigator.pop(context, true)`.
- Tombol edit pindah ke `EditPostPage(artikel: artikel)`.

### 2.5 `pages/add_post_page.dart` - Tambah

Widget: `AddPostPage`.

Saat dibuka (`initState`):
- `GET /api/kategori` -> isi dropdown kategori.
- `GET /api/penerbit` -> isi dropdown penerbit.

Saat tekan Simpan (`tambahArtikel()`):
1. `formKey.currentState!.validate()` cek judul, penulis, isi, kategori, penerbit.
2. Kalau tanpa gambar -> kirim JSON:
   ```dart
   http.post(url, headers: {'Content-Type':'application/json'},
     body: jsonEncode({'judul_artikel': judul, ...}));
   ```
3. Kalau ada gambar -> kirim Multipart (karena JSON tidak bisa bawa file):
   ```dart
   var req = http.MultipartRequest('POST', url);
   req.fields['judul_artikel'] = judul; // teks
   req.files.add(await http.MultipartFile.fromPath('gambar_artikel', path)); // file
   ```
4. Sukses (`200`/`201`) -> `Navigator.pop(context, true)`.

Gambar dicek dulu: max 5MB, hanya `jpg/jpeg/png/webp`.

### 2.6 `pages/edit_post_page.dart` - Edit

Widget: `EditPostPage(artikel)`. Hampir sama dengan tambah, bedanya:

- Form langsung diisi data lama di `initState`:
  ```dart
  judulController.text = widget.artikel['judul_artikel'].toString();
  ```
- Kirim pakai `PUT /api/artikel/{id}`, bukan `POST`.
- Kalau tidak ganti gambar, kirim JSON saja agar gambar lama tidak hilang.
- Ada pengaman `nilaiDropdownKategoriAman()` agar dropdown tidak error kalau ID lama sudah dihapus di server.

---

## 3. Hubungan Antar File

```text
main.dart
  |
  v
PostListScreen (home_page.dart) -- pakai apiBaseUrl + gambarArtikelUrl
  |
  +-- tombol + --> AddPostPage -- pakai apiBaseUrl + parseId + mediaType + pesanError
  |                    | POST sukses
  |                    v
  |                 kembali + refresh daftar
  |
  +-- tap kartu --> PostDetailScreen(postId) -- pakai apiBaseUrl + gambarArtikelUrl
                        |
                        +-- tombol edit --> EditPostPage(artikel) -- PUT sukses --> kembali + refresh detail
                        +-- tombol hapus --> DELETE sukses --> kembali + refresh daftar
```

Aturan yang dipakai semua halaman:
- Tidak ada yang tulis IP manual. Semua `import '../api_config.dart'`.
- Setelah tambah/edit/hapus selalu `pop(true)` + `getArtikel()` / `getDetail()` lagi. Jadi UI selalu data terbaru dari server, bukan data lama di memori.

---

## 4. Cara Mengambil Link API dari Backend (Paling Penting)

### 4.1 Konsep Base URL + Endpoint

Link lengkap = **Base URL + Endpoint**.

Contoh di project ini:

```dart
'$apiBaseUrl/api/artikel' // = http://10.2.8.213:8000/api/artikel
```

| Method | Link Lengkap | Fungsi | Dipakai di |
|--------|--------------|--------|------------|
| GET | `http://10.2.8.213:8000/api/artikel` | Ambil semua artikel | `home_page.dart:32` |
| GET | `http://10.2.8.213:8000/api/artikel/1` | Ambil 1 artikel id=1 | `detail_page.dart:31` |
| POST | `http://10.2.8.213:8000/api/artikel` | Tambah baru | `add_post_page.dart:198` |
| PUT | `http://10.2.8.213:8000/api/artikel/1` | Edit id=1 | `edit_post_page.dart:201` |
| DELETE | `http://10.2.8.213:8000/api/artikel/1` | Hapus id=1 | `detail_page.dart:131` |
| GET | `http://10.2.8.213:8000/api/kategori` | Daftar kategori | `add/edit:47` |
| GET | `http://10.2.8.213:8000/api/penerbit` | Daftar penerbit | `add/edit:96` |
| GET gambar | `http://10.2.8.213:8000/uploads/namafile.jpg` | Tampilkan gambar | via `gambarArtikelUrl()` |

### 4.2 Dari Mana Dapat Base URL?

1. Lihat backend (biasanya Laravel). Buka `routes/api.php`, pastikan ada route `artikel`, `kategori`, `penerbit`.
2. Jalankan backend, contoh:
   ```bash
   php artisan serve --host=0.0.0.0 --port=8000
   ```
3. Cari IP komputer server: buka CMD -> `ipconfig` -> lihat IPv4, misal `10.2.8.213`.
4. Base URL = `http://IP_TSB:8000`. Itulah yang diisi ke `apiBaseUrl`.

### 4.3 Cara Ganti Base URL Tanpa Edit Kode

Karena pakai `String.fromEnvironment('API_URL')`, ganti cukup saat `run` / `build`:

```bash
# dari folder blog_app/
flutter pub get
flutter run --dart-define=API_URL=http://10.2.8.213:8000

# contoh lain:
flutter run -d chrome --dart-define=API_URL=http://localhost:8000
flutter run -d windows --dart-define=API_URL=http://localhost:8000
flutter build apk --dart-define=API_URL=http://10.2.8.213:8000
```

Panduan pilih IP:
- Emulator Android akses localhost PC -> `http://10.0.2.2:8000`
- Chrome / Windows di PC yang sama -> `http://localhost:8000`
- HP fisik + laptop satu WiFi -> `http://IP_LAN_LAPTOP:8000` (cek `ipconfig`)

Kalau tidak pakai `--dart-define`, aplikasi pakai `defaultValue` di `api_config.dart:8`.

### 4.4 Contoh Request - Response Asli

Request tambah tanpa gambar:

```http
POST /api/artikel HTTP/1.1
Content-Type: application/json

{
  "judul_artikel": "Seblak",
  "isi_artikel": "Isi...",
  "id_kategori": 2,
  "id_penerbit": 3,
  "penulis_artikel": "Budi"
}
```

Response daftar (2 bentuk didukung kode):

```json
{ "data": [{ "id": 1, "judul_artikel": "Seblak", "gambar_artikel": "seblak.jpg" }] }
```

atau langsung:

```json
[{ "id": 1, "judul_artikel": "Seblak", "gambar_artikel": "seblak.jpg" }]
```

Itulah kenapa di semua `getArtikel/getKategori/getPenerbit` ada cek:

```dart
if (body is Map && body['data'] != null) dataBaru = body['data'];
else if (body is List) dataBaru = body;
```

---

## 5. Cara Menjalankan

```bash
cd blog_app
flutter pub get
flutter devices
flutter run --dart-define=API_URL=http://10.2.8.213:8000
```

Syarat: backend sudah jalan, HP/emulator satu jaringan dengan server.

Cek sebelum commit:

```bash
flutter analyze
flutter test
```

---

## 6. Troubleshooting Cepat

- `Tidak bisa konek ke server` -> backend mati / salah IP / beda WiFi / firewall. Coba buka `http://IP:8000/api/artikel` di browser HP dulu.
- `Request timeout` -> server lambat / jaringan putus. Ulangi.
- Daftar kosong padahal server ada data -> cek JSON punya `id` / `id_artikel` dan key `data`.
- Gambar tidak muncul -> pastikan file ada di `uploads/` server dan `API_URL` bisa dibuka dari HP, bukan cuma dari laptop.
- Dropdown kosong -> `GET /api/kategori` dan `/api/penerbit` harus bisa dibuka, tiap item harus ada `id_kategori` / `id_penerbit` dan `nama_kategori` / `nama_penerbit`.
