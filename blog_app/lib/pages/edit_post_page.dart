import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../api_config.dart';

class EditPostPage extends StatefulWidget {
  final dynamic artikel;

  const EditPostPage({
    super.key,
    this.artikel,
  });

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final judulController = TextEditingController();
  final isiController = TextEditingController();
  final penulisController = TextEditingController();

  List<dynamic> kategori = [];
  bool _loadingKategori = true;
  String? _kategoriError;
  int? selectedKategori;

  List<dynamic> penerbit = [];
  bool _loadingPenerbit = true;
  String? _penerbitError;
  int? selectedPenerbit;

  XFile? pickedImage;
  bool _isSubmitting = false;

  final ImagePicker _picker = ImagePicker();

  int? _parseKategoriId(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    return int.tryParse(raw.toString());
  }

  String _kategoriName(dynamic item) {
    return (item['nama_kategori'] ?? item['name'] ?? '-').toString();
  }

  int? _parsePenerbitId(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    return int.tryParse(raw.toString());
  }

  String _penerbitName(dynamic item) {
    return (item['nama_penerbit'] ?? item['name'] ?? '-').toString();
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

  Future<void> getPenerbit() async {
    setState(() {
      _loadingPenerbit = true;
      _penerbitError = null;
    });
    try {
      final response = await http.get(
        Uri.parse("$apiBaseUrl/api/penerbit"),
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
          penerbit = data;
          _loadingPenerbit = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _loadingPenerbit = false;
          _penerbitError = "Gagal memuat penerbit (${response.statusCode})";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingPenerbit = false;
        _penerbitError = "Tidak bisa konek ke server";
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
          const SnackBar(
            content: Text("Ukuran file maksimal 5MB"),
          ),
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
            content: Text(
              "Hanya jpg, jpeg, png, webp yang diperbolehkan",
            ),
          ),
        );

        return;
      }

      setState(() {
        pickedImage = image;
      });
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> updateArtikel() async {
    if (_isSubmitting) return;
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
    if (selectedPenerbit == null) {
      _snack("Wajib pilih penerbit");
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

    final idRaw = widget.artikel['id'] ?? widget.artikel['id_artikel'];
    if (idRaw == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ID artikel tidak ditemukan")),
      );
      return;
    }
    final id = idRaw.toString();

    setState(() => _isSubmitting = true);
    try {
      final url = Uri.parse("$apiBaseUrl/api/artikel/$id");
      http.Response response;

      if (pickedImage == null) {
        // Tanpa gambar baru: PUT JSON biasa ke backend Express.
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
                'id_kategori': selectedKategori,
                'id_penerbit': selectedPenerbit,
                'penulis_artikel': penulis,
              }),
            )
            .timeout(const Duration(seconds: 20));
      } else {
        // Dengan gambar: backend Express (multer) terima PUT multipart langsung.
        var request = http.MultipartRequest('PUT', url);

        request.headers['Accept'] = 'application/json';
        request.fields['judul_artikel'] = judul;
        request.fields['isi_artikel'] = isi;
        request.fields['id_kategori'] = selectedKategori.toString();
        request.fields['id_penerbit'] = selectedPenerbit.toString();
        request.fields['penulis_artikel'] = penulis;

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

        var streamed =
            await request.send().timeout(const Duration(seconds: 30));

        response = await http.Response.fromStream(
          streamed,
        );
      }

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Artikel berhasil diupdate"),
          ),
        );

        Navigator.pop(context, true);
      } else {
        print(
          "Gagal update: ${response.statusCode} ${response.body}",
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Gagal update (${response.statusCode}): ${_pesanError(response.body)}",
            ),
          ),
        );
      }
    } catch (e) {
      print("Error update: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _pesanError(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        final errors = decoded['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final parts = <String>[];
          errors.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              parts.add("${value.first}");
            } else {
              parts.add("$key: $value");
            }
          });
          return parts.join(", ");
        }
        final msg = decoded['message'];
        if (msg is String && msg.isNotEmpty) return msg;
      }
      if (body.length > 300) return "${body.substring(0, 300)}...";
      return body.isEmpty ? "respons kosong dari server" : body;
    } catch (_) {
      if (body.length > 300) return "${body.substring(0, 300)}...";
      return body.isEmpty ? "respons kosong dari server" : body;
    }
  }

  @override
  void initState() {
    super.initState();

    getKategori();
    getPenerbit();

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

    selectedKategori = _parseKategoriId(
      widget.artikel['id_kategori'] ??
          widget.artikel['category_id'] ??
          widget.artikel['kategori_id'],
    );

    selectedPenerbit = _parsePenerbitId(
      widget.artikel['id_penerbit'] ??
          widget.artikel['penerbit_id'] ??
          widget.artikel['idPenerbit'],
    );
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
  InputDecoration _decor(String label) {
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
    final existingGambar =
        (widget.artikel['gambar_artikel'] ??
                widget.artikel['gambar'] ??
                widget.artikel['image'])
            ?.toString();

    final kategoriIds =
        kategori.map(_parseKategoriIdFromItem).whereType<int>().toSet();
    final dropdownValue =
        (selectedKategori != null && kategoriIds.contains(selectedKategori))
            ? selectedKategori
            : null;

    final kategoriItems = kategori
        .map((item) {
          final id = _parseKategoriIdFromItem(item);
          if (id == null) return null;
          return DropdownMenuItem<int>(
            value: id,
            child: Text(_kategoriName(item),
                overflow: TextOverflow.ellipsis),
          );
        })
        .whereType<DropdownMenuItem<int>>()
        .toList();

    final penerbitIds = penerbit
        .map((item) =>
            _parsePenerbitId(item['id_penerbit'] ?? item['id']))
        .whereType<int>()
        .toSet();
    final dropdownPenerbitValue =
        (selectedPenerbit != null && penerbitIds.contains(selectedPenerbit))
            ? selectedPenerbit
            : null;

    final penerbitItems = penerbit
        .map((item) {
          final id =
              _parsePenerbitId(item['id_penerbit'] ?? item['id']);
          if (id == null) return null;
          return DropdownMenuItem<int>(
            value: id,
            child: Text(_penerbitName(item),
                overflow: TextOverflow.ellipsis),
          );
        })
        .whereType<DropdownMenuItem<int>>()
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Edit Artikel",
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("CicipYuk",
                style: TextStyle(
                    color: Color(0xFFF28C28),
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text("Edit Post",
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                    color: Color(0xFF33251F))),
            const SizedBox(height: 16),
            TextField(
              controller: judulController,
              textInputAction: TextInputAction.next,
              decoration: _decor("Judul Artikel"),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: dropdownValue,
              isExpanded: true,
              hint: Text(_loadingKategori
                  ? "Memuat kategori..."
                  : "Pilih Kategori"),
              decoration: _decor("Kategori"),
              items: kategoriItems,
              onChanged: _loadingKategori
                  ? null
                  : (value) {
                      setState(() {
                        selectedKategori = value;
                      });
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
              ] else if (!_loadingKategori && kategoriItems.isEmpty) ...[
                const SizedBox(height: 6),
                const Text("Belum ada kategori di server.",
                    style: TextStyle(color: Colors.red, fontSize: 12)),
              ],
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: dropdownPenerbitValue,
              isExpanded: true,
              hint: Text(_loadingPenerbit
                  ? "Memuat penerbit..."
                  : "Pilih Penerbit"),
              decoration: _decor("Penerbit"),
              items: penerbitItems,
              onChanged: _loadingPenerbit
                  ? null
                  : (value) {
                      setState(() {
                        selectedPenerbit = value;
                      });
                    },
            ),
              if (_penerbitError != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(_penerbitError!,
                          style: const TextStyle(
                              color: Colors.red, fontSize: 12)),
                    ),
                    TextButton(
                        onPressed: getPenerbit,
                        child: const Text("Coba lagi")),
                  ],
                ),
              ] else if (!_loadingPenerbit && penerbitItems.isEmpty) ...[
                const SizedBox(height: 6),
                const Text("Belum ada penerbit di server.",
                    style: TextStyle(color: Colors.red, fontSize: 12)),
              ],
            const SizedBox(height: 12),
            TextField(
              controller: penulisController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: _decor("Penulis Artikel"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: isiController,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
              decoration: _decor("Isi Artikel"),
            ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (pickedImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(pickedImage!.path),
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    else if (existingGambar != null &&
                        existingGambar.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          gambarArtikelUrl(existingGambar),
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          loadingBuilder: (
                            c,
                            child,
                            progress,
                          ) {
                            if (progress == null) {
                              return child;
                            }

                            return Container(
                              height: 180,
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                          errorBuilder: (c, e, s) {
                            print(
                              'Gagal load gambar edit '
                              '${gambarArtikelUrl(existingGambar)}: $e',
                            );

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
                    else
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.image,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF33251F),
                        side:
                            const BorderSide(color: Color(0xFFF28C28)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      icon: const Icon(
                        Icons.photo_library,
                      ),
                      label: Text(
                        pickedImage == null &&
                                (existingGambar == null ||
                                    existingGambar.isEmpty)
                            ? "Pilih Gambar (jpg/png/webp, max 5MB)"
                            : "Ganti Gambar (opsional)",
                      ),
                      onPressed: pickImage,
                    ),
                    if (pickedImage != null)
                      TextButton.icon(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        label: const Text(
                          "Hapus Gambar Baru",
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            pickedImage = null;
                          });
                        },
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
                    backgroundColor: const Color(0xFFF28C28),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: _isSubmitting ? null : updateArtikel,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text("Update",
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ],
          ),
      ),
    );
  }

  int? _parseKategoriIdFromItem(dynamic item) {
    if (item is! Map) return null;
    return _parseKategoriId(
        item['id_kategori'] ?? item['id'] ?? item['idKategori']);
  }
}

class EditArtikelPage extends EditPostPage {
  const EditArtikelPage({
    super.key,
    required super.artikel,
  });
}
