import 'package:flutter/material.dart';
import '../post.dart';
import '../category.dart';
import '../api_service.dart';

class PostFormScreen extends StatefulWidget {
  final Post? post;
  const PostFormScreen({super.key, this.post});
  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final ApiService _api = ApiService();
  List<Category> _kategori = [];
  bool _loadingKategori = false;
  int? _selectedCategoryId;
  bool _isSaving = false;
  bool get isEdit => widget.post != null;

  @override
  void initState() {
    super.initState();
    if (widget.post != null) {
      _titleCtrl.text = widget.post!.title;
      _contentCtrl.text = widget.post!.content;
      _selectedCategoryId = widget.post!.categoryId;
    }
    _loadKategori();
  }

  Future<void> _loadKategori() async {
    setState(() => _loadingKategori = true);
    try {
      final data = await _api.fetchCategories();
      setState(() => _kategori = data);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal load kategori: $e'), backgroundColor: Colors.orange));
    }
    setState(() => _loadingKategori = false);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih kategori'), backgroundColor: Colors.orange));
      return;
    }
    setState(() => _isSaving = true);
    try {
      if (isEdit) {
        await _api.updatePost(widget.post!.id, title: _titleCtrl.text.trim(), content: _contentCtrl.text.trim(), categoryId: _selectedCategoryId!);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Artikel diupdate'), backgroundColor: Colors.green));
      } else {
        await _api.createPost(title: _titleCtrl.text.trim(), content: _contentCtrl.text.trim(), categoryId: _selectedCategoryId!);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Artikel dibuat'), backgroundColor: Colors.green));
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red));
    }
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Artikel' : 'Tulis Artikel')),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          TextFormField(
            controller: _titleCtrl,
            decoration: const InputDecoration(labelText: 'Judul *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.title)),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Judul wajib diisi';
              if (v.trim().length < 3) return 'Minimal 3 karakter';
              return null;
            },
          ),
          const SizedBox(height: 14),
          if (_loadingKategori)
            const LinearProgressIndicator()
          else
            DropdownButtonFormField<int>(
              initialValue: _selectedCategoryId,
              decoration: const InputDecoration(labelText: 'Kategori *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.category)),
              hint: const Text('Pilih kategori'),
              items: _kategori.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
              onChanged: (v) => setState(() => _selectedCategoryId = v),
              validator: (v) => v == null ? 'Kategori wajib dipilih' : null,
            ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _contentCtrl,
            decoration: const InputDecoration(labelText: 'Isi Artikel *', border: OutlineInputBorder(), alignLabelWithHint: true),
            maxLines: 7,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Isi wajib diisi';
              if (v.trim().length < 10) return 'Minimal 10 karakter';
              return null;
            },
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 48,
            child: FilledButton.icon(onPressed: _isSaving ? null : _save, icon: _isSaving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Icon(isEdit ? Icons.save : Icons.send), label: Text(_isSaving ? 'Menyimpan...' : (isEdit ? 'Update' : 'Publikasikan'))),
          ),
        ]),
      ),
    );
  }
}

class AddPostPage extends PostFormScreen {
  const AddPostPage({super.key}) : super(post: null);
}
