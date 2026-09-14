import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  bool isLoading = true;
  String? pesanError;

  Future<void> getArtikel() async {
    setState(() {
      isLoading = true;
      pesanError = null;
    });

    try {
      final response = await http
          .get(Uri.parse('$apiBaseUrl/api/artikel'))
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode == 200) {
        dynamic body = jsonDecode(response.body);

        List dataBaru = [];
        if (body is Map && body['data'] != null) {
          dataBaru = body['data'];
        } else if (body is List) {
          dataBaru = body;
        }

        setState(() {
          artikel.clear();
          artikel.addAll(dataBaru);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          pesanError =
              'Gagal ambil data: ${response.statusCode} - cek API_URL $apiBaseUrl';
        });
        tampilkanSnack(pesanError!);
      }
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        pesanError =
            'Request timeout - periksa koneksi lalu coba lagi ($apiBaseUrl)';
      });
      tampilkanSnack(pesanError!);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        pesanError = 'Tidak bisa konek ke $apiBaseUrl - cek WiFi & firewall';
      });
      tampilkanSnack(pesanError!);
    }
  }

  void tampilkanSnack(String pesan) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  String ambilPenerbit(dynamic item) {
    dynamic nama =
        item['nama_penerbit'] ?? item['penerbit_artikel'] ?? item['penerbit'];
    if (nama == null) {
      return '';
    }
    return nama.toString();
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
                      errorBuilder: (c, e, s) {
                        return const Icon(
                          Icons.restaurant,
                          size: 22,
                          color: Color(0xFFF28C28),
                        );
                      },
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
                'Ruang Inspirasi\nKuliner Kamu',
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
                child: pilihTampilan(),
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
          ).then((hasil) {
            getArtikel();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget pilihTampilan() {
    if (isLoading) {
      return tampilanLoading();
    }
    if (pesanError != null) {
      return tampilanError();
    }
    if (artikel.isEmpty) {
      return tampilanKosong();
    }
    return daftarArtikel();
  }

  Widget tampilanLoading() {
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

  Widget tampilanError() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 100),
      children: [
        const Icon(Icons.cloud_off, size: 48, color: Color(0xFF806B5D)),
        const SizedBox(height: 12),
        Center(
          child: Text(
            pesanError!,
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

  Widget tampilanKosong() {
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

  Widget daftarArtikel() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: artikel.length,
      itemBuilder: (context, index) {
        dynamic item = artikel[index];
        return kartuArtikel(item);
      },
    );
  }

  Widget kartuArtikel(dynamic item) {
    String gambar = gambarArtikelUrl(
      item['gambar_artikel'] ?? item['gambar'] ?? item['image'],
    );
    String judul = (item['judul_artikel'] ?? item['title'] ?? '-').toString();
    String penerbit = ambilPenerbit(item);

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
          dynamic id = item['id'] ?? item['id_artikel'];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailScreen(postId: id),
            ),
          ).then((hasil) {
            getArtikel();
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (penerbit.isNotEmpty)
                Row(
                  children: [
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
                ),
              const SizedBox(height: 8),
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
