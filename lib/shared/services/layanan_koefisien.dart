import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/model_koefisien.dart';

class LayananKoefisien {
  final FirebaseFirestore _db;

  LayananKoefisien({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _refDataAktif =>
      _db.collection('master_koefisien').doc('data_aktif');

  /// Fetch 1x saat app launch. Fallback ke default jika dokumen belum ada.
  Future<KoefisienAktif> ambilKoefisien() async {
    try {
      final doc = await _refDataAktif.get();
      if (!doc.exists || doc.data() == null) {
        debugPrint('⚠️ Koefisien belum ada di Firestore, gunakan default.');
        return const KoefisienAktif();
      }
      return KoefisienAktif.dariFirestore(doc.data()!);
    } catch (e) {
      debugPrint('❌ Gagal fetch koefisien, gunakan default: $e');
      return const KoefisienAktif();
    }
  }

  /// Seed guard: hanya jalankan jika dokumen belum ada
  Future<void> seedJikaKosong({required String idAdmin}) async {
    try {
      final doc = await _refDataAktif.get();
      if (doc.exists) {
        debugPrint('✓ Koefisien sudah ada, skip seed.');
        return;
      }
      final data = const KoefisienAktif().keFirestore()
        ..['disemai_oleh'] = idAdmin;
      await _refDataAktif.set(data);
      debugPrint('✓ Seed koefisien selesai (${data.length} field).');
    } catch (e) {
      debugPrint('❌ Gagal seed koefisien: $e');
    }
  }

  /// Update seluruh dokumen koefisien. Dipanggil dari Web Admin.
  Future<void> simpanKoefisien({
    required KoefisienAktif koefisien,
    required String idAdmin,
  }) async {
    final data = koefisien.keFirestore()..['diperbarui_oleh'] = idAdmin;
    await _refDataAktif.set(data, SetOptions(merge: true));
  }
}