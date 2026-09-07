import 'package:flutter/material.dart';
import 'screens/post_list_screen.dart';

// Contoh variabel dari materi Bab 2
// var = tipe otomatis terkunci setelah diisi pertama
// final = diisi sekali saat runtime
// const = nilai tetap dan harus tau saat compile

void main() {
  // var contoh - tipe String
  var appName = "Blog App";

  // final contoh - nilai cuma diisi sekali
  final int tahun = 2026;

  // const contoh - nilai konstan compile-time
  const double versi = 1.0;

  // bool contoh
  bool isDebug = false;

  // List contoh
  List<String> daftarFitur = ["Post", "Kategori", "Search"];

  // Set contoh - data unik tidak duplikat (kalau tulis "flutter" dua kali, cuma kesimpen satu)
  Set<String> tagUnik = {"flutter", "dart", "kotlin"};

  // Map contoh - key value
  Map<String, dynamic> infoApp = {
    "nama": appName,
    "tahun": tahun,
    "versi": versi,
    "debug": isDebug,
  };

  // Operator contoh
  int a = 10;
  int b = 5;
  int tambah = a + b; // 15
  int kurang = a - b; // 5
  int kali = a * b; // 50
  double bagi = a / b; // 2.0
  int sisa = a % b; // 0
  a += 2; // a sekarang 12
  a++; // tambah 1 jadi 13
  b--; // kurang 1 jadi 4
  bool cek = (tambah > 10) && (isDebug == false); // && AND
  bool cek2 = (kurang < 10) || isDebug; // || OR
  bool cek3 = !isDebug; // ! NOT

  // biar tidak warning unused variable
  // ignore: avoid_print
  print("$infoApp $daftarFitur $tagUnik $kali $bagi $sisa $cek $cek2 $cek3");

  runApp(const BlogApp());
}

// Everything is a Widget - semua di Flutter adalah Widget
class BlogApp extends StatelessWidget {
  const BlogApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp adalah root widget aplikasi
    return MaterialApp(
      title: 'Blog App - SMK Taruna Bhakti',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: const PostListScreen(),
    );
  }
}
