// Model minimal ATS: categories
class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    int parseId(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }
    return Category(
      id: parseId(json['id'] ?? json['id_kategori']),
      name: (json['name'] ?? json['nama_kategori'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {'name': name};
}
