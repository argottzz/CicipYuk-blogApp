import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../api_config.dart';
import 'edit_post_page.dart';

class PostDetailScreen extends StatefulWidget {
  final int postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  Map<String, dynamic>? artikel;
  bool isLoading = true;

  Future<void> getDetail() async {
    try {
      http.Response? response;
      try {
        response = await http.get(
          Uri.parse("$apiBaseUrl/api/artikel/${widget.postId}"),
        );
      } catch (e) {
        print("error GET detail by id: $e");
      }

      dynamic data;
      if (response != null && response.statusCode == 200) {
        var body = jsonDecode(response.body);
        if (body is Map && body['data'] != null) {
          data = body['data'];
        } else {
          data = body;
        }
      } else {
        // Fallback: backend belum punya route GET /api/artikel/{id}
        // (server ini balas 404), jadi ambil daftar artikel lalu
        // cari item yang id-nya cocok.
        print(
          "GET /api/artikel/${widget.postId} gagal "
          "(${response?.statusCode ?? 'error'}), fallback ambil daftar artikel",
        );
        final listResponse = await http.get(
          Uri.parse("$apiBaseUrl/api/artikel"),
        );
        if (listResponse.statusCode == 200) {
          var body = jsonDecode(listResponse.body);
          List list;
          if (body is Map && body['data'] != null) {
            list = body['data'];
          } else if (body is List) {
            list = body;
          } else {
            list = [];
          }
          for (final item in list) {
            if ((item['id'] ?? item['id_artikel']) == widget.postId) {
              data = item;
              break;
            }
          }
        } else {
          print("gagal ambil daftar artikel: ${listResponse.statusCode}");
        }
      }

      if (!mounted) return;
      if (data is Map) {
        setState(() {
          artikel = Map<String, dynamic>.from(data);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("error getDetail: $e");
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteArtikel(int id) async {
    final response = await http.delete(
      Uri.parse('$apiBaseUrl/api/artikel/$id'),
    );

    if (!mounted) return;
    if (response.statusCode == 200 || response.statusCode == 204) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Artikel berhasil dihapus')),
      );
      Navigator.pop(context, true);
    } else {
      print('gagal hapus: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    getDetail();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Detail Artikel")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (artikel == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Detail Artikel")),
        body: Center(child: Text("Artikel tidak ditemukan")),
      );
    }

    final gambarUrl = gambarArtikelUrl(artikel!['gambar_artikel']);

    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Artikel"),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPostPage(artikel: artikel),
                ),
              ).then((value) {
                if (value == true) getDetail();
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              deleteArtikel(artikel!['id'] ?? artikel!['id_artikel']);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar artikel (DB simpan nama file, backend sajikan di /uploads)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: gambarUrl.isNotEmpty
                  ? Image.network(
                      gambarUrl,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        height: 180,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image, size: 48, color: Colors.grey),
                      ),
                    )
                  : Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.image, size: 48, color: Colors.grey),
                    ),
            ),
            const SizedBox(height: 12),
            Text(
              artikel!['judul_artikel'] ?? artikel!['title'] ?? '-',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                artikel!['nama_kategori'] ?? artikel!['category_name'] ?? '-',
                style: const TextStyle(color: Colors.deepPurple, fontSize: 12),
              ),
            ),
            if (artikel!['penulis_artikel'] != null) ...[
              const SizedBox(height: 6),
              Text(
                "Penulis: ${artikel!['penulis_artikel']}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              artikel!['isi_artikel'] ?? artikel!['content'] ?? '-',
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditPostPage(artikel: artikel),
                        ),
                      ).then((v) {
                        if (v == true) getDetail();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text("Hapus", style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      deleteArtikel(artikel!['id'] ?? artikel!['id_artikel']);
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
