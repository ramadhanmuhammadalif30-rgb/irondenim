import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../state/app_state.dart';
import '../utils.dart';
import '../widgets/common.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  String _payment = 'Transfer Bank';

  static const _methods = [
    ('Transfer Bank', Icons.account_balance_outlined, 'BCA / Mandiri / BRI'),
    ('E-Wallet', Icons.account_balance_wallet_outlined, 'GoPay / OVO / DANA'),
    ('COD (Bayar di tempat)', Icons.payments_outlined, 'Bayar saat barang tiba'),
  ];

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_key.currentState!.validate()) return;
    final st = context.read<AppState>();
    final err = st.checkout(
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      address: _address.text.trim(),
      payment: _payment,
    );
    if (err != null) {
      showSnack(context, err);
      return;
    }
    HapticFeedback.mediumImpact();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (_) => OrderSuccessScreen(order: st.lastOrder!)),
    );
  }

  Widget _payTile(String value, IconData icon, String sub) {
    final selected = _payment == value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Surface(
        onTap: () => setState(() => _payment = value),
        color: selected ? kPanel2 : kPanel,
        borderColor: selected ? kGold : kBorder,
        child: Row(
          children: [
            Icon(icon, color: selected ? kGold : kMuted),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(sub,
                      style: const TextStyle(color: kMuted, fontSize: 12)),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? kGold : kMuted,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final entries =
        s.cart.entries.where((e) => s.byId(e.key) != null).toList();
    final total = s.cartTotal;

    return Scaffold(
      appBar: AppBar(title: const Text('CHECKOUT')),
      body: Form(
        key: _key,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            const SectionTitle('Alamat pengiriman'),
            TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'Nama penerima',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
              ],
              decoration: const InputDecoration(
                hintText: 'No. telepon',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (v) => (v ?? '').trim().length < 8
                  ? 'Nomor telepon tidak valid'
                  : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _address,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Alamat lengkap',
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 44),
                  child: Icon(Icons.location_on_outlined),
                ),
              ),
              validator: (v) =>
                  (v ?? '').trim().length < 6 ? 'Alamat wajib diisi' : null,
            ),
            const SectionTitle('Metode pembayaran'),
            for (final m in _methods) _payTile(m.$1, m.$2, m.$3),
            const SectionTitle('Ringkasan pesanan'),
            Surface(
              child: Column(
                children: [
                  for (final e in entries)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text('${e.value}x  ${s.byId(e.key)!.name}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 8),
                          Text(rupiah(s.byId(e.key)!.price * e.value),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  const Divider(height: 22),
                  Row(
                    children: [
                      const Text('Ongkos kirim',
                          style: TextStyle(color: kMuted)),
                      const Spacer(),
                      const Text('Gratis'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Total',
                          style: TextStyle(fontWeight: FontWeight.w800)),
                      const Spacer(),
                      Text(rupiah(total),
                          style: serif(size: 20, color: kGold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: kPanel,
          border: Border(top: BorderSide(color: kGold.withAlpha(60))),
        ),
        child: SafeArea(
          top: false,
          child: GoldButton(
            onPressed: entries.isEmpty ? null : _submit,
            label: 'BAYAR ${rupiah(total)}',
          ),
        ),
      ),
    );
  }
}

class OrderSuccessScreen extends StatelessWidget {
  final Order order;
  const OrderSuccessScreen({super.key, required this.order});

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(label, style: const TextStyle(color: kMuted)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, v, child) =>
                    Transform.scale(scale: v, child: child),
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kGold.withAlpha(30),
                    border: Border.all(color: kGold, width: 2),
                  ),
                  child: const Icon(Icons.check_rounded, color: kGold, size: 56),
                ),
              ),
              const SizedBox(height: 22),
              Text('Pesanan Berhasil!',
                  style: serif(size: 28, color: kGoldLight)),
              const SizedBox(height: 10),
              const SizedBox(width: 160, child: GoldDivider()),
              const SizedBox(height: 6),
              Text('Terima kasih, ${order.name}.',
                  style: const TextStyle(color: kMuted)),
              const SizedBox(height: 24),
              Surface(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _row('No. pesanan', '#${order.shortId}'),
                    _row('Total', rupiah(order.total)),
                    _row('Status', order.status),
                    _row('Pembayaran', order.payment),
                    _row('Dikirim ke', order.address),
                  ],
                ),
              ),
              const Spacer(),
              GoldButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((r) => r.isFirst),
                label: 'KEMBALI KE BERANDA',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
