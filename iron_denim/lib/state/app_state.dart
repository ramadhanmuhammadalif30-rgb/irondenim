import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../image_store.dart';
import '../models/order.dart';
import '../models/product.dart';

enum UserRole { none, admin, customer }

class AppState extends ChangeNotifier {
  static const adminUser = 'admin';
  static const adminPass = 'admin123';

  /// Produk bawaan 11-15 ditambahkan satu kali ke data lama (versi data < 3).
  static const _newSeedIds = {'p11', 'p12', 'p13', 'p14', 'p15'};

  /// Naikkan angka ini jika ada migrasi data baru.
  static const _seedVersion = 4;

  SharedPreferences? _prefs;
  bool loaded = false;
  String imageBase = ''; // folder dokumen aplikasi (untuk gambar pilihan sendiri)
  UserRole role = UserRole.none;

  final List<Product> products = [];
  final Map<String, int> cart = {}; // productId -> qty
  final Set<String> favorites = {};
  final List<Order> orders = []; // terbaru di atas
  Order? lastOrder;

  // ---------- load & save ----------
  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    try {
      imageBase = await imageBaseDir();
    } catch (_) {}

    final raw = _prefs!.getString('products_v2');
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      products.addAll(
          list.map((e) => Product.fromJson(e as Map<String, dynamic>)));
    } else {
      products.addAll(_seed());
    }

    final ver = _prefs!.getInt('seed_version') ?? 0;
    if (ver < 3) {
      final have = products.map((p) => p.id).toSet();
      for (final p in _seed()) {
        if (_newSeedIds.contains(p.id) && !have.contains(p.id)) {
          products.add(p);
        }
      }
    }
    if (ver < 4) {
      // isi deskripsi produk bawaan yang masih kosong
      final seeds = {for (final p in _seed()) p.id: p.description};
      for (final p in products) {
        if (p.description.isEmpty && seeds.containsKey(p.id)) {
          p.description = seeds[p.id]!;
        }
      }
    }
    if (ver < _seedVersion) {
      await _prefs!.setInt('seed_version', _seedVersion);
    }

    final c = _prefs!.getString('cart');
    if (c != null) {
      (jsonDecode(c) as Map<String, dynamic>)
          .forEach((k, v) => cart[k] = v as int);
    }
    favorites.addAll(_prefs!.getStringList('favorites') ?? []);

    final o = _prefs!.getString('orders');
    if (o != null) {
      try {
        orders.addAll((jsonDecode(o) as List)
            .map((e) => Order.fromJson(e as Map<String, dynamic>)));
      } catch (_) {}
    }

    cart.removeWhere((id, _) => byId(id) == null);
    favorites.removeWhere((id) => byId(id) == null);
    loaded = true;
    await _save();
    notifyListeners();
  }

  Product _s(int n, String name, String cat, int price, int stock, String desc) =>
      Product(
        id: 'p$n',
        name: name,
        category: cat,
        price: price,
        stock: stock,
        imageUrl: 'assets/images/products/p$n.jpg',
        description: desc,
      );

  List<Product> _seed() => [
        _s(1, 'Raw Indigo Slim Jeans', 'Jeans', 450000, 20,
            'Potongan slim dengan denim indigo pekat yang akan memudar indah mengikuti kebiasaanmu. Jahitan emas dan detail selvedge di lipatan hem.'),
        _s(2, 'Black Straight Cut Jeans', 'Jeans', 475000, 15,
            'Potongan lurus klasik dalam hitam pekat. Tampil tegas untuk gaya harian maupun malam.'),
        _s(3, 'Heritage Loose Fit Jeans', 'Jeans', 520000, 10,
            'Siluet longgar bergaya heritage dengan wash biru yang hidup. Nyaman dan leluasa bergerak.'),
        _s(4, 'Classic Trucker Jacket', 'Jaket', 650000, 12,
            'Jaket trucker ikonik dengan kantong dada berpenutup, kancing logam tembaga, dan jahitan ganda yang kokoh.'),
        _s(5, 'Washed Black Denim Jacket', 'Jaket', 699000, 8,
            'Denim hitam dengan efek wash lembut. Potongan klasik yang mudah dipadukan dengan apa saja.'),
        _s(6, 'Selvedge Tapered Raw Jeans', 'Jeans', 560000, 14,
            'Raw denim potongan tapered dengan detail selvedge. Dibuat untuk dipakai lama dan terus berkarakter.'),
        _s(7, 'Rigid Indigo Straight Jeans', 'Jeans', 495000, 18,
            'Denim rigid indigo potongan lurus. Kaku di awal, makin nyaman seiring pemakaian.'),
        _s(8, 'Stone Grey Slim Jeans', 'Jeans', 485000, 12,
            'Warna abu batu yang bersih dengan potongan slim modern. Netral dan serbaguna.'),
        _s(9, 'Sherpa Collar Denim Jacket', 'Jaket', 780000, 7,
            'Jaket denim dengan kerah sherpa yang hangat. Perpaduan tekstur lembut dan denim yang tegas.'),
        _s(10, 'Vintage Chore Denim Jacket', 'Jaket', 720000, 9,
            'Chore jacket bergaya vintage dengan empat kantong tempel dan wash biru muda yang segar.'),
        _s(11, 'Light Wash Slim Jeans', 'Jeans', 430000, 16,
            'Wash biru muda yang cerah dengan potongan slim. Ringan dan segar untuk pemakaian santai.'),
        _s(12, 'Sand Khaki Denim Pants', 'Jeans', 465000, 11,
            'Celana denim warna pasir khaki dengan potongan slim. Tampilan hangat dan elegan.'),
        _s(13, 'Olive Chore Denim Jacket', 'Jaket', 740000, 6,
            'Chore jacket warna zaitun dengan kantong tempel yang fungsional. Gaya utilitarian yang rapi.'),
        _s(14, 'Espresso Brown Denim Jacket', 'Jaket', 690000, 8,
            'Denim cokelat espresso yang kaya dengan jahitan kontras. Hangat, berkelas, dan berbeda.'),
        _s(15, 'Black Sherpa Denim Jacket', 'Jaket', 810000, 5,
            'Denim gelap dengan kerah sherpa krem. Kesan mewah yang tetap maskulin.'),
      ];

  Future<void> _save() async {
    final p = _prefs;
    if (p == null) return;
    try {
      await p.setString(
          'products_v2', jsonEncode(products.map((e) => e.toJson()).toList()));
      await p.setString('cart', jsonEncode(cart));
      await p.setStringList('favorites', favorites.toList());
      await p.setString(
          'orders', jsonEncode(orders.map((e) => e.toJson()).toList()));
    } catch (_) {
      // mis. penyimpanan browser penuh; data tetap ada selama sesi berjalan
    }
  }

  void _commit() {
    _save();
    notifyListeners();
  }

  Product? byId(String id) {
    for (final p in products) {
      if (p.id == id) return p;
    }
    return null;
  }

  // ---------- auth ----------
  bool loginAdmin(String user, String pass) {
    if (user.trim() == adminUser && pass == adminPass) {
      role = UserRole.admin;
      notifyListeners();
      return true;
    }
    return false;
  }

  void loginCustomer() {
    role = UserRole.customer;
    notifyListeners();
  }

  void logout() {
    role = UserRole.none;
    notifyListeners();
  }

  // ---------- admin: statistik ----------
  int get totalStock => products.fold(0, (a, p) => a + p.stock);

  int get lowStockCount => products.where((p) => p.stock <= 5).length;

  /// Pendapatan = total pesanan yang tidak dibatalkan.
  int get revenue =>
      orders.where((o) => !o.isCancelled).fold(0, (a, o) => a + o.total);

  int countStatus(String status) =>
      orders.where((o) => o.status == status).length;

  // ---------- admin: produk ----------
  void addProduct({
    required String name,
    required String category,
    required int price,
    required int stock,
    String imageUrl = '',
    String description = '',
  }) {
    products.add(Product(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      category: category,
      price: price,
      stock: stock,
      imageUrl: imageUrl,
      description: description,
    ));
    _commit();
  }

  /// Edit data produk (nama, kategori, harga, stok, deskripsi, gambar).
  void updateProduct(
    String id, {
    required String name,
    required String category,
    required int price,
    required int stock,
    required String description,
    required String imageUrl,
  }) {
    final p = byId(id);
    if (p == null) return;
    if (p.imageUrl != imageUrl) deleteStoredImage(p.imageUrl);
    p.name = name;
    p.category = category;
    p.price = price;
    p.stock = stock;
    p.description = description;
    p.imageUrl = imageUrl;
    // jumlah di keranjang tidak boleh melebihi stok baru
    final inCart = cart[id];
    if (inCart != null && inCart > stock) {
      if (stock <= 0) {
        cart.remove(id);
      } else {
        cart[id] = stock;
      }
    }
    _commit();
  }

  void addStock(String id, int qty) {
    final p = byId(id);
    if (p == null || qty <= 0) return;
    p.stock += qty;
    _commit();
  }

  /// Ganti gambar produk. [ref] kosong = hapus gambar.
  void setProductImage(String id, String ref) {
    final p = byId(id);
    if (p == null) return;
    if (p.imageUrl != ref) deleteStoredImage(p.imageUrl);
    p.imageUrl = ref;
    _commit();
  }

  void deleteProduct(String id) {
    final old = byId(id)?.imageUrl;
    if (old != null) deleteStoredImage(old);
    products.removeWhere((p) => p.id == id);
    cart.remove(id);
    favorites.remove(id);
    _commit();
  }

  // ---------- favorit ----------
  bool isFavorite(String id) => favorites.contains(id);

  void toggleFavorite(String id) {
    if (!favorites.remove(id)) favorites.add(id);
    _commit();
  }

  List<Product> get favoriteProducts =>
      products.where((p) => favorites.contains(p.id)).toList();

  // ---------- keranjang ----------
  int get cartCount => cart.values.fold(0, (a, b) => a + b);

  int get cartTotal {
    var t = 0;
    cart.forEach((id, q) {
      final p = byId(id);
      if (p != null) t += p.price * q;
    });
    return t;
  }

  /// return pesan error, atau null jika berhasil
  String? addToCart(String id) {
    final p = byId(id);
    if (p == null) return 'Produk tidak ditemukan';
    final now = cart[id] ?? 0;
    if (now + 1 > p.stock) return 'Stok ${p.name} tidak cukup';
    cart[id] = now + 1;
    _commit();
    return null;
  }

  void decreaseCart(String id) {
    final now = cart[id] ?? 0;
    if (now <= 1) {
      cart.remove(id);
    } else {
      cart[id] = now - 1;
    }
    _commit();
  }

  void setCartQty(String id, int qty) {
    final p = byId(id);
    if (p == null) return;
    var q = qty;
    if (q > p.stock) q = p.stock;
    if (q <= 0) {
      cart.remove(id);
    } else {
      cart[id] = q;
    }
    _commit();
  }

  void removeFromCart(String id) {
    cart.remove(id);
    _commit();
  }

  // ---------- pesanan ----------
  /// Checkout: kurangi stok, simpan pesanan, kosongkan keranjang.
  /// Return pesan error, atau null jika berhasil (pesanan ada di [lastOrder]).
  String? checkout({
    required String name,
    required String phone,
    required String address,
    required String payment,
  }) {
    if (cart.isEmpty) return 'Keranjang kosong';
    for (final e in cart.entries) {
      final p = byId(e.key);
      if (p == null || p.stock < e.value) {
        return 'Stok ${p?.name ?? 'produk'} tidak mencukupi';
      }
    }
    final items = <OrderItem>[];
    var total = 0;
    for (final e in cart.entries) {
      final p = byId(e.key)!;
      p.stock -= e.value;
      items.add(OrderItem(
          productId: p.id, name: p.name, qty: e.value, price: p.price));
      total += p.price * e.value;
    }
    final order = Order(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      date: DateTime.now(),
      items: items,
      total: total,
      name: name,
      phone: phone,
      address: address,
      payment: payment,
    );
    orders.insert(0, order);
    lastOrder = order;
    cart.clear();
    _commit();
    return null;
  }

  /// Kembalikan stok barang pesanan ke produk (dipakai saat dibatalkan).
  void _restoreStock(Order o) {
    for (final it in o.items) {
      Product? target;
      if (it.productId.isNotEmpty) target = byId(it.productId);
      if (target == null) {
        // pesanan lama tanpa productId: cocokkan lewat nama
        for (final p in products) {
          if (p.name == it.name) {
            target = p;
            break;
          }
        }
      }
      if (target != null) target.stock += it.qty;
    }
  }

  /// Ubah status pesanan. Jika dibatalkan, stok dikembalikan otomatis.
  /// Return pesan error, atau null jika berhasil.
  String? setOrderStatus(String orderId, String newStatus) {
    Order? o;
    for (final x in orders) {
      if (x.id == orderId) {
        o = x;
        break;
      }
    }
    if (o == null) return 'Pesanan tidak ditemukan';
    if (!o.nextStatuses.contains(newStatus)) {
      return 'Status pesanan tidak dapat diubah ke $newStatus';
    }
    if (newStatus == 'Dibatalkan') _restoreStock(o);
    o.status = newStatus;
    o.history.add(StatusEntry(status: newStatus, date: DateTime.now()));
    _commit();
    return null;
  }
}
