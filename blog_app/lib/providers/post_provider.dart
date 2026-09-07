import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../services/api_service.dart';

class PostProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Post> _posts = [];
  bool _isLoading = false;
  String? _error;
  String? _searchQuery;
  int? _filterCategoryId;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get searchQuery => _searchQuery;
  int? get filterCategoryId => _filterCategoryId;

  bool get hasError => _error != null;
  bool get isEmpty => !_isLoading && _posts.isEmpty && _error == null;

  Future<void> loadPosts({String? search, int? categoryId, bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }
    _searchQuery = search;
    _filterCategoryId = categoryId;
    try {
      _posts = await _api.fetchPosts(search: search, categoryId: categoryId);
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('ApiException', '').replaceAll('Exception:', '').trim();
      // Jangan kosongkan _posts agar data lama tetap tampil saat error refresh
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadPosts(search: _searchQuery, categoryId: _filterCategoryId);

  Future<Post> getPostDetail(int id) {
    return _api.fetchPost(id);
  }

  Future<bool> addPost({
    required String title,
    required String content,
    String? excerpt,
    String? imageUrl,
    int? categoryId,
  }) async {
    try {
      final created = await _api.createPost(
        title: title,
        content: content,
        excerpt: excerpt,
        imageUrl: imageUrl,
        categoryId: categoryId,
      );
      _posts.insert(0, created);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> editPost(
    int id, {
    required String title,
    required String content,
    String? excerpt,
    String? imageUrl,
    int? categoryId,
  }) async {
    try {
      final updated = await _api.updatePost(
        id,
        title: title,
        content: content,
        excerpt: excerpt,
        imageUrl: imageUrl,
        categoryId: categoryId,
      );
      final idx = _posts.indexWhere((p) => p.id == id);
      if (idx != -1) {
        _posts[idx] = updated;
        notifyListeners();
      } else {
        await refresh();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removePost(int id) async {
    // Optimistic delete dengan rollback jika gagal
    final backup = List<Post>.from(_posts);
    _posts.removeWhere((p) => p.id == id);
    notifyListeners();
    try {
      await _api.deletePost(id);
    } catch (e) {
      _posts = backup;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void setFilter({String? search, int? categoryId}) {
    loadPosts(search: search, categoryId: categoryId);
  }

  void clearFilter() {
    loadPosts(search: null, categoryId: null);
  }
}
