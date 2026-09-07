import 'category.dart';

class Post {
  final int id;
  final String title;
  final String content;
  final String? excerpt;
  final String? imageUrl;
  final int? categoryId;
  final String? categoryName;
  final String? categorySlug;
  final Category? category;
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

  factory Post.fromJson(Map<String, dynamic> json) {
    // Backend may return flat fields or nested category object
    Category? cat;
    if (json['category'] is Map<String, dynamic>) {
      cat = Category.fromJson(json['category']);
    }

    return Post(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      excerpt: json['excerpt'],
      imageUrl: json['image_url'] ?? json['imageUrl'],
      categoryId: json['category_id'] != null
          ? (json['category_id'] is int
              ? json['category_id']
              : int.tryParse(json['category_id'].toString()))
          : cat?.id,
      categoryName: json['category_name'] ?? json['categoryName'] ?? cat?.name,
      categorySlug: json['category_slug'] ?? json['categorySlug'] ?? cat?.slug,
      category: cat,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : (json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString())
              : null),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : (json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'].toString())
              : null),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'excerpt': excerpt,
        'image_url': imageUrl,
        'category_id': categoryId,
      };

  /// For POST / PUT body
  Map<String, dynamic> toCreateJson() => {
        'title': title,
        'content': content,
        'excerpt': excerpt,
        'image_url': imageUrl,
        'category_id': categoryId,
      };

  Post copyWith({
    int? id,
    String? title,
    String? content,
    String? excerpt,
    String? imageUrl,
    int? categoryId,
    String? categoryName,
    String? categorySlug,
    Category? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      excerpt: excerpt ?? this.excerpt,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categorySlug: categorySlug ?? this.categorySlug,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
