import 'package:flutter/material.dart';

// ---- Palet "luxury": hitam hangat + emas champagne ----
const Color kBlack = Color(0xFF080808);
const Color kPanel = Color(0xFF121110);
const Color kPanel2 = Color(0xFF1B1916);
const Color kBorder = Color(0xFF2C2822);
const Color kGold = Color(0xFFC9A55C);
const Color kGoldLight = Color(0xFFEBD8A6);
const Color kGoldDark = Color(0xFF8F7035);
const Color kCream = Color(0xFFF1E9D6);
const Color kMuted = Color(0xFF9C9382);
const Color kCopper = Color(0xFFD08A4A);
const Color kDanger = Color(0xFFE5675C);
const Color kOk = Color(0xFF6FCF97);
const Color kInfo = Color(0xFF6FA8DC);

const LinearGradient kGoldGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kGoldLight, kGold, kGoldDark],
);

// ---- Tipografi: serif untuk judul & harga ----
const String kSerif = 'Playfair';
const List<String> kSerifFallback = ['Georgia', 'Times New Roman', 'serif'];

TextStyle serif({
  double size = 16,
  int weight = 700,
  Color color = kCream,
  double letterSpacing = 0,
  double? height,
}) {
  var idx = (weight ~/ 100) - 1;
  if (idx < 0) idx = 0;
  if (idx > 8) idx = 8;
  return TextStyle(
    fontFamily: kSerif,
    fontFamilyFallback: kSerifFallback,
    fontSize: size,
    fontWeight: FontWeight.values[idx],
    fontVariations: [FontVariation('wght', weight.toDouble())],
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );
}

// ---- Status pesanan ----
Color statusColor(String s) {
  switch (s) {
    case 'Dikirim':
      return kInfo;
    case 'Selesai':
      return kOk;
    case 'Dibatalkan':
      return kDanger;
    default:
      return kCopper; // Diproses
  }
}

IconData statusIcon(String s) {
  switch (s) {
    case 'Dikirim':
      return Icons.local_shipping_outlined;
    case 'Selesai':
      return Icons.check_circle_outline;
    case 'Dibatalkan':
      return Icons.cancel_outlined;
    default:
      return Icons.hourglass_top_rounded;
  }
}

String rupiah(int v) {
  final s = v.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return 'Rp $b';
}

const _bulan = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
];

String formatDate(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.day} ${_bulan[d.month - 1]} ${d.year}, ${two(d.hour)}:${two(d.minute)}';
}

void showSnack(BuildContext context, String msg,
    {String? actionLabel, VoidCallback? onAction}) {
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(SnackBar(
    content: Text(msg),
    duration: const Duration(seconds: 3),
    action: (actionLabel != null && onAction != null)
        ? SnackBarAction(
            label: actionLabel, onPressed: onAction, textColor: kGold)
        : null,
  ));
}
