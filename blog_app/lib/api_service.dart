import 'dart:convert';
import 'package:http/http.dart' as http;
import 'post.dart';
import 'category.dart';

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);
  @override
  String toString() => 'Error $statusCode: $message';
}

class ApiService {
  // BASE URL - ganti 1 tempat saja
  // HP USB + adb reverse -> http://localhost:8000
  // Emulator -> http://10.0.2.2:8000
  // HP WiFi -> http://192.168.x.x:8000
  static const String baseUrl = 'http://localhost:8000';

  Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Duration get timeout => const Duration(seconds: 10);

  List _extractList(dynamic body) {
    if (body is Map && body['data'] != null && body['data'] is List) return body['data'];
    if (body is List) return body;
    return [];
  }

  dynamic _extractData(dynamic body) {
    if (body is Map && body['data'] != null) return body['data'];
    return body;
  }

  // GET categories
  Future<List<Category>> fetchCategories() async {
    final url = Uri.parse('$baseUrl/api/categories');
    try {
      final res = await http.get(url, headers: headers).timeout(timeout);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final raw = _extractList(body);
        return raw.map((e) => Category.fromJson(e)).toList();
      }
      throw ApiException('Gagal ambil kategori', res.statusCode);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Koneksi gagal ke $baseUrl', 0);
    }
  }

  // GET posts (READ)
  Future<List<Post>> fetchPosts() async {
    final url = Uri.parse('$baseUrl/api/posts');
    try {
      final res = await http.get(url, headers: headers).timeout(timeout);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final raw = _extractList(body);
        return raw.map((e) => Post.fromJson(e)).toList();
      }
      throw ApiException('Gagal ambil artikel', res.statusCode);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Koneksi gagal ke $baseUrl. Cek adb reverse', 0);
    }
  }

  // GET detail (READ)
  Future<Post> fetchPost(int id) async {
    final url = Uri.parse('$baseUrl/api/posts/$id');
    try {
      final res = await http.get(url, headers: headers).timeout(timeout);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return Post.fromJson(_extractData(body));
      }
      if (res.statusCode == 404) throw ApiException('Artikel tidak ditemukan', 404);
      throw ApiException('Gagal ambil detail', res.statusCode);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Koneksi gagal', 0);
    }
  }

  // POST (CREATE) - 201
  Future<Post> createPost({required String title, required String content, required int categoryId}) async {
    final url = Uri.parse('$baseUrl/api/posts');
    final payload = {'title': title, 'content': content, 'category_id': categoryId};
    try {
      final res = await http.post(url, headers: headers, body: jsonEncode(payload)).timeout(timeout);
      if (res.statusCode == 200 || res.statusCode == 201) {
        return Post.fromJson(_extractData(jsonDecode(res.body)));
      }
      throw ApiException('Gagal buat artikel', res.statusCode);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Koneksi gagal', 0);
    }
  }

  // PUT (UPDATE) - 200
  Future<Post> updatePost(int id, {required String title, required String content, required int categoryId}) async {
    final url = Uri.parse('$baseUrl/api/posts/$id');
    final payload = {'title': title, 'content': content, 'category_id': categoryId};
    try {
      final res = await http.put(url, headers: headers, body: jsonEncode(payload)).timeout(timeout);
      if (res.statusCode == 200) {
        return Post.fromJson(_extractData(jsonDecode(res.body)));
      }
      throw ApiException('Gagal update', res.statusCode);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Koneksi gagal', 0);
    }
  }

  // DELETE - 200/204
  Future<void> deletePost(int id) async {
    final url = Uri.parse('$baseUrl/api/posts/$id');
    try {
      final res = await http.delete(url, headers: headers).timeout(timeout);
      if (res.statusCode == 200 || res.statusCode == 204) return;
      throw ApiException('Gagal hapus', res.statusCode);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Koneksi gagal', 0);
    }
  }
}
