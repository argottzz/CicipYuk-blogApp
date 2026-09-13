import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import '../api_config.dart';
import 'add_post_page.dart';
import 'detail_page.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  final List<dynamic> artikel = [];
  bool _isLoading = true;
  String? _errorMessage;

  Future<void> getArtikel() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    } else {
      _isLoading = true;
      _errorMessage = null;
    }
    try {
      final response = await http
          .get(Uri.parse("$apiBaseUrl/api/artikel"))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        // handle 2 bentuk: langsung List atau {data: [...]}
        final List data;
        if (body is Map && body['data'] != null) {
          data = body['data'];
        } else if (body is List) {
          data = body;
        } else {
          data = [];
        }
        if (!mounted) return;
        setState(() {
          artikel
            ..clear()
            ..addAll(data);
          _isLoading = false;
        });
        if (data.isNotEmpty) {
          print("contoh gambar_artikel: ${data.first['gambar_artikel']}");
          print(
            "contoh URL gambar: ${gambarArtikelUrl(data.first['gambar_artikel'])}",
          );
        }
      } else {
        print("gagal ambil data artikel: ${response.statusCode}");
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Gagal ambil data: ${response.statusCode} - cek API_URL $apiBaseUrl';
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_errorMessage!)));
      }
    } on TimeoutException {
      print("timeout getArtikel");
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Request timeout - periksa koneksi lalu coba lagi ($apiBaseUrl)';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_errorMessage!)));
    } catch (e) {
      print("error getArtikel: $e");
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Tidak bisa konek ke $apiBaseUrl - cek WiFi & firewall';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_errorMessage!)));
    }
  }

  String _penerbit(dynamic item) {
    return (item['nama_penerbit'] ??
            item['penerbit_artikel'] ??
            item['penerbit'] ??
            '')
        .toString();
  }

  @override
  void initState() {
    super.initState();
    getArtikel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/logo-cicipyuk-clean.png',
                      width: 28,
                      height: 28,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const Icon(
                        Icons.restaurant,
                        size: 22,
                        color: Color(0xFFF28C28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'CicipYuk',
                    style: TextStyle(
                      color: Color(0xFFF28C28),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 6, 20, 16),
              child: Text(
                "Ruang Inspirasi\nKuliner Kamu",
                style: TextStyle(
                  color: Color(0xFF33251F),
                  fontSize: 32,
                  height: 1.1,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: getArtikel,
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF28C28),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPostPage()),
          ).then((value) => getArtikel());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 100),
        children: const [
          Center(child: CircularProgressIndicator(color: Color(0xFFF28C28))),
          SizedBox(height: 16),
          Center(
            child: Text(
              'Memuat artikel...',
              style: TextStyle(color: Color(0xFF806B5D)),
            ),
          ),
        ],
      );
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 100),
        children: [
          const Icon(Icons.cloud_off, size: 48, color: Color(0xFF806B5D)),
          const SizedBox(height: 12),
          Center(
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF806B5D)),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF28C28),
                foregroundColor: Colors.white,
              ),
              onPressed: getArtikel,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ),
        ],
      );
    }

    if (artikel.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 100),
        children: const [
          Icon(Icons.article_outlined, size: 48, color: Color(0xFF806B5D)),
          SizedBox(height: 12),
          Center(
            child: Text(
              'Belum ada artikel',
              style: TextStyle(color: Color(0xFF806B5D)),
            ),
          ),
        ],
      );
    }

    return _buildList();
  }

  Widget _buildList() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: artikel.length,
      itemBuilder: (context, index) {
        final item = artikel[index];
        return _buildArticleCard(item);
      },
    );
  }

  // Extract widget in-file (tanpa file baru): kartu artikel reusable.
  Widget _buildArticleCard(dynamic item) {
    final String gambar = gambarArtikelUrl(
      item['gambar_artikel'] ?? item['gambar'] ?? item['image'],
    );
    final String judul = (item['judul_artikel'] ?? item['title'] ?? '-')
        .toString();
    final String penerbit = _penerbit(item);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailScreen(
                postId: item['id'] ?? item['id_artikel'],
              ),
            ),
          ).then((value) => getArtikel());
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Baris atas: nama penerbit + ikon verified
              Row(
                children: [
                  if (penerbit.isNotEmpty) ...[
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              penerbit,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF33251F),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            size: 14,
                            color: Color(0xFF2D9CDB),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              // Judul apa adanya dari database
              Text(
                judul,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  color: Color(0xFF33251F),
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  width: double.infinity,
                  height: 190,
                  child: gambar.isNotEmpty
                      ? Image.network(
                          gambar,
                          width: double.infinity,
                          height: 190,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          errorBuilder: (c, e, s) {
                            print('gagal load gambar $gambar: $e');
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.image,
                                color: Colors.grey,
                                size: 40,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.image,
                            color: Colors.grey,
                            size: 40,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
