import 'package:flutter/material.dart';
import '../post.dart';
import '../api_service.dart';
import '../post_card.dart';
import 'detail_page.dart';
import 'add_post_page.dart';
import 'edit_post_page.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});
  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  final ApiService _api = ApiService();
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _api.fetchPosts();
      setState(() => _posts = data);
    } catch (e) {
      setState(() => _error = e.toString());
    }
    setState(() => _isLoading = false);
  }

  void _goToDetail(int id) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => PostDetailScreen(postId: id))).then((_) => _loadPosts());
  }

  void _goToCreate() async {
    final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPostPage()));
    if (res == true) _loadPosts();
  }

  void _goToEdit(Post post) async {
    final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => EditPostPage(post: post)));
    if (res == true) _loadPosts();
  }

  Future<void> _confirmDelete(Post post) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Artikel?'),
        content: Text('Yakin hapus "${post.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(style: FilledButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (ok == true) {
      try {
        await _api.deletePost(post.id);
        setState(() => _posts.removeWhere((p) => p.id == post.id));
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Artikel dihapus'), backgroundColor: Colors.green));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal hapus: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blog App', style: TextStyle(fontWeight: FontWeight.bold)), actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadPosts)]),
      floatingActionButton: FloatingActionButton.extended(onPressed: _goToCreate, icon: const Icon(Icons.add), label: const Text('Tulis')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.cloud_off, size: 56, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(_error!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 8),
                      const Text('Pastikan backend jalan di http://localhost:8000\nUSB: adb reverse tcp:8000 tcp:8000', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 16),
                      FilledButton.icon(onPressed: _loadPosts, icon: const Icon(Icons.refresh), label: const Text('Coba lagi'))
                    ]),
                  ),
                )
              : _posts.isEmpty
                  ? Center(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.article_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        const Text('Belum ada artikel'),
                        const SizedBox(height: 16),
                        FilledButton.icon(onPressed: _goToCreate, icon: const Icon(Icons.add), label: const Text('Buat Artikel'))
                      ]),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPosts,
                      child: ListView.builder(
                        itemCount: _posts.length,
                        itemBuilder: (ctx, i) {
                          final p = _posts[i];
                          return PostCard(post: p, onTap: () => _goToDetail(p.id), onEdit: () => _goToEdit(p), onDelete: () => _confirmDelete(p));
                        },
                      ),
                    ),
    );
  }
}
