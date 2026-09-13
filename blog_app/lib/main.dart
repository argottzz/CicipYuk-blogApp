import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/home_page.dart';

// 1. Fungsi pertama yang dijalankan Flutter.
void main() {
  runApp(const BlogApp());
}

// 2. Widget utama aplikasi.
// StatelessWidget dipakai karena pengaturan tema tidak berubah-ubah.
class BlogApp extends StatelessWidget {
  const BlogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CicipYuk',
      debugShowCheckedModeBanner: false,
      // 3. Atur tema warna krem + font Plus Jakarta Sans.
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFF9F0),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF28C28),
          primary: const Color(0xFFF28C28),
        ),
        useMaterial3: true,
        // 4. Atur tampilan AppBar: transparan, tulisan coklat tua.
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF33251F),
        ),
        // 5. Atur tampilan semua TextField: putih, sudut bulat 12.
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          labelStyle: const TextStyle(color: Color(0xFF806B5D)),
          hintStyle: const TextStyle(color: Color(0xFF806B5D)),
          floatingLabelStyle: const TextStyle(color: Color(0xFFF28C28)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFF28C28)),
          ),
        ),
      ),
      // 6. Halaman pertama yang dibuka adalah daftar artikel.
      home: const PostListScreen(),
    );
  }
}
