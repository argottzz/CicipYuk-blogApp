PENJELASAN KODE PROJECT CICIPYUK UNTUK UJIAN PEMROGRAMAN MOBILE

Nama Project : CicipYuk Blog App

Fungsi utama:
CicipYuk adalah aplikasi mobile untuk membaca dan mengelola artikel kuliner.

Data artikel tidak disimpan langsung di HP.
Flutter mengambil dan mengirim data melalui REST API ke server.
Server kemudian berhubungan dengan database.

Fitur utama:
- Melihat daftar artikel
- Melihat detail artikel
- Menambah artikel
- Mengedit artikel
- Menghapus artikel
- Memilih kategori
- Memilih dan mengupload gambar artikel

FILE UTAMA DI FOLDER lib/

1. main.dart
   → Pintu masuk aplikasi dan pengaturan tema.

2. api_config.dart
   → Menyimpan alamat server dan helper untuk mengolah data API.

3. pages/home_page.dart
   → Menampilkan daftar artikel.
   → Widget utama: PostListScreen.

4. pages/add_post_page.dart
   → Form untuk menambah artikel.
   → Widget utama: AddPostPage.

5. pages/detail_page.dart
   → Menampilkan detail artikel dan fitur hapus.
   → Widget utama: PostDetailScreen.

6. pages/edit_post_page.dart
   → Form untuk mengedit artikel.
   → Widget utama: EditPostPage.


==================================================
1. TIPE DATA
==================================================

1.1. KONSEP SINGKAT

Tipe data adalah jenis data yang disimpan oleh sebuah variabel.

Tipe data yang digunakan di project:

- String
  → Menyimpan teks.

- int
  → Menyimpan angka bulat.

- bool
  → Menyimpan true atau false.

- List
  → Menyimpan banyak data dalam bentuk daftar.

- Map
  → Menyimpan data dalam bentuk key dan value, seperti objek JSON.

- dynamic
  → Tipe data yang bisa menerima berbagai jenis nilai.

- ?
  → Menandakan bahwa variabel boleh bernilai null.


1.2. PENERAPAN DI PROJECT

Contoh di home_page.dart:

List<dynamic> artikel = [];

bool isLoading = true;

String? pesanError;


Contoh di detail_page.dart:

Map<String, dynamic>? artikel;

bool lagiMenghapus = false;


Contoh di add_post_page.dart:

int? kategoriTerpilih;

XFile? gambarTerpilih;


Contoh helper di api_config.dart:

String gambarArtikelUrl(dynamic gambar)

int? parseKategoriId(dynamic raw)

String kategoriName(dynamic item)


1.3. PENJELASAN KODE

List<dynamic> artikel = [];

Digunakan untuk menyimpan banyak artikel yang didapat dari API.

Kenapa menggunakan List?

Karena artikel yang diterima dari API jumlahnya bisa lebih dari satu.

Contohnya:

[
  {
    "id_artikel": 1,
    "judul_artikel": "Sate Maranggi"
  },
  {
    "id_artikel": 2,
    "judul_artikel": "Ramen"
  }
]

Kenapa menggunakan dynamic?

Karena setiap artikel berbentuk Map yang isinya bisa memiliki beberapa tipe data.

Contohnya:

- id_artikel → int
- judul_artikel → String
- id_kategori → int
- gambar_artikel → String

Jadi List<dynamic> digunakan agar data dari API lebih fleksibel.


bool isLoading = true;

Digunakan untuk mengetahui apakah aplikasi sedang mengambil data.

Nilai:

true
→ sedang loading.

false
→ proses loading selesai.

Contohnya ketika halaman pertama kali dibuka:

isLoading = true;

Setelah data berhasil didapat:

isLoading = false;

Nilai ini digunakan oleh pilihTampilan() untuk menentukan apakah aplikasi menampilkan loading, error, data kosong, atau daftar artikel.


String? pesanError;

Digunakan untuk menyimpan pesan error.

Tanda ? berarti variabel tersebut boleh bernilai null.

Contohnya:

pesanError = null;

Artinya tidak ada error.

Sedangkan:

pesanError = "Gagal mengambil data";

Artinya terjadi error.


Map<String, dynamic>? artikel;

Digunakan untuk menyimpan satu artikel pada halaman detail.

Kenapa Map?

Karena satu artikel dari API berbentuk seperti objek JSON:

{
  "id_artikel": 1,
  "judul_artikel": "Ramen",
  "isi_artikel": "..."
}

Key-nya berupa String.

Value-nya bisa bermacam-macam tipe, sehingga menggunakan dynamic.

Tanda ? digunakan karena sebelum data dari API selesai diambil, artikel masih bisa bernilai null.


int? kategoriTerpilih;

Digunakan untuk menyimpan ID kategori yang dipilih user.

Contohnya:

kategoriTerpilih = 3;

Kenapa int?

Karena ID kategori dari database berupa angka.

Kenapa menggunakan ?

Karena saat pertama kali halaman dibuka, user belum memilih kategori.


dynamic pada:

gambarArtikelUrl(dynamic gambar)

Digunakan karena data gambar dari API bisa memiliki bentuk berbeda.

Contohnya bisa:

null

"ramen.jpg"

"uploads/ramen.jpg"

"http://192.168.1.5:8000/uploads/ramen.jpg"

Karena bentuk datanya belum tentu sama, parameter diterima sebagai dynamic.


1.4. HUBUNGAN ANTAR KODE

Alurnya:

API
↓
List<dynamic> artikel
↓
ListView.builder
↓
artikel[index]
↓
Map artikel
↓
item['judul_artikel']
↓
Text


1.5. HAL YANG WAJIB DIPAHAMI

- String digunakan untuk teks.
- int digunakan untuk angka bulat.
- bool digunakan untuk true/false.
- List digunakan untuk banyak data.
- Map digunakan untuk satu objek/data JSON.
- dynamic digunakan ketika tipe data belum dikunci.
- ? berarti nullable atau boleh null.


1.6. CONTOH PERTANYAAN GURU

1. Apa fungsi List<dynamic> artikel?

2. Kenapa menggunakan dynamic?

3. Apa perbedaan String dan String?

4. Kenapa artikel di home menggunakan List, sedangkan detail menggunakan Map?

5. Apa fungsi tanda ??


1.7. CONTOH JAWABAN

Pertanyaan:
"List<dynamic> artikel itu untuk apa?"

Jawaban:
"Itu untuk menampung daftar artikel dari API, Pak. Karena datanya berupa banyak artikel saya menggunakan List. Saya menggunakan dynamic karena isi setiap artikel bisa memiliki tipe data yang berbeda, seperti id berupa int dan judul berupa String."


Pertanyaan:
"Kenapa menggunakan String? pesanError?"

Jawaban:
"Karena pesan error belum tentu ada, Pak. Kalau null berarti belum ada error. Kalau terjadi error, variabel itu diisi teks pesan error."


Pertanyaan:
"Kenapa home menggunakan List sedangkan detail menggunakan Map?"

Jawaban:
"Karena home menampilkan banyak artikel sehingga menggunakan List. Sedangkan detail hanya menampilkan satu artikel sehingga menggunakan Map."


==================================================
2. DEKLARASI VARIABEL
==================================================

2.1. KONSEP SINGKAT

Beberapa cara deklarasi yang digunakan di Dart:

var
→ Tipe ditentukan otomatis oleh Dart berdasarkan nilai awal.

final
→ Variabel hanya bisa diberi nilai satu kali.

const
→ Nilainya sudah pasti sejak compile-time dan tidak berubah.

late
→ Variabel akan diisi nanti sebelum digunakan.

Tipe eksplisit
→ Kita menentukan langsung tipe datanya, misalnya String, int, atau bool.

?
→ Variabel boleh bernilai null.


2.2. PENERAPAN DI PROJECT

Di main.dart:

const BlogApp({super.key});

const Color(0xFFF28C28);

const PostListScreen();


Di home_page.dart:

final response = await http.get(...);

dynamic item = artikel[index];

String judul = (...).toString();


Di add_post_page.dart:

final formKey = GlobalKey<FormState>();

final judulController = TextEditingController();

late http.Response response;

var request = http.MultipartRequest('POST', url);


Di api_config.dart:

const String apiBaseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://192.168.1.5:8000'
);


2.3. PENJELASAN

CONST

Contoh:

const Color(0xFFF28C28);

Digunakan untuk nilai yang sudah diketahui dan tidak berubah.

Contohnya:

- warna
- widget statis
- teks yang nilainya tetap
- konfigurasi tertentu


FINAL

Contoh:

final judulController = TextEditingController();

final formKey = GlobalKey<FormState>();

final response = await http.get(...);

final berarti variabel tersebut tidak bisa diberi nilai baru setelah diinisialisasi.

Contoh:

final judulController = TextEditingController();

Controller dibuat sekali dan digunakan selama halaman tersebut aktif.


VAR

Contoh:

var request = http.MultipartRequest('POST', url);

Dart akan menentukan tipe request berdasarkan nilai yang diberikan.

var juga sering digunakan dalam looping:

for (var item in list) {
  ...
}

Karena tipe item sudah dapat diketahui dari data yang sedang di-loop.


LATE

Contoh:

late http.Response response;

Variabel response belum langsung diberi nilai.

Response baru diberikan setelah program menentukan cara mengirim data.

Misalnya:

Jika tidak ada gambar:
→ http.post()

Jika ada gambar:
→ MultipartRequest

Setelah salah satu proses tersebut selesai, response baru digunakan:

if (response.statusCode == 200) {
  ...
}

Jadi late berarti:

"Saya belum mengisi variabel ini sekarang, tetapi saya menjamin variabel ini akan diisi sebelum digunakan."


TIPE EKSPLISIT

Contoh:

String judul;

int? kategoriTerpilih;

bool isLoading;

Digunakan agar tipe data lebih jelas dan program lebih aman.


2.4. HAL YANG WAJIB DIPAHAMI

var
→ Dart menentukan tipe secara otomatis.

final
→ Hanya bisa diisi satu kali.

const
→ Nilai konstan sejak compile-time.

late
→ Diisi nanti sebelum digunakan.

String/int/bool
→ Tipe data ditentukan langsung.


2.5. CONTOH PERTANYAAN GURU

1. Kenapa formKey menggunakan final?

2. Kenapa controller menggunakan final?

3. Apa fungsi late http.Response response?

4. Kapan menggunakan const?

5. Apa perbedaan final dan const?


2.6. CONTOH JAWABAN

Pertanyaan:
"Kenapa formKey menggunakan final?"

Jawaban:
"Karena formKey hanya dibuat satu kali selama halaman digunakan dan tidak perlu diganti. Jadi saya menggunakan final supaya referensinya tidak berubah."


Pertanyaan:
"Apa fungsi late?"

Jawaban:
"Late digunakan karena response belum bisa ditentukan di awal. Response baru diisi nanti, tergantung apakah user mengirim artikel dengan gambar atau tanpa gambar. Sebelum digunakan untuk mengecek statusCode, response sudah pasti diisi."


Pertanyaan:
"Kapan menggunakan const?"

Jawaban:
"Saya menggunakan const untuk nilai yang sudah pasti dan tidak berubah, seperti warna dan widget yang tidak membutuhkan perubahan state."


==================================================
3. WIDGET
==================================================

3.1. KONSEP SINGKAT

Widget adalah komponen pembentuk tampilan Flutter.

Semua bagian UI di Flutter pada dasarnya tersusun dari widget.

Widget dapat memiliki parent dan child.

Contoh:

Scaffold
└── Column
    └── Expanded
        └── ListView.builder


3.2. CONTOH DI HOME

Scaffold(
  body: SafeArea(
    child: Column(
      children: [
        Padding(...),
        Expanded(
          child: RefreshIndicator(
            child: pilihTampilan(),
          ),
        ),
      ],
    ),
  ),
  floatingActionButton: FloatingActionButton(...),
)


3.3. WIDGET PENTING

SCAFFOLD

Scaffold adalah kerangka utama halaman.

Di CicipYuk digunakan untuk menampung:

- body
- floatingActionButton
- bagian halaman lainnya


COLUMN

Column menyusun widget secara vertikal.

Contoh:

Column(
  children: [
    logo,
    judul,
    daftarArtikel
  ],
)


ROW

Row menyusun widget secara horizontal.

Contohnya digunakan untuk menyusun nama penerbit dan ikon.


EXPANDED

Expanded digunakan agar widget mengambil ruang yang tersedia.

Di CicipYuk digunakan untuk ListView.

Contoh:

Column(
  children: [
    Header(),
    Expanded(
      child: ListView.builder(...)
    )
  ],
)

Tanpa Expanded, ListView yang berada di dalam Column bisa mengalami masalah karena tinggi yang tersedia tidak jelas.


LISTVIEW.BUILDER

Digunakan untuk menampilkan daftar artikel.

Contoh:

ListView.builder(
  itemCount: artikel.length,
  itemBuilder: (context, index) {
    return kartuArtikel(artikel[index]);
  },
)


itemCount
→ Menentukan jumlah artikel yang ditampilkan.

itemBuilder
→ Membuat widget untuk setiap artikel.


CONTAINER

Digunakan untuk membuat wadah dan mengatur tampilan seperti:

- ukuran
- warna
- margin
- decoration


PADDING

Digunakan untuk memberikan jarak antara isi widget dengan bagian dalam widget.


CLIPRRECT

Digunakan untuk membuat sudut widget atau gambar menjadi melengkung.


SIZEDBOX

Digunakan untuk memberikan jarak atau ukuran tertentu.

Contoh:

SizedBox(height: 8)


INKWELL

Digunakan agar widget dapat menerima sentuhan.

Pada kartu artikel:

InkWell(
  onTap: () {
    Navigator.push(...);
  },
)

Saat kartu ditekan, aplikasi berpindah ke halaman detail.


IMAGE.ASSET

Digunakan untuk gambar lokal yang ada di dalam aplikasi.

Contoh:

Image.asset(
  'assets/logo-cicipyuk-clean.png'
)


IMAGE.NETWORK

Digunakan untuk gambar dari server melalui URL.

Contoh:

Image.network(gambar)


IMAGE.FILE

Digunakan untuk menampilkan file gambar yang ada di perangkat.

Contohnya saat user baru memilih gambar dari galeri.


3.4. PERBEDAAN IMAGE

Image.asset
→ Gambar berasal dari asset aplikasi.

Image.network
→ Gambar berasal dari server/internet.

Image.file
→ Gambar berasal dari file di perangkat.


3.5. HUBUNGAN WIDGET DI HOME

Scaffold
↓
SafeArea
↓
Column
↓
Expanded
↓
RefreshIndicator
↓
ListView.builder
↓
Container
↓
InkWell
↓
Column
↓
Text / Image


3.6. HAL YANG WAJIB DIPAHAMI

- Widget adalah komponen UI Flutter.
- Parent adalah widget yang membungkus child.
- Column untuk susunan vertikal.
- Row untuk susunan horizontal.
- Expanded untuk mengisi ruang yang tersedia.
- ListView.builder untuk daftar yang dapat di-scroll.
- InkWell untuk interaksi klik.
- Image.asset untuk asset lokal.
- Image.network untuk gambar dari server.
- Image.file untuk file gambar dari perangkat.


3.7. CONTOH JAWABAN GURU

Pertanyaan:
"Kenapa menggunakan ListView.builder?"

Jawaban:

"Karena artikel berasal dari API dan jumlahnya bisa banyak, Pak. ListView.builder cocok untuk daftar yang bisa di-scroll dan membuat item sesuai kebutuhan tampilan."


Pertanyaan:
"Fungsi InkWell?"

Jawaban:

"InkWell digunakan supaya kartu artikel bisa ditekan. Saat ditekan, onTap menjalankan Navigator.push untuk membuka halaman detail."


==================================================
4. STATEFULWIDGET DAN STATELESSWIDGET
==================================================

4.1. KONSEP

StatelessWidget
→ Widget yang tidak memiliki state yang berubah.

StatefulWidget
→ Widget yang memiliki state yang dapat berubah selama aplikasi berjalan.


4.2. PENERAPAN

main.dart:

class BlogApp extends StatelessWidget {
  ...
}


home_page.dart:

class PostListScreen extends StatefulWidget {
  ...
}


Halaman yang menggunakan StatefulWidget:

1. PostListScreen
2. AddPostPage
3. PostDetailScreen
4. EditPostPage

Sedangkan:

BlogApp
→ StatelessWidget


4.3. KENAPA BLOGAPP STATELESS?

BlogApp hanya mengatur:

- MaterialApp
- tema
- font
- halaman awal

Tidak ada data yang berubah di dalamnya.

Karena itu tidak membutuhkan State.


4.4. KENAPA HOME STATEFUL?

Karena ada data yang berubah.

Contohnya:

List<dynamic> artikel = [];

bool isLoading = true;

String? pesanError;


Alurnya:

1. Halaman dibuka.
2. isLoading = true.
3. initState() menjalankan getArtikel().
4. Flutter meminta data ke API.
5. Data berhasil diterima.
6. artikel diisi.
7. isLoading diubah menjadi false.
8. setState() dipanggil.
9. UI dibuat ulang.
10. Daftar artikel ditampilkan.


4.5. FUNGSI SETSTATE

setState() digunakan untuk memberi tahu Flutter:

"State saya berubah, tolong rebuild UI."

Contoh:

setState(() {
  artikel.addAll(dataBaru);
  isLoading = false;
});


Kalau data sudah berubah tetapi tidak menggunakan setState, Flutter belum tentu menggambar ulang UI.


4.6. INITSTATE

initState() dipanggil satu kali ketika StatefulWidget mulai dibuat.

Di project digunakan untuk mengambil data awal.

Contoh:

@override
void initState() {
  super.initState();
  getArtikel();
}


Pada form:

getKategori();


4.7. DISPOSE

dispose() dipanggil ketika halaman sudah tidak digunakan.

Controller dibersihkan di sini.

Contoh:

@override
void dispose() {
  judulController.dispose();
  isiController.dispose();
  super.dispose();
}


Tujuannya untuk membersihkan resource yang sudah tidak digunakan.


4.8. MOUNTED

mounted digunakan untuk mengecek apakah State masih terpasang di widget tree.

Ini penting karena request HTTP bersifat asynchronous.

Contohnya:

if (!mounted) return;

setState(() {
  ...
});


Artinya:

"Kalau halaman sudah ditutup, jangan lanjut melakukan setState."


4.9. STATE DI SETIAP HALAMAN

Home:

- artikel
- isLoading
- pesanError


Add:

- kategoriTerpilih
- penerbitTerpilih
- gambarTerpilih
- lagiMenyimpan
- daftarKategori


Edit:

- data artikel lama
- kategoriTerpilih
- penerbitTerpilih
- gambarTerpilih
- lagiMenyimpan


Detail:

- artikel
- lagiMenghapus
- loading/error


4.10. CONTOH JAWABAN

"Kenapa home Stateful?"

"Karena data di home berubah, Pak. Awalnya artikel masih kosong dan isLoading true. Setelah API mengembalikan data, artikel diisi dan isLoading menjadi false. Karena ada perubahan state, saya menggunakan StatefulWidget dan setState."


==================================================
5. INPUT FORM
==================================================

5.1. KONSEP

Input form digunakan untuk menerima data dari user.

Di CicipYuk digunakan untuk:

- Judul
- Kategori
- Penerbit
- Penulis
- Isi artikel
- Gambar


Widget yang digunakan:

- Form
- TextFormField
- DropdownButtonFormField
- TextEditingController
- validator


5.2. FORM KEY

Contoh:

final formKey = GlobalKey<FormState>();

Digunakan untuk mengontrol dan melakukan validasi terhadap Form.


5.3. TEXTEDITINGCONTROLLER

Contoh:

final judulController = TextEditingController();

Controller digunakan untuk mengambil teks yang diketik user.

Contoh:

String judul = judulController.text.trim();


5.4. ALUR INPUT

User mengetik
↓
TextFormField
↓
TextEditingController
↓
judulController.text
↓
validate()
↓
POST / PUT
↓
Server


5.5. VALIDASI

Sebelum dikirim:

if (!formKey.currentState!.validate()) {
  return;
}


Artinya:

Jalankan semua validator.

Jika ada yang gagal:
→ fungsi berhenti.

Jika semua berhasil:
→ proses pengiriman dilanjutkan.


5.6. CONTOH VALIDATOR

validator: (value) {
  String v = (value ?? '').trim();

  if (v.isEmpty) {
    return 'Judul wajib diisi';
  }

  if (v.length > 200) {
    return 'Judul maksimal 200 karakter';
  }

  return null;
}


return null
→ validasi berhasil.

return teks error
→ validasi gagal.


5.7. DROPDOWN KATEGORI

Kategori diambil dari API:

GET /api/kategori

Kemudian disimpan di daftarKategori.

Data tersebut dibuat menjadi DropdownMenuItem.

Ketika user memilih:

onChanged: (value) {
  setState(() {
    kategoriTerpilih = value;
  });
}


Jadi yang disimpan adalah ID kategori.


5.8. PEMILIHAN GAMBAR

Menggunakan image_picker.

Contoh:

XFile? image = await picker.pickImage(
  source: ImageSource.gallery
);


Setelah gambar dipilih:

1. Cek ukuran.
2. Cek format.
3. Simpan ke gambarTerpilih.
4. Tampilkan preview.
5. Saat submit, upload menggunakan MultipartRequest.


Ukuran maksimal:

5 MB


Format yang diperiksa:

- JPG
- JPEG
- PNG
- WEBP


5.9. FORM EDIT

Form edit berbeda dengan tambah.

Tambah:
→ Form awalnya kosong.

Edit:
→ Form diisi dengan data artikel lama.

Contoh:

judulController.text =
    (widget.artikel['judul_artikel'] ?? '').toString();


Jadi user tinggal mengubah data yang diperlukan.


5.10. CONTOH JAWABAN

"Bagaimana mengambil teks judul?"

"Pakainya TextEditingController, Pak. TextFormField dihubungkan dengan judulController. Setelah user mengetik, saya bisa mengambil nilainya menggunakan judulController.text."


"Kalau judul kosong?"

"Form tidak dikirim. validate() menjalankan validator. Kalau judul kosong, validator mengembalikan pesan 'Judul wajib diisi', sehingga proses berhenti."


==================================================
6. NAVIGATOR
==================================================

6.1. KONSEP

Navigator digunakan untuk berpindah halaman.

Push:
→ Membuka halaman baru.

Pop:
→ Kembali ke halaman sebelumnya.


6.2. ALUR HALAMAN CICIPYUK

PostListScreen
      |
      +----> AddPostPage
      |
      +----> PostDetailScreen
                    |
                    +----> EditPostPage


6.3. HOME KE ADD

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const AddPostPage(),
  ),
);


6.4. HOME KE DETAIL

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PostDetailScreen(
      postId: id,
    ),
  ),
);


ID artikel dikirim ke halaman detail.

Tujuannya agar detail tahu artikel mana yang harus diambil.


6.5. DETAIL KE EDIT

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => EditPostPage(
      artikel: artikel,
    ),
  ),
);


Data satu artikel dikirim ke halaman edit.


6.6. POP BIASA

Navigator.pop(context);

Digunakan untuk kembali ke halaman sebelumnya tanpa mengirim hasil.


6.7. POP DENGAN HASIL

Navigator.pop(context, true);

true digunakan untuk memberi tahu halaman sebelumnya bahwa suatu proses berhasil.


Contoh:

Tambah berhasil
↓
Navigator.pop(context, true)
↓
Kembali ke Home
↓
.then(...)
↓
getArtikel()
↓
Data terbaru ditampilkan


6.8. KENAPA MENGGUNAKAN .THEN()?

Contoh:

Navigator.push(...).then((hasil) {
  getArtikel();
});


Setelah halaman berikutnya ditutup, getArtikel() dipanggil lagi.

Tujuannya supaya data di home selalu diperbarui.


6.9. CONTOH JAWABAN

"Kenapa setelah tambah artikel daftar langsung update?"

"Karena setelah tambah berhasil saya menggunakan Navigator.pop(context, true). Di halaman home ada .then() yang memanggil getArtikel() lagi. Jadi setelah kembali dari halaman tambah, aplikasi mengambil data terbaru dari server."


==================================================
7. PACKAGE
==================================================

7.1. KONSEP

Package adalah kode tambahan yang dibuat untuk membantu pengembangan aplikasi.

Package ditambahkan melalui:

pubspec.yaml

Kemudian dijalankan:

flutter pub get

Setelah itu package bisa digunakan dengan import.


7.2. PACKAGE DI CICIPYUK

http
→ Komunikasi dengan REST API.

image_picker
→ Memilih gambar dari galeri.

google_fonts
→ Menggunakan font Google.

http_parser
→ Menentukan MIME type file gambar.


7.3. HTTP

Contoh:

import 'package:http/http.dart' as http;


Digunakan untuk:

http.get()
http.post()
http.put()
http.delete()
http.MultipartRequest()


Fungsinya adalah menghubungkan Flutter dengan REST API.


7.4. IMAGE_PICKER

Contoh:

final ImagePicker picker = ImagePicker();

XFile? image = await picker.pickImage(
  source: ImageSource.gallery,
);


Hasilnya berupa XFile.

XFile digunakan untuk:

- preview gambar
- mengambil path
- upload gambar


7.5. GOOGLE_FONTS

Contoh:

GoogleFonts.plusJakartaSansTextTheme()


Digunakan untuk menggunakan font Plus Jakarta Sans pada aplikasi.


7.6. HTTP_PARSER

Digunakan untuk menentukan MIME type gambar.

Contoh:

.jpg
→ image/jpeg

.png
→ image/png

.webp
→ image/webp


MIME type tersebut dikirim ketika upload file.


7.7. INTL

Package intl terdapat di pubspec.yaml.

Namun berdasarkan kode project:

intl belum di-import di folder lib.

Jadi untuk ujian lebih aman menjawab:

"Package intl sudah ada di project, tetapi belum digunakan langsung di kode Dart saya."


7.8. PACKAGE LAIN

cupertino_icons
→ Digunakan untuk kebutuhan ikon tertentu.

flutter_native_splash
→ Konfigurasi splash screen.

flutter_launcher_icons
→ Konfigurasi ikon aplikasi.

Ketiganya tidak digunakan secara langsung melalui import di kode Dart.


7.9. CONTOH JAWABAN

"Package http digunakan untuk apa?"

"Untuk komunikasi dengan REST API, Pak. GET digunakan untuk mengambil data, POST untuk menambah, PUT untuk mengedit, DELETE untuk menghapus, dan MultipartRequest untuk upload gambar."


==================================================
8. ASSET DAN FONT
==================================================

8.1. KONSEP

Asset adalah file yang disimpan di dalam aplikasi.

Contohnya:

- gambar
- logo
- icon
- file lokal lainnya


Font adalah jenis huruf yang digunakan aplikasi.


8.2. ASSET DI PUBSPEC

Contoh:

flutter:
  uses-material-design: true

  assets:
    - assets/logo-cicipyuk.jpg
    - assets/logo-cicipyuk-clean.png


Artinya Flutter mengetahui bahwa dua file tersebut merupakan asset aplikasi.


8.3. PEMAKAIAN ASSET

Contoh:

Image.asset(
  'assets/logo-cicipyuk-clean.png',
)


Digunakan untuk menampilkan logo CicipYuk.


8.4. ERROR BUILDER

Contoh:

Image.asset(
  'assets/logo-cicipyuk-clean.png',
  errorBuilder: (c, e, s) {
    return const Icon(Icons.restaurant);
  },
)


Jika gambar gagal dibaca, aplikasi menampilkan Icon sebagai pengganti.


8.5. FONT

CicipYuk tidak menggunakan font lokal.

Tidak ada konfigurasi:

fonts:

di pubspec.yaml.

Sebagai gantinya menggunakan package google_fonts.

Contoh:

textTheme:
  GoogleFonts.plusJakartaSansTextTheme()


Jadi aplikasi menggunakan Plus Jakarta Sans.


8.6. PERBEDAAN GAMBAR

Logo:

Image.asset()
→ karena file berada di dalam aplikasi.


Gambar artikel:

Image.network()
→ karena gambar berasal dari server.


Preview gambar:

Image.file()
→ karena gambar berasal dari file yang dipilih user dari perangkat.


8.7. CONTOH JAWABAN

"Logo di aplikasi berasal dari mana?"

"Logo berasal dari asset lokal, Pak. File dimasukkan ke folder assets, didaftarkan di pubspec.yaml, lalu ditampilkan menggunakan Image.asset."


"Font yang digunakan?"

"Saya menggunakan Plus Jakarta Sans melalui package google_fonts. Jadi saya tidak menggunakan file font .ttf lokal."


==================================================
9. REST API
==================================================

9.1. KONSEP

REST API digunakan sebagai penghubung antara aplikasi Flutter dengan server.

Alurnya:

Flutter
↓
HTTP Request
↓
REST API
↓
Server
↓
Database
↓
Server
↓
JSON Response
↓
Flutter
↓
UI


9.2. BASE URL

Di api_config.dart:

const String apiBaseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://192.168.1.5:8000'
);


Base URL adalah alamat utama server API.


9.3. ENDPOINT YANG DIGUNAKAN

GET
/api/artikel
→ Mengambil daftar artikel.

GET
/api/artikel/{id}
→ Mengambil satu artikel berdasarkan ID.

POST
/api/artikel
→ Menambah artikel.

PUT
/api/artikel/{id}
→ Mengubah artikel.

DELETE
/api/artikel/{id}
→ Menghapus artikel.

GET
/api/kategori
→ Mengambil daftar kategori.

GET
/api/penerbit
→ Mengambil daftar penerbit.


9.4. CRUD

CREATE
→ POST

READ
→ GET

UPDATE
→ PUT

DELETE
→ DELETE


Project CicipYuk sudah menerapkan CRUD lengkap.


9.5. CONTOH GET

final response = await http
    .get(
      Uri.parse('$apiBaseUrl/api/artikel'),
    )
    .timeout(
      const Duration(seconds: 15),
    );


Penjelasan:

http.get()
→ Mengirim request GET.

Uri.parse()
→ Mengubah String URL menjadi Uri.

apiBaseUrl
→ Alamat server.

'/api/artikel'
→ Endpoint artikel.

timeout()
→ Membatasi waktu tunggu request.


9.6. CEK STATUS

if (response.statusCode == 200) {
  ...
}


Status 200:

→ Request berhasil.


Status 201:

→ Data berhasil dibuat.


Status 204:

→ Request berhasil tetapi server tidak mengirim isi response.


9.7. JSON DECODE

Contoh:

dynamic body = jsonDecode(response.body);


response.body awalnya berupa teks JSON.

jsonDecode()
→ Mengubah teks JSON menjadi struktur Dart seperti:

Map

atau

List


9.8. RESPONSE BISA BERBENTUK LIST ATAU MAP

Contoh List:

[
  {...},
  {...}
]


Contoh Map:

{
  "data": [
    {...},
    {...}
  ]
}


Karena itu kode mengecek:

if (body is Map && body['data'] != null) {
  dataBaru = body['data'];
} else if (body is List) {
  dataBaru = body;
}


9.9. POST JSON

Contoh:

response = await http.post(
  Uri.parse('$apiBaseUrl/api/artikel'),
  headers: {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  },
  body: jsonEncode({
    'judul_artikel': judul,
    'isi_artikel': isi,
    'id_kategori': kategoriTerpilih,
    'id_penerbit': penerbitTerpilih,
    'penulis_artikel': penulis,
  }),
);


Accept:

→ Meminta server mengembalikan JSON.


Content-Type:

→ Memberi tahu server bahwa data yang dikirim adalah JSON.


jsonEncode():

→ Mengubah Map Dart menjadi teks JSON.


9.10. POST DENGAN GAMBAR

JSON tidak digunakan untuk mengirim file gambar secara langsung.

Karena itu digunakan:

MultipartRequest


Contoh:

var request = http.MultipartRequest(
  'POST',
  url,
);


Data teks:

request.fields['judul_artikel'] = judul;


File:

request.files.add(
  await http.MultipartFile.fromPath(
    'gambar_artikel',
    gambarTerpilih!.path,
    filename: gambarTerpilih!.name,
    contentType: mediaTypeForImage(
      gambarTerpilih!.name,
    ),
  ),
);


Jadi:

fields
→ untuk data teks.

files
→ untuk file gambar.


9.11. PUT

Digunakan pada halaman edit.

Contoh endpoint:

/api/artikel/{id}


Fungsinya untuk mengubah artikel yang sudah ada.


9.12. DELETE

Digunakan pada halaman detail.

Contoh:

final response = await http.delete(
  Uri.parse('$apiBaseUrl/api/artikel/$id'),
);


Jika:

statusCode == 200

atau:

statusCode == 204

berarti proses delete berhasil.


9.13. TRY-CATCH

Request API dibungkus try-catch.

Tujuannya untuk menangani error seperti:

- Server tidak aktif.
- Tidak ada koneksi.
- Request timeout.
- Error dari server.


9.14. TIMEOUT

Contohnya:

Duration(seconds: 15)

Duration(seconds: 20)

Duration(seconds: 30)


Digunakan supaya aplikasi tidak menunggu server tanpa batas.


9.15. CONTOH JAWABAN

"POST dan Multipart bedanya apa?"

"Kalau tidak ada gambar saya bisa menggunakan POST JSON biasa. Kalau ada gambar saya menggunakan MultipartRequest karena file gambar perlu dikirim sebagai multipart. Data teks dikirim melalui fields dan file dikirim melalui files."


"CRUD di project kamu apa saja?"

"CREATE menggunakan POST, READ menggunakan GET, UPDATE menggunakan PUT, dan DELETE menggunakan DELETE."


==================================================
10. IMPLEMENTASI REST API KE UI
==================================================

10.1. KONSEP

Implementasi REST API berarti data dari server tidak hanya diambil, tetapi diproses sampai akhirnya tampil di UI.


10.2. ALUR UTAMA

http.get()
↓
response
↓
jsonDecode()
↓
List / Map
↓
setState()
↓
artikel
↓
ListView.builder
↓
kartuArtikel()
↓
Text / Image


10.3. GET ARTIKEL

Contoh:

Future<void> getArtikel() async {

  setState(() {
    isLoading = true;
    pesanError = null;
  });

  final response = await http.get(...);

  if (response.statusCode == 200) {

    dynamic body = jsonDecode(response.body);

    List dataBaru = ...;

    setState(() {
      artikel.clear();
      artikel.addAll(dataBaru);
      isLoading = false;
    });
  }
}


10.4. KENAPA artikel.clear() DAN addAll()?

Kode:

artikel.clear();
artikel.addAll(dataBaru);


Digunakan untuk mengosongkan data lama dan memasukkan data terbaru.

Artinya:

Data lama
↓
clear()
↓
kosong
↓
addAll(dataBaru)
↓
data terbaru


10.5. PILIHTAMPILAN()

Fungsi ini menentukan UI yang harus ditampilkan.

Contoh:

Widget pilihTampilan() {

  if (isLoading) {
    return tampilanLoading();
  }

  if (pesanError != null) {
    return tampilanError();
  }

  if (artikel.isEmpty) {
    return tampilanKosong();
  }

  return daftarArtikel();
}


Ada 4 kondisi:

1. Loading
2. Error
3. Data kosong
4. Data tersedia


10.6. DAFTAR ARTIKEL

Jika data tersedia:

return ListView.builder(
  itemCount: artikel.length,
  itemBuilder: (context, index) {
    return kartuArtikel(
      artikel[index],
    );
  },
);


Setiap index mewakili satu artikel.


10.7. KARTU ARTIKEL

Contoh:

Widget kartuArtikel(dynamic item) {

  String gambar = gambarArtikelUrl(
    item['gambar_artikel']
        ?? item['gambar']
        ?? item['image'],
  );

  String judul =
      (item['judul_artikel']
          ?? item['title']
          ?? '-')
      .toString();

  ...
}


Data artikel dibaca dari Map.


10.8. OPERATOR ??

Contoh:

item['judul_artikel']
    ?? item['title']
    ?? '-'


Artinya:

1. Coba ambil judul_artikel.
2. Kalau null, coba ambil title.
3. Kalau masih null, gunakan "-".

Ini disebut fallback.


10.9. HELPER GAMBAR

gambarArtikelUrl()

Digunakan untuk mengubah data gambar menjadi URL yang dapat digunakan Image.network.


Contoh data:

ramen.jpg

bisa diubah menjadi:

http://192.168.1.5:8000/uploads/ramen.jpg


Kalau datanya sudah berupa URL lengkap, helper tidak perlu menambahkan base URL lagi.


10.10. DETAIL ARTICLE

Halaman detail pertama mencoba:

GET /api/artikel/{id}


Jika endpoint tersebut gagal, aplikasi memiliki fallback:

GET /api/artikel


Kemudian semua artikel dicari satu per satu berdasarkan ID.


Contoh:

for (var item in list) {

  String idItem =
      (item['id'] ?? item['id_artikel']).toString();

  if (idItem == widget.postId.toString()) {
    data = item;
    break;
  }
}


ID diubah menjadi String agar:

1

dan:

"1"

bisa dibandingkan dengan cara yang sama.


10.11. REFRESH SETELAH CRUD

Setelah tambah:

POST
↓
berhasil
↓
pop(true)
↓
Home
↓
getArtikel()
↓
data terbaru


Setelah edit:

PUT
↓
berhasil
↓
pop(true)
↓
Home
↓
getArtikel()


Setelah hapus:

DELETE
↓
berhasil
↓
pop(true)
↓
Home
↓
getArtikel()


10.12. CONTOH JAWABAN

"Bagaimana data API bisa muncul di home?"

"Pertama getArtikel mengirim GET ke API. Response JSON diubah menggunakan jsonDecode menjadi List atau Map. Data tersebut dimasukkan ke variabel artikel menggunakan setState. Setelah itu ListView.builder melakukan looping dan setiap item dibuat menjadi kartu artikel yang berisi Text dan Image."


==================================================
RANGKUMAN WAJIB SEBELUM UJIAN
==================================================

1. TIPE DATA

List
→ Banyak artikel.

Map
→ Satu artikel.

String
→ Teks.

int
→ ID/angka.

bool
→ Status true/false.

dynamic
→ Data yang tipenya fleksibel.

?
→ Boleh null.


2. DEKLARASI

var
→ Tipe ditentukan Dart.

final
→ Hanya bisa diisi satu kali.

const
→ Nilai konstan.

late
→ Akan diisi nanti sebelum digunakan.


3. WIDGET

Scaffold
→ Kerangka halaman.

Column
→ Susunan vertikal.

Row
→ Susunan horizontal.

Expanded
→ Mengisi ruang yang tersedia.

ListView.builder
→ Menampilkan daftar.

Container
→ Wadah/tampilan.

Padding
→ Jarak bagian dalam.

ClipRRect
→ Membuat sudut melengkung.

InkWell
→ Membuat widget bisa ditekan.

Image.asset
→ Gambar lokal.

Image.network
→ Gambar dari server.

Image.file
→ Gambar dari perangkat.


4. STATE

StatelessWidget
→ Tidak memiliki state yang berubah.

StatefulWidget
→ Memiliki state yang bisa berubah.

setState()
→ Memberi tahu Flutter untuk rebuild UI.

initState()
→ Dijalankan sekali saat halaman dibuat.

dispose()
→ Membersihkan controller/resource.

mounted
→ Mengecek apakah widget masih aktif.


5. INPUT FORM

TextEditingController
→ Mengambil teks user.

Form
→ Membungkus input.

GlobalKey<FormState>
→ Mengontrol validasi form.

validator
→ Mengecek input.

Dropdown
→ Memilih kategori/penerbit.

ImagePicker
→ Memilih gambar dari galeri.


6. NAVIGATOR

push()
→ Pergi ke halaman baru.

pop()
→ Kembali.

pop(context, true)
→ Kembali sambil mengirim hasil.

then()
→ Menjalankan kode setelah halaman sebelumnya kembali.


7. PACKAGE

http
→ REST API.

image_picker
→ Galeri.

google_fonts
→ Font.

http_parser
→ MIME type gambar.

intl
→ Ada di project, tetapi belum digunakan langsung di lib.


8. ASSET

Image.asset
→ Asset lokal.

Image.network
→ Gambar server.

Image.file
→ File dari perangkat.

google_fonts
→ Font dari Google, bukan font lokal.


9. REST API

GET
→ Membaca data.

POST
→ Menambah data.

PUT
→ Mengubah data.

DELETE
→ Menghapus data.


10. ALUR DATA API

Flutter
↓
HTTP Request
↓
REST API
↓
Server
↓
Database
↓
JSON Response
↓
jsonDecode
↓
List / Map
↓
setState
↓
ListView.builder
↓
UI


==================================================
SIMULASI TANYA JAWAB GURU
==================================================

1. KENAPA HOME MENGGUNAKAN STATEFULWIDGET?

Jawaban:

"Karena data di home berubah, Pak. Awalnya artikel masih kosong dan isLoading bernilai true. Setelah data dari API berhasil diterima, artikel diisi dan isLoading menjadi false. Karena ada perubahan state, saya menggunakan StatefulWidget dan setState."


Kode yang ditunjukkan:

PostListScreen extends StatefulWidget

List<dynamic> artikel = [];

bool isLoading = true;

getArtikel();

setState();


--------------------------------------------------

2. KALAU http.get() BERHASIL, DATA YANG DIDAPAT BENTUKNYA APA?

Jawaban:

"Response dari HTTP berupa teks JSON, Pak. Kemudian saya menggunakan jsonDecode untuk mengubahnya menjadi List atau Map Dart agar bisa diproses oleh aplikasi."


Kode:

jsonDecode(response.body)


--------------------------------------------------

3. BAGAIMANA DATA API BISA SAMPAI MUNCUL DI HOME?

Jawaban:

"Pertama getArtikel melakukan http.get. Setelah response berhasil, JSON di-decode menjadi List. List tersebut dimasukkan ke variabel artikel menggunakan setState. Kemudian ListView.builder melakukan looping dan setiap item dibuat menjadi kartu artikel."


Alur:

getArtikel()
→ http.get()
→ jsonDecode()
→ setState()
→ artikel
→ ListView.builder
→ kartuArtikel()


--------------------------------------------------

4. PACKAGE HTTP DIPAKAI UNTUK APA?

Jawaban:

"Package http digunakan untuk komunikasi dengan REST API. GET untuk membaca data, POST untuk menambah, PUT untuk mengedit, DELETE untuk menghapus, dan MultipartRequest untuk upload gambar."


--------------------------------------------------

5. KENAPA formKey DAN controller MENGGUNAKAN FINAL?

Jawaban:

"Karena formKey dan controller hanya dibuat sekali selama halaman digunakan dan tidak perlu diganti. Jadi saya menggunakan final agar variabelnya tidak diberi nilai baru."


--------------------------------------------------

6. APA YANG TERJADI KETIKA USER MENEKAN SIMPAN?

Jawaban:

"Pertama form divalidasi menggunakan validate(). Kalau ada input yang salah, proses berhenti. Kalau valid, saya mengambil data dari controller, kemudian mengirim data menggunakan POST atau Multipart. Kalau berhasil, halaman ditutup menggunakan Navigator.pop(context, true), sehingga halaman home bisa mengambil data terbaru."


Alur:

validate()
→ ambil controller.text
→ cek gambar
→ POST / Multipart
→ cek statusCode
→ pop(true)
→ refresh Home


--------------------------------------------------

7. KENAPA ADA POST JSON DAN MULTIPART?

Jawaban:

"Karena kalau tidak ada gambar saya bisa menggunakan JSON biasa. Kalau ada gambar, saya menggunakan MultipartRequest karena file gambar perlu dikirim sebagai multipart. Data teks dikirim melalui fields dan gambar melalui files."


--------------------------------------------------

8. DROPDOWN KATEGORI DAPAT DATA DARI MANA?

Jawaban:

"Dari API GET /api/kategori. Data kategori disimpan di daftarKategori lalu dibuat menjadi DropdownMenuItem. Saat user memilih, ID kategori disimpan ke kategoriTerpilih."


--------------------------------------------------

9. INKWELL DIGUNAKAN UNTUK APA?

Jawaban:

"InkWell digunakan agar kartu artikel bisa ditekan. Ketika ditekan, onTap menjalankan Navigator.push untuk membuka halaman detail sambil membawa ID artikel."


--------------------------------------------------

10. KENAPA SETELAH HAPUS DAFTAR OTOMATIS UPDATE?

Jawaban:

"Setelah DELETE berhasil, saya menggunakan Navigator.pop(context, true). Halaman home menerima hasil tersebut dan menjalankan getArtikel() lagi. Jadi data yang tampil adalah data terbaru dari server."


--------------------------------------------------

11. APA FUNGSI late?

Jawaban:

"late digunakan ketika variabel belum bisa diisi saat deklarasi, tetapi saya tahu variabel tersebut akan diisi sebelum digunakan. Di project saya response bisa berasal dari POST JSON atau MultipartRequest, sehingga response dideklarasikan menggunakan late."


--------------------------------------------------

12. KENAPA GAMBAR BISA TETAP TAMPIL WALAU FORMAT DATANYA BERBEDA?

Jawaban:

"Saya menggunakan helper gambarArtikelUrl(). Helper tersebut mengecek apakah data gambar null, nama file, path uploads, atau URL lengkap. Setelah dinormalisasi menjadi URL, hasilnya digunakan oleh Image.network."


--------------------------------------------------

13. APA BEDANYA Image.asset, Image.network, DAN Image.file?

Jawaban:

"Image.asset digunakan untuk logo yang tersimpan di aplikasi. Image.network digunakan untuk gambar artikel yang berasal dari server. Image.file digunakan untuk preview gambar yang baru dipilih dari galeri."


--------------------------------------------------

14. FONT APA YANG DIGUNAKAN?

Jawaban:

"Saya menggunakan Plus Jakarta Sans melalui package google_fonts. Pengaturannya ada di main.dart menggunakan GoogleFonts.plusJakartaSansTextTheme(). Saya tidak menggunakan file font .ttf lokal."


--------------------------------------------------

15. VALIDATOR JUDUL MENGECEK APA?

Jawaban:

"Validator mengecek apakah judul kosong dan apakah panjangnya lebih dari 200 karakter. Kalau tidak valid, validator mengembalikan pesan error. Kalau valid, validator mengembalikan null."


--------------------------------------------------

16. KENAPA DETAIL PUNYA FALLBACK GET?

Jawaban:

"Pertama aplikasi mencoba GET /api/artikel/{id}. Kalau endpoint detail gagal, aplikasi mengambil semua artikel menggunakan GET /api/artikel, kemudian mencari artikel yang ID-nya sesuai. Jadi halaman detail masih bisa mendapatkan data."


--------------------------------------------------

17. APA FUNGSI mounted?

Jawaban:

"mounted digunakan untuk mengecek apakah halaman masih aktif. Karena request HTTP berjalan secara asynchronous, user bisa saja menutup halaman sebelum response selesai. Kalau halaman sudah tidak aktif, saya tidak menjalankan setState supaya tidak terjadi error."


--------------------------------------------------

18. APA BEDANYA TAMBAH DAN EDIT?

Jawaban:

"Tambah menggunakan form kosong dan POST ke /api/artikel. Edit menggunakan data lama sebagai nilai awal form dan menggunakan PUT ke /api/artikel/{id}."


==================================================
KUNCI PALING PENTING UNTUK DIHAFAL
==================================================

Kalau waktu belajar sedikit, pahami 10 alur ini:

1. API
Flutter → HTTP → Server → Database → JSON → Flutter

2. GET
GET → ambil data → jsonDecode → List/Map → UI

3. POST
Form → validate → POST → server → berhasil → pop(true)

4. PUT
Form data lama → edit → PUT → server → berhasil → pop(true)

5. DELETE
Detail → DELETE → server → berhasil → pop(true)

6. State
Data berubah → setState() → UI rebuild

7. Form
User mengetik → Controller → validate → kirim

8. Gambar
ImagePicker → XFile → validasi → Multipart → server

9. Navigator
push() → pergi
pop() → kembali
pop(true) → kembali + memberi hasil

10. Tampilan
API → artikel → ListView.builder → kartuArtikel → Text/Image


KALIMAT BESAR UNTUK MENJELASKAN PROJECT

"CicipYuk adalah aplikasi blog kuliner berbasis Flutter yang menggunakan REST API untuk berkomunikasi dengan server. Data artikel tidak disimpan langsung di aplikasi, tetapi diambil dari server menggunakan HTTP. Flutter menggunakan GET untuk membaca data, POST untuk menambah, PUT untuk mengedit, dan DELETE untuk menghapus. Data JSON yang diterima dari server diubah menggunakan jsonDecode, kemudian disimpan ke state dan ditampilkan menggunakan widget seperti ListView.builder. Untuk input, aplikasi menggunakan Form, TextEditingController, validator, dropdown, dan image_picker. Setelah proses CRUD berhasil, Navigator digunakan untuk kembali ke halaman sebelumnya dan melakukan refresh data."