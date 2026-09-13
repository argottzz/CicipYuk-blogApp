import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
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
  bool _isDeleting = false;

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

  Future<void> _confirmAndDelete(dynamic idRaw) async {
    if (_isDeleting) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Artikel?'),
        content: const Text(
          'Artikel yang dihapus tidak bisa dikembalikan. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _performDelete(idRaw);
    }
  }

  Future<void> _performDelete(dynamic idRaw) async {
    if (_isDeleting) return;
    setState(() => _isDeleting = true);
    try {
      final id = idRaw.toString();
      final response = await http
          .delete(Uri.parse('$apiBaseUrl/api/artikel/$id'))
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Artikel berhasil dihapus')),
        );

        Navigator.pop(context, true);
      } else {
        print('gagal hapus: ${response.statusCode} ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal hapus (${response.statusCode}): ${_pesanError(response.body)}',
            ),
          ),
        );
      }
    } on TimeoutException {
      print('timeout deleteArtikel');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request timeout - coba lagi')),
      );
    } catch (e) {
      print('error deleteArtikel: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal hapus: $e')));
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  String _pesanError(String body) => pesanErrorBackend(body);

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
          child: CircularProgressIndicator(color: Color(0xFFF28C28)),
        ),
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

    final judul = (artikel!['judul_artikel'] ?? artikel!['title'] ?? '-')
        .toString();

    final kategori =
        (artikel!['nama_kategori'] ?? artikel!['category_name'] ?? '')
            .toString();

    final penulis = (artikel!['penulis_artikel'] ?? '-').toString();

    final penerbit =
        (artikel!['nama_penerbit'] ??
                artikel!['penerbit_artikel'] ??
                artikel!['penerbit'] ??
                '')
            .toString();

    final tanggal = (artikel!['created_at'] ?? artikel!['updated_at'] ?? '')
        .toString()
        .split('T')
        .first
        .split(' ')
        .first;

    final isi = (artikel!['isi_artikel'] ?? artikel!['content'] ?? '-')
        .toString();

    final id = artikel!['id'] ?? artikel!['id_artikel'];

    Widget circleBtn(
      IconData icon,
      VoidCallback onTap, {
      Color iconColor = const Color(0xFF33251F),
    }) {
      return InkWell(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
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
                              child: const Icon(
                                Icons.image,
                                size: 48,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey.shade300,
                          child: const Icon(
                            Icons.image,
                            size: 48,
                            color: Colors.grey,
                          ),
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
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              size: 16,
                              color: Color(0xFF33251F),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        const Text(
                          "Post Detail",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const Spacer(),

                        circleBtn(Icons.edit, () {
                          if (_isDeleting) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditPostPage(artikel: artikel),
                            ),
                          ).then((value) {
                            if (value == true) {
                              getDetail();
                            }
                          });
                        }, iconColor: const Color(0xFFF28C28)),

                        const SizedBox(width: 8),

                        _isDeleting
                            ? Container(
                                width: 38,
                                height: 38,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(10),
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFFF28C28),
                                ),
                              )
                            : circleBtn(
                                Icons.delete,
                                () => _confirmAndDelete(id),
                                iconColor: const Color(0xFFF28C28),
                              ),
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
                        color: Color(0xFF33251F),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                penulis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF33251F),
                                ),
                              ),

                              if (tanggal.isNotEmpty)
                                Text(
                                  tanggal,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF806B5D),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (kategori.isNotEmpty) ...[
                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (kategori.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD166),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                kategori,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF33251F),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 16),

                    Text(
                      isi,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Color(0xFF33251F),
                      ),
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
