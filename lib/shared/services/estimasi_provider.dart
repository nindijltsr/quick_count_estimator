import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/model_input_surveyor.dart';
import '../models/model_hasil_perhitungan.dart';
import '../models/model_rekap_dan_lainnya.dart';
import '../models/model_koefisien.dart';
import './layanan_perhitungan.dart';
import './layanan_master_harga.dart';
import './layanan_proyek.dart';
import './layanan_koefisien.dart';

enum StatusProses { awal, memuat, sukses, gagal }

class EstimasiProvider extends ChangeNotifier {
  final LayananPerhitungan _hitungEngine = LayananPerhitungan();
  final LayananKoefisien _layananKoefisien = LayananKoefisien();

  // KOEFISIEN DINAMIS
  KoefisienAktif _koefisienAktif = const KoefisienAktif();

  void setKoefisienAktif(KoefisienAktif k) {
    _koefisienAktif = k;
  }

  // SNAPSHOT PROYEK
  Map<String, double> _snapshotHargaMaterial = {};
  Map<String, double> _snapshotHargaUpah = {};
  Map<String, double> _snapshotKoefisien = {};
  DateTime? _tanggalSnapshotDiambil;

  DateTime? get tanggalSnapshotDiambil => _tanggalSnapshotDiambil;
  bool get snapshotTersedia => _snapshotHargaMaterial.isNotEmpty;
  Map<String, double> get snapshotHargaMaterial => _snapshotHargaMaterial;

  final LayananMasterHarga _layananHarga = LayananMasterHarga();
  final LayananProyek _layananProyek = LayananProyek();
  final LayananHistori _layananHistori = LayananHistori();

  // StreamSubscription<HargaUpah?>? _hargaUpahSubscription;
  // bool _isListeningHargaUpah = false;

  // State Proyek
  String _idProyek = '';
  String _idPengguna = '';
  String _namaProyek = '';
  String get idProyek => _idProyek;

  Future<void> inisialisasiProyek({
    required String idProyek,
    required String idPengguna,
    required String namaProyek,
  }) async {
    debugPrint('=== inisialisasiProyek dipanggil ===');
    final proyekBerubah = _idProyek != idProyek;

    _idProyek = idProyek;
    _idPengguna = idPengguna;
    _namaProyek = namaProyek;

    if (proyekBerubah) {
      debugPrint('    → Proyek BERBEDA, reset state');
      resetSemuaState();
    } else {
      debugPrint('    → Proyek SAMA, skip reset');
    }

    await _muatDataTersimpan();
    notifyListeners();
  }

  void resetSemuaState() {
    _pTanah = 0;
    _lTanah = 0;
    _pPondasi = 0;
    _jmlTitikTapak = 0;
    _pDinding = 0;
    _jmlKolom = 0;
    _pBangunan = 0;
    _lBangunan = 0;
    _jmlPintu = 0;
    _jmlJendela = 0;
    _jmlLampu = 0;
    _jmlSaklar1 = 0;
    _jmlSaklar2 = 0;
    _jmlStopKontak = 0;
    _menuASudahDisimpan = false;
    _menuBSudahDisimpan = false;
    _menuCSudahDisimpan = false;
    _menuDSudahDisimpan = false;
    _menuESudahDisimpan = false;
    _menuFSudahDisimpan = false;
    _hasilMenuA = null;
    _hasilMenuB = null;
    _hasilMenuC = null;
    _hasilMenuD = null;
    _hasilMenuE = null;
    _hasilMenuF = null;
    _hasilMenuG = null;
    _rekapMaterial = null;

    // Reset Snapshot
    _snapshotHargaMaterial = {};
    _snapshotHargaUpah = {};
    _snapshotKoefisien = {};
    _tanggalSnapshotDiambil = null;

    _status = StatusProses.awal;
    _pesanError = '';
  }

  StatusProses _status = StatusProses.awal;
  StatusProses get status => _status;
  String _pesanError = '';
  String get pesanError => _pesanError;
  bool get sedangMemuat => _status == StatusProses.memuat;

  double _pTanah = 0;
  double _lTanah = 0;
  double _pPondasi = 0;
  int _jmlTitikTapak = 0;
  double _pDinding = 0;
  int _jmlKolom = 0;
  double _pBangunan = 0;
  double _lBangunan = 0;
  int _jmlPintu = 0;
  int _jmlJendela = 0;
  int _jmlLampu = 0;
  int _jmlSaklar1 = 0;
  int _jmlSaklar2 = 0;
  int _jmlStopKontak = 0;

  double get pTanah => _pTanah;
  double get lTanah => _lTanah;
  double get pPondasi => _pPondasi;
  int get jmlTitikTapak => _jmlTitikTapak;
  double get pDinding => _pDinding;
  int get jmlKolom => _jmlKolom;
  double get pBangunan => _pBangunan;
  double get lBangunan => _lBangunan;
  int get jmlPintu => _jmlPintu;
  int get jmlJendela => _jmlJendela;
  int get jmlLampu => _jmlLampu;
  int get jmlSaklar1 => _jmlSaklar1;
  int get jmlSaklar2 => _jmlSaklar2;
  int get jmlStopKontak => _jmlStopKontak;

  bool _menuASudahDisimpan = false;
  bool _menuBSudahDisimpan = false;
  bool _menuCSudahDisimpan = false;
  bool _menuDSudahDisimpan = false;
  bool _menuESudahDisimpan = false;
  bool _menuFSudahDisimpan = false;

  bool get menuASudahDisimpan => _menuASudahDisimpan;
  bool get menuBSudahDisimpan => _menuBSudahDisimpan;
  bool get menuCSudahDisimpan => _menuCSudahDisimpan;
  bool get menuDSudahDisimpan => _menuDSudahDisimpan;
  bool get menuESudahDisimpan => _menuESudahDisimpan;
  bool get menuFSudahDisimpan => _menuFSudahDisimpan;

  HasilMenuA? _hasilMenuA;
  HasilMenuB? _hasilMenuB;
  HasilMenuC? _hasilMenuC;
  HasilMenuD? _hasilMenuD;
  HasilMenuE? _hasilMenuE;
  HasilMenuF? _hasilMenuF;
  HasilMenuG? _hasilMenuG;
  RekapMaterial? _rekapMaterial;

  HasilMenuA? get hasilMenuA => _hasilMenuA;
  HasilMenuB? get hasilMenuB => _hasilMenuB;
  HasilMenuC? get hasilMenuC => _hasilMenuC;
  HasilMenuD? get hasilMenuD => _hasilMenuD;
  HasilMenuE? get hasilMenuE => _hasilMenuE;
  HasilMenuF? get hasilMenuF => _hasilMenuF;
  HasilMenuG? get hasilMenuG => _hasilMenuG;
  RekapMaterial? get rekapMaterial => _rekapMaterial;

  int get jumlahMenuTerisi {
    int count = 0;
    if (_menuASudahDisimpan) count++;
    if (_menuBSudahDisimpan) count++;
    if (_menuCSudahDisimpan) count++;
    if (_menuDSudahDisimpan) count++;
    if (_menuESudahDisimpan) count++;
    if (_menuFSudahDisimpan) count++;
    return count;
  }

  bool get adaDataParsial => jumlahMenuTerisi > 0 && jumlahMenuTerisi < 6;
  bool get dataLengkap => jumlahMenuTerisi == 6;
  bool get dataKosong => jumlahMenuTerisi == 0;

  String get statusMenuText {
    if (dataKosong) return 'Belum ada data';
    if (dataLengkap) return 'Data lengkap (6/6 menu)';
    return 'Data parsial ($jumlahMenuTerisi/6 menu)';
  }

  Future<bool> simpanMenuA({
    required String pTanahStr,
    required String lTanahStr,
    required String pPondasiStr,
    required String jmlTitikTapakStr,
  }) async {
    if (_idProyek.isEmpty) {
      _setGagal('ID Proyek tidak ditemukan.');
      return false;
    }
    _setMemuat();
    try {
      _pTanah = double.parse(pTanahStr.replaceAll(',', '.'));
      _lTanah = double.parse(lTanahStr.replaceAll(',', '.'));
      _pPondasi = double.parse(pPondasiStr.replaceAll(',', '.'));
      _jmlTitikTapak = int.parse(jmlTitikTapakStr);
      _pDinding = _pPondasi;
      _jmlKolom = _jmlTitikTapak;
      final input = _buatInputSurveyor();
      _hasilMenuA = _hitungEngine.hitungMenuA(input);
      await _layananProyek.simpanInputSurveyor(input);
      await _layananProyek.simpanHasilMenuA(_idProyek, _hasilMenuA!);
      await _catatAktivitas('SIMPAN_MENU_A');
      _menuASudahDisimpan = true;
      _setSukses();
      return true;
    } catch (e) {
      _setGagal('Gagal: $e');
      return false;
    }
  }

  Future<bool> simpanMenuB({
    required String pDindingStr,
    required String jmlKolomStr,
  }) async {
    if (_idProyek.isEmpty) {
      _setGagal('ID Proyek tidak ditemukan.');
      return false;
    }
    _setMemuat();
    try {
      _pDinding = double.parse(pDindingStr.replaceAll(',', '.'));
      _jmlKolom = int.parse(jmlKolomStr);
      _pPondasi = _pDinding;
      _jmlTitikTapak = _jmlKolom;
      final input = _buatInputSurveyor();
      _hasilMenuB = _hitungEngine.hitungMenuB(input);
      await _layananProyek.simpanInputSurveyor(input);
      await _layananProyek.simpanHasilMenuB(_idProyek, _hasilMenuB!);
      await _catatAktivitas('SIMPAN_MENU_B');
      _menuBSudahDisimpan = true;
      _setSukses();
      return true;
    } catch (e) {
      _setGagal('Gagal: $e');
      return false;
    }
  }

  Future<bool> simpanMenuC({
    required String pBangunanStr,
    required String lBangunanStr,
  }) async {
    if (_idProyek.isEmpty) {
      _setGagal('ID Proyek tidak ditemukan.');
      return false;
    }
    _setMemuat();
    try {
      _pBangunan = double.parse(pBangunanStr.replaceAll(',', '.'));
      _lBangunan = double.parse(lBangunanStr.replaceAll(',', '.'));
      final input = _buatInputSurveyor();
      _hasilMenuC = _hitungEngine.hitungMenuC(input);
      await _layananProyek.simpanInputSurveyor(input);
      await _layananProyek.simpanHasilMenuC(_idProyek, _hasilMenuC!);
      await _catatAktivitas('SIMPAN_MENU_C');
      _menuCSudahDisimpan = true;
      _setSukses();
      return true;
    } catch (e) {
      _setGagal('Gagal: $e');
      return false;
    }
  }

  Future<bool> simpanMenuD({
    required String jmlPintuStr,
    required String jmlJendelaStr,
  }) async {
    if (_idProyek.isEmpty) {
      _setGagal('ID Proyek tidak ditemukan.');
      return false;
    }
    _setMemuat();
    try {
      _jmlPintu = int.parse(jmlPintuStr);
      _jmlJendela = int.parse(jmlJendelaStr);
      final input = _buatInputSurveyor();
      _hasilMenuD = _hitungEngine.hitungMenuD(input);
      await _layananProyek.simpanInputSurveyor(input);
      await _layananProyek.simpanHasilMenuD(_idProyek, _hasilMenuD!);
      await _catatAktivitas('SIMPAN_MENU_D');
      _menuDSudahDisimpan = true;
      _setSukses();
      return true;
    } catch (e) {
      _setGagal('Gagal: $e');
      return false;
    }
  }

  Future<bool> simpanMenuE({
    required String pBangunanStr,
    required String lBangunanStr,
  }) async {
    if (_idProyek.isEmpty) {
      _setGagal('ID Proyek tidak ditemukan.');
      return false;
    }
    _setMemuat();
    try {
      _pBangunan = double.parse(pBangunanStr.replaceAll(',', '.'));
      _lBangunan = double.parse(lBangunanStr.replaceAll(',', '.'));
      final input = _buatInputSurveyor();
      _hasilMenuE = _hitungEngine.hitungMenuE(input);
      await _layananProyek.simpanInputSurveyor(input);
      await _layananProyek.simpanHasilMenuE(_idProyek, _hasilMenuE!);
      await _catatAktivitas('SIMPAN_MENU_E');
      _menuESudahDisimpan = true;
      _setSukses();
      return true;
    } catch (e) {
      _setGagal('Gagal: $e');
      return false;
    }
  }

  Future<bool> simpanMenuF({
    required String jmlLampuStr,
    required String jmlSaklar1Str,
    required String jmlSaklar2Str,
    required String jmlStopKontakStr,
  }) async {
    if (_idProyek.isEmpty) {
      _setGagal('ID Proyek tidak ditemukan.');
      return false;
    }
    if (!_menuASudahDisimpan ||
        !_menuBSudahDisimpan ||
        !_menuCSudahDisimpan ||
        !_menuDSudahDisimpan ||
        !_menuESudahDisimpan) {
      _setGagal('Menu A-E harus disimpan terlebih dahulu.');
      return false;
    }

    _setMemuat();
    try {
      _jmlLampu = int.parse(jmlLampuStr);
      _jmlSaklar1 = int.parse(jmlSaklar1Str);
      _jmlSaklar2 = int.parse(jmlSaklar2Str);
      _jmlStopKontak = int.parse(jmlStopKontakStr);
      final input = _buatInputSurveyor();

      _hasilMenuF = _hitungEngine.hitungMenuF(
        hasilB: _hasilMenuB!,
        hasilD: _hasilMenuD!,
        hasilE: _hasilMenuE!,
        input: input,
      );

      // Cek snapshot vs master
      Map<String, double> hargaMaterial;
      HargaUpah? hargaUpah;

      if (snapshotTersedia) {
        hargaMaterial = _snapshotHargaMaterial;
        final upahMap = _snapshotHargaUpah;
        hargaUpah = HargaUpah(
          pekerja: upahMap['pekerja'] ?? 0,
          tukang: upahMap['tukang'] ?? 0,
          mandor: upahMap['mandor'] ?? 0,
          diperbaruidOleh: '',
          diperbaruidPada: _tanggalSnapshotDiambil ?? DateTime.now(),
        );
        debugPrint('✓ Menggunakan harga snapshot proyek');
      } else {
        hargaMaterial = await _layananHarga.ambilSemuaHargaMaterial();
        hargaUpah = await _layananHarga.ambilHargaUpah();

        _snapshotHargaMaterial = hargaMaterial;
        _snapshotHargaUpah = {
          'pekerja': hargaUpah?.pekerja ?? 0,
          'tukang': hargaUpah?.tukang ?? 0,
          'mandor': hargaUpah?.mandor ?? 0,
        };
        _snapshotKoefisien = _koefisienAktif.keFirestore().map(
          (k, v) => MapEntry(k, (v is num) ? v.toDouble() : 0.0),
        );
        _snapshotKoefisien.remove('diperbarui_pada');
        debugPrint('✓ Menggunakan harga master — proyek baru');
      }

      if (hargaUpah == null) {
        _setGagal('Harga upah belum diatur.');
        return false;
      }

      final (:rekap, :menuG) = _hitungEngine.hitungMaterialDanUpah(
        a: _hasilMenuA!,
        b: _hasilMenuB!,
        c: _hasilMenuC!,
        d: _hasilMenuD!,
        e: _hasilMenuE!,
        f: _hasilMenuF!,
        hargaMaterial: hargaMaterial,
        hargaUpah: hargaUpah,
        k: _koefisienAktif,
      );

      _rekapMaterial = rekap;
      _hasilMenuG = menuG;

      await _layananProyek.simpanInputSurveyor(input);
      await _layananProyek.simpanSemuaHasil(
        idProyek: _idProyek,
        menuA: _hasilMenuA!,
        menuB: _hasilMenuB!,
        menuC: _hasilMenuC!,
        menuD: _hasilMenuD!,
        menuE: _hasilMenuE!,
        menuF: _hasilMenuF!,
        menuG: _hasilMenuG!,
        rekap: _rekapMaterial!,
        snapshotHargaMaterial: _snapshotHargaMaterial,
        snapshotHargaUpah: _snapshotHargaUpah,
        snapshotKoefisien: _snapshotKoefisien,
      );

      await _catatAktivitas('SIMPAN_MENU_F');
      await _catatAktivitas(
        'KALKULASI_SELESAI',
        detail: 'Grand Total: ${_rekapMaterial!.totalBiayaMaterial.toStringAsFixed(0)}',
      );

      _tanggalSnapshotDiambil = DateTime.now();
      _menuFSudahDisimpan = true;
      _setSukses();
      return true;
    } catch (e) {
      _setGagal('Gagal: $e');
      return false;
    }
  }

  void resetMenuA() {
    _pTanah = 0;
    _lTanah = 0;
    _pPondasi = 0;
    _jmlTitikTapak = 0;
    _hasilMenuA = null;
    _menuASudahDisimpan = false;
    notifyListeners();
  }

  void resetMenuB() {
    _pDinding = 0;
    _jmlKolom = 0;
    _hasilMenuB = null;
    _menuBSudahDisimpan = false;
    notifyListeners();
  }

  void resetMenuC() {
    _pBangunan = 0;
    _lBangunan = 0;
    _hasilMenuC = null;
    _menuCSudahDisimpan = false;
    notifyListeners();
  }

  void resetMenuD() {
    _jmlPintu = 0;
    _jmlJendela = 0;
    _hasilMenuD = null;
    _menuDSudahDisimpan = false;
    notifyListeners();
  }

  void resetMenuE() {
    _hasilMenuE = null;
    _menuESudahDisimpan = false;
    notifyListeners();
  }

  void resetMenuF() {
    _jmlLampu = 0;
    _jmlSaklar1 = 0;
    _jmlSaklar2 = 0;
    _jmlStopKontak = 0;
    _hasilMenuF = null;
    _hasilMenuG = null;
    _rekapMaterial = null;
    _menuFSudahDisimpan = false;
    notifyListeners();
  }

  Future<void> _muatDataTersimpan() async {
    if (_idProyek.isEmpty) return;
    try {
      final input = await _layananProyek.ambilInputSurveyor(_idProyek);
      if (input != null) {
        _pTanah = input.pTanah;
        _lTanah = input.lTanah;
        _pPondasi = input.pPondasi;
        _jmlTitikTapak = input.jmlTitikTapak;
        _pDinding = input.pDinding;
        _jmlKolom = input.jmlKolom;
        _pBangunan = input.pBangunan;
        _lBangunan = input.lBangunan;
        _jmlPintu = input.jmlPintu;
        _jmlJendela = input.jmlJendela;
        _jmlLampu = input.jmlLampu;
        _jmlSaklar1 = input.jmlSaklar1;
        _jmlSaklar2 = input.jmlSaklar2;
        _jmlStopKontak = input.jmlStopKontak;
      }

      // Muat snapshot proyek
      final dataSnapshot = await _layananProyek.ambilSnapshotProyek(_idProyek);
      if (dataSnapshot != null) {
        final rawMat = dataSnapshot['snapshot_harga_material'];
        final rawUpah = dataSnapshot['snapshot_harga_upah'];
        final rawKoef = dataSnapshot['snapshot_koefisien'];

        if (rawMat is Map && rawMat.isNotEmpty) {
          _snapshotHargaMaterial = rawMat.map(
            (k, v) => MapEntry(k.toString(), (v as num?)?.toDouble() ?? 0.0),
          );
          _snapshotHargaUpah =
              (rawUpah as Map?)?.map(
                (k, v) => MapEntry(k.toString(), (v as num?)?.toDouble() ?? 0.0),
              ) ??
              {};
          _snapshotKoefisien =
              (rawKoef as Map?)?.map(
                (k, v) => MapEntry(k.toString(), (v as num?)?.toDouble() ?? 0.0),
              ) ??
              {};
          _tanggalSnapshotDiambil =
              (dataSnapshot['tanggal_snapshot_diambil'] as Timestamp?)?.toDate();

          // Inject koefisien snapshot ke engine
          _koefisienAktif = KoefisienAktif.dariFirestore(_snapshotKoefisien);
          debugPrint('✓ Snapshot proyek dimuat — kalkulasi pakai data snapshot');
        }
      }

      _hasilMenuA = await _layananProyek.ambilHasilMenuA(_idProyek);
      if (_hasilMenuA != null) _menuASudahDisimpan = true;
      _hasilMenuB = await _layananProyek.ambilHasilMenuB(_idProyek);
      if (_hasilMenuB != null) _menuBSudahDisimpan = true;
      _hasilMenuC = await _layananProyek.ambilHasilMenuC(_idProyek);
      if (_hasilMenuC != null) _menuCSudahDisimpan = true;
      _hasilMenuD = await _layananProyek.ambilHasilMenuD(_idProyek);
      if (_hasilMenuD != null) _menuDSudahDisimpan = true;
      _hasilMenuE = await _layananProyek.ambilHasilMenuE(_idProyek);
      if (_hasilMenuE != null) _menuESudahDisimpan = true;
      _hasilMenuF = await _layananProyek.ambilHasilMenuF(_idProyek);
      if (_hasilMenuF != null) _menuFSudahDisimpan = true;
      _hasilMenuG = await _layananProyek.ambilHasilMenuG(_idProyek);
      _rekapMaterial = await _layananProyek.ambilRekapMaterial(_idProyek);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ GAGAL MUAT: $e');
    }
  }

  Future<void> rekalkulasiDenganHargaTerbaru() async {
    if (_idProyek.isEmpty || !dataLengkap) return;
    debugPrint('🔄 Re-kalkulasi dengan harga snapshot...');
    try {
      Map<String, double> hargaMaterial;
      HargaUpah? hargaUpah;

      if (snapshotTersedia) {
        hargaMaterial = _snapshotHargaMaterial;
        final upahMap = _snapshotHargaUpah;
        hargaUpah = HargaUpah(
          pekerja: upahMap['pekerja'] ?? 0,
          tukang: upahMap['tukang'] ?? 0,
          mandor: upahMap['mandor'] ?? 0,
          diperbaruidOleh: '',
          diperbaruidPada: _tanggalSnapshotDiambil ?? DateTime.now(),
        );
      } else {
        hargaMaterial = await _layananHarga.ambilSemuaHargaMaterial();
        hargaUpah = await _layananHarga.ambilHargaUpah();
      }

      if (hargaUpah == null) {
        debugPrint('⚠️ Harga upah tidak ditemukan');
        return;
      }

      final (:rekap, :menuG) = _hitungEngine.hitungMaterialDanUpah(
        a: _hasilMenuA!,
        b: _hasilMenuB!,
        c: _hasilMenuC!,
        d: _hasilMenuD!,
        e: _hasilMenuE!,
        f: _hasilMenuF!,
        hargaMaterial: hargaMaterial,
        hargaUpah: hargaUpah,
        k: _koefisienAktif,
      );
      _rekapMaterial = rekap;
      _hasilMenuG = menuG;
      debugPrint('✓ Re-kalkulasi selesai');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error rekalkulasi: $e');
    }
  }

  Future<void> kalkulasiParsial() async {
    if (_idProyek.isEmpty || dataKosong) return;
    debugPrint('🔄 Kalkulasi parsial (${jumlahMenuTerisi}/6 menu)...');
    try {
      Map<String, double> hargaMaterial;
      HargaUpah? hargaUpah;

      if (snapshotTersedia) {
        hargaMaterial = _snapshotHargaMaterial;
        final upahMap = _snapshotHargaUpah;
        hargaUpah = HargaUpah(
          pekerja: upahMap['pekerja'] ?? 0,
          tukang: upahMap['tukang'] ?? 0,
          mandor: upahMap['mandor'] ?? 0,
          diperbaruidOleh: '',
          diperbaruidPada: _tanggalSnapshotDiambil ?? DateTime.now(),
        );
      } else {
        hargaMaterial = await _layananHarga.ambilSemuaHargaMaterial();
        hargaUpah = await _layananHarga.ambilHargaUpah();
      }

      if (hargaUpah == null) {
        debugPrint('⚠️ Harga upah tidak ditemukan');
        return;
      }

      final (:rekap, :menuG) = _hitungEngine.hitungMaterialDanUpah(
        a: _hasilMenuA ?? _buatMenuAKosong(),
        b: _hasilMenuB ?? _buatMenuBKosong(),
        c: _hasilMenuC ?? _buatMenuCKosong(),
        d: _hasilMenuD ?? _buatMenuDKosong(),
        e: _hasilMenuE ?? _buatMenuEKosong(),
        f: _hasilMenuF ?? _buatMenuFKosong(),
        hargaMaterial: hargaMaterial,
        hargaUpah: hargaUpah,
        k: _koefisienAktif,
      );
      _rekapMaterial = rekap;
      _hasilMenuG = menuG;
      debugPrint('✓ Kalkulasi parsial selesai');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error parsial: $e');
    }
  }

  /// Tarik master terbaru, inject ke provider, update snapshot di Firestore.
  /// Dipanggil dari tombol "Refresh Data" di ProjectEstimationPage.
  Future<void> refreshDariMaster() async {
    if (_idProyek.isEmpty) return;
    if (_hasilMenuA == null ||
        _hasilMenuB == null ||
        _hasilMenuC == null ||
        _hasilMenuD == null ||
        _hasilMenuE == null ||
        _hasilMenuF == null) return;

    debugPrint('🔄 Refresh dari master...');

    try {
      // A. Tarik semua data master langsung dari Firestore
      final hargaMaterial = await _layananHarga.ambilSemuaHargaMaterial();
      final hargaUpah = await _layananHarga.ambilHargaUpah();
      final koefisienTerbaru = await _layananKoefisien.ambilKoefisien();

      if (hargaUpah == null) {
        debugPrint('⚠️ Harga upah tidak ditemukan di master');
        return;
      }

      // B. Overwrite semua variabel snapshot lokal secara eksplisit
      _koefisienAktif = koefisienTerbaru;
      _snapshotHargaMaterial = hargaMaterial;
      _snapshotHargaUpah = {
        'pekerja': hargaUpah.pekerja,
        'tukang': hargaUpah.tukang,
        'mandor': hargaUpah.mandor,
      };
      final koefMap = koefisienTerbaru.keFirestore().map(
        (k, v) => MapEntry(k, (v is num) ? v.toDouble() : 0.0),
      );
      koefMap.remove('diperbarui_pada');
      _snapshotKoefisien = koefMap;
      _tanggalSnapshotDiambil = DateTime.now();

      // C. Jalankan kalkulasi menggunakan data yang baru di-assign
      final (:rekap, :menuG) = _hitungEngine.hitungMaterialDanUpah(
        a: _hasilMenuA!,
        b: _hasilMenuB!,
        c: _hasilMenuC!,
        d: _hasilMenuD!,
        e: _hasilMenuE!,
        f: _hasilMenuF!,
        hargaMaterial: _snapshotHargaMaterial,
        hargaUpah: hargaUpah,
        k: _koefisienAktif,
      );
      _rekapMaterial = rekap;
      _hasilMenuG = menuG;

      // D. Persist snapshot + hasil kalkulasi terbaru ke Firestore
      await _layananProyek.perbaruiSnapshot(
        idProyek: _idProyek,
        snapshotHargaMaterial: _snapshotHargaMaterial,
        snapshotHargaUpah: _snapshotHargaUpah,
        snapshotKoefisien: _snapshotKoefisien,
      );
      await _layananProyek.simpanSemuaHasil(
        idProyek: _idProyek,
        menuA: _hasilMenuA!,
        menuB: _hasilMenuB!,
        menuC: _hasilMenuC!,
        menuD: _hasilMenuD!,
        menuE: _hasilMenuE!,
        menuF: _hasilMenuF!,
        menuG: _hasilMenuG!,
        rekap: _rekapMaterial!,
        snapshotHargaMaterial: _snapshotHargaMaterial,
        snapshotHargaUpah: _snapshotHargaUpah,
        snapshotKoefisien: _snapshotKoefisien,
      );

      await _catatAktivitas('REFRESH_MASTER');

      debugPrint('✓ Refresh selesai — snapshot, kalkulasi & Firestore diperbarui');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error refresh dari master: $e');
    }
  }

  // void mulaiListenHargaUpah() {
  //   if (_isListeningHargaUpah || !dataLengkap) return;
  //   _hargaUpahSubscription = _layananHarga.streamHargaUpah().listen((hargaUpah) async {
  //     if (hargaUpah == null) return;
  //     try {
  //       final hargaMaterial = await _layananHarga.ambilSemuaHargaMaterial();
  //       final (:rekap, :menuG) = _hitungEngine.hitungMaterialDanUpah(
  //         a: _hasilMenuA!,
  //         b: _hasilMenuB!,
  //         c: _hasilMenuC!,
  //         d: _hasilMenuD!,
  //         e: _hasilMenuE!,
  //         f: _hasilMenuF!,
  //         hargaMaterial: hargaMaterial,
  //         hargaUpah: hargaUpah,
  //         k: _koefisienAktif,
  //       );
  //       _rekapMaterial = rekap;
  //       _hasilMenuG = menuG;
  //       notifyListeners();
  //     } catch (e) {
  //       debugPrint('❌ Error auto-rekalkulasi: $e');
  //     }
  //   });
  //   _isListeningHargaUpah = true;
  // }

  // void hentikanListenHargaUpah() {
  //   if (_hargaUpahSubscription != null) {
  //     _hargaUpahSubscription!.cancel();
  //     _hargaUpahSubscription = null;
  //     _isListeningHargaUpah = false;
  //   }
  // }

  @override
  void dispose() {
    // hentikanListenHargaUpah();
    super.dispose();
  }

  void _setMemuat() {
    _status = StatusProses.memuat;
    _pesanError = '';
    notifyListeners();
  }

  void _setSukses() {
    _status = StatusProses.sukses;
    notifyListeners();
  }

  void _setGagal(String pesan) {
    _pesanError = pesan;
    _status = StatusProses.gagal;
    notifyListeners();
  }

  /// Catat aktivitas surveyor ke koleksi riwayatAktivitas.
  /// meski proyek baru dibuat dan cache History belum ter-refresh.
  Future<void> _catatAktivitas(String namaAksi, {String detail = ''}) async {
    if (_idProyek.isEmpty || _idPengguna.isEmpty) return;
    try {
      await _layananHistori.catatAktivitas(
        idProyek: _idProyek,
        idPengguna: _idPengguna,
        namaAksi: namaAksi,
        detail: detail.isEmpty ? _namaProyek : detail,
      );
    } catch (e) {
      debugPrint('⚠️ Gagal catat aktivitas ($namaAksi): $e');
    }
  }

  InputSurveyor _buatInputSurveyor() {
    return InputSurveyor(
      idProyek: _idProyek,
      pTanah: _pTanah,
      lTanah: _lTanah,
      pPondasi: _pPondasi,
      jmlTitikTapak: _jmlTitikTapak,
      pDinding: _pDinding,
      jmlKolom: _jmlKolom,
      pBangunan: _pBangunan,
      lBangunan: _lBangunan,
      jmlPintu: _jmlPintu,
      jmlJendela: _jmlJendela,
      jmlLampu: _jmlLampu,
      jmlSaklar1: _jmlSaklar1,
      jmlSaklar2: _jmlSaklar2,
      jmlStopKontak: _jmlStopKontak,
      dibuatPada: DateTime.now(),
      diperbaruidPada: DateTime.now(),
    );
  }

  HasilMenuA _buatMenuAKosong() => HasilMenuA(
        volBersih: 0, volBouwplank: 0, volGalianMenerus: 0,
        volPasirMenerus: 0, volAanstampMenerus: 0, volBatuKali: 0,
        volGalianTapak: 0, volPasirTapak: 0, volAanstampTapak: 0,
        volBetonTapak: 0, volUrugMenerus: 0, volUrugTapak: 0,
        dihitungPada: DateTime.now(),
      );

  HasilMenuB _buatMenuBKosong() => HasilMenuB(
        volSloof: 0, volKolom: 0, volRingBalok: 0,
        volDinding: 0, volPlester: 0, volAcian: 0,
        dihitungPada: DateTime.now(),
      );

  HasilMenuC _buatMenuCKosong() => HasilMenuC(
        luasLantai: 0, volTimbunan: 0, volPasirLantai: 0,
        volCorLantai: 0, volKeramik: 0,
        dihitungPada: DateTime.now(),
      );

  HasilMenuD _buatMenuDKosong() => HasilMenuD(
        volKusenPintu: 0, volDaunPintu: 0, volKusenVentilasi: 0,
        jmlKunci: 0, jmlEngselPintu: 0, volKusenJendela: 0,
        volDaunJendela: 0, volKaca: 0, jmlEngselJendela: 0,
        volKusenTotal: 0, dihitungPada: DateTime.now(),
      );

  HasilMenuE _buatMenuEKosong() => HasilMenuE(
        volPlafon: 0, volListPlafon: 0, volRangkaAtap: 0,
        volGenteng: 0, volListplank: 0, volNok: 0,
        dihitungPada: DateTime.now(),
      );

  HasilMenuF _buatMenuFKosong() => HasilMenuF(
        volCatTembok: 0, volCatPlafon: 0, volCatKayu: 0,
        volLampu: 0, volSaklar1: 0, volSaklar2: 0,
        volStopKontak: 0, dihitungPada: DateTime.now(),
      );
}