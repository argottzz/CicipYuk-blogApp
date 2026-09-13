import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
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
  // Form + validator sesuai materi (Bab Input Form Widget).
  final _formKey = GlobalKey<FormState>();

  final judulController = TextEditingController();
  final isiController = TextEditingController();
  final penulisController = TextEditingController();

  final List<dynamic> kategori = [];
  bool _loadingKategori = true;
  String? _kategoriError;
  int? selectedKategori;

  final List<dynamic> penerbit = [];
  bool _loadingPenerbit = true;
  String? _penerbitError;
  int? selectedPenerbit;

  XFile? pickedImage;
  bool _isSubmitting = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> getKategori() async {
    setState(() {
      _loadingKategori = true;
      _kategoriError = null;
    });
    try {
      final response = await http
          .get(Uri.parse('$apiBaseUrl/api/kategori'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List data;
        if (body is Map && body['data'] != null) {
          data = (body['data'] as List?) ?? [];
        } else if (body is List) {
          data = body;
        } else {
          data = [];
        }
        if (!mounted) return;
        setState(() {
          kategori
            ..clear()
            ..addAll(data);
          _loadingKategori = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _loadingKategori = false;
          _kategoriError = 'Gagal memuat kategori (${response.statusCode})';
        });
      }
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _loadingKategori = false;
        _kategoriError = 'Request timeout - coba lagi';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingKategori = false;
        _kategoriError = 'Tidak bisa konek ke server';
      });
    }
  }

  Future<void> getPenerbit() async {
    setState(() {
      _loadingPenerbit = true;
      _penerbitError = null;
    });
    try {
      final response = await http
          .get(Uri.parse('$apiBaseUrl/api/penerbit'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List data;
        if (body is Map && body['data'] != null) {
          data = (body['data'] as List?) ?? [];
        } else if (body is List) {
          data = body;
        } else {
          data = [];
        }
        if (!mounted) return;
        setState(() {
          penerbit
            ..clear()
            ..addAll(data);
          _loadingPenerbit = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _loadingPenerbit = false;
          _penerbitError = 'Gagal memuat penerbit (${response.statusCode})';
        });
      }
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _loadingPenerbit = false;
        _penerbitError = 'Request timeout - coba lagi';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingPenerbit = false;
        _penerbitError = 'Tidak bisa konek ke server';
      });
    }
  }

  /// Pilih gambar dengan validasi ukuran (max 5MB) dan ekstensi.
  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) {
      final int bytes = await image.length();
      if (bytes > 5 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ukuran file maksimal 5MB')),
        );
        return;
      }
      final String ext = image.name.toLowerCase();
      if (!(ext.endsWith('.jpg') ||
          ext.endsWith('.jpeg') ||
          ext.endsWith('.png') ||
          ext.endsWith('.webp'))) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hanya jpg, jpeg, png, webp yang diperbolehkan'),
          ),
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
    // Validasi via Form (materi: formKey.currentState!.validate()).
    // Validator inline di tiap field, jadi tidak ada teks merah sebelum Simpan.
    if (!_formKey.currentState!.validate()) return;

    final String judul = judulController.text.trim();
    final String penulis = penulisController.text.trim();
    final String isi = isiController.text.trim();

    setState(() => _isSubmitting = true);
    try {
      final Uri url = Uri.parse('$apiBaseUrl/api/artikel');
      late final http.Response response;

      if (pickedImage == null) {
        // Tanpa gambar: kirim JSON biasa.
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
                'id_kategori': selectedKategori,
                'id_penerbit': selectedPenerbit,
                'penulis_artikel': penulis,
              }),
            )
            .timeout(const Duration(seconds: 20));
      } else {
        final request = http.MultipartRequest('POST', url);
        request.headers['Accept'] = 'application/json';
        request.fields['judul_artikel'] = judul;
        request.fields['isi_artikel'] = isi;
        request.fields['id_kategori'] = selectedKategori.toString();
        request.fields['id_penerbit'] = selectedPenerbit.toString();
        request.fields['penulis_artikel'] = penulis;

        request.files.add(
          await http.MultipartFile.fromPath(
            'gambar_artikel',
            pickedImage!.path,
            filename: pickedImage!.name,
            contentType: mediaTypeForImage(pickedImage!.name),
          ),
        );

        final streamed = await request.send().timeout(
          const Duration(seconds: 30),
        );
        response = await http.Response.fromStream(streamed);
      }

      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Artikel berhasil ditambahkan')),
        );
        Navigator.pop(context, true);
      } else {
        print('gagal tambah artikel: ${response.statusCode} ${response.body}');
        _snack(
          'Gagal tambah (${response.statusCode}): ${pesanErrorBackend(response.body)}',
        );
      }
    } on TimeoutException {
      print('timeout tambah artikel');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request timeout - coba lagi')),
      );
    } catch (e) {
      print('error tambah: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void initState() {
    super.initState();
    getKategori();
    getPenerbit();
  }

  @override
  void dispose() {
    judulController.dispose();
    isiController.dispose();
    penulisController.dispose();
    super.dispose();
  }

  // Extract widget in-file: dekorasi field disamakan Add/Edit.
  InputDecoration _field(String label) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      alignLabelWithHint: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuItem<int>> kategoriItems = kategori
        .map((item) {
          final int? id = parseKategoriIdFromItem(item);
          if (id == null) return null;
          return DropdownMenuItem<int>(
            value: id,
            child: Text(kategoriName(item), overflow: TextOverflow.ellipsis),
          );
        })
        .whereType<DropdownMenuItem<int>>()
        .toList();

    final List<DropdownMenuItem<int>> penerbitItems = penerbit
        .map((item) {
          final int? id = parsePenerbitIdFromItem(item);
          if (id == null) return null;
          return DropdownMenuItem<int>(
            value: id,
            child: Text(penerbitName(item), overflow: TextOverflow.ellipsis),
          );
        })
        .whereType<DropdownMenuItem<int>>()
        .toList();

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
          key: _formKey,
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
                'New Post',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                  color: Color(0xFF33251F),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: judulController,
                textInputAction: TextInputAction.next,
                decoration: _field('Judul Artikel'),
                validator: (value) {
                  final v = (value ?? '').trim();
                  if (v.isEmpty) return 'Judul wajib diisi';
                  if (v.length > 200) return 'Judul maksimal 200 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildKategoriField(kategoriItems),
              if (_kategoriError != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _kategoriError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                    TextButton(
                      onPressed: getKategori,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              _buildPenerbitField(penerbitItems),
              if (_penerbitError != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _penerbitError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                    TextButton(
                      onPressed: getPenerbit,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: penulisController,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: _field('Penulis Artikel'),
                validator: (value) {
                  final v = (value ?? '').trim();
                  if (v.isEmpty) return 'Penulis wajib diisi';
                  if (v.length > 100) return 'Penulis maksimal 100 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: isiController,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                decoration: _field('Isi Artikel'),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Isi artikel wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildImageSection(),
              const SizedBox(height: 20),
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
                  onPressed: _isSubmitting ? null : tambahArtikel,
                  child: _isSubmitting
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

  // Extract widget in-file (tanpa file baru).
  Widget _buildKategoriField(List<DropdownMenuItem<int>> kategoriItems) {
    return DropdownButtonFormField<int>(
      initialValue: selectedKategori,
      isExpanded: true,
      hint: Text(
        _loadingKategori ? 'Memuat kategori...' : 'Pilih Kategori',
      ),
      decoration: _field('Kategori'),
      items: kategoriItems,
      validator: (value) =>
          value == null ? 'Wajib pilih kategori' : null,
      onChanged: _loadingKategori
          ? null
          : (value) {
              setState(() => selectedKategori = value);
            },
    );
  }

  Widget _buildPenerbitField(List<DropdownMenuItem<int>> penerbitItems) {
    return DropdownButtonFormField<int>(
      initialValue: selectedPenerbit,
      isExpanded: true,
      hint: Text(
        _loadingPenerbit ? 'Memuat penerbit...' : 'Pilih Penerbit',
      ),
      decoration: _field('Penerbit'),
      items: penerbitItems,
      validator: (value) =>
          value == null ? 'Wajib pilih penerbit' : null,
      onChanged: _loadingPenerbit
          ? null
          : (value) {
              setState(() => selectedPenerbit = value);
            },
    );
  }

  Widget _buildImageSection() {
    return Container(
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
              pickedImage == null
                  ? 'Pilih Gambar (jpg/png/webp, max 5MB)'
                  : 'Ganti Gambar',
            ),
            onPressed: pickImage,
          ),
          if (pickedImage != null)
            TextButton.icon(
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text(
                'Hapus Gambar',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () => setState(() => pickedImage = null),
            ),
        ],
      ),
    );
  }
}
