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

  String _penerbit(dynamic item) {
    return (item['penerbit_artikel'] ?? item['penerbit'] ?? '').toString();
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
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                "CicipYuk",
                style: TextStyle(
                  color: Color(0xFFF28C28),
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
                child: artikel.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                        children: const [
                          Center(
                            child: Text(
                              'Belum ada artikel',
                              style: TextStyle(color: Color(0xFF806B5D)),
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
                          final penerbit = _penerbit(item);
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
}
