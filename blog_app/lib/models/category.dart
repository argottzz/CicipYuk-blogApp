// Model untuk kategori
// Ini contoh tipe data di Dart sesuai materi Bab 2

class Category {
  // final = nilai hanya diisi sekali saat bikin object (runtime)
  final int id; // int = bilangan bulat
  final String name; // String = teks
  final String slug; // String = teks
  final DateTime? createdAt; // DateTime bisa null (?)

  // Constructor
  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.createdAt,
  });

  // fromJson = ubah Map dari API jadi object Category
  factory Category.fromJson(Map<String, dynamic> json) {
    // ambil data dari Map (key-value)
    int id = json['id'] as int;
    String name = json['name'] ?? '';
    String slug = json['slug'] ?? '';

    DateTime? tanggal;
    if (json['created_at'] != null) {
      tanggal = DateTime.tryParse(json['created_at'].toString());
    }

    return Category(
      id: id,
      name: name,
      slug: slug,
      createdAt: tanggal,
    );
  }

  // toJson = ubah object jadi Map untuk dikirim ke API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
    };
  }
}
