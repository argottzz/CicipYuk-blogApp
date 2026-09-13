import 'dart:convert';

import 'package:http_parser/http_parser.dart';

// Centralized API config
// Ganti IP cukup via --dart-define=API_URL=http://IP_BARU:8000
// Default: IP sekolah 10.2.14.97, di rumah ganti ke 192.168.1.5
const String apiBaseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://192.168.1.5:8000',
);

/// Membangun URL lengkap untuk gambar artikel.
///
/// Database hanya menyimpan nama file (mis. "seblak.jpg"), sedangkan
/// backend menyajikan file upload dari folder /uploads, jadi:
///   "seblak.jpg"  ->  "$apiBaseUrl/uploads/seblak.jpg"
///
/// Tetap kompatibel kalau suatu saat bentuk data di DB berubah:
/// - null / string kosong -> '' (UI menampilkan placeholder)
/// - URL lengkap          -> dipakai apa adanya
/// - diawali "/"          -> dianggap path dari root server
/// - diawali "uploads/"   -> tidak di-dobel prefixnya
String gambarArtikelUrl(dynamic gambar) {
  if (gambar == null) return '';
  var g = gambar.toString().trim().replaceAll('\\', '/');
  while (g.startsWith('./')) {
    g = g.substring(2);
  }
  // buang slash ganda di depan, tapi sisakan satu untuk path root
  while (g.startsWith('//')) {
    g = g.substring(1);
  }
  if (g.isEmpty || g.toLowerCase() == 'null') return '';
  if (g.startsWith('http://') || g.startsWith('https://')) return g;
  if (g.startsWith('/')) return '$apiBaseUrl$g';
  if (g.toLowerCase().startsWith('uploads/')) return '$apiBaseUrl/$g';
  return '$apiBaseUrl/uploads/$g';
}

/// Helper bersama Add/Edit (Extract Helper in-place, tanpa file baru).
/// Dipindah ke sini agar tidak duplikat di add_post_page & edit_post_page.

int? parseKategoriId(dynamic raw) {
  if (raw is Map) {
    raw = raw['id_kategori'] ?? raw['id'] ?? raw['idKategori'];
  }
  if (raw == null) return null;
  if (raw is int) return raw;
  return int.tryParse(raw.toString());
}

int? parseKategoriIdFromItem(dynamic item) {
  if (item is! Map) return null;
  return parseKategoriId(
    item['id_kategori'] ?? item['id'] ?? item['idKategori'],
  );
}

String kategoriName(dynamic item) {
  if (item is! Map) return '-';
  return (item['nama_kategori'] ?? item['name'] ?? '-').toString();
}

int? parsePenerbitId(dynamic raw) {
  if (raw is Map) {
    raw = raw['id_penerbit'] ?? raw['id'] ?? raw['idPenerbit'];
  }
  if (raw == null) return null;
  if (raw is int) return raw;
  return int.tryParse(raw.toString());
}

int? parsePenerbitIdFromItem(dynamic item) {
  if (item is! Map) return null;
  return parsePenerbitId(
    item['id_penerbit'] ?? item['id'] ?? item['idPenerbit'],
  );
}

String penerbitName(dynamic item) {
  if (item is! Map) return '-';
  return (item['nama_penerbit'] ?? item['name'] ?? '-').toString();
}

MediaType mediaTypeForImage(String filename) {
  final name = filename.toLowerCase();
  if (name.endsWith('.png')) return MediaType('image', 'png');
  if (name.endsWith('.webp')) return MediaType('image', 'webp');
  return MediaType('image', 'jpeg');
}

/// Ambil pesan validasi backend (Laravel: {message, errors:{...}})
/// agar SnackBar mudah dibaca user. Dipakai Add/Edit/Detail.
String pesanErrorBackend(String body) {
  try {
    final decoded = jsonDecode(body);
    if (decoded is Map) {
      final errors = decoded['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final parts = <String>[];
        errors.forEach((key, value) {
          if (value is List && value.isNotEmpty) {
            parts.add('${value.first}');
          } else {
            parts.add('$key: $value');
          }
        });
        return parts.join(', ');
      }
      final msg = decoded['message'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    if (body.length > 300) return '${body.substring(0, 300)}...';
    return body.isEmpty ? 'respons kosong dari server' : body;
  } catch (_) {
    if (body.length > 300) return '${body.substring(0, 300)}...';
    return body.isEmpty ? 'respons kosong dari server' : body;
  }
}
