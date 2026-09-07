import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import '../models/category.dart';

// Class untuk error dari API
class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() {
    return 'Error $statusCode: $message';
  }
}

class ApiService {
  // baseUrl = alamat backend
  // kalau pakai emulator android pakai 10.0.2.2
  // kalau pakai hp asli ganti dengan IP laptop
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // header untuk request json
  Map<String, String> get headers {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // ============ CATEGORY ============

  // ambil semua kategori
  Future<List<Category>> fetchCategories() async {
    var url = Uri.parse('$baseUrl/categories');
    var res = await http.get(url, headers: headers);

    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      var raw = body['data'];
      // kalau tidak ada key data, pakai body langsung
      if (raw == null) {
        raw = body;
      }

      List<Category> list = [];
      if (raw is List) {
        for (var item in raw) {
          list.add(Category.fromJson(item));
        }
      }
      return list;
    } else {
      // kalau error
      var body = jsonDecode(res.body);
      String msg = 'Gagal ambil kategori';
      if (body['message'] != null) {
        msg = body['message'].toString();
      }
      throw ApiException(msg, res.statusCode);
    }
  }

  // buat kategori baru
  Future<Category> createCategory({required String name, required String slug}) async {
    var url = Uri.parse('$baseUrl/categories');
    var bodyJson = jsonEncode({'name': name, 'slug': slug});
    var res = await http.post(url, headers: headers, body: bodyJson);

    if (res.statusCode == 200 || res.statusCode == 201) {
      var body = jsonDecode(res.body);
      var data = body['data'];
      if (data == null) {
        data = body;
      }
      return Category.fromJson(data);
    } else {
      var body = jsonDecode(res.body);
      String msg = 'Gagal buat kategori';
      if (body['message'] != null) {
        msg = body['message'].toString();
      }
      throw ApiException(msg, res.statusCode);
    }
  }

  // ============ POST ============

  // ambil semua post, bisa filter search dan kategori
  Future<List<Post>> fetchPosts({String? search, int? categoryId}) async {
    var uri = Uri.parse('$baseUrl/posts');

    // bikin query param kalau ada search atau kategori
    Map<String, String> qp = {};
    if (search != null && search.isNotEmpty) {
      qp['search'] = search;
    }
    if (categoryId != null) {
      qp['category'] = categoryId.toString();
    }
    if (qp.isNotEmpty) {
      uri = uri.replace(queryParameters: qp);
    }

    var res = await http.get(uri, headers: headers);

    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      var raw = body['data'];
      if (raw == null) {
        raw = body;
      }

      List<Post> list = [];
      if (raw is List) {
        for (var item in raw) {
          list.add(Post.fromJson(item));
        }
      }
      return list;
    } else {
      var body = jsonDecode(res.body);
      String msg = 'Gagal ambil post';
      if (body['message'] != null) {
        msg = body['message'].toString();
      }
      throw ApiException(msg, res.statusCode);
    }
  }

  // ambil 1 post berdasarkan id
  Future<Post> fetchPost(int id) async {
    var url = Uri.parse('$baseUrl/posts/$id');
    var res = await http.get(url, headers: headers);

    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      var data = body['data'];
      if (data == null) {
        data = body;
      }
      return Post.fromJson(data);
    } else {
      throw ApiException('Post tidak ditemukan', res.statusCode);
    }
  }

  // buat post baru
  Future<Post> createPost({
    required String title,
    required String content,
    String? excerpt,
    String? imageUrl,
    int? categoryId,
  }) async {
    // Map untuk data yang dikirim
    Map<String, dynamic> payload = {
      'title': title,
      'content': content,
    };
    // hanya tambah kalau tidak kosong
    if (excerpt != null && excerpt.isNotEmpty) {
      payload['excerpt'] = excerpt;
    }
    if (imageUrl != null && imageUrl.isNotEmpty) {
      payload['image_url'] = imageUrl;
    }
    if (categoryId != null) {
      payload['category_id'] = categoryId;
    }

    var url = Uri.parse('$baseUrl/posts');
    var res = await http.post(url, headers: headers, body: jsonEncode(payload));

    if (res.statusCode == 200 || res.statusCode == 201) {
      var body = jsonDecode(res.body);
      var data = body['data'];
      if (data == null) {
        data = body;
      }
      return Post.fromJson(data);
    } else {
      var body = jsonDecode(res.body);
      String msg = 'Gagal buat post';
      if (body['message'] != null) {
        msg = body['message'].toString();
      }
      throw ApiException(msg, res.statusCode);
    }
  }

  // update post
  Future<Post> updatePost(
    int id, {
    required String title,
    required String content,
    String? excerpt,
    String? imageUrl,
    int? categoryId,
  }) async {
    Map<String, dynamic> payload = {
      'title': title,
      'content': content,
    };
    if (excerpt != null && excerpt.isNotEmpty) {
      payload['excerpt'] = excerpt;
    }
    if (imageUrl != null && imageUrl.isNotEmpty) {
      payload['image_url'] = imageUrl;
    }
    if (categoryId != null) {
      payload['category_id'] = categoryId;
    }

    var url = Uri.parse('$baseUrl/posts/$id');
    var res = await http.put(url, headers: headers, body: jsonEncode(payload));

    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      var data = body['data'];
      if (data == null) {
        data = body;
      }
      return Post.fromJson(data);
    } else {
      var body = jsonDecode(res.body);
      String msg = 'Gagal update post';
      if (body['message'] != null) {
        msg = body['message'].toString();
      }
      throw ApiException(msg, res.statusCode);
    }
  }

  // hapus post
  Future<void> deletePost(int id) async {
    var url = Uri.parse('$baseUrl/posts/$id');
    var res = await http.delete(url, headers: headers);

    if (res.statusCode == 200 || res.statusCode == 204) {
      return;
    } else {
      var body = {};
      if (res.body.isNotEmpty) {
        body = jsonDecode(res.body);
      }
      String msg = 'Gagal hapus post';
      if (body['message'] != null) {
        msg = body['message'].toString();
      }
      throw ApiException(msg, res.statusCode);
    }
  }
}
