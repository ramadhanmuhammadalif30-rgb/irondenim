import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../image_store.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../state/app_state.dart';
import '../utils.dart';
import '../widgets/common.dart';
import '../widgets/order_tile.dart';
import '../widgets/product_image.dart';

void _openProductForm(BuildContext context, {Product? product}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _ProductFormSheet(product: product),
  );
}

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    // pesanan yang perlu tindakan (Diproses) ditampilkan sebagai lencana
    final pending = context.select<AppState, int>(
        (s) => s.countStatus('Diproses'));

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _tab,
          children: const [_ProductsTab(), _OrdersTab()],
        ),
      ),
      floatingActionButton: _tab == 0
          ? Container(
              decoration: BoxDecoration(
                gradient: kGoldGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: kGold.withAlpha(70),
                      blurRadius: 18,
                      offset: const Offset(0, 6)),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: () => _openProductForm(context),
                icon: const Icon(Icons.add),
                label: const Text('Produk Baru',
                    style: TextStyle(
                        fontWeight: FontWeight.w800, letterSpacing: 0.6)),
                backgroundColor: Colors.transparent,
                foregroundColor: kBlack,
                elevation: 0,
                focusElevation: 0,
                hoverElevation: 0,
                highlightElevation: 0,
              ),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: kGold.withAlpha(60))),
        ),
        child: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2, color: kBlack),
              label: 'Produk',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: pending > 0,
                label: Text('$pending'),
                backgroundColor: kGold,
                textColor: kBlack,
                child: const Icon(Icons.receipt_long_outlined),
              ),
              selectedIcon: const Icon(Icons.receipt_long, color: kBlack),
              label: 'Pesanan',
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ Tab produk
class _ProductsTab extends StatefulWidget {
  const _ProductsTab();

  @override
  State<_ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<_ProductsTab> {
  String _filter = 'Semua';
  String _query = '';

  Widget _stat(IconData icon, String value, String label, {Color? color}) {
    return Expanded(
      child: Surface(
        padding: const EdgeInsets.all(12),
        borderColor: kGold.withAlpha(45),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: color ?? kGold),
            const SizedBox(height: 10),
            Text(value, style: serif(size: 24, color: color ?? kGoldLight)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: kMuted, fontSize: 11.5)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final q = _query.trim().toLowerCase();
    final items = s.products.where((p) {
      final okFilter = switch (_filter) {
        'Semua' => true,
        'Menipis' => p.stock <= 5,
        _ => p.category == _filter,
      };
      return okFilter && (q.isEmpty || p.name.toLowerCase().contains(q));
    }).toList();
    final low = s.lowStockCount;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: TabHeader(
            title: 'Panel Admin',
            subtitle: 'Kelola produk & stok IRON DENIM',
            trailing: CircleIconButton(
              icon: Icons.logout,
              background: kPanel,
              onTap: () => context.read<AppState>().logout(),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
            child: Row(
              children: [
                _stat(Icons.inventory_2_outlined, '${s.products.length}', 'Produk'),
                const SizedBox(width: 10),
                _stat(Icons.layers_outlined, '${s.totalStock}', 'Total stok'),
                const SizedBox(width: 10),
                _stat(Icons.warning_amber_rounded, '$low', 'Stok menipis',
                    color: low > 0 ? kDanger : null),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              children: [
                for (final f in const ['Semua', 'Jeans', 'Jaket', 'Menipis'])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterPill(
                      label: f,
                      selected: _filter == f,
                      onTap: () => setState(() => _filter = f),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (items.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Tidak ada produk',
              subtitle: 'Tambah produk baru dengan tombol di bawah.',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
            sliver: SliverList.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _AdminTile(product: items[i]),
            ),
          ),
      ],
    );
  }
}

class _AdminTile extends StatelessWidget {
  final Product product;
  const _AdminTile({required this.product});

  Future<void> _changeImage(BuildContext context) async {
    final ref = await chooseProductImage(context,
        allowRemove: product.imageUrl.isNotEmpty);
    if (ref == null || !context.mounted) return;
    context.read<AppState>().setProductImage(product.id, ref);
    showSnack(context, ref.isEmpty ? 'Gambar dihapus' : 'Gambar diperbarui');
  }

  Future<void> _delete(BuildContext context) async {
    final ok = await confirmDialog(
      context,
      title: 'Hapus produk?',
      message: '"${product.name}" akan dihapus permanen.',
      confirmLabel: 'Hapus',
      danger: true,
    );
    if (!ok || !context.mounted) return;
    context.read<AppState>().deleteProduct(product.id);
    showSnack(context, 'Produk dihapus');
  }

  Widget _squareBtn(IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: 48,
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(48, 48),
          foregroundColor: color,
          side: BorderSide(color: color.withAlpha(120)),
        ),
        onPressed: onTap,
        child: Icon(icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final out = product.stock <= 0;
    final low = product.stock <= 5;
    final stockColor = out ? kDanger : (low ? kCopper : kOk);
    final stockText = out
        ? 'Stok habis'
        : (low ? 'Stok menipis: ${product.stock}' : 'Stok: ${product.stock}');

    return Surface(
      padding: const EdgeInsets.all(12),
      borderColor: kGold.withAlpha(45),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _changeImage(context),
                child: Stack(
                  children: [
                    ProductImage(
                        product: product, width: 76, height: 95, radius: 10),
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                            gradient: kGoldGradient, shape: BoxShape.circle),
                        child: const Icon(Icons.photo_camera,
                            size: 13, color: kBlack),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
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
                            fontWeight: FontWeight.w700, height: 1.25)),
                    const SizedBox(height: 4),
                    Text(rupiah(product.price),
                        style: serif(size: 15, color: kGoldLight)),
                    const SizedBox(height: 8),
                    Tag(stockText, color: stockColor),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => _AddStockSheet(product: product),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Stok'),
                ),
              ),
              const SizedBox(width: 8),
              _squareBtn(Icons.edit_outlined, kGold,
                  () => _openProductForm(context, product: product)),
              const SizedBox(width: 8),
              _squareBtn(Icons.delete_outline, kDanger, () => _delete(context)),
            ],
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------ Tambah stok
class _AddStockSheet extends StatefulWidget {
  final Product product;
  const _AddStockSheet({required this.product});

  @override
  State<_AddStockSheet> createState() => _AddStockSheetState();
}

class _AddStockSheetState extends State<_AddStockSheet> {
  final _qty = TextEditingController();
  final _key = GlobalKey<FormState>();

  @override
  void dispose() {
    _qty.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Form(
        key: _key,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tambah Stok', style: serif(size: 24, color: kGoldLight)),
            const SizedBox(height: 4),
            Text('${p.name}  •  stok sekarang ${p.stock}',
                style: const TextStyle(color: kMuted)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                for (final n in const [5, 10, 20, 50])
                  ActionChip(
                    label: Text('+$n'),
                    backgroundColor: kPanel2,
                    side: BorderSide(color: kGold.withAlpha(90)),
                    labelStyle: const TextStyle(
                        color: kGoldLight, fontWeight: FontWeight.w700),
                    onPressed: () => setState(() => _qty.text = '$n'),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _qty,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                hintText: 'Jumlah tambahan',
                prefixIcon: Icon(Icons.add_box_outlined),
              ),
              validator: (v) {
                final n = int.tryParse((v ?? '').trim());
                if (n == null || n <= 0) return 'Masukkan angka lebih dari 0';
                return null;
              },
            ),
            const SizedBox(height: 16),
            GoldButton(
              label: 'SIMPAN',
              onPressed: () {
                if (!_key.currentState!.validate()) return;
                final n = int.parse(_qty.text.trim());
                context.read<AppState>().addStock(p.id, n);
                Navigator.pop(context);
                showSnack(context, 'Stok ${p.name} +$n');
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------- Produk baru / edit produk
class _ProductFormSheet extends StatefulWidget {
  final Product? product; // null = produk baru
  const _ProductFormSheet({this.product});

  @override
  State<_ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<_ProductFormSheet> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _stock;
  late final TextEditingController _desc;
  late final TextEditingController _image;
  late String _category;
  String _ref = ''; // gambar aset/file/foto yang aktif
  final List<String> _created = []; // foto baru yang dibuat di form ini
  bool _saved = false;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? '');
    _price = TextEditingController(text: p == null ? '' : '${p.price}');
    _stock = TextEditingController(text: p == null ? '' : '${p.stock}');
    _desc = TextEditingController(text: p?.description ?? '');
    _category = p?.category ?? 'Jeans';
    var url = '';
    if (p != null) {
      if (p.imageUrl.startsWith('http')) {
        url = p.imageUrl;
      } else {
        _ref = p.imageUrl;
      }
    }
    _image = TextEditingController(text: url);
  }

  Future<void> _pickImage() async {
    final ref = await chooseProductImage(context, allowRemove: _ref.isNotEmpty);
    if (ref == null || !mounted) return;
    if (ref.isNotEmpty) _created.add(ref);
    setState(() => _ref = ref);
  }

  @override
  void dispose() {
    if (!_saved) {
      for (final r in _created) {
        deleteStoredImage(r);
      }
    }
    _name.dispose();
    _price.dispose();
    _stock.dispose();
    _desc.dispose();
    _image.dispose();
    super.dispose();
  }

  String? _numValidator(String? v) {
    final n = int.tryParse((v ?? '').trim());
    if (n == null || n < 0) return 'Angka tidak valid';
    return null;
  }

  void _save() {
    if (!_key.currentState!.validate()) return;
    final st = context.read<AppState>();
    final imageUrl = _ref.isNotEmpty ? _ref : _image.text.trim();
    for (final r in _created) {
      if (r != imageUrl) deleteStoredImage(r);
    }
    _created.clear();
    final price = int.parse(_price.text.trim());
    final stock = int.parse(_stock.text.trim());
    final p = widget.product;
    if (p == null) {
      st.addProduct(
        name: _name.text.trim(),
        category: _category,
        price: price,
        stock: stock,
        imageUrl: imageUrl,
        description: _desc.text.trim(),
      );
    } else {
      st.updateProduct(
        p.id,
        name: _name.text.trim(),
        category: _category,
        price: price,
        stock: stock,
        description: _desc.text.trim(),
        imageUrl: imageUrl,
      );
    }
    _saved = true;
    Navigator.pop(context);
    showSnack(context, _isEdit ? 'Perubahan disimpan' : 'Produk ditambahkan');
  }

  @override
  Widget build(BuildContext context) {
    final preview = Product(
      id: 'preview',
      name: '',
      category: _category,
      price: 0,
      stock: 0,
      imageUrl: _ref,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Form(
          key: _key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_isEdit ? 'Edit Produk' : 'Produk Baru',
                  style: serif(size: 24, color: kGoldLight)),
              const SizedBox(height: 16),
              Row(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: SizedBox(
                      width: 92,
                      height: 115,
                      child: _ref.isEmpty
                          ? Container(
                              decoration: BoxDecoration(
                                color: kPanel2,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: kGold.withAlpha(90)),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo_outlined,
                                      color: kGold),
                                  SizedBox(height: 6),
                                  Text('Foto',
                                      style: TextStyle(
                                          color: kMuted, fontSize: 12)),
                                ],
                              ),
                            )
                          : ProductImage(
                              product: preview, expand: true, radius: 12),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      _ref.isEmpty
                          ? 'Ketuk kotak untuk memilih foto produk dari galeri atau kamera.'
                          : 'Ketuk foto untuk mengganti atau menghapus.',
                      style: const TextStyle(color: kMuted, height: 1.4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'Nama produk'),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final c in const ['Jeans', 'Jaket'])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SizedBox(
                        height: 42,
                        child: FilterPill(
                          label: c,
                          selected: _category == c,
                          onTap: () => setState(() => _category = c),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _price,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                          hintText: 'Harga', prefixText: 'Rp '),
                      validator: _numValidator,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _stock,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(hintText: 'Stok'),
                      validator: _numValidator,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _desc,
                maxLines: 4,
                maxLength: 400,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                    hintText: 'Deskripsi produk (opsional)'),
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: _image,
                enabled: _ref.isEmpty,
                decoration: const InputDecoration(
                    hintText: 'atau URL gambar (opsional)',
                    prefixIcon: Icon(Icons.link)),
              ),
              const SizedBox(height: 18),
              GoldButton(
                label: _isEdit ? 'SIMPAN PERUBAHAN' : 'SIMPAN PRODUK',
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ Tab pesanan
class _OrdersTab extends StatefulWidget {
  const _OrdersTab();

  @override
  State<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<_OrdersTab> {
  String _filter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final list = _filter == 'Semua'
        ? s.orders
        : s.orders.where((o) => o.status == _filter).toList();
    final filters = ['Semua', ...kOrderStatuses];

    return Column(
      children: [
        TabHeader(
          title: 'Pesanan',
          subtitle: '${s.orders.length} pesanan  •  Pendapatan ${rupiah(s.revenue)}',
          trailing: CircleIconButton(
            icon: Icons.logout,
            background: kPanel,
            onTap: () => context.read<AppState>().logout(),
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              for (final f in filters)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterPill(
                    label: f == 'Semua'
                        ? 'Semua (${s.orders.length})'
                        : '$f (${s.countStatus(f)})',
                    selected: _filter == f,
                    onTap: () => setState(() => _filter = f),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: list.isEmpty
              ? EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: s.orders.isEmpty
                      ? 'Belum ada pesanan'
                      : 'Tidak ada pesanan "$_filter"',
                  subtitle: 'Pesanan dari pelanggan akan muncul di sini.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) =>
                      OrderTile(key: ValueKey(list[i].id), order: list[i], admin: true),
                ),
        ),
      ],
    );
  }
}
