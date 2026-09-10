import 'package:flutter/material.dart';
import '../post.dart';
import 'add_post_page.dart';

class EditPostPage extends StatelessWidget {
  final Post post;
  const EditPostPage({super.key, required this.post});
  @override
  Widget build(BuildContext context) => PostFormScreen(post: post);
}
