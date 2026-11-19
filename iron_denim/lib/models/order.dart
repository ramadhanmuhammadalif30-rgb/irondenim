const List<String> kOrderStatuses = [
  'Diproses',
  'Dikirim',
  'Selesai',
  'Dibatalkan',
];

class OrderItem {
  final String productId; // kosong pada pesanan lama
  final String name;
  final int qty;
  final int price;

  const OrderItem({
    this.productId = '',
    required this.name,
    required this.qty,
    required this.price,
  });

  Map<String, dynamic> toJson() =>
      {'productId': productId, 'name': name, 'qty': qty, 'price': price};

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
        productId: (j['productId'] ?? '') as String,
        name: j['name'] as String,
        qty: j['qty'] as int,
        price: j['price'] as int,
      );
}

class StatusEntry {
  final String status;
  final DateTime date;
  const StatusEntry({required this.status, required this.date});

  Map<String, dynamic> toJson() =>
      {'status': status, 'date': date.toIso8601String()};

  factory StatusEntry.fromJson(Map<String, dynamic> j) => StatusEntry(
        status: j['status'] as String,
        date: DateTime.parse(j['date'] as String),
      );
}

class Order {
  final String id;
  final DateTime date;
  final List<OrderItem> items;
  final int total;
  final String name;
  final String phone;
  final String address;
  final String payment;
  String status;
  final List<StatusEntry> history;

  Order({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    required this.name,
    required this.phone,
    required this.address,
    required this.payment,
    this.status = 'Diproses',
    List<StatusEntry>? history,
  }) : history = history ?? [StatusEntry(status: status, date: date)];

  String get shortId => id.length > 6 ? id.substring(id.length - 6) : id;

  int get itemCount => items.fold(0, (a, b) => a + b.qty);

  bool get isCancelled => status == 'Dibatalkan';

  /// Alur status: Diproses -> Dikirim -> Selesai; boleh dibatalkan
  /// selama belum selesai.
  List<String> get nextStatuses {
    switch (status) {
      case 'Diproses':
        return ['Dikirim', 'Dibatalkan'];
      case 'Dikirim':
        return ['Selesai', 'Dibatalkan'];
      default:
        return [];
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
        'total': total,
        'name': name,
        'phone': phone,
        'address': address,
        'payment': payment,
        'status': status,
        'history': history.map((e) => e.toJson()).toList(),
      };

  factory Order.fromJson(Map<String, dynamic> j) {
    final date = DateTime.parse(j['date'] as String);
    final status = (j['status'] ?? 'Diproses') as String;
    final h = j['history'];
    return Order(
      id: j['id'] as String,
      date: date,
      items: (j['items'] as List)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: j['total'] as int,
      name: (j['name'] ?? '') as String,
      phone: (j['phone'] ?? '') as String,
      address: (j['address'] ?? '') as String,
      payment: (j['payment'] ?? '') as String,
      status: status,
      history: h is List
          ? h.map((e) => StatusEntry.fromJson(e as Map<String, dynamic>)).toList()
          : [StatusEntry(status: status, date: date)],
    );
  }
}
