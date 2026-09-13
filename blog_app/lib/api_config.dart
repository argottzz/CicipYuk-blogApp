import 'dart:convert';

import 'package:http_parser/http_parser.dart';

const String apiBaseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://192.168.1.5:8000',
);

String gambarArtikelUrl(dynamic gambar) {
  if (gambar == null) {
    return '';
  }

  String namaFile = gambar.toString().trim();

  if (namaFile.isEmpty || namaFile.toLowerCase() == 'null') {
    return '';
  }

  if (namaFile.startsWith('http://') || namaFile.startsWith('https://')) {
    return namaFile;
  }

  if (namaFile.toLowerCase().startsWith('uploads/')) {
    return '$apiBaseUrl/$namaFile';
  }

  if (namaFile.startsWith('/')) {
    return '$apiBaseUrl$namaFile';
  }

  return '$apiBaseUrl/uploads/$namaFile';
}

int? parseKategoriId(dynamic raw) {
  if (raw is Map) {
    raw = raw['id_kategori'] ?? raw['id'];
  }

  if (raw == null) {
    return null;
  }

  if (raw is int) {
    return raw;
  }

  return int.tryParse(raw.toString());
}

int? parseKategoriIdFromItem(dynamic item) {
  if (item is! Map) {
    return null;
  }
  return parseKategoriId(item);
}

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

int? parsePenerbitIdFromItem(dynamic item) {
  if (item is! Map) {
    return null;
  }
  return parsePenerbitId(item);
}

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

MediaType mediaTypeForImage(String filename) {
  String nama = filename.toLowerCase();

  if (nama.endsWith('.png')) {
    return MediaType('image', 'png');
  }

  if (nama.endsWith('.webp')) {
    return MediaType('image', 'webp');
  }

  return MediaType('image', 'jpeg');
}

String pesanErrorBackend(String body) {
  try {
    dynamic decoded = jsonDecode(body);

    if (decoded is! Map) {
      return body;
    }

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

    dynamic msg = decoded['message'];
    if (msg is String && msg.isNotEmpty) {
      return msg;
    }

    return body;
  } catch (e) {
    return body.isEmpty ? 'respons kosong dari server' : body;
  }
}
