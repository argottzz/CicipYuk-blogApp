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
          // DB menyimpan "uploads/namafile.jpg", backend menyajikannya
          // dari folder /uploads, jadi URL dibangun lewat helper ini.
          final gambar = gambarArtikelUrl(
            item['gambar_artikel'] ?? item['gambar'] ?? item['image'],
          );
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: SizedBox(
                width: 60,
                height: 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: gambar.isNotEmpty
                      ? Image.network(
                          gambar,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          loadingBuilder: (c, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (c, e, s) {
                            print('gagal load gambar $gambar: $e');
                            return Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image, color: Colors.grey),
                            );
                          },
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                ),
              ),
              title: Text(item['judul_artikel'] ?? item['title'] ?? '-'),
              subtitle: Text(
                "${item['nama_kategori'] ?? item['category_name'] ?? '-'} - ${item['isi_artikel'] ?? item['content'] ?? ''}",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
