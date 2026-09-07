import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/post_card.dart';
import 'post_detail_screen.dart';
import 'post_form_screen.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  final _searchCtrl = TextEditingController();
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    // Load after first frame agar context ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().loadPosts();
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await context.read<PostProvider>().refresh();
  }

  void _onSearch() {
    final q = _searchCtrl.text.trim();
    context.read<PostProvider>().setFilter(
          search: q.isEmpty ? null : q,
          categoryId: _selectedCategoryId,
        );
  }

  void _onCategoryChanged(int? catId) {
    setState(() => _selectedCategoryId = catId);
    context.read<PostProvider>().setFilter(
          search: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
          categoryId: catId,
        );
  }

  void _goToDetail(int id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PostDetailScreen(postId: id)),
    );
  }

  void _goToCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PostFormScreen()),
    );
    if (result == true && mounted) {
      context.read<PostProvider>().refresh();
    }
  }

  void _goToEdit(int id) async {
    // Ambil post dari list untuk prefill
    final post = context.read<PostProvider>().posts.firstWhere((p) => p.id == id);
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PostFormScreen(post: post)),
    );
    if (result == true && mounted) {
      context.read<PostProvider>().refresh();
    }
  }

  Future<void> _confirmDelete(int id, String title) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Artikel?'),
        content: Text('Yakin hapus "$title"? Tindakan tidak bisa dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      try {
        await context.read<PostProvider>().removePost(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Artikel berhasil dihapus'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal hapus: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog App', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToCreate,
        icon: const Icon(Icons.add),
        label: const Text('Tulis'),
      ),
      body: Column(
        children: [
          // Search + Filter
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Cari judul / konten...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() {});
                              _onSearch();
                            },
                          )
                        : IconButton(icon: const Icon(Icons.send), onPressed: _onSearch),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _onSearch(),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                Consumer<CategoryProvider>(
                  builder: (context, catProv, _) {
                    if (catProv.isLoading) {
                      return const Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)));
                    }
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: const Text('Semua'),
                            selected: _selectedCategoryId == null,
                            onSelected: (_) => _onCategoryChanged(null),
                          ),
                          const SizedBox(width: 6),
                          ...catProv.categories.map((cat) => Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: ChoiceChip(
                                  label: Text(cat.name),
                                  selected: _selectedCategoryId == cat.id,
                                  onSelected: (_) => _onCategoryChanged(cat.id),
                                ),
                              )),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // List
          Expanded(
            child: Consumer<PostProvider>(
              builder: (context, prov, _) {
                if (prov.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (prov.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_off, size: 56, color: Colors.grey),
                          const SizedBox(height: 12),
                          Text('Gagal memuat data',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 6),
                          Text(
                            prov.error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Pastikan backend jalan di http://10.0.2.2:3000\nEmulator pakai 10.0.2.2, HP fisik pakai IP LAN laptop',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () => prov.refresh(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (prov.posts.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.article_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          const Text('Belum ada artikel',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          const Text('Tap tombol Tulis untuk membuat artikel pertama.',
                              style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _goToCreate,
                            icon: const Icon(Icons.add),
                            label: const Text('Buat Artikel'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    itemCount: prov.posts.length,
                    itemBuilder: (ctx, i) {
                      final post = prov.posts[i];
                      return PostCard(
                        post: post,
                        onTap: () => _goToDetail(post.id),
                        onEdit: () => _goToEdit(post.id),
                        onDelete: () => _confirmDelete(post.id, post.title),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
