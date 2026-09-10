import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'post.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  const PostCard({super.key, required this.post, required this.onTap, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    String date = '-';
    if (post.createdAt != null) date = DateFormat('dd MMM yyyy', 'id_ID').format(post.createdAt!.toLocal());
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (post.categoryName != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFEDE7F6), borderRadius: BorderRadius.circular(20)),
                child: Text(post.categoryName!, style: const TextStyle(fontSize: 11, color: Colors.deepPurple, fontWeight: FontWeight.w600)),
              ),
            const SizedBox(height: 8),
            Text(post.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Text(post.content, style: TextStyle(fontSize: 13, color: Colors.grey[700]), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Text(date, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton.icon(onPressed: onTap, icon: const Icon(Icons.visibility, size: 16), label: const Text('Detail')),
              if (onEdit != null) IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: onEdit),
              if (onDelete != null) IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: onDelete),
            ])
          ]),
        ),
      ),
    );
  }
}
