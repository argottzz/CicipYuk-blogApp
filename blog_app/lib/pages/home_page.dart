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

  String _tanggal(dynamic item) {
    final raw = (item['created_at'] ?? item['updated_at'] ?? item['tanggal'] ?? '').toString();
    if (raw.isEmpty) return (item['nama_kategori'] ?? item['category_name'] ?? '').toString();
    // ambil YYYY-MM-DD saja
    final t = raw.split('T').first.split(' ').first;
    return t;
  }

  String _inisial(String nama) {
    final parts = nama.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
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
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: artikel.length,
                  separatorBuilder: (_, _) => Container(
                    height: 1,
                    color: const Color(0xFFE8E0D5),
                    margin: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  itemBuilder: (context, index) {
                    final item = artikel[index];
                    // key gambar dipertahankan sama seperti sebelumnya
                    final gambar = gambarArtikelUrl(
                      item['gambar_artikel'] ?? item['gambar'] ?? item['image'],
                    );
                    final judul = (item['judul_artikel'] ?? item['title'] ?? '-').toString();
                    final penulis = (item['penulis_artikel'] ?? '-').toString();
                    final tanggal = _tanggal(item);
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 96,
                              height: 96,
                              child: gambar.isNotEmpty
                                  ? Image.network(
                                      gambar,
                                      width: 96,
                                      height: 96,
                                      fit: BoxFit.cover,
                                      gaplessPlayback: true,
                                      errorBuilder: (c, e, s) {
                                        print('gagal load gambar $gambar: $e');
                                        return Container(
                                          color: Colors.grey.shade200,
                                          child: const Icon(Icons.image, color: Colors.grey),
                                        );
                                      },
                                    )
                                  : Container(
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.image, color: Colors.grey),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  judul,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    height: 1.3,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: const Color(0xFFE8E0D5),
                                      child: Text(
                                        _inisial(penulis),
                                        style: const TextStyle(fontSize: 11, color: Colors.black87),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            penulis,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            tanggal,
                                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
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
