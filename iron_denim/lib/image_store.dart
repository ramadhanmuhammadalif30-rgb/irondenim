import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'utils.dart';

/// Gambar hasil pilihan pengguna disimpan sebagai "file:<namafile>"
/// (file ada di <documents>/product_images/). Hanya nama file yang disimpan
/// supaya tetap valid walau lokasi folder aplikasi berubah (mis. di iOS).
const String kFilePrefix = 'file:';
const String _folder = 'product_images';

/// Di Flutter Web tidak ada akses file, jadi foto disimpan sebagai
/// data URI ("data:image/jpeg;base64,...") di penyimpanan browser.
const String kDataPrefix = 'data:';

final Map<String, Uint8List> _dataCache = {};

Uint8List dataBytes(String ref) => _dataCache.putIfAbsent(
    ref, () => base64Decode(ref.substring(ref.indexOf(',') + 1)));

Future<String> imageBaseDir() async {
  if (kIsWeb) return '';
  return (await getApplicationDocumentsDirectory()).path;
}

File storedImageFile(String base, String ref) =>
    File('$base/$_folder/${ref.substring(kFilePrefix.length)}');

Future<String?> _pickAndStore(ImageSource source) async {
  final picked = await ImagePicker().pickImage(
    source: source,
    maxWidth: kIsWeb ? 800 : 1200,
    maxHeight: kIsWeb ? 1000 : 1600,
    imageQuality: kIsWeb ? 80 : 85,
  );
  if (picked == null) return null;
  if (kIsWeb) {
    final bytes = await picked.readAsBytes();
    var mime = picked.mimeType ?? 'image/jpeg';
    if (!mime.startsWith('image/')) mime = 'image/jpeg';
    return '$kDataPrefix$mime;base64,${base64Encode(bytes)}';
  }
  final base = await imageBaseDir();
  final dir = Directory('$base/$_folder');
  if (!await dir.exists()) await dir.create(recursive: true);
  final dot = picked.path.lastIndexOf('.');
  var ext = dot > 0 ? picked.path.substring(dot).toLowerCase() : '.jpg';
  if (ext.length > 5) ext = '.jpg';
  final name = 'img_${DateTime.now().microsecondsSinceEpoch}$ext';
  await File(picked.path).copy('${dir.path}/$name');
  return '$kFilePrefix$name';
}

/// Hapus file gambar yang disimpan aplikasi (abaikan jika bukan "file:").
Future<void> deleteStoredImage(String ref) async {
  if (!ref.startsWith(kFilePrefix)) return;
  try {
    final f = storedImageFile(await imageBaseDir(), ref);
    if (await f.exists()) await f.delete();
  } catch (_) {}
}

/// Tampilkan pilihan sumber gambar.
/// Hasil: null = batal, '' = hapus gambar, selain itu = referensi gambar baru.
Future<String?> chooseProductImage(BuildContext context,
    {bool allowRemove = false}) async {
  final action = await showModalBottomSheet<String>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(kIsWeb ? 'Pilih file gambar' : 'Pilih dari galeri'),
            onTap: () => Navigator.pop(ctx, 'gallery'),
          ),
          if (!kIsWeb)
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Ambil foto dengan kamera'),
              onTap: () => Navigator.pop(ctx, 'camera'),
            ),
          if (allowRemove)
            ListTile(
              leading:
                  const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text('Hapus gambar'),
              onTap: () => Navigator.pop(ctx, 'remove'),
            ),
        ],
      ),
    ),
  );
  if (action == null) return null;
  if (action == 'remove') return '';
  try {
    return await _pickAndStore(
        action == 'camera' ? ImageSource.camera : ImageSource.gallery);
  } catch (e) {
    if (context.mounted) showSnack(context, 'Tidak bisa mengambil gambar: $e');
    return null;
  }
}
