import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../api_config.dart';

// Halaman 4: Edit Artikel.
// Mirip halaman Tambah, bedanya form sudah terisi data lama.
// Polanya mirip EditProductPage di latihan.
class EditPostPage extends StatefulWidget {
  // Data artikel lama yang mau diedit.
  final dynamic artikel;

  const EditPostPage({super.key, this.artikel});

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  // 1. Kunci form untuk validasi.
  final formKey = GlobalKey<FormState>();

  // 2. Controller untuk membaca ketikan user.
  final judulController = TextEditingController();
  final isiController = TextEditingController();
  final penulisController = TextEditingController();

  // 3. Data kategori dan penerbit dari server.
  List<dynamic> daftarKategori = [];
  bool kategoriLoading = true;
  String? kategoriError;
  int? kategoriTerpilih;

  List<dynamic> daftarPenerbit = [];
  bool penerbitLoading = true;
  String? penerbitError;
  int? penerbitTerpilih;

  // 4. Gambar baru (kalau user ganti) + status simpan.
  XFile? gambarBaru;
  bool lagiMenyimpan = false;
  final ImagePicker picker = ImagePicker();

  // Ambil daftar kategori dari server.
  Future<void> getKategori() async {
    setState(() {
      kategoriLoading = true;
      kategoriError = null;
    });

    try {
      final response = await http
          .get(Uri.parse('$apiBaseUrl/api/kategori'))
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
          daftarKategori.clear();
          daftarKategori.addAll(dataBaru);
          kategoriLoading = false;
        });
      } else {
        setState(() {
          kategoriLoading = false;
          kategoriError = 'Gagal memuat kategori (${response.statusCode})';
        });
      }
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        kategoriLoading = false;
        kategoriError = 'Request timeout - coba lagi';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        kategoriLoading = false;
        kategoriError = 'Tidak bisa konek ke server';
      });
    }
  }

  // Ambil daftar penerbit. Caranya sama persis seperti getKategori.
  Future<void> getPenerbit() async {
    setState(() {
      penerbitLoading = true;
      penerbitError = null;
    });

    try {
      final response = await http
          .get(Uri.parse('$apiBaseUrl/api/penerbit'))
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
          daftarPenerbit.clear();
          daftarPenerbit.addAll(dataBaru);
          penerbitLoading = false;
        });
      } else {
        setState(() {
          penerbitLoading = false;
          penerbitError = 'Gagal memuat penerbit (${response.statusCode})';
        });
      }
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        penerbitLoading = false;
        penerbitError = 'Request timeout - coba lagi';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        penerbitLoading = false;
        penerbitError = 'Tidak bisa konek ke server';
      });
    }
  }

  // Pilih gambar baru dari galeri. Sama persis seperti di Tambah.
  Future<void> pilihGambar() async {
    XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) {
      return;
    }

    int ukuran = await image.length();
    if (ukuran > 5 * 1024 * 1024) {
      if (!mounted) return;
      tampilkanSnack('Ukuran file maksimal 5MB');
      return;
    }

    String nama = image.name.toLowerCase();
    bool boleh =
        nama.endsWith('.jpg') ||
        nama.endsWith('.jpeg') ||
        nama.endsWith('.png') ||
        nama.endsWith('.webp');
    if (!boleh) {
      if (!mounted) return;
      tampilkanSnack('Hanya jpg, jpeg, png, webp yang diperbolehkan');
      return;
    }

    setState(() {
      gambarBaru = image;
    });
  }

  void tampilkanSnack(String pesan) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  // Kirim perubahan ke server.
  Future<void> updateArtikel() async {
    if (lagiMenyimpan) return;

    // 1. Validasi dulu.
    if (!formKey.currentState!.validate()) {
      return;
    }

    String judul = judulController.text.trim();
    String penulis = penulisController.text.trim();
    String isi = isiController.text.trim();

    // 2. Ambil ID artikel lama.
    dynamic idRaw = widget.artikel['id'] ?? widget.artikel['id_artikel'];
    if (idRaw == null) {
      tampilkanSnack('ID artikel tidak ditemukan');
      return;
    }
    String id = idRaw.toString();

    setState(() {
      lagiMenyimpan = true;
    });

    try {
      Uri url = Uri.parse('$apiBaseUrl/api/artikel/$id');
      late http.Response response;

      if (gambarBaru == null) {
        // 3a. Tanpa gambar baru: kirim JSON biasa pakai PUT.
        response = await http
            .put(
              url,
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                'judul_artikel': judul,
                'isi_artikel': isi,
                'id_kategori': kategoriTerpilih,
                'id_penerbit': penerbitTerpilih,
                'penulis_artikel': penulis,
              }),
            )
            .timeout(const Duration(seconds: 20));
      } else {
        // 3b. Dengan gambar baru: kirim multipart pakai PUT.
        var request = http.MultipartRequest('PUT', url);
        request.headers['Accept'] = 'application/json';
        request.fields['judul_artikel'] = judul;
        request.fields['isi_artikel'] = isi;
        request.fields['id_kategori'] = kategoriTerpilih.toString();
        request.fields['id_penerbit'] = penerbitTerpilih.toString();
        request.fields['penulis_artikel'] = penulis;

        request.files.add(
          await http.MultipartFile.fromPath(
            'gambar_artikel',
            gambarBaru!.path,
            filename: gambarBaru!.name,
            contentType: mediaTypeForImage(gambarBaru!.name),
          ),
        );

        var terkirim = await request.send().timeout(
          const Duration(seconds: 30),
        );
        response = await http.Response.fromStream(terkirim);
      }

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        tampilkanSnack('Artikel berhasil diupdate');
        Navigator.pop(context, true);
      } else {
        tampilkanSnack(
          'Gagal update (${response.statusCode}): ${pesanErrorBackend(response.body)}',
        );
      }
    } on TimeoutException {
      tampilkanSnack('Request timeout - coba lagi');
    } catch (e) {
      tampilkanSnack('Error: $e');
    }

    if (mounted) {
      setState(() {
        lagiMenyimpan = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getKategori();
    getPenerbit();

    // Isi form dengan data lama supaya user tinggal mengubah.
    judulController.text =
        (widget.artikel['judul_artikel'] ?? widget.artikel['title'] ?? '')
            .toString();
    isiController.text =
        (widget.artikel['isi_artikel'] ?? widget.artikel['content'] ?? '')
            .toString();
    penulisController.text =
        (widget.artikel['penulis_artikel'] ??
                widget.artikel['penerbit_artikel'] ??
                '')
            .toString();

    // Isi dropdown dengan ID lama.
    kategoriTerpilih = parseKategoriId(
      widget.artikel['id_kategori'] ?? widget.artikel['category_id'],
    );
    penerbitTerpilih = parsePenerbitId(
      widget.artikel['id_penerbit'] ?? widget.artikel['penerbit_id'],
    );
  }

  @override
  void dispose() {
    judulController.dispose();
    isiController.dispose();
    penulisController.dispose();
    super.dispose();
  }

  // Dekorasi input: putih, sudut bulat. Sama seperti di Tambah.
  InputDecoration dekorasiInput(String label) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      alignLabelWithHint: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    );
  }

  // Buat item dropdown kategori pakai for supaya mudah dibaca.
  List<DropdownMenuItem<int>> buatItemKategori() {
    List<DropdownMenuItem<int>> hasil = [];
    for (var item in daftarKategori) {
      int? id = parseKategoriIdFromItem(item);
      if (id == null) {
        continue;
      }
      hasil.add(
        DropdownMenuItem<int>(
          value: id,
          child: Text(kategoriName(item), overflow: TextOverflow.ellipsis),
        ),
      );
    }
    return hasil;
  }

  // Buat item dropdown penerbit.
  List<DropdownMenuItem<int>> buatItemPenerbit() {
    List<DropdownMenuItem<int>> hasil = [];
    for (var item in daftarPenerbit) {
      int? id = parsePenerbitIdFromItem(item);
      if (id == null) {
        continue;
      }
      hasil.add(
        DropdownMenuItem<int>(
          value: id,
          child: Text(penerbitName(item), overflow: TextOverflow.ellipsis),
        ),
      );
    }
    return hasil;
  }

  // Cek apakah ID lama masih ada di daftar server.
  // Kalau tidak ada (misal dihapus admin), dropdown dikosongkan supaya tidak error.
  int? nilaiDropdownKategoriAman() {
    if (kategoriTerpilih == null) {
      return null;
    }
    for (var item in daftarKategori) {
      if (parseKategoriIdFromItem(item) == kategoriTerpilih) {
        return kategoriTerpilih;
      }
    }
    return null;
  }

  int? nilaiDropdownPenerbitAman() {
    if (penerbitTerpilih == null) {
      return null;
    }
    for (var item in daftarPenerbit) {
      if (parsePenerbitIdFromItem(item) == penerbitTerpilih) {
        return penerbitTerpilih;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Nama file gambar lama (kalau ada).
    dynamic gambarLamaRaw =
        widget.artikel['gambar_artikel'] ??
        widget.artikel['gambar'] ??
        widget.artikel['image'];
    String gambarLama = '';
    if (gambarLamaRaw != null) {
      gambarLama = gambarLamaRaw.toString();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Edit Artikel',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CicipYuk',
                style: TextStyle(
                  color: Color(0xFFF28C28),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Edit Post',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                  color: Color(0xFF33251F),
                ),
              ),
              const SizedBox(height: 16),

              // Input judul.
              TextFormField(
                controller: judulController,
                textInputAction: TextInputAction.next,
                decoration: dekorasiInput('Judul Artikel'),
                validator: (value) {
                  String v = (value ?? '').trim();
                  if (v.isEmpty) {
                    return 'Judul wajib diisi';
                  }
                  if (v.length > 200) {
                    return 'Judul maksimal 200 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Dropdown kategori.
              DropdownButtonFormField<int>(
                initialValue: nilaiDropdownKategoriAman(),
                isExpanded: true,
                hint: Text(
                  kategoriLoading ? 'Memuat kategori...' : 'Pilih Kategori',
                ),
                decoration: dekorasiInput('Kategori'),
                items: buatItemKategori(),
                validator: (value) {
                  if (value == null) {
                    return 'Wajib pilih kategori';
                  }
                  return null;
                },
                onChanged: kategoriLoading
                    ? null
                    : (value) {
                        setState(() {
                          kategoriTerpilih = value;
                        });
                      },
              ),
              if (kategoriError != null)
                barisError(kategoriError!, getKategori)
              else if (!kategoriLoading && buatItemKategori().isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    'Belum ada kategori di server.',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 12),

              // Dropdown penerbit.
              DropdownButtonFormField<int>(
                initialValue: nilaiDropdownPenerbitAman(),
                isExpanded: true,
                hint: Text(
                  penerbitLoading ? 'Memuat penerbit...' : 'Pilih Penerbit',
                ),
                decoration: dekorasiInput('Penerbit'),
                items: buatItemPenerbit(),
                validator: (value) {
                  if (value == null) {
                    return 'Wajib pilih penerbit';
                  }
                  return null;
                },
                onChanged: penerbitLoading
                    ? null
                    : (value) {
                        setState(() {
                          penerbitTerpilih = value;
                        });
                      },
              ),
              if (penerbitError != null)
                barisError(penerbitError!, getPenerbit)
              else if (!penerbitLoading && buatItemPenerbit().isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    'Belum ada penerbit di server.',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 12),

              // Input penulis.
              TextFormField(
                controller: penulisController,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: dekorasiInput('Penulis Artikel'),
                validator: (value) {
                  String v = (value ?? '').trim();
                  if (v.isEmpty) {
                    return 'Penulis wajib diisi';
                  }
                  if (v.length > 100) {
                    return 'Penulis maksimal 100 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Input isi.
              TextFormField(
                controller: isiController,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                decoration: dekorasiInput('Isi Artikel'),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Isi artikel wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Kotak gambar: gambar baru > gambar lama > placeholder.
              bagianGambar(gambarLama),
              const SizedBox(height: 20),

              // Tombol update.
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF28C28),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: lagiMenyimpan ? null : updateArtikel,
                  child: lagiMenyimpan
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Update',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
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

  // Baris merah error + tombol coba lagi.
  Widget barisError(String pesan, VoidCallback cobaLagi) {
    return Column(
      children: [
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                pesan,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
            TextButton(onPressed: cobaLagi, child: const Text('Coba lagi')),
          ],
        ),
      ],
    );
  }

  // Kotak gambar untuk edit: ada 3 kemungkinan.
  Widget bagianGambar(String gambarLama) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Kalau user baru pilih gambar, tampilkan gambar baru.
          if (gambarBaru != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(gambarBaru!.path),
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          // 2. Kalau belum pilih baru tapi ada gambar lama, tampilkan gambar lama.
          else if (gambarLama.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                gambarArtikelUrl(gambarLama),
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                loadingBuilder: (c, child, progress) {
                  if (progress == null) {
                    return child;
                  }
                  return Container(
                    height: 180,
                    color: Colors.grey.shade200,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (c, e, s) {
                  return Container(
                    height: 120,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.image,
                      size: 48,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            )
          // 3. Kalau tidak ada gambar sama sekali, tampilkan placeholder.
          else
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.image, size: 48, color: Colors.grey),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF33251F),
              side: const BorderSide(color: Color(0xFFF28C28)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            icon: const Icon(Icons.photo_library),
            label: Text(
              gambarBaru == null && gambarLama.isEmpty
                  ? 'Pilih Gambar'
                  : 'Ganti Gambar',
            ),
            onPressed: pilihGambar,
          ),
          if (gambarBaru != null)
            TextButton.icon(
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text(
                'Hapus Gambar Baru',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                setState(() {
                  gambarBaru = null;
                });
              },
            ),
        ],
      ),
    );
  }
}
