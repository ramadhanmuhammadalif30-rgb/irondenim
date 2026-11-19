import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../state/app_state.dart';
import '../utils.dart';
import 'common.dart';

/// Kartu pesanan. [admin] = true menampilkan tombol ubah status;
/// untuk pelanggan hanya ada tombol batalkan (saat masih Diproses).
class OrderTile extends StatelessWidget {
  final Order order;
  final bool admin;

  const OrderTile({super.key, required this.order, this.admin = false});

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(label,
                style: const TextStyle(color: kMuted, fontSize: 12)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12.5)),
          ),
        ],
      ),
    );
  }

  Widget _stepper() {
    const steps = ['Diproses', 'Dikirim', 'Selesai'];
    final idx = steps.indexOf(order.status);
    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: i <= idx ? kGoldGradient : null,
                  border: i <= idx
                      ? null
                      : Border.all(color: kBorder, width: 1.5),
                ),
                child: i <= idx
                    ? const Icon(Icons.check, size: 14, color: kBlack)
                    : null,
              ),
              const SizedBox(height: 4),
              Text(steps[i],
                  style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: i <= idx ? kGold : kMuted)),
            ],
          ),
          if (i < steps.length - 1)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 18, left: 4, right: 4),
                child: Container(
                    height: 2, color: i < idx ? kGold : kBorder),
              ),
            ),
        ],
      ],
    );
  }

  Future<void> _change(BuildContext context, String newStatus) async {
    final cancel = newStatus == 'Dibatalkan';
    if (cancel) {
      final ok = await confirmDialog(
        context,
        title: 'Batalkan pesanan?',
        message:
            'Pesanan #${order.shortId} akan dibatalkan dan stok produk dikembalikan.',
        confirmLabel: 'Batalkan',
        danger: true,
      );
      if (!ok || !context.mounted) return;
    }
    final err = context.read<AppState>().setOrderStatus(order.id, newStatus);
    if (!context.mounted) return;
    showSnack(
      context,
      err ??
          (cancel
              ? 'Pesanan dibatalkan, stok dikembalikan'
              : 'Status pesanan: $newStatus'),
    );
  }

  Widget _actions(BuildContext context) {
    final next = order.nextStatuses;
    if (next.isEmpty) return const SizedBox.shrink();

    if (!admin) {
      if (order.status != 'Diproses') return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 14),
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: kDanger,
            side: BorderSide(color: kDanger.withAlpha(120)),
          ),
          onPressed: () => _change(context, 'Dibatalkan'),
          icon: const Icon(Icons.close, size: 18),
          label: const Text('BATALKAN PESANAN'),
        ),
      );
    }

    final forward = next.first; // Dikirim atau Selesai
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: GoldButton(
              height: 46,
              icon: forward == 'Dikirim'
                  ? Icons.local_shipping_outlined
                  : Icons.check_circle_outline,
              label: forward == 'Dikirim' ? 'KIRIM PESANAN' : 'TANDAI SELESAI',
              onPressed: () => _change(context, forward),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: kDanger,
                side: BorderSide(color: kDanger.withAlpha(120)),
              ),
              onPressed: () => _change(context, 'Dibatalkan'),
              child: const Text('BATALKAN'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = statusColor(order.status);
    return Container(
      decoration: BoxDecoration(
        color: kPanel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          iconColor: kGold,
          collapsedIconColor: kMuted,
          shape: const Border(),
          collapsedShape: const Border(),
          title: Row(
            children: [
              Text('#${order.shortId}',
                  style: serif(size: 16, color: kGoldLight)),
              const SizedBox(width: 8),
              Tag(order.status.toUpperCase(),
                  color: color, icon: statusIcon(order.status)),
              const Spacer(),
              Text(rupiah(order.total),
                  style: serif(size: 15, color: kGold)),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              admin
                  ? '${order.name} • ${formatDate(order.date)}'
                  : '${formatDate(order.date)} • ${order.itemCount} barang',
              style: const TextStyle(color: kMuted, fontSize: 12),
            ),
          ),
          children: [
            const Divider(),
            const SizedBox(height: 14),
            if (order.isCancelled)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kDanger.withAlpha(22),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kDanger.withAlpha(80)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cancel_outlined, color: kDanger, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Pesanan dibatalkan. Stok produk sudah dikembalikan.',
                        style: TextStyle(fontSize: 12.5, height: 1.4),
                      ),
                    ),
                  ],
                ),
              )
            else
              _stepper(),
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 6),
            for (final it in order.items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('${it.qty}x  ${it.name}',
                          style: const TextStyle(fontSize: 13)),
                    ),
                    Text(rupiah(it.price * it.qty),
                        style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            const SizedBox(height: 6),
            const Divider(),
            _info('Penerima', order.name),
            _info('Telepon', order.phone),
            _info('Alamat', order.address),
            _info('Pembayaran', order.payment),
            const SizedBox(height: 14),
            const Text('RIWAYAT STATUS',
                style: TextStyle(
                    color: kGold,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.8)),
            const SizedBox(height: 6),
            for (final h in order.history)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: statusColor(h.status)),
                    const SizedBox(width: 10),
                    Text(h.status,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 12.5)),
                    const Spacer(),
                    Text(formatDate(h.date),
                        style: const TextStyle(color: kMuted, fontSize: 11.5)),
                  ],
                ),
              ),
            _actions(context),
          ],
        ),
      ),
    );
  }
}
