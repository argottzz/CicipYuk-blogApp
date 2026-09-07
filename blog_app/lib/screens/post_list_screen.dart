import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../widgets/post_card.dart';
import 'post_detail_screen.dart';
import 'post_form_screen.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  // controller untuk input search (TextField)
  final TextEditingController _searchCtrl = TextEditingController();

  // ApiService untuk ambil data
  final ApiService _api = ApiService();

  // List untuk simpan data
  List<Post> _posts = [];
  List<Category> _kategori = [];

  // variabel untuk loading dan error
  bool _isLoading = false;
  bool _isLoadingKategori = false;
  String? _error;

  // untuk filter kategori
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    // load data pertama kali
    _loadPosts();
    _loadKategori();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ambil data post dari API
  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      String? search;
      if (_searchCtrl.text.trim().isNotEmpty) {
        search = _searchCtrl.text.trim();
      }

      List<Post> data = await _api.fetchPosts(
        search: search,
        categoryId: _selectedCategoryId,
      );

      setState(() {
        _posts = data;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  // ambil kategori
  Future<void> _loadKategori() async {
    setState(() {
      _isLoadingKategori = true;
    });
    try {
      List<Category> data = await _api.fetchCategories();
      setState(() {
        _kategori = data;
      });
    } catch (e) {
      // kalau gagal ambil kategori tidak usah tampilkan error besar
      // ignore: avoid_print
      print("Gagal load kategori: $e");
    }
    setState(() {
      _isLoadingKategori = false;
    });
  }

  // kalau tekan cari
  void _onSearch() {
    _loadPosts();
  }

  // kalau ganti kategori
  void _onCategoryChanged(int? catId) {
    setState(() {
      _selectedCategoryId = catId;
    });
    _loadPosts();
  }

  // pindah ke halaman detail
  void _goToDetail(int id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostDetailScreen(postId: id)),
    ).then((value) {
      // kalau balik dari detail, refresh
      _loadPosts();
    });
  }

  // pindah ke halaman buat post baru
  void _goToCreate() async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PostFormScreen()),
    );
    if (result == true) {
      _loadPosts();
    }
  }

  // pindah ke halaman edit
  void _goToEdit(Post post) async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostFormScreen(post: post)),
    );
    if (result == true) {
      _loadPosts();
    }
  }

  // hapus post
  Future<void> _confirmDelete(int id, String title) async {
    bool? ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Hapus Artikel?'),
          content: Text('Yakin hapus "$title"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx, false);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(ctx, true);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (ok == true) {
      try {
        await _api.deletePost(id);
        // hapus dari list lokal
        setState(() {
          _posts.removeWhere((p) => p.id == id);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Artikel berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal hapus: $e'),
              backgroundColor: Colors.red,
            ),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPosts,
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
          // bagian search dan filter
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                // TextField untuk search
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
                        : IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: _onSearch,
                          ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    isDense: true,
                  ),
                  onSubmitted: (value) {
                    _onSearch();
                  },
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 8),
                // filter kategori pakai ChoiceChip
                if (_isLoadingKategori)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ChoiceChip(
                          label: const Text('Semua'),
                          selected: _selectedCategoryId == null,
                          onSelected: (val) {
                            _onCategoryChanged(null);
                          },
                        ),
                        const SizedBox(width: 6),
                        // loop kategori
                        for (var cat in _kategori)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(cat.name),
                              selected: _selectedCategoryId == cat.id,
                              onSelected: (val) {
                                _onCategoryChanged(cat.id);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          // bagian list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.cloud_off, size: 56, color: Colors.grey),
                              const SizedBox(height: 12),
                              Text('Gagal memuat data', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 6),
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Pastikan backend jalan di http://10.0.2.2:3000\nEmulator pakai 10.0.2.2, HP fisik pakai IP LAN',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: _loadPosts,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Coba lagi'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _posts.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.article_outlined, size: 64, color: Colors.grey[400]),
                                  const SizedBox(height: 12),
                                  const Text('Belum ada artikel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  const Text('Tap tombol Tulis untuk membuat artikel pertama.', style: TextStyle(color: Colors.grey)),
                                  const SizedBox(height: 16),
                                  FilledButton.icon(
                                    onPressed: _goToCreate,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Buat Artikel'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadPosts,
                            child: ListView.builder(
                              itemCount: _posts.length,
                              itemBuilder: (ctx, i) {
                                Post post = _posts[i];
                                return PostCard(
                                  post: post,
                                  onTap: () {
                                    _goToDetail(post.id);
                                  },
                                  onEdit: () {
                                    _goToEdit(post);
                                  },
                                  onDelete: () {
                                    _confirmDelete(post.id, post.title);
                                  },
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
