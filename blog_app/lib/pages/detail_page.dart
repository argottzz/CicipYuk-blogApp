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
        const SnackBar(content: Text('Artikel berhasil dihapus')),
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
      return const Scaffold(
        backgroundColor: Color(0xFFFFF9F0),
        body: Center(
            child: CircularProgressIndicator(color: Color(0xFFF28C28))),
      );
    }

    if (artikel == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF9F0),
        appBar: AppBar(title: const Text("Post Detail")),
        body: const Center(child: Text("Artikel tidak ditemukan")),
      );
    }

    final gambarUrl = gambarArtikelUrl(
      artikel!['gambar_artikel'] ?? artikel!['gambar'] ?? artikel!['image'],
    );
    final judul = (artikel!['judul_artikel'] ?? artikel!['title'] ?? '-').toString();
    final kategori = (artikel!['nama_kategori'] ?? artikel!['category_name'] ?? '').toString();
    final penulis = (artikel!['penulis_artikel'] ?? '-').toString();
    final penerbit = (artikel!['penerbit_artikel'] ?? artikel!['penerbit'] ?? '').toString();
    final tanggal = (artikel!['created_at'] ?? artikel!['updated_at'] ?? '').toString().split('T').first.split(' ').first;
    final isi = (artikel!['isi_artikel'] ?? artikel!['content'] ?? '-').toString();
    final id = artikel!['id'] ?? artikel!['id_artikel'];

    Widget circleBtn(IconData icon, VoidCallback onTap, {Color iconColor = const Color(0xFF33251F)}) {
      return InkWell(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Icon(icon, size: 18, color: iconColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 420,
                  width: double.infinity,
                  child: gambarUrl.isNotEmpty
                      ? Image.network(
                          gambarUrl,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          errorBuilder: (c, e, s) {
                            print('gagal load gambar detail $gambarUrl: $e');
                            return Container(
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.image, size: 48, color: Colors.grey),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image, size: 48, color: Colors.grey),
                        ),
                ),
                Container(
                  height: 420,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.45),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.25),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.arrow_back_ios_new,
                                size: 16, color: Color(0xFF33251F)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Post Detail",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        circleBtn(Icons.edit, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditPostPage(artikel: artikel),
                            ),
                          ).then((value) {
                            if (value == true) getDetail();
                          });
                        }, iconColor: const Color(0xFFF28C28)),
                        const SizedBox(width: 8),
                        circleBtn(Icons.delete, () => deleteArtikel(id),
                            iconColor: const Color(0xFFF28C28)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Transform.translate(
              offset: const Offset(0, -28),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (penerbit.isNotEmpty) ...[
                      Row(
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
                      const SizedBox(height: 8),
                    ],
                    Text(
                      judul,
                      style: const TextStyle(
                          fontSize: 24,
                          height: 1.25,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                          color: Color(0xFF33251F)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(penulis,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF33251F))),
                              if (tanggal.isNotEmpty)
                                Text(tanggal,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF806B5D))),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (kategori.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD166),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(kategori,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF33251F))),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      isi,
                      style: const TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: Color(0xFF33251F)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
