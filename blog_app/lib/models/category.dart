class Category {
  final int id;
  final String name;
  final String slug;
  final DateTime? createdAt;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
      };

  Map<String, dynamic> toCreateJson() => {
        'name': name,
        'slug': slug,
      };
}
