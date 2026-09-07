import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../providers/post_provider.dart';
import '../providers/category_provider.dart';

class PostFormScreen extends StatefulWidget {
  final Post? post; // null = create, not null = edit
  const PostFormScreen({super.key, this.post});

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;
  late TextEditingController _excerptCtrl;
  late TextEditingController _imageCtrl;
  int? _selectedCategoryId;
  bool _isSaving = false;

  bool get isEdit => widget.post != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.post?.title ?? '');
    _contentCtrl = TextEditingController(text: widget.post?.content ?? '');
    _excerptCtrl = TextEditingController(text: widget.post?.excerpt ?? '');
    _imageCtrl = TextEditingController(text: widget.post?.imageUrl ?? '');
    _selectedCategoryId = widget.post?.categoryId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final catProv = context.read<CategoryProvider>();
      if (catProv.categories.isEmpty) catProv.loadCategories();
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori dulu'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final prov = context.read<PostProvider>();
      if (isEdit) {
        await prov.editPost(
          widget.post!.id,
          title: _titleCtrl.text.trim(),
          content: _contentCtrl.text.trim(),
          excerpt: _excerptCtrl.text.trim().isEmpty ? null : _excerptCtrl.text.trim(),
          imageUrl: _imageCtrl.text.trim().isEmpty ? null : _imageCtrl.text.trim(),
          categoryId: _selectedCategoryId,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Artikel berhasil diupdate'), backgroundColor: Colors.green),
          );
        }
      } else {
        await prov.addPost(
          title: _titleCtrl.text.trim(),
          content: _contentCtrl.text.trim(),
          excerpt: _excerptCtrl.text.trim().isEmpty ? null : _excerptCtrl.text.trim(),
          imageUrl: _imageCtrl.text.trim().isEmpty ? null : _imageCtrl.text.trim(),
          categoryId: _selectedCategoryId,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Artikel berhasil dibuat'), backgroundColor: Colors.green),
          );
        }
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal simpan: $e'), backgroundColor: Colors.red, duration: const Duration(seconds: 4)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
            // Preview image
            if (_imageCtrl.text.trim().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _imageCtrl.text.trim(),
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 80,
                    color: Colors.grey[200],
                    child: const Center(child: Text('Preview gagal, cek URL gambar')),
                  ),
                ),
              ),
            if (_imageCtrl.text.trim().isNotEmpty) const SizedBox(height: 12),
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Judul *',
                hintText: 'Contoh: Belajar Flutter untuk Pemula',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Judul wajib diisi';
                if (v.trim().length < 3) return 'Judul minimal 3 karakter';
                if (v.trim().length > 255) return 'Judul maksimal 255 karakter';
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 14),
            Consumer<CategoryProvider>(
              builder: (context, catProv, _) {
                if (catProv.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: LinearProgressIndicator(),
                  );
                }
                if (catProv.categories.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.orange),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.orange.withValues(alpha: 0.05),
                    ),
                    child: Row(
                      children: [
                        const Expanded(child: Text('Belum ada kategori. Buat di backend dulu.')),
                        TextButton(
                          onPressed: () => catProv.loadCategories(),
                          child: const Text('Refresh'),
                        ),
                      ],
                    ),
                  );
                }
                return DropdownButtonFormField<int>(
                  initialValue: _selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Kategori *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  hint: const Text('Pilih kategori'),
                  items: catProv.categories
                      .map((c) => DropdownMenuItem<int>(value: c.id, child: Text(c.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategoryId = v),
                  validator: (v) => v == null ? 'Kategori wajib dipilih' : null,
                );
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _excerptCtrl,
              decoration: const InputDecoration(
                labelText: 'Ringkasan (opsional)',
                hintText: 'Ringkasan singkat artikel',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.short_text),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _imageCtrl,
              decoration: InputDecoration(
                labelText: 'URL Gambar (opsional)',
                hintText: 'https://...',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.image),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.preview),
                  onPressed: () => setState(() {}),
                  tooltip: 'Preview',
                ),
              ),
              keyboardType: TextInputType.url,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final uri = Uri.tryParse(v.trim());
                if (uri == null || !uri.hasAbsolutePath || !(uri.scheme == 'http' || uri.scheme == 'https')) {
                  return 'URL harus http/https yang valid';
                }
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _contentCtrl,
              decoration: const InputDecoration(
                labelText: 'Konten *',
                hintText: 'Tulis isi artikel lengkap di sini...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Konten wajib diisi';
                if (v.trim().length < 10) return 'Konten minimal 10 karakter';
                return null;
              },
            ),
            const SizedBox(height: 20),
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
            const Text(
              '* wajib diisi. Data akan divalidasi juga di backend (REST API) dan disimpan ke database.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
