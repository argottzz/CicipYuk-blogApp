import 'package:flutter_test/flutter_test.dart';
import 'package:blog_app/main.dart';

void main() {
  testWidgets('BlogApp loads', (WidgetTester tester) async {
    await tester.pumpWidget(const BlogApp());
    expect(find.text('Blog App'), findsOneWidget);
  });
}
