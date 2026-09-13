import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../api_config.dart';

// Halaman 2: Tambah Artikel.
// Polanya mirip AddProductPage di latihan:
// TextEditingController + http.post + isSaving.
class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  // 1. Kunci form untuk validasi (sama seperti formKey di latihan login).
  final formKey = GlobalKey<FormState>();

  // 2. Controller untuk membaca isi ketikan user.
  final judulController = TextEditingController();
  final isiController = TextEditingController();
  final penulisController = TextEditingController();

  // 3. Data kategori dari server.
  List<dynamic> daftarKategori = [];
  bool kategoriLoading = true;
  String? kategoriError;
  int? kategoriTerpilih;

  // 4. Data penerbit dari server.
  List<dynamic> daftarPenerbit = [];
  bool penerbitLoading = true;
  String? penerbitError;
  int? penerbitTerpilih;

  // 5. Gambar yang dipilih user + status simpan.
  XFile? gambarTerpilih;
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

  // Pilih gambar dari galeri HP.
  Future<void> pilihGambar() async {
    // 1. Buka galeri.
    XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    // 2. Kalau user batal, berhenti.
    if (image == null) {
      return;
    }

    // 3. Cek ukuran maksimal 5MB.
    int ukuran = await image.length();
    if (ukuran > 5 * 1024 * 1024) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ukuran file maksimal 5MB')));
      return;
    }

    // 4. Cek ekstensi yang boleh: jpg, jpeg, png, webp.
    String nama = image.name.toLowerCase();
    bool boleh =
        nama.endsWith('.jpg') ||
        nama.endsWith('.jpeg') ||
        nama.endsWith('.png') ||
        nama.endsWith('.webp');
    if (!boleh) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hanya jpg, jpeg, png, webp yang diperbolehkan'),
        ),
      );
      return;
    }

    // 5. Simpan gambarnya.
    setState(() {
      gambarTerpilih = image;
    });
  }

  // Tampilkan pesan kecil di bawah layar.
  void tampilkanSnack(String pesan) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  // Kirim artikel baru ke server.
  Future<void> tambahArtikel() async {
    // Jangan kirim dua kali.
    if (lagiMenyimpan) return;

    // 1. Validasi semua field dulu. Kalau ada yang kosong, berhenti.
    if (!formKey.currentState!.validate()) {
      return;
    }

    String judul = judulController.text.trim();
    String penulis = penulisController.text.trim();
    String isi = isiController.text.trim();

    setState(() {
      lagiMenyimpan = true;
    });

    try {
      Uri url = Uri.parse('$apiBaseUrl/api/artikel');
      late http.Response response;

      if (gambarTerpilih == null) {
        // 2a. Tanpa gambar: kirim JSON biasa (mirip addProduct di latihan).
        response = await http
            .post(
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
        // 2b. Dengan gambar: kirim multipart (form + file).
        var request = http.MultipartRequest('POST', url);
        request.headers['Accept'] = 'application/json';
        request.fields['judul_artikel'] = judul;
        request.fields['isi_artikel'] = isi;
        request.fields['id_kategori'] = kategoriTerpilih.toString();
        request.fields['id_penerbit'] = penerbitTerpilih.toString();
        request.fields['penulis_artikel'] = penulis;

        request.files.add(
          await http.MultipartFile.fromPath(
            'gambar_artikel',
            gambarTerpilih!.path,
            filename: gambarTerpilih!.name,
            contentType: mediaTypeForImage(gambarTerpilih!.name),
          ),
        );

        var terkirim = await request.send().timeout(
          const Duration(seconds: 30),
        );
        response = await http.Response.fromStream(terkirim);
      }

      if (!mounted) return;

      // 3. Kalau berhasil (200/201), kembali ke daftar.
      if (response.statusCode == 200 || response.statusCode == 201) {
        tampilkanSnack('Artikel berhasil ditambahkan');
        Navigator.pop(context, true);
      } else {
        tampilkanSnack(
          'Gagal tambah (${response.statusCode}): ${pesanErrorBackend(response.body)}',
        );
      }
    } on TimeoutException {
      tampilkanSnack('Request timeout - coba lagi');
    } catch (e) {
      tampilkanSnack('Error: $e');
    }

    // 4. Matikan loading apa pun hasilnya.
    if (mounted) {
      setState(() {
        lagiMenyimpan = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Ambil kategori dan penerbit saat halaman dibuka.
    getKategori();
    getPenerbit();
  }

  @override
  void dispose() {
    // Buang controller supaya tidak bocor memori.
    judulController.dispose();
    isiController.dispose();
    penulisController.dispose();
    super.dispose();
  }

  // Dekorasi input supaya sama semua: putih, sudut bulat.
  InputDecoration dekorasiInput(String label) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      alignLabelWithHint: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    );
  }

  // Buat daftar item dropdown kategori dari data server.
  // Ditulis pakai for supaya mudah dibaca pemula.
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

  // Sama seperti kategori, tapi untuk penerbit.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Tambah Artikel',
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
              // Judul kecil di atas form.
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
                'New Post',
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
              dropdownKategori(),
              // Kalau gagal muat kategori, tampilkan error + tombol coba lagi.
              if (kategoriError != null)
                barisError(kategoriError!, getKategori),
              const SizedBox(height: 12),

              // Dropdown penerbit.
              dropdownPenerbit(),
              if (penerbitError != null)
                barisError(penerbitError!, getPenerbit),
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

              // Input isi artikel.
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

              // Kotak pilih gambar.
              bagianGambar(),
              const SizedBox(height: 20),

              // Tombol simpan.
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
                  onPressed: lagiMenyimpan ? null : tambahArtikel,
                  child: lagiMenyimpan
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Dropdown kategori.
  Widget dropdownKategori() {
    return DropdownButtonFormField<int>(
      initialValue: kategoriTerpilih,
      isExpanded: true,
      hint: Text(kategoriLoading ? 'Memuat kategori...' : 'Pilih Kategori'),
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
    );
  }

  // Dropdown penerbit.
  Widget dropdownPenerbit() {
    return DropdownButtonFormField<int>(
      initialValue: penerbitTerpilih,
      isExpanded: true,
      hint: Text(penerbitLoading ? 'Memuat penerbit...' : 'Pilih Penerbit'),
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
    );
  }

  // Baris merah untuk error + tombol coba lagi.
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

  // Kotak untuk pilih / ganti / hapus gambar.
  Widget bagianGambar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Pratinjau gambar.
          if (gambarTerpilih != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(gambarTerpilih!.path),
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.image,
                size: 48,
                color: Color(0xFF806B5D),
              ),
            ),
          const SizedBox(height: 8),
          // Tombol pilih gambar.
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
              gambarTerpilih == null
                  ? 'Pilih Gambar (jpg/png/webp, max 5MB)'
                  : 'Ganti Gambar',
            ),
            onPressed: pilihGambar,
          ),
          // Tombol hapus gambar.
          if (gambarTerpilih != null)
            TextButton.icon(
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text(
                'Hapus Gambar',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                setState(() {
                  gambarTerpilih = null;
                });
              },
            ),
        ],
      ),
    );
  }
}
