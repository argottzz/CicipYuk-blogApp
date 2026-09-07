import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import '../models/category.dart';

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  // Ganti sesuai device:
  // Android Emulator -> 10.0.2.2
  // iOS Simulator / Web / Windows -> localhost
  // HP Fisik -> IP LAN laptop, contoh: 192.168.1.10
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  // static const String baseUrl = 'http://localhost:3000/api';

  static const Duration timeout = Duration(seconds: 10);

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Helper untuk parse response yang formatnya {status, data, message}
  dynamic _parseBody(http.Response res) {
    if (res.body.isEmpty) return null;
    try {
      return jsonDecode(res.body);
    } catch (_) {
      return res.body;
    }
  }

  void _handleError(http.Response res, dynamic body) {
    String msg = 'Terjadi kesalahan';
    if (body is Map && body['message'] != null) {
      msg = body['message'].toString();
    } else if (body is Map && body['errors'] != null) {
      msg = body['errors'].toString();
    } else if (res.body.isNotEmpty) {
      msg = res.body;
    }
    throw ApiException(msg, res.statusCode);
  }

  // ============ CATEGORIES ============

  Future<List<Category>> fetchCategories() async {
    final res = await http
        .get(Uri.parse('$baseUrl/categories'), headers: _headers)
        .timeout(timeout);
    final body = _parseBody(res);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final List data = body is Map ? (body['data'] ?? body) : body;
      if (data is List) {
        return data.map((e) => Category.fromJson(e)).toList();
      }
      return [];
    }
    _handleError(res, body);
    return [];
  }

  Future<Category> createCategory({required String name, required String slug}) async {
    final res = await http
        .post(Uri.parse('$baseUrl/categories'),
            headers: _headers, body: jsonEncode({'name': name, 'slug': slug}))
        .timeout(timeout);
    final body = _parseBody(res);
    if (res.statusCode == 201 || res.statusCode == 200) {
      final data = body is Map ? (body['data'] ?? body) : body;
      return Category.fromJson(data);
    }
    _handleError(res, body);
    throw ApiException('Gagal membuat kategori', res.statusCode);
  }

  // ============ POSTS ============

  Future<List<Post>> fetchPosts({String? search, int? categoryId}) async {
    var uri = Uri.parse('$baseUrl/posts');
    final qp = <String, String>{};
    if (search != null && search.isNotEmpty) qp['search'] = search;
    if (categoryId != null) qp['category'] = categoryId.toString();
    if (qp.isNotEmpty) uri = uri.replace(queryParameters: qp);

    final res = await http.get(uri, headers: _headers).timeout(timeout);
    final body = _parseBody(res);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final List data = body is Map ? (body['data'] ?? body) : body;
      if (data is List) return data.map((e) => Post.fromJson(e)).toList();
      return [];
    }
    _handleError(res, body);
    return [];
  }

  Future<Post> fetchPost(int id) async {
    final res = await http
        .get(Uri.parse('$baseUrl/posts/$id'), headers: _headers)
        .timeout(timeout);
    final body = _parseBody(res);
    if (res.statusCode == 200) {
      final data = body is Map ? (body['data'] ?? body) : body;
      return Post.fromJson(data is Map<String, dynamic> ? data : (data as Map).cast<String, dynamic>());
    }
    _handleError(res, body);
    throw ApiException('Post tidak ditemukan', res.statusCode);
  }

  Future<Post> createPost({
    required String title,
    required String content,
    String? excerpt,
    String? imageUrl,
    int? categoryId,
  }) async {
    final payload = {
      'title': title,
      'content': content,
      if (excerpt != null) 'excerpt': excerpt,
      if (imageUrl != null) 'image_url': imageUrl,
      if (categoryId != null) 'category_id': categoryId,
    };
    final res = await http
        .post(Uri.parse('$baseUrl/posts'), headers: _headers, body: jsonEncode(payload))
        .timeout(timeout);
    final body = _parseBody(res);
    if (res.statusCode == 201 || res.statusCode == 200) {
      final data = body is Map ? (body['data'] ?? body) : body;
      return Post.fromJson((data as Map).cast<String, dynamic>());
    }
    _handleError(res, body);
    throw ApiException('Gagal membuat post', res.statusCode);
  }

  Future<Post> updatePost(
    int id, {
    required String title,
    required String content,
    String? excerpt,
    String? imageUrl,
    int? categoryId,
  }) async {
    final payload = {
      'title': title,
      'content': content,
      if (excerpt != null) 'excerpt': excerpt,
      if (imageUrl != null) 'image_url': imageUrl,
      if (categoryId != null) 'category_id': categoryId,
    };
    final res = await http
        .put(Uri.parse('$baseUrl/posts/$id'), headers: _headers, body: jsonEncode(payload))
        .timeout(timeout);
    final body = _parseBody(res);
    if (res.statusCode == 200) {
      final data = body is Map ? (body['data'] ?? body) : body;
      return Post.fromJson((data as Map).cast<String, dynamic>());
    }
    _handleError(res, body);
    throw ApiException('Gagal update post', res.statusCode);
  }

  Future<void> deletePost(int id) async {
    final res = await http
        .delete(Uri.parse('$baseUrl/posts/$id'), headers: _headers)
        .timeout(timeout);
    final body = _parseBody(res);
    if (res.statusCode == 200 || res.statusCode == 204) return;
    _handleError(res, body);
  }
}
