import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  List<dynamic> artikel = [];

  Future<void> getArtikel() async {
    try {
      final response = await http.get(
        Uri.parse("$apiBaseUrl/api/artikel"),
      );

      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        // handle 2 bentuk: langsung List atau {data: [...]}
        List data;
        if (body is Map && body['data'] != null) {
          data = body['data'];
        } else if (body is List) {
          data = body;
        } else {
          data = [];
        }
        setState(() {
          artikel = data;
        });
        if (data.isNotEmpty) {
          print("contoh gambar_artikel: ${data.first['gambar_artikel']}");
          print("contoh URL gambar: ${gambarArtikelUrl(data.first['gambar_artikel'])}");
        }
      } else {
        print("gagal ambil data artikel: ${response.statusCode}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal ambil data: ${response.statusCode} - cek API_URL $apiBaseUrl')),
          );
        }
      }
    } catch (e) {
      print("error getArtikel: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak bisa konek ke $apiBaseUrl - cek WiFi & firewall')),
        );
      }
    }
  }

  String _kategori(dynamic item) {
    return (item['nama_kategori'] ?? item['category_name'] ?? '').toString();
  }

  String _timeAgo(dynamic item) {
    final raw = (item['created_at'] ?? item['updated_at'] ?? item['tanggal'] ?? '').toString();
    if (raw.isEmpty) return '';
    try {
      // Normalisasi format: "2026-09-12T10:00:00.000Z" atau "2026-09-12 10:00:00"
      final normalized = raw.contains('T') ? raw : raw.replaceFirst(' ', 'T');
      final date = DateTime.parse(normalized);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 1) return 'just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
      if (diff.inHours < 24) return '${diff.inHours} hours ago';
      if (diff.inDays < 7) return '${diff.inDays} days ago';
    } catch (_) {
      // abaikan, fallback ke tanggal polos di bawah
    }
    // fallback YYYY-MM-DD saja
    return raw.split('T').first.split(' ').first;
  }

  @override
  void initState() {
    super.initState();
    getArtikel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                "CicipYuk",
                style: TextStyle(
                  color: Color(0xFFE85D2A),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 6, 20, 16),
              child: Text(
                "Your Culinary\nInspiration Vault",
                style: TextStyle(
                  color: Colors.black,
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
                child: artikel.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                        children: const [
                          Center(
                            child: Text(
                              'Belum ada artikel',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount: artikel.length,
                        itemBuilder: (context, index) {
                          final item = artikel[index];
                          final gambar = gambarArtikelUrl(
                            item['gambar_artikel'] ?? item['gambar'] ?? item['image'],
                          );
                          final judul = (item['judul_artikel'] ?? item['title'] ?? '-').toString();
                          final kategori = _kategori(item);
                          final waktu = _timeAgo(item);
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
                                    // Baris atas: kategori + waktu, tanpa icon pembuat, tanpa titik 3
                                    Row(
                                      children: [
                                        if (kategori.isNotEmpty) ...[
                                          Flexible(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    kategori,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w700,
                                                      color: Colors.black,
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
                                        const Spacer(),
                                        if (waktu.isNotEmpty)
                                          Text(
                                            waktu,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
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
                                        color: Colors.black,
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
                                                    child: const Icon(Icons.image, color: Colors.grey, size: 40),
                                                  );
                                                },
                                              )
                                            : Container(
                                                color: Colors.grey.shade200,
                                                child: const Icon(Icons.image, color: Colors.grey, size: 40),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
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
}
