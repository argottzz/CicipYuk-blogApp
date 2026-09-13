import 'dart:convert';

import 'package:http_parser/http_parser.dart';

// File ini menyimpan semua pengaturan API di satu tempat.
// Tujuannya supaya kalau IP server ganti, cukup ganti di satu tempat.
//
// Cara ganti IP saat jalan:
//   flutter run --dart-define=API_URL=http://IP_BARU:8000
// Kalau tidak diisi, dipakai alamat default di bawah ini.
const String apiBaseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://192.168.1.5:8000',
);

// Langkah membuat URL gambar:
// Database hanya menyimpan nama file, contoh: "seblak.jpg"
// Sedangkan file aslinya ada di folder /uploads di server.
// Jadi "seblak.jpg" harus jadi "http://IP:8000/uploads/seblak.jpg"
String gambarArtikelUrl(dynamic gambar) {
  // 1. Kalau kosong, kembalikan teks kosong.
  // Nanti di layar akan diganti gambar placeholder.
  if (gambar == null) {
    return '';
  }

  String namaFile = gambar.toString().trim();

  // 2. Kalau kosong atau tulisan "null", anggap tidak ada gambar.
  if (namaFile.isEmpty || namaFile.toLowerCase() == 'null') {
    return '';
  }

  // 3. Kalau sudah berupa link lengkap, pakai apa adanya.
  if (namaFile.startsWith('http://') || namaFile.startsWith('https://')) {
    return namaFile;
  }

  // 4. Kalau sudah diawali "uploads/", tinggal tempel alamat server.
  if (namaFile.toLowerCase().startsWith('uploads/')) {
    return '$apiBaseUrl/$namaFile';
  }

  // 5. Kalau diawali "/", itu artinya path dari root server.
  if (namaFile.startsWith('/')) {
    return '$apiBaseUrl$namaFile';
  }

  // 6. Sisanya berarti nama file biasa, simpan di folder /uploads.
  return '$apiBaseUrl/uploads/$namaFile';
}

// Ambil id kategori dari data server.
// Bentuk datanya kadang beda-beda: bisa angka, bisa teks, bisa Map.
// Contoh Map: {"id": 1, "nama_kategori": "Kuliner"}
int? parseKategoriId(dynamic raw) {
  // Kalau datanya Map, ambil dulu isi id-nya.
  if (raw is Map) {
    raw = raw['id_kategori'] ?? raw['id'];
  }

  if (raw == null) {
    return null;
  }

  // Kalau sudah angka, langsung pakai.
  if (raw is int) {
    return raw;
  }

  // Kalau teks seperti "1", ubah jadi angka 1.
  return int.tryParse(raw.toString());
}

// Ambil id kategori dari satu baris data kategori.
int? parseKategoriIdFromItem(dynamic item) {
  if (item is! Map) {
    return null;
  }
  return parseKategoriId(item);
}

// Ambil nama kategori untuk ditampilkan di dropdown.
String kategoriName(dynamic item) {
  if (item is! Map) {
    return '-';
  }
  Object? nama = item['nama_kategori'] ?? item['name'];
  if (nama == null) {
    return '-';
  }
  return nama.toString();
}

// Ambil id penerbit, caranya sama persis seperti kategori.
int? parsePenerbitId(dynamic raw) {
  if (raw is Map) {
    raw = raw['id_penerbit'] ?? raw['id'];
  }

  if (raw == null) {
    return null;
  }

  if (raw is int) {
    return raw;
  }

  return int.tryParse(raw.toString());
}

// Ambil id penerbit dari satu baris data penerbit.
int? parsePenerbitIdFromItem(dynamic item) {
  if (item is! Map) {
    return null;
  }
  return parsePenerbitId(item);
}

// Ambil nama penerbit untuk ditampilkan di dropdown.
String penerbitName(dynamic item) {
  if (item is! Map) {
    return '-';
  }
  Object? nama = item['nama_penerbit'] ?? item['name'];
  if (nama == null) {
    return '-';
  }
  return nama.toString();
}

// Tentukan tipe file gambar untuk dikirim ke server.
// Server butuh tahu ini gambar jenis apa: jpeg, png, atau webp.
MediaType mediaTypeForImage(String filename) {
  String nama = filename.toLowerCase();

  if (nama.endsWith('.png')) {
    return MediaType('image', 'png');
  }

  if (nama.endsWith('.webp')) {
    return MediaType('image', 'webp');
  }

  // jpg dan jpeg dianggap sama: jpeg.
  return MediaType('image', 'jpeg');
}

// Baca pesan error dari server supaya mudah dipahami.
// Server (Laravel) biasanya mengirim seperti ini:
//   {"message": "...", "errors": {"judul_artikel": ["wajib diisi"]}}
String pesanErrorBackend(String body) {
  try {
    dynamic decoded = jsonDecode(body);

    // Kalau bukan Map, berarti bukan format Laravel. Tampilkan apa adanya.
    if (decoded is! Map) {
      return body;
    }

    // 1. Utamakan isi "errors" karena paling jelas.
    dynamic errors = decoded['errors'];
    if (errors is Map && errors.isNotEmpty) {
      List<String> pesan = [];
      errors.forEach((key, value) {
        if (value is List && value.isNotEmpty) {
          pesan.add(value.first.toString());
        } else {
          pesan.add('$key: $value');
        }
      });
      return pesan.join(', ');
    }

    // 2. Kalau tidak ada "errors", pakai "message".
    dynamic msg = decoded['message'];
    if (msg is String && msg.isNotEmpty) {
      return msg;
    }

    return body;
  } catch (e) {
    // Kalau body bukan JSON, tampilkan apa adanya.
    return body.isEmpty ? 'respons kosong dari server' : body;
  }
}
