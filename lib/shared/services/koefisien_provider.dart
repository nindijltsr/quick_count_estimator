import 'package:flutter/foundation.dart';
import '../models/model_koefisien.dart';
import 'layanan_koefisien.dart';

/// Menyimpan koefisien aktif di memori. Fetch hanya 1x saat inisialisasi.
class KoefisienProvider extends ChangeNotifier {
  final LayananKoefisien _layanan = LayananKoefisien();

  KoefisienAktif _aktif = const KoefisienAktif();
  bool _sudahDimuat = false;

  KoefisienAktif get aktif => _aktif;
  bool get sudahDimuat => _sudahDimuat;

  /// Dipanggil 1x di main.dart setelah Firebase init.
  Future<void> inisialisasi({required String idAdmin}) async {
    await _layanan.seedJikaKosong(idAdmin: idAdmin);
    _aktif = await _layanan.ambilKoefisien();
    _sudahDimuat = true;
    notifyListeners();
    debugPrint('✓ KoefisienProvider siap (${_aktif.keFirestore().length} key).');
  }

  /// Dipanggil setelah admin simpan perubahan koefisien di Web Admin.
  Future<void> simpanDanRefresh({
    required KoefisienAktif koefisien,
    required String idAdmin,
  }) async {
    await _layanan.simpanKoefisien(koefisien: koefisien, idAdmin: idAdmin);
    _aktif = koefisien;
    notifyListeners();
  }
}