import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../api_config.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final judulController = TextEditingController();
  final isiController = TextEditingController();
  final penulisController = TextEditingController();

  List<dynamic> kategori = [];
  bool _loadingKategori = true;
  String? _kategoriError;
  int? selectedKategori;
  XFile? pickedImage;
  bool _isSubmitting = false;
  final ImagePicker _picker = ImagePicker();

  int? _parseKategoriId(dynamic item) {
    final raw = item['id_kategori'] ?? item['id'];
    if (raw == null) return null;
    if (raw is int) return raw;
    return int.tryParse(raw.toString());
  }

  String _kategoriName(dynamic item) {
    return (item['nama_kategori'] ?? item['name'] ?? '-').toString();
  }

  Future<void> getKategori() async {
    setState(() {
      _loadingKategori = true;
      _kategoriError = null;
    });
    try {
      final response = await http.get(
        Uri.parse("$apiBaseUrl/api/kategori"),
      );

      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        List data;
        if (body is Map && body['data'] != null) {
          data = (body['data'] as List?) ?? [];
        } else if (body is List) {
          data = body;
        } else {
          data = [];
        }
        if (!mounted) return;
        setState(() {
          kategori = data;
          _loadingKategori = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _loadingKategori = false;
          _kategoriError = "Gagal memuat kategori (${response.statusCode})";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingKategori = false;
        _kategoriError = "Tidak bisa konek ke server";
      });
    }
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) {
      final bytes = await image.length();
      if (bytes > 5 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ukuran file maksimal 5MB")),
        );
        return;
      }
      final ext = image.name.toLowerCase();
      if (!(ext.endsWith(".jpg") ||
          ext.endsWith(".jpeg") ||
          ext.endsWith(".png") ||
          ext.endsWith(".webp"))) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Hanya jpg, jpeg, png, webp yang diperbolehkan")),
        );
        return;
      }
      setState(() => pickedImage = image);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> tambahArtikel() async {
    if (_isSubmitting) return;
    // Validasi manual saat Simpan saja, tidak ada teks merah inline.
    final judul = judulController.text.trim();
    final penulis = penulisController.text.trim();
    final isi = isiController.text.trim();
    if (judul.isEmpty) {
      _snack("Judul wajib diisi");
      return;
    }
    if (judul.length > 200) {
      _snack("Judul maksimal 200 karakter");
      return;
    }
    if (selectedKategori == null) {
      _snack("Wajib pilih kategori");
      return;
    }
    if (penulis.isEmpty) {
      _snack("Penulis wajib diisi");
      return;
    }
    if (penulis.length > 100) {
      _snack("Penulis maksimal 100 karakter");
      return;
    }
    if (isi.isEmpty) {
      _snack("Isi artikel wajib diisi");
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$apiBaseUrl/api/artikel"),
      );
      request.headers['Accept'] = 'application/json';
      request.fields['judul_artikel'] = judulController.text.trim();
      request.fields['isi_artikel'] = isiController.text.trim();
      request.fields['id_kategori'] = selectedKategori.toString();
      request.fields['penulis_artikel'] = penulisController.text.trim();

      if (pickedImage != null) {
        final name = pickedImage!.name.toLowerCase();
        MediaType contentType;
        if (name.endsWith('.png')) {
          contentType = MediaType('image', 'png');
        } else if (name.endsWith('.webp')) {
          contentType = MediaType('image', 'webp');
        } else {
          contentType = MediaType('image', 'jpeg');
        }
        request.files.add(
          await http.MultipartFile.fromPath(
            'gambar_artikel',
            pickedImage!.path,
            filename: pickedImage!.name,
            contentType: contentType,
          ),
        );
      }

      var streamed = await request.send();
      var response = await http.Response.fromStream(streamed);

      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Artikel berhasil ditambahkan")),
        );
        Navigator.pop(context, true);
      } else {
        print("gagal tambah artikel: ${response.statusCode} ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Gagal tambah (${response.statusCode}): ${response.body}")),
        );
      }
    } catch (e) {
      print("error tambah: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void initState() {
    super.initState();
    getKategori();
  }

  @override
  void dispose() {
    judulController.dispose();
    isiController.dispose();
    penulisController.dispose();
    super.dispose();
  }

  // Fix label nabrak: beri ruang vertikal + pastikan label mengambang
  // di atas input, tidak menumpuk dengan teks/hint.
  InputDecoration _field(String label) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      alignLabelWithHint: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kategoriItems = kategori
        .map((item) {
          final id = _parseKategoriId(item);
          if (id == null) return null;
          return DropdownMenuItem<int>(
            value: id,
            child: Text(_kategoriName(item),
                overflow: TextOverflow.ellipsis),
          );
        })
        .whereType<DropdownMenuItem<int>>()
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Tambah Artikel",
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("CicipYuk",
                style: TextStyle(
                    color: Color(0xFFE85D2A),
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text("New Post",
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5)),
            const SizedBox(height: 16),
            TextField(
              controller: judulController,
              textInputAction: TextInputAction.next,
              decoration: _field("Judul Artikel"),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: selectedKategori,
              isExpanded: true,
              hint: Text(_loadingKategori
                  ? "Memuat kategori..."
                  : "Pilih Kategori"),
              decoration: _field("Kategori"),
              items: kategoriItems,
              onChanged: _loadingKategori
                  ? null
                  : (value) {
                      setState(() => selectedKategori = value);
                    },
            ),
              if (_kategoriError != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(_kategoriError!,
                          style: const TextStyle(
                              color: Colors.red, fontSize: 12)),
                    ),
                    TextButton(
                        onPressed: getKategori,
                        child: const Text("Coba lagi")),
                  ],
                ),
              ],
            const SizedBox(height: 12),
            TextField(
              controller: penulisController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: _field("Penulis Artikel"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: isiController,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
              decoration: _field("Isi Artikel"),
            ),
              const SizedBox(height: 12),
              // Image picker
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    if (pickedImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(pickedImage!.path),
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
                          color: const Color(0xFFF5F1EA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.image,
                            size: 48, color: Colors.grey),
                      ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side:
                            const BorderSide(color: Color(0xFFE8E0D5)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      icon: const Icon(Icons.photo_library),
                      label: Text(pickedImage == null
                          ? "Pilih Gambar (jpg/png/webp, max 5MB)"
                          : "Ganti Gambar"),
                      onPressed: pickImage,
                    ),
                    if (pickedImage != null)
                      TextButton.icon(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text("Hapus Gambar",
                            style: TextStyle(color: Colors.red)),
                        onPressed: () =>
                            setState(() => pickedImage = null),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: _isSubmitting ? null : tambahArtikel,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text("Simpan"),
                ),
              ),
            ],
          ),
      ),
    );
  }
}
