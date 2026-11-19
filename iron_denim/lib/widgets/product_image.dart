import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../image_store.dart';
import '../models/product.dart';
import '../state/app_state.dart';
import '../utils.dart';

/// Gambar produk: foto pilihan sendiri (data:/file:), aset lokal (assets/...),
/// URL (http...), atau ikon sesuai kategori jika kosong / gagal dimuat.
class ProductImage extends StatelessWidget {
  final Product product;
  final double? size;
  final double? width;
  final double? height;
  final bool expand;
  final double radius;

  const ProductImage({
    super.key,
    required this.product,
    this.size,
    this.width,
    this.height,
    this.expand = false,
    this.radius = 10,
  });

  @override
  Widget build(BuildContext context) {
    final double w = expand ? double.infinity : (width ?? size ?? 64);
    final double h = expand ? double.infinity : (height ?? size ?? 64);

    final placeholder = Container(
      width: w,
      height: h,
      color: kPanel2,
      alignment: Alignment.center,
      child: Icon(
        product.category == 'Jaket' ? Icons.checkroom : Icons.dry_cleaning,
        color: kCream,
        size: expand ? 56 : (size ?? 64) * 0.5,
      ),
    );

    final ref = product.imageUrl;
    final Widget child;
    if (ref.isEmpty) {
      child = placeholder;
    } else if (ref.startsWith(kDataPrefix)) {
      child = Image.memory(
        dataBytes(ref),
        width: w,
        height: h,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => placeholder,
      );
    } else if (ref.startsWith(kFilePrefix)) {
      child = Image.file(
        storedImageFile(context.read<AppState>().imageBase, ref),
        width: w,
        height: h,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      );
    } else if (ref.startsWith('assets/')) {
      child = Image.asset(
        ref,
        width: w,
        height: h,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      );
    } else {
      child = Image.network(
        ref,
        width: w,
        height: h,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      );
    }
    if (radius <= 0) return child;
    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: child);
  }
}
