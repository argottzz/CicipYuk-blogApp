// Centralized API config
// Ganti IP cukup via --dart-define=API_URL=http://IP_BARU:8000
// Default: IP sekolah 10.2.14.97, di rumah ganti ke 192.168.1.5
const String apiBaseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://10.98.232.86:8000',
);

/// Membangun URL lengkap untuk gambar artikel.
///
/// Database hanya menyimpan nama file (mis. "seblak.jpg"), sedangkan
/// backend menyajikan file upload dari folder /uploads, jadi:
///   "seblak.jpg"  ->  "$apiBaseUrl/uploads/seblak.jpg"
///
/// Tetap kompatibel kalau suatu saat bentuk data di DB berubah:
/// - null / string kosong -> '' (UI menampilkan placeholder)
/// - URL lengkap          -> dipakai apa adanya
/// - diawali "/"          -> dianggap path dari root server
/// - diawali "uploads/"   -> tidak di-dobel prefixnya
String gambarArtikelUrl(dynamic gambar) {
  if (gambar == null) return '';
  var g = gambar.toString().trim().replaceAll('\\', '/');
  while (g.startsWith('./')) {
    g = g.substring(2);
  }
  // buang slash ganda di depan, tapi sisakan satu untuk path root
  while (g.startsWith('//')) {
    g = g.substring(1);
  }
  if (g.isEmpty || g.toLowerCase() == 'null') return '';
  if (g.startsWith('http://') || g.startsWith('https://')) return g;
  if (g.startsWith('/')) return '$apiBaseUrl$g';
  if (g.toLowerCase().startsWith('uploads/')) return '$apiBaseUrl/$g';
  return '$apiBaseUrl/uploads/$g';
}
