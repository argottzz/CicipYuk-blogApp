import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../post.dart';
import '../api_service.dart';
import 'edit_post_page.dart';

class PostDetailScreen extends StatefulWidget {
  final int postId;
  const PostDetailScreen({super.key, required this.postId});
  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final ApiService _api = ApiService();
  Post? _post;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _api.fetchPost(widget.postId);
      setState(() => _post = data);
    } catch (e) {
      setState(() => _error = e.toString());
    }
    setState(() => _isLoading = false);
  }

  Future<void> _onEdit() async {
    if (_post == null) return;
    final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => EditPostPage(post: _post!)));
    if (res == true) _load();
  }

  Future<void> _onDelete() async {
    if (_post == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Artikel?'),
        content: Text('Yakin hapus "${_post!.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(style: FilledButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (ok == true) {
      try {
        await _api.deletePost(_post!.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Artikel dihapus'), backgroundColor: Colors.green));
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal hapus: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Artikel'), actions: [
        if (_post != null) ...[IconButton(icon: const Icon(Icons.edit), onPressed: _onEdit), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: _onDelete)]
      ]),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.error_outline, size: 48, color: Colors.red), const SizedBox(height: 12), Text(_error!, textAlign: TextAlign.center), const SizedBox(height: 16), FilledButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Coba lagi'))])))
              : _post == null
                  ? const Center(child: Text('Tidak ditemukan'))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          if (_post!.categoryName != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: const Color(0xFFEDE7F6), borderRadius: BorderRadius.circular(20)),
                              child: Text(_post!.categoryName!, style: const TextStyle(fontSize: 12, color: Colors.deepPurple, fontWeight: FontWeight.w600)),
                            ),
                          const SizedBox(height: 12),
                          Text(_post!.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            _post!.createdAt != null ? DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(_post!.createdAt!.toLocal()) : '-',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          const Divider(height: 24),
                          Text(_post!.content, style: const TextStyle(fontSize: 15, height: 1.7)),
                          const SizedBox(height: 24),
                          Row(children: [
                            Expanded(child: OutlinedButton.icon(onPressed: _onEdit, icon: const Icon(Icons.edit), label: const Text('Edit'))),
                            const SizedBox(width: 12),
                            Expanded(child: FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: Colors.red), onPressed: _onDelete, icon: const Icon(Icons.delete), label: const Text('Hapus'))),
                          ])
                        ]),
                      ),
                    ),
    );
  }
}
