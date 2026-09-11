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

  Future<void> deleteArtikel(int id) async {
    final response = await http.delete(
      Uri.parse('$apiBaseUrl/api/artikel/$id'),
    );

    if (!mounted) return;
    if (response.statusCode == 200 || response.statusCode == 204) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Artikel berhasil dihapus')),
      );
      setState(() {
        artikel.removeWhere((a) => (a['id'] ?? a['id_artikel']) == id);
      });
    } else {
      print('gagal hapus artikel: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal hapus: ${response.statusCode}')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getArtikel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CicipYuk"),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: getArtikel),
        ],
      ),
      body: ListView.builder(
        itemCount: artikel.length,
        itemBuilder: (context, index) {
          final item = artikel[index];
          // DB hanya menyimpan nama file gambar; backend menyajikannya
          // dari folder /uploads, jadi URL dibangun lewat helper ini.
          final gambar = gambarArtikelUrl(item['gambar_artikel']);
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: gambar.isNotEmpty
                    ? Image.network(
                        gambar,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
              ),
              title: Text(item['judul_artikel'] ?? item['title'] ?? '-'),
              subtitle: Text(
                "${item['nama_kategori'] ?? item['category_name'] ?? '-'} - ${item['isi_artikel'] ?? item['content'] ?? ''}",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  deleteArtikel(item['id'] ?? item['id_artikel']);
                },
              ),
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
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPostPage()),
          ).then((value) => getArtikel());
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
