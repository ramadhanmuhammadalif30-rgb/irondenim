import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/admin_screen.dart';
import 'screens/customer_screen.dart';
import 'screens/login_screen.dart';
import 'state/app_state.dart';
import 'utils.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..load(),
      child: const IronDenimApp(),
    ),
  );
}

/// Agar bisa digeser dengan mouse juga (saat dijalankan di Chrome/desktop).
class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}

/// Di layar lebar (Chrome/desktop) aplikasi ditampilkan di dalam mockup HP
/// (bezel, dynamic island, status bar, tombol samping). Di HP asli
/// (lebar <= 600) aplikasi memenuhi layar seperti biasa.
class _PhoneFrame extends StatelessWidget {
  final Widget child;
  const _PhoneFrame({required this.child});

  static const double _w = 390;
  static const double _h = 844;
  static const double _bezel = 13;
  static const double _statusH = 46;
  static const double _homeH = 26;

  Widget _sideButton(double h) => Container(
        width: 4,
        height: h,
        decoration: BoxDecoration(
          color: const Color(0xFF3A3A3A),
          borderRadius: BorderRadius.circular(2),
        ),
      );

  Widget _info() {
    return SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset('assets/images/logo.png', height: 150),
          const SizedBox(height: 20),
          Text('IRON DENIM',
              style: serif(size: 36, color: kGoldLight, letterSpacing: 4)),
          const SizedBox(height: 10),
          Container(
            width: 48,
            height: 2,
            decoration: const BoxDecoration(gradient: kGoldGradient),
          ),
          const SizedBox(height: 14),
          const Text('PREMIUM DENIM GOODS',
              style: TextStyle(
                  color: kGold,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3)),
          const SizedBox(height: 16),
          const Text(
            'Tampilan aplikasi mobile.\nGeser dengan mouse seperti di layar sentuh.',
            style: TextStyle(color: kMuted, height: 1.6),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    if (mq.size.width <= 600) return child;

    const insets = EdgeInsets.only(top: _statusH, bottom: _homeH);

    final screen = ClipRRect(
      borderRadius: BorderRadius.circular(44),
      child: SizedBox(
        width: _w,
        height: _h,
        child: MediaQuery(
          data: mq.copyWith(
            size: const Size(_w, _h),
            padding: insets,
            viewPadding: insets,
            viewInsets: EdgeInsets.zero,
          ),
          child: Stack(
            children: [
              Positioned.fill(child: child),
              // bayangan tipis di belakang status bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: _statusH + 10,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withAlpha(150), Colors.transparent],
                      ),
                    ),
                  ),
                ),
              ),
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: _statusH,
                child: IgnorePointer(child: _StatusBar()),
              ),
              // dynamic island
              Positioned(
                top: 11,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      width: 112,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),
              // indikator home
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      width: 130,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(210),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final phone = Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(left: -4, top: 140, child: _sideButton(34)),
        Positioned(left: -4, top: 200, child: _sideButton(58)),
        Positioned(left: -4, top: 270, child: _sideButton(58)),
        Positioned(right: -4, top: 220, child: _sideButton(88)),
        Container(
          padding: const EdgeInsets.all(_bezel),
          decoration: BoxDecoration(
            color: const Color(0xFF050505),
            borderRadius: BorderRadius.circular(58),
            border: Border.all(color: const Color(0xFF4A4A4A), width: 3),
            boxShadow: [
              BoxShadow(
                  color: kGold.withAlpha(28), blurRadius: 80, spreadRadius: 4),
              const BoxShadow(color: Colors.black, blurRadius: 40),
            ],
          ),
          child: screen,
        ),
      ],
    );

    final wide = mq.size.width > 1000;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.2),
            radius: 1.1,
            colors: [Color(0xFF1C160A), Color(0xFF050505)],
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: wide
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [_info(), const SizedBox(width: 90), phone],
                )
              : phone,
        ),
      ),
    );
  }
}

/// Jam, sinyal, wifi, baterai di bagian atas layar HP.
class _StatusBar extends StatefulWidget {
  const _StatusBar();

  @override
  State<_StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<_StatusBar> {
  DateTime _now = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String two(int n) => n.toString().padLeft(2, '0');
    return Padding(
      padding: const EdgeInsets.fromLTRB(36, 15, 30, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${two(_now.hour)}:${two(_now.minute)}',
              style: const TextStyle(
                  color: kCream, fontWeight: FontWeight.w700, fontSize: 15)),
          const Spacer(),
          const Icon(Icons.signal_cellular_alt, size: 16, color: kCream),
          const SizedBox(width: 6),
          const Icon(Icons.wifi, size: 16, color: kCream),
          const SizedBox(width: 6),
          Transform.rotate(
            angle: math.pi / 2,
            child: const Icon(Icons.battery_full, size: 18, color: kCream),
          ),
        ],
      ),
    );
  }
}

ThemeData _buildTheme() {
  const scheme = ColorScheme.dark(
    primary: kGold,
    onPrimary: kBlack,
    secondary: kGoldLight,
    onSecondary: kBlack,
    surface: kPanel,
    onSurface: kCream,
    error: kDanger,
  );
  final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);

  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c, width: w),
      );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: kBlack,
    textTheme: base.textTheme.apply(bodyColor: kCream, displayColor: kCream),
    appBarTheme: AppBarTheme(
      backgroundColor: kBlack,
      foregroundColor: kGold,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: serif(size: 18, color: kGoldLight, letterSpacing: 3),
    ),
    dividerTheme:
        const DividerThemeData(color: kBorder, space: 1, thickness: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kPanel,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: border(kBorder),
      enabledBorder: border(kBorder),
      focusedBorder: border(kGold, 1.2),
      errorBorder: border(kDanger),
      focusedErrorBorder: border(kDanger, 1.2),
      hintStyle: const TextStyle(color: kMuted),
      labelStyle: const TextStyle(color: kMuted),
      prefixIconColor: kGoldDark,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kGold,
        foregroundColor: kBlack,
        disabledBackgroundColor: const Color(0xFF26231F),
        disabledForegroundColor: kMuted,
        minimumSize: const Size(64, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
            fontWeight: FontWeight.w800, letterSpacing: 1.2, fontSize: 13.5),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kGoldLight,
        side: BorderSide(color: kGold.withAlpha(110)),
        minimumSize: const Size(64, 46),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
            fontWeight: FontWeight.w700, letterSpacing: 0.6),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: kBlack,
      surfaceTintColor: Colors.transparent,
      indicatorColor: kGold,
      elevation: 0,
      height: 68,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: kPanel2,
      contentTextStyle: const TextStyle(color: kCream),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: kGold.withAlpha(70)),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: kPanel,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: kGoldDark,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: kGold.withAlpha(60)),
      ),
    ),
  );
}

class IronDenimApp extends StatelessWidget {
  const IronDenimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IRON DENIM',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const _AppScrollBehavior(),
      theme: _buildTheme(),
      builder: (context, child) => _PhoneFrame(child: child ?? const SizedBox()),
      home: Consumer<AppState>(
        builder: (context, s, _) {
          if (!s.loaded) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator(color: kGold)),
            );
          }
          switch (s.role) {
            case UserRole.admin:
              return const AdminScreen();
            case UserRole.customer:
              return const CustomerScreen();
            case UserRole.none:
              return const LoginScreen();
          }
        },
      ),
    );
  }
}
