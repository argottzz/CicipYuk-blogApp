import 'category.dart';

// Model untuk Post / Artikel
// Contoh penggunaan tipe data Dart

class Post {
  // final = hanya diisi sekali
  final int id; // int
  final String title; // String
  final String content; // String
  final String? excerpt; // String bisa null
  final String? imageUrl; // String bisa null
  final int? categoryId; // int bisa null
  final String? categoryName; // String bisa null
  final String? categorySlug;
  final Category? category; // object Category bisa null
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Post({
    required this.id,
    required this.title,
    required this.content,
    this.excerpt,
    this.imageUrl,
    this.categoryId,
    this.categoryName,
    this.categorySlug,
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  // Buat Post dari json (Map) yang dikirim backend
  factory Post.fromJson(Map<String, dynamic> json) {
    // cek apakah ada category di dalam json (Map nested)
    Category? cat;
    if (json['category'] is Map<String, dynamic>) {
      cat = Category.fromJson(json['category']);
    }

    // ambil id, kalau bukan int paksa jadi int
    int id = json['id'] as int;

    // ambil title dan content, kalau null kasih string kosong
    String title = json['title'] ?? '';
    String content = json['content'] ?? '';

    // image bisa dari image_url atau imageUrl
    String? img = json['image_url'];
    if (img == null) {
      img = json['imageUrl'];
    }

    // categoryId
    int? catId;
    if (json['category_id'] != null) {
      catId = json['category_id'] as int;
    } else {
      // kalau tidak ada, ambil dari cat object
      if (cat != null) {
        catId = cat.id;
      }
    }

    // categoryName
    String? catName = json['category_name'];
    if (catName == null) {
      catName = json['categoryName'];
    }
    if (catName == null && cat != null) {
      catName = cat.name;
    }

    // categorySlug
    String? catSlug = json['category_slug'];
    if (catSlug == null) {
      catSlug = json['categorySlug'];
    }
    if (catSlug == null && cat != null) {
      catSlug = cat.slug;
    }

    // tanggal dibuat
    DateTime? created;
    if (json['created_at'] != null) {
      created = DateTime.tryParse(json['created_at'].toString());
    } else if (json['createdAt'] != null) {
      created = DateTime.tryParse(json['createdAt'].toString());
    }

    // tanggal update
    DateTime? updated;
    if (json['updated_at'] != null) {
      updated = DateTime.tryParse(json['updated_at'].toString());
    } else if (json['updatedAt'] != null) {
      updated = DateTime.tryParse(json['updatedAt'].toString());
    }

    return Post(
      id: id,
      title: title,
      content: content,
      excerpt: json['excerpt'],
      imageUrl: img,
      categoryId: catId,
      categoryName: catName,
      categorySlug: catSlug,
      category: cat,
      createdAt: created,
      updatedAt: updated,
    );
  }

  // Untuk kirim data ke API (create / update)
  Map<String, dynamic> toJson() {
    // Map = kumpulan key-value
    Map<String, dynamic> data = {
      'id': id,
      'title': title,
      'content': content,
      'excerpt': excerpt,
      'image_url': imageUrl,
      'category_id': categoryId,
    };
    return data;
  }
}
