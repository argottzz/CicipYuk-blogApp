// Model sesuai ATS minimal: db_blog_app -> posts + categories
// Field penting saja: id, judul, isi, kategori (FK), tanggal
class Post {
  final int id;
  final int categoryId;
  final String title;
  final String content;
  final String? categoryName; // dari JOIN categories.nama_kategori
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Post({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.content,
    this.categoryName,
    this.createdAt,
    this.updatedAt,
  });

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: _toInt(json['id'] ?? json['id_artikel']),
      categoryId: _toInt(json['category_id'] ?? json['id_kategori']),
      title: (json['title'] ?? json['judul_artikel'] ?? '').toString(),
      content: (json['content'] ?? json['isi_artikel'] ?? '').toString(),
      categoryName: json['category_name'] ?? json['nama_kategori'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  // untuk POST/PUT
  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'title': title,
      'content': content,
    };
  }
}
