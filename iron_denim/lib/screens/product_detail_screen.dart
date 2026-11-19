import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../state/app_state.dart';
import '../utils.dart';
import '../widgets/common.dart';
import '../widgets/product_image.dart';

void openProduct(BuildContext context, String productId) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: productId)),
  );
}

class ProductDetailScreen extends StatelessWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  String _desc(Product p) {
    if (p.description.trim().isNotEmpty) return p.description.trim();
    return p.category == 'Jaket'
        ? 'Jaket denim dengan potongan klasik, jahitan kuat, dan kancing logam tahan lama. Mudah dipadukan untuk gaya harian maupun santai.'
        : 'Celana denim dengan jahitan rapi dan bahan yang nyaman dipakai seharian. Makin sering dipakai, makin terlihat karakternya.';
  }

  Widget _feature(IconData icon, String text) {
    return Expanded(
      child: Surface(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        borderColor: kGold.withAlpha(50),
        child: Column(
          children: [
            Icon(icon, color: kGold, size: 24),
            const SizedBox(height: 8),
            Text(text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11.5, color: kMuted)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final p = s.byId(productId);
    if (p == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.search_off,
          title: 'Produk tidak ditemukan',
          subtitle: 'Produk ini mungkin sudah dihapus.',
        ),
      );
    }
    final fav = s.isFavorite(p.id);
    final inCart = s.cart[p.id] ?? 0;
    final out = p.stock <= 0;
    final maxed = inCart >= p.stock;
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 0.85,
                        child: ProductImage(
                            product: p, expand: true, radius: 0),
                      ),
                      const Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 110,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, kBlack],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: top + 10,
                        left: 14,
                        child: CircleIconButton(
                          icon: Icons.arrow_back_ios_new,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ),
                      Positioned(
                        top: top + 10,
                        right: 14,
                        child: CircleIconButton(
                          icon: fav ? Icons.favorite : Icons.favorite_border,
                          color: fav ? kDanger : kGoldLight,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            context.read<AppState>().toggleFavorite(p.id);
                          },
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Tag(p.category.toUpperCase()),
                            const SizedBox(width: 8),
                            if (out)
                              const Tag('STOK HABIS', color: kDanger)
                            else if (p.stock <= 5)
                              Tag('SISA ${p.stock}', color: kCopper)
                            else
                              Tag('STOK ${p.stock}', color: kOk),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(p.name,
                            style: serif(size: 28, color: kGoldLight, height: 1.2)),
                        const SizedBox(height: 10),
                        Text(rupiah(p.price),
                            style: serif(size: 25, color: kGold)),
                        const SizedBox(height: 18),
                        const GoldDivider(),
                        const SectionTitle('Deskripsi'),
                        Text(_desc(p),
                            style: const TextStyle(
                                color: Color(0xFFCFC6B2), height: 1.65)),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            _feature(Icons.verified_outlined, 'Kualitas\npremium'),
                            const SizedBox(width: 10),
                            _feature(Icons.local_shipping_outlined, 'Gratis\nongkir'),
                            const SizedBox(width: 10),
                            _feature(Icons.shield_outlined, 'Tahan\nlama'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
            decoration: BoxDecoration(
              color: kPanel,
              border: Border(top: BorderSide(color: kGold.withAlpha(60))),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(inCart > 0 ? 'Di keranjang: $inCart' : 'Harga',
                          style: const TextStyle(color: kMuted, fontSize: 12)),
                      const SizedBox(height: 2),
                      Text(rupiah(p.price),
                          style: serif(size: 18, color: kGold)),
                    ],
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: GoldButton(
                      icon: Icons.add_shopping_cart,
                      label: out
                          ? 'STOK HABIS'
                          : maxed
                              ? 'STOK PENUH'
                              : 'TAMBAH',
                      onPressed: (out || maxed)
                          ? null
                          : () {
                              HapticFeedback.lightImpact();
                              final err =
                                  context.read<AppState>().addToCart(p.id);
                              showSnack(
                                  context, err ?? 'Ditambahkan ke keranjang');
                            },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
