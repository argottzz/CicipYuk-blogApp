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
  TextEditingController judulController = TextEditingController();
  TextEditingController isiController = TextEditingController();
  TextEditingController penulisController = TextEditingController();

  List<dynamic> kategori = [];
  int? selectedKategori;

  XFile? pickedImage;

  final ImagePicker _picker = ImagePicker();

  Future<void> getKategori() async {
    try {
      final response = await http.get(
        Uri.parse("$apiBaseUrl/api/kategori"),
      );

      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);

        List data;

        if (body is Map && body['data'] != null) {
          data = body['data'];
        } else if (body is List) {
          data = body;
        } else {
          data = [];
        }

        setState(() {
          kategori = data;
        });
      } else {
        print("Gagal ambil kategori");
      }
    } catch (e) {
      print("Error ambil kategori: $e");
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
              "Hanya jpg, png, webp yang diperbolehkan",
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

  Future<void> updateArtikel() async {
    try {
      int id = widget.artikel['id'] ?? widget.artikel['id_artikel'];

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse("$apiBaseUrl/api/artikel/$id"),
      );

      request.headers['Accept'] = 'application/json';

      request.fields['judul_artikel'] = judulController.text;
      request.fields['isi_artikel'] = isiController.text;
      request.fields['id_kategori'] = selectedKategori.toString();
      request.fields['penulis_artikel'] = penulisController.text;

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

      var response = await http.Response.fromStream(
        streamed,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
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
              "Gagal update: ${response.statusCode} ${response.body}",
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
    }
  }

  @override
  void initState() {
    super.initState();

    getKategori();

    judulController.text =
        widget.artikel['judul_artikel'] ??
        widget.artikel['title'] ??
        '';

    isiController.text =
        widget.artikel['isi_artikel'] ??
        widget.artikel['content'] ??
        '';

    penulisController.text =
        widget.artikel['penulis_artikel'] ?? '';

    selectedKategori =
        widget.artikel['id_kategori'] ??
        widget.artikel['category_id'];
  }

  @override
  Widget build(BuildContext context) {
    final existingGambar =
        (widget.artikel['gambar_artikel'] ??
                widget.artikel['gambar'] ??
                widget.artikel['image'])
            as String?;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Edit Artikel", style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("CicipYuk", style: TextStyle(color: Color(0xFFE85D2A), fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text("Edit Post", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600, letterSpacing: -0.5)),
            const SizedBox(height: 16),
            TextField(
              controller: judulController,
              decoration: const InputDecoration(
                labelText: "Judul Artikel",
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: kategori.any(
                (e) =>
                    (e['id'] ?? e['id_kategori']) ==
                    selectedKategori,
              )
                  ? selectedKategori
                  : null,
              hint: const Text("Pilih Kategori"),
              decoration: const InputDecoration(
                labelText: "Kategori",
              ),
              items: kategori.map((item) {
                return DropdownMenuItem<int>(
                  value: item['id'] ?? item['id_kategori'],
                  child: Text(
                    item['nama_kategori'] ??
                        item['name'] ??
                        '-',
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedKategori = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: penulisController,
              decoration: const InputDecoration(
                labelText: "Penulis Artikel",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: isiController,
              decoration: const InputDecoration(
                labelText: "Isi Artikel",
              ),
              maxLines: 5,
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
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Color(0xFFE8E0D5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    icon: const Icon(
                      Icons.photo_library,
                    ),
                    label: Text(
                      pickedImage == null &&
                              existingGambar == null
                          ? "Pilih Gambar (jpg/png/webp, max 5MB)"
                          : "Ganti Gambar",
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
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: updateArtikel,
                child: const Text("Update"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditArtikelPage extends EditPostPage {
  const EditArtikelPage({
    super.key,
    required super.artikel,
  });
}