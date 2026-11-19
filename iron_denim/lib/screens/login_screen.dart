import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../utils.dart';
import '../widgets/common.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _user = TextEditingController();
  final _pass = TextEditingController();
  bool _hide = true;
  bool _admin = false;

  @override
  void dispose() {
    _user.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _loginAdmin() {
    FocusScope.of(context).unfocus();
    final ok = context.read<AppState>().loginAdmin(_user.text, _pass.text);
    if (!ok) showSnack(context, 'Username atau password admin salah');
  }

  Widget _tab(String label, IconData icon, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            gradient: selected ? kGoldGradient : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? kBlack : kMuted),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: selected ? kBlack : kMuted)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _customerPanel() {
    return Column(
      key: const ValueKey('customer'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Jelajahi koleksi jeans & jaket denim premium tanpa perlu daftar akun.',
          textAlign: TextAlign.center,
          style: TextStyle(color: kMuted, height: 1.5),
        ),
        const SizedBox(height: 22),
        GoldButton(
          label: 'MULAI BELANJA',
          icon: Icons.shopping_bag_outlined,
          onPressed: () => context.read<AppState>().loginCustomer(),
        ),
      ],
    );
  }

  Widget _adminPanel() {
    return Column(
      key: const ValueKey('admin'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _user,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            hintText: 'Username',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _pass,
          obscureText: _hide,
          onSubmitted: (_) => _loginAdmin(),
          decoration: InputDecoration(
            hintText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_hide
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined),
              onPressed: () => setState(() => _hide = !_hide),
            ),
          ),
        ),
        const SizedBox(height: 18),
        GoldButton(label: 'MASUK SEBAGAI ADMIN', onPressed: _loginAdmin),
        const SizedBox(height: 12),
        const Text(
          'Demo: admin / admin123',
          textAlign: TextAlign.center,
          style: TextStyle(color: kMuted, fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.75),
            radius: 1.0,
            colors: [kGold.withAlpha(34), kBlack],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(26, 12, 26, 24),
            child: Column(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOut,
                  builder: (context, v, child) => Opacity(
                    opacity: v,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - v)),
                      child: child,
                    ),
                  ),
                  child: Image.asset('assets/images/logo.png', height: 220),
                ),
                const SizedBox(height: 2),
                Text('Selamat Datang',
                    style: serif(size: 30, color: kGoldLight)),
                const SizedBox(height: 10),
                const SizedBox(width: 180, child: GoldDivider()),
                const SizedBox(height: 10),
                const Text('PILIH CARA MASUK',
                    style: TextStyle(
                        color: kMuted, fontSize: 11, letterSpacing: 3)),
                const SizedBox(height: 26),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: kPanel,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kGold.withAlpha(70)),
                  ),
                  child: Row(
                    children: [
                      _tab('Pelanggan', Icons.person_outline, !_admin,
                          () => setState(() => _admin = false)),
                      _tab('Admin', Icons.admin_panel_settings_outlined,
                          _admin, () => setState(() => _admin = true)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _admin ? _adminPanel() : _customerPanel(),
                ),
                const SizedBox(height: 28),
                const Text('EST. 2024   •   BUILT TO LAST',
                    style: TextStyle(
                        color: kGoldDark, fontSize: 10.5, letterSpacing: 2.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
