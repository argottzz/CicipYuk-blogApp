import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/category.dart';
import '../services/api_service.dart';

class PostFormScreen extends StatefulWidget {
  final Post? post;
  const PostFormScreen({super.key, this.post});

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  // GlobalKey untuk kontrol Form (materi Bab 4)
  final _formKey = GlobalKey<FormState>();

  // Controller untuk TextField dan TextFormField
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _contentCtrl = TextEditingController();
  final TextEditingController _excerptCtrl = TextEditingController();
  final TextEditingController _imageCtrl = TextEditingController();

  final ApiService _api = ApiService();

  // data kategori
  List<Category> _kategori = [];
  bool _loadingKategori = false;

  // variabel untuk widget input sesuai materi Bab 4
  int? _selectedCategoryId; // untuk DropdownButton
  bool _setuju = false; // untuk Checkbox
  String _status = "draft"; // untuk Radio (draft / publish)
  bool _komentarAktif = true; // untuk Switch
  double _rating = 3; // untuk Slider
  DateTime? _tanggalPilih; // untuk DatePicker
  TimeOfDay? _jamPilih; // untuk TimePicker

  bool _isSaving = false;

  bool get isEdit => widget.post != null;

  @override
  void initState() {
    super.initState();
    // kalau edit, isi data lama
    if (widget.post != null) {
      _titleCtrl.text = widget.post!.title;
      _contentCtrl.text = widget.post!.content;
      _excerptCtrl.text = widget.post!.excerpt ?? '';
      _imageCtrl.text = widget.post!.imageUrl ?? '';
      _selectedCategoryId = widget.post!.categoryId;
    }
    _loadKategori();
  }

  Future<void> _loadKategori() async {
    setState(() {
      _loadingKategori = true;
    });
    try {
      List<Category> data = await _api.fetchCategories();
      setState(() {
        _kategori = data;
      });
    } catch (e) {
      // ignore: avoid_print
      print("gagal load kategori: $e");
    }
    setState(() {
      _loadingKategori = false;
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _excerptCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  // simpan data
  Future<void> _save() async {
    // validate() = cek semua validator di TextFormField
    bool valid = _formKey.currentState!.validate();
    if (valid == false) {
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori dulu'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_setuju == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Centang persetujuan dulu'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (isEdit) {
        // edit
        await _api.updatePost(
          widget.post!.id,
          title: _titleCtrl.text.trim(),
          content: _contentCtrl.text.trim(),
          excerpt: _excerptCtrl.text.trim(),
          imageUrl: _imageCtrl.text.trim(),
          categoryId: _selectedCategoryId,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Artikel berhasil diupdate'), backgroundColor: Colors.green),
          );
        }
      } else {
        // buat baru
        await _api.createPost(
          title: _titleCtrl.text.trim(),
          content: _contentCtrl.text.trim(),
          excerpt: _excerptCtrl.text.trim(),
          imageUrl: _imageCtrl.text.trim(),
          categoryId: _selectedCategoryId,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Artikel berhasil dibuat'), backgroundColor: Colors.green),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal simpan: $e'), backgroundColor: Colors.red),
        );
      }
    }

    setState(() {
      _isSaving = false;
    });
  }

  // reset form
  void _resetForm() {
    // reset() = kembalikan form ke nilai awal
    _formKey.currentState!.reset();
    _titleCtrl.clear();
    _contentCtrl.clear();
    _excerptCtrl.clear();
    _imageCtrl.clear();
    setState(() {
      _selectedCategoryId = null;
      _setuju = false;
      _status = "draft";
      _komentarAktif = true;
      _rating = 3;
      _tanggalPilih = null;
      _jamPilih = null;
    });
  }

  // pilih tanggal
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _tanggalPilih = picked;
      });
    }
  }

  // pilih jam
  Future<void> _pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _jamPilih = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Artikel' : 'Tulis Artikel'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // preview gambar
            if (_imageCtrl.text.trim().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _imageCtrl.text.trim(),
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) {
                    return Container(
                      height: 80,
                      color: Colors.grey[200],
                      child: const Center(child: Text('URL gambar tidak valid')),
                    );
                  },
                ),
              ),
            if (_imageCtrl.text.trim().isNotEmpty) const SizedBox(height: 12),

            // TextFormField untuk judul (wajib pakai validator)
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Judul *',
                hintText: 'Contoh: Belajar Flutter untuk Pemula',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                // validator = cek input, return String kalau error, null kalau benar
                if (value == null || value.trim().isEmpty) {
                  return 'Judul wajib diisi';
                }
                if (value.trim().length < 3) {
                  return 'Judul minimal 3 huruf';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // DropdownButton untuk kategori (materi Bab 4)
            if (_loadingKategori)
              const LinearProgressIndicator()
            else
              DropdownButtonFormField<int>(
                initialValue: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Kategori *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                hint: const Text('Pilih kategori'),
                items: _kategori.map((cat) {
                  return DropdownMenuItem<int>(
                    value: cat.id,
                    child: Text(cat.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Kategori wajib dipilih';
                  }
                  return null;
                },
              ),
            const SizedBox(height: 14),

            // TextFormField untuk ringkasan (opsional)
            TextFormField(
              controller: _excerptCtrl,
              decoration: const InputDecoration(
                labelText: 'Ringkasan (opsional)',
                hintText: 'Ringkasan singkat',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.short_text),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 14),

            // TextFormField untuk URL gambar
            TextFormField(
              controller: _imageCtrl,
              decoration: InputDecoration(
                labelText: 'URL Gambar (opsional)',
                hintText: 'https://...',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.image),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.preview),
                  onPressed: () {
                    setState(() {});
                  },
                ),
              ),
              onChanged: (val) {
                setState(() {});
              },
            ),
            const SizedBox(height: 14),

            // TextFormField untuk konten (wajib)
            TextFormField(
              controller: _contentCtrl,
              decoration: const InputDecoration(
                labelText: 'Konten *',
                hintText: 'Tulis isi artikel...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 6,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Konten wajib diisi';
                }
                if (value.trim().length < 10) {
                  return 'Konten minimal 10 huruf';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // ===== Widget Input sesuai materi Bab 4 =====
            const Text('Pengaturan Tambahan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),

            // CheckboxListTile
            CheckboxListTile(
              title: const Text('Saya setuju artikel ini original'),
              value: _setuju,
              onChanged: (value) {
                setState(() {
                  _setuju = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),

            // Checkbox biasa (contoh lain)
            Row(
              children: [
                Checkbox(
                  value: _setuju,
                  onChanged: (value) {
                    setState(() {
                      _setuju = value ?? false;
                    });
                  },
                ),
                const Text('Setuju syarat & ketentuan'),
              ],
            ),
            const SizedBox(height: 8),

            // RadioListTile untuk status (pakai RadioGroup biar tidak deprecated)
            const Text('Status Artikel:'),
            RadioGroup<String>(
              groupValue: _status,
              onChanged: (value) {
                setState(() {
                  _status = value!;
                });
              },
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Draft'),
                    value: "draft",
                  ),
                  RadioListTile<String>(
                    title: const Text('Publish'),
                    value: "publish",
                  ),
                ],
              ),
            ),

            // Radio biasa
            RadioGroup<String>(
              groupValue: _status,
              onChanged: (value) {
                setState(() {
                  _status = value!;
                });
              },
              child: const Row(
                children: [
                  Radio<String>(value: "draft"),
                  Text('Draft'),
                  Radio<String>(value: "publish"),
                  Text('Publish'),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // SwitchListTile
            SwitchListTile(
              title: const Text('Aktifkan Komentar'),
              subtitle: const Text('Pembaca bisa komentar'),
              value: _komentarAktif,
              onChanged: (value) {
                setState(() {
                  _komentarAktif = value;
                });
              },
            ),

            // Switch biasa
            Row(
              children: [
                const Text('Komentar: '),
                Switch(
                  value: _komentarAktif,
                  onChanged: (value) {
                    setState(() {
                      _komentarAktif = value;
                    });
                  },
                ),
                Text(_komentarAktif ? 'On' : 'Off'),
              ],
            ),
            const SizedBox(height: 8),

            // Slider untuk rating
            const Text('Rating Artikel:'),
            Slider(
              value: _rating,
              min: 0,
              max: 5,
              divisions: 5,
              label: _rating.toString(),
              onChanged: (value) {
                setState(() {
                  _rating = value;
                });
              },
            ),
            Text('Nilai: $_rating dari 5', textAlign: TextAlign.center),
            const SizedBox(height: 12),

            // DatePicker dan TimePicker
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.date_range),
                    label: Text(_tanggalPilih == null ? 'Pilih Tanggal' : '${_tanggalPilih!.day}/${_tanggalPilih!.month}/${_tanggalPilih!.year}'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.access_time),
                    label: Text(_jamPilih == null ? 'Pilih Jam' : _jamPilih!.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tombol simpan dan reset
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Icon(isEdit ? Icons.save : Icons.send),
                label: Text(_isSaving ? 'Menyimpan...' : (isEdit ? 'Update Artikel' : 'Publikasikan')),
              ),
            ),
            const SizedBox(height: 10),

            // Tombol reset pakai reset()
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _resetForm,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset Form'),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '* wajib diisi. Data akan divalidasi di form dan di backend.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
