import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RiwayatMaster {
  final String id;
  final String judul;
  final DateTime tanggal;
  final String oleh;
  final double? hargaLama;
  final double? hargaBaru;

  const RiwayatMaster({
    required this.id,
    required this.judul,
    required this.tanggal,
    required this.oleh,
    this.hargaLama,
    this.hargaBaru,
  });

  factory RiwayatMaster.dariFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return RiwayatMaster(
      id: doc.id,
      judul: d['judul'] as String? ?? 'Pembaruan Master',
      tanggal: (d['tanggal'] as Timestamp?)?.toDate() ?? DateTime.now(),
      oleh: d['oleh'] as String? ?? 'Admin',
      hargaLama: (d['harga_lama'] as num?)?.toDouble(),
      hargaBaru: (d['harga_baru'] as num?)?.toDouble(),
    );
  }
}

class LayananNotifikasi {
  static const String _keyLastSeen = 'last_seen_update';

  final FirebaseFirestore _db;

  LayananNotifikasi({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _refConfig =>
      _db.collection('config').doc('global');

  CollectionReference<Map<String, dynamic>> get _refHistoryMaster =>
      _db.collection('history_master');

  /// Stream real-time untuk dokumen config/global.
  /// Dipakai oleh dashboard mobile agar red dot langsung reaktif.
  Stream<DateTime?> streamLastMasterUpdate() {
    return _refConfig.snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return (doc.data()!['last_master_update'] as Timestamp?)?.toDate();
    });
  }

  /// Ambil sekali — untuk cek banner proyek (tidak perlu real-time).
  Future<DateTime?> ambilLastMasterUpdate() async {
    try {
      final doc = await _refConfig.get();
      if (!doc.exists || doc.data() == null) return null;
      return (doc.data()!['last_master_update'] as Timestamp?)?.toDate();
    } catch (e) {
      debugPrint('⚠️ Gagal ambil last_master_update: $e');
      return null;
    }
  }

  /// Baca timestamp last_seen dari SharedPreferences.
  Future<DateTime?> bacaLastSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keyLastSeen);
    if (str == null) return null;
    return DateTime.tryParse(str);
  }

  /// Cek apakah ada update master yang belum dilihat.
  Future<bool> adaUpdateBaru() async {
    final lastMaster = await ambilLastMasterUpdate();
    if (lastMaster == null) return false;
    final lastSeen = await bacaLastSeen();
    if (lastSeen == null) return true;
    return lastMaster.isAfter(lastSeen);
  }

  /// Simpan waktu tanda baca ke SharedPreferences.
  /// Terima [waktuTandai] dari luar agar konsisten dengan waktu server 
  Future<void> tandaiSudahDibaca(DateTime waktuTandai) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastSeen, waktuTandai.toIso8601String());
  }

  /// Ambil riwayat terbaru.
  Future<List<RiwayatMaster>> ambilRiwayatTerbaru({int limit = 15}) async {
    try {
      final snap = await _refHistoryMaster
          .orderBy('tanggal', descending: true)
          .limit(limit)
          .get();
      return snap.docs.map((d) => RiwayatMaster.dariFirestore(d)).toList();
    } catch (e) {
      debugPrint('❌ Gagal ambil riwayat master: $e');
      return [];
    }
  }

  /// Stream real-time seluruh riwayat pembaruan master untuk History Page Web Admin.
  Stream<List<RiwayatMaster>> streamRiwayatMaster({int limit = 200}) {
    return _refHistoryMaster
        .orderBy('tanggal', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => RiwayatMaster.dariFirestore(d)).toList());
  }

  /// Catat pembaruan + update config/global.
  Future<void> catatPembaruan({
    required String judul,
    required String idAdmin, 
    double? hargaLama,
    double? hargaBaru,
  }) async {
    final Map<String, dynamic> dataRiwayat = {
      'judul': judul,
      'tanggal': FieldValue.serverTimestamp(),
      'oleh': 'Admin',
    };

    if (hargaLama != null) dataRiwayat['harga_lama'] = hargaLama;
    if (hargaBaru != null) dataRiwayat['harga_baru'] = hargaBaru;

    final batch = _db.batch();
    batch.set(_refHistoryMaster.doc(), dataRiwayat);
    batch.set(
      _refConfig,
      {'last_master_update': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
    await batch.commit();
  }
}