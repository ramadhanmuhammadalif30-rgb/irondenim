import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../state/app_state.dart';
import '../utils.dart';
import '../widgets/common.dart';
import '../widgets/order_tile.dart';
import '../widgets/product_image.dart';
import 'checkout_screen.dart';
import 'product_detail_screen.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  int _tab = 0;

  void _go(int i) => setState(() => _tab = i);

  @override
  Widget build(BuildContext context) {
    final cartCount = context.select<AppState, int>((s) => s.cartCount);
    final favCount = context.select<AppState, int>((s) => s.favorites.length);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _tab,
          children: [
            _HomeTab(onOpenCart: () => _go(2)),
            _FavoritesTab(onShop: () => _go(0)),
            _CartTab(onShop: () => _go(0)),
            const _AccountTab(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: kGold.withAlpha(60))),
        ),
        child: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: _go,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront, color: kBlack),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: favCount > 0,
                label: Text('$favCount'),
                backgroundColor: kGold,
                textColor: kBlack,
                child: const Icon(Icons.favorite_border),
              ),
              selectedIcon: const Icon(Icons.favorite, color: kBlack),
              label: 'Favorit',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: cartCount > 0,
                label: Text('$cartCount'),
                backgroundColor: kGold,
                textColor: kBlack,
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              selectedIcon: const Icon(Icons.shopping_cart, color: kBlack),
              label: 'Keranjang',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: kBlack),
              label: 'Akun',
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ Kartu produk
class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final fav = s.isFavorite(product.id);
    final inCart = s.cart[product.id] ?? 0;
    final out = product.stock <= 0;
    final canAdd = !out && inCart < product.stock;

    return GestureDetector(
      onTap: () => openProduct(context, product.id),
      child: Container(
        decoration: BoxDecoration(
          color: kPanel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kGold.withAlpha(45)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ProductImage(product: product, expand: true, radius: 0),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleIconButton(
                      size: 34,
                      icon: fav ? Icons.favorite : Icons.favorite_border,
                      color: fav ? kDanger : kGoldLight,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        context.read<AppState>().toggleFavorite(product.id);
                      },
                    ),
                  ),
                  if (out)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black54,
                        alignment: Alignment.center,
                        child: Text('HABIS',
                            style: serif(size: 16, letterSpacing: 4)),
                      ),
                    )
                  else if (product.stock <= 5)
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Tag('Sisa ${product.stock}', color: kCopper),
                    ),
                ],
              ),
            ),
            SizedBox(
              height: 98,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.category.toUpperCase(),
                        style: const TextStyle(
                            color: kGold,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.8)),
                    const SizedBox(height: 3),
                    Text(product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.25)),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(rupiah(product.price),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: serif(size: 14.5, color: kGoldLight)),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: canAdd
                              ? () {
                                  HapticFeedback.lightImpact();
                                  final err = context
                                      .read<AppState>()
                                      .addToCart(product.id);
                                  showSnack(context,
                                      err ?? '${product.name} masuk keranjang');
                                }
                              : null,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: canAdd ? kGoldGradient : null,
                              color: canAdd ? null : const Color(0xFF26231F),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.add,
                                size: 20, color: canAdd ? kBlack : kMuted),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

SliverGridDelegate _gridDelegate(BuildContext context) {
  final w = MediaQuery.of(context).size.width;
  final itemW = (w - 32 - 14) / 2;
  final ratio = itemW / (itemW * 1.25 + 98);
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 14,
    crossAxisSpacing: 14,
    childAspectRatio: ratio,
  );
}

// ---------------------------------------------------------------- Beranda
class _HomeTab extends StatefulWidget {
  final VoidCallback onOpenCart;
  const _HomeTab({required this.onOpenCart});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  String _filter = 'Semua';
  String _query = '';
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Widget _banner() {
    return Container(
      height: 158,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kGold.withAlpha(120)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF33270F), Color(0xFF0E0D0A)],
        ),
        boxShadow: [
          BoxShadow(color: kGold.withAlpha(30), blurRadius: 24),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 0, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('PREMIUM DENIM GOODS',
                      style: TextStyle(
                          color: kGold,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.2)),
                  const SizedBox(height: 8),
                  Text('Built to\nLast.',
                      style: serif(size: 31, color: kGoldLight, height: 1.05)),
                  const SizedBox(height: 8),
                  Text('Koleksi jeans & jaket denim pilihan',
                      style: TextStyle(
                          color: kCream.withAlpha(170), fontSize: 11.5)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Image.asset('assets/images/logo.png', height: 128),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final all = s.products;
    final q = _query.trim().toLowerCase();
    final items = all
        .where((p) =>
            (_filter == 'Semua' || p.category == _filter) &&
            (q.isEmpty || p.name.toLowerCase().contains(q)))
        .toList();
    final filters = {
      'Semua': all.length,
      'Jeans': all.where((p) => p.category == 'Jeans').length,
      'Jaket': all.where((p) => p.category == 'Jaket').length,
    };
    final cartCount = s.cartCount;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Image.asset('assets/images/logo.png', height: 46),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SELAMAT DATANG DI',
                          style: TextStyle(
                              color: kGold,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.2)),
                      const SizedBox(height: 2),
                      Text('IRON DENIM',
                          style: serif(
                              size: 21, color: kGoldLight, letterSpacing: 3)),
                    ],
                  ),
                ),
                Badge(
                  isLabelVisible: cartCount > 0,
                  label: Text('$cartCount'),
                  backgroundColor: kGold,
                  textColor: kBlack,
                  child: CircleIconButton(
                    icon: Icons.shopping_bag_outlined,
                    background: kPanel,
                    onTap: widget.onOpenCart,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _search,
              onChanged: (v) => setState(() => _query = v),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Cari jeans, jaket...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _search.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
            ),
          ),
        ),
        if (q.isEmpty && _filter == 'Semua') SliverToBoxAdapter(child: _banner()),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              children: [
                for (final e in filters.entries)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterPill(
                      label: '${e.key} (${e.value})',
                      selected: _filter == e.key,
                      onTap: () => setState(() => _filter = e.key),
                    ),
                  ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    _filter == 'Semua' ? 'Koleksi Kami' : _filter,
                    style: serif(size: 22, color: kGoldLight),
                  ),
                ),
                Text('${items.length} item',
                    style: const TextStyle(color: kMuted, fontSize: 12)),
              ],
            ),
          ),
        ),
        if (items.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: Icons.search_off,
              title: 'Produk tidak ditemukan',
              subtitle: 'Coba kata kunci atau kategori lain.',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverGrid(
              gridDelegate: _gridDelegate(context),
              delegate: SliverChildBuilderDelegate(
                (context, i) => _ProductCard(product: items[i]),
                childCount: items.length,
              ),
            ),
          ),
      ],
    );
  }
}

// ----------------------------------------------------------------- Favorit
class _FavoritesTab extends StatelessWidget {
  final VoidCallback onShop;
  const _FavoritesTab({required this.onShop});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final items = s.favoriteProducts;
    return Column(
      children: [
        TabHeader(title: 'Favorit', subtitle: '${items.length} produk disimpan'),
        Expanded(
          child: items.isEmpty
              ? EmptyState(
                  icon: Icons.favorite_border,
                  title: 'Belum ada favorit',
                  subtitle:
                      'Ketuk ikon hati pada produk untuk menyimpannya di sini.',
                  buttonLabel: 'JELAJAHI PRODUK',
                  onPressed: onShop,
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  gridDelegate: _gridDelegate(context),
                  itemCount: items.length,
                  itemBuilder: (_, i) => _ProductCard(product: items[i]),
                ),
        ),
      ],
    );
  }
}

// --------------------------------------------------------------- Keranjang
class _CartTab extends StatelessWidget {
  final VoidCallback onShop;
  const _CartTab({required this.onShop});

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(
                  color: bold ? kGoldLight : kMuted,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w500)),
          const Spacer(),
          Text(value,
              style: bold
                  ? serif(size: 21, color: kGold)
                  : const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final entries =
        s.cart.entries.where((e) => s.byId(e.key) != null).toList();

    return Column(
      children: [
        TabHeader(title: 'Keranjang', subtitle: '${s.cartCount} barang'),
        Expanded(
          child: entries.isEmpty
              ? EmptyState(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Keranjang masih kosong',
                  subtitle: 'Yuk pilih jeans atau jaket denim favoritmu.',
                  buttonLabel: 'MULAI BELANJA',
                  onPressed: onShop,
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final p = s.byId(entries[i].key)!;
                    final qty = entries[i].value;
                    return Dismissible(
                      key: ValueKey('cart-${p.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        decoration: BoxDecoration(
                          color: kDanger.withAlpha(60),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.delete_outline, color: kDanger),
                      ),
                      onDismissed: (_) {
                        final st = context.read<AppState>();
                        st.removeFromCart(p.id);
                        showSnack(
                          context,
                          '${p.name} dihapus',
                          actionLabel: 'URUNGKAN',
                          onAction: () => st.setCartQty(p.id, qty),
                        );
                      },
                      child: Surface(
                        padding: const EdgeInsets.all(10),
                        borderColor: kGold.withAlpha(45),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ProductImage(
                                product: p, width: 76, height: 95, radius: 10),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 95,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(p.name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                height: 1.25)),
                                        const SizedBox(height: 2),
                                        Text(rupiah(p.price),
                                            style: const TextStyle(
                                                color: kMuted, fontSize: 12)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(rupiah(p.price * qty),
                                              style: serif(
                                                  size: 15, color: kGold)),
                                        ),
                                        QtyStepper(
                                          qty: qty,
                                          onMinus: () => context
                                              .read<AppState>()
                                              .decreaseCart(p.id),
                                          onPlus: qty >= p.stock
                                              ? null
                                              : () => context
                                                  .read<AppState>()
                                                  .addToCart(p.id),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        if (entries.isNotEmpty)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
            decoration: BoxDecoration(
              color: kPanel,
              border: Border(top: BorderSide(color: kGold.withAlpha(70))),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _row('Subtotal (${s.cartCount} barang)', rupiah(s.cartTotal)),
                _row('Ongkos kirim', 'Gratis'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: GoldDivider(),
                ),
                _row('Total', rupiah(s.cartTotal), bold: true),
                const SizedBox(height: 12),
                GoldButton(
                  icon: Icons.arrow_forward,
                  label: 'CHECKOUT',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// -------------------------------------------------------------------- Akun
class _AccountTab extends StatelessWidget {
  const _AccountTab();

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        const TabHeader(title: 'Akun'),
        Surface(
          padding: const EdgeInsets.all(16),
          borderColor: kGold.withAlpha(60),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                    gradient: kGoldGradient, shape: BoxShape.circle),
                child: Container(
                  decoration: const BoxDecoration(
                      color: kBlack, shape: BoxShape.circle),
                  child: const Icon(Icons.person, color: kGold, size: 30),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pelanggan IRON DENIM',
                        style: serif(size: 17, color: kGoldLight)),
                    const SizedBox(height: 3),
                    const Text('Mode tamu',
                        style: TextStyle(color: kMuted, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SectionTitle('Pesanan Saya'),
        if (s.orders.isEmpty)
          const Surface(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text('Belum ada pesanan',
                  style: TextStyle(color: kMuted)),
            ),
          )
        else
          for (final o in s.orders)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OrderTile(order: o),
            ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => context.read<AppState>().logout(),
          icon: const Icon(Icons.logout, size: 18),
          label: const Text('KELUAR'),
        ),
        const SizedBox(height: 20),
        const Center(
          child: Text('IRON DENIM  •  EST. 2024  •  BUILT TO LAST',
              style: TextStyle(
                  color: kGoldDark, fontSize: 10, letterSpacing: 1.8)),
        ),
      ],
    );
  }
}
