
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/model_input_surveyor.dart';
import '../models/model_hasil_perhitungan.dart';
import '../models/model_rekap_dan_lainnya.dart';
import 'layanan_perhitungan.dart';
import 'layanan_master_harga.dart';
import 'layanan_proyek.dart';

enum StatusProses { awal, memuat, sukses, gagal }

class EstimasiProvider extends ChangeNotifier {
  final LayananPerhitungan _hitungEngine = LayananPerhitungan();
  final LayananMasterHarga _layananHarga = LayananMasterHarga();
  final LayananProyek _layananProyek = LayananProyek();
  final LayananHistori _layananHistori = LayananHistori();

  StreamSubscription<HargaUpah?>? _hargaUpahSubscription;
  bool _isListeningHargaUpah = false;

  // State Proyek
  String _idProyek = '';
  String _idPengguna = '';
  String get idProyek => _idProyek;

  Future<void> inisialisasiProyek({
    required String idProyek,
    required String idPengguna,
  }) async {
    debugPrint('=== inisialisasiProyek dipanggil ===');
    debugPrint('    idProyek baru : "$idProyek"');
    debugPrint('    idProyek lama : "$_idProyek"');

    final proyekBerubah = _idProyek != idProyek;

    _idProyek = idProyek;
    _idPengguna = idPengguna;

    if (proyekBerubah) {
      debugPrint('    → Proyek BERBEDA, reset state');
      resetSemuaState();
    } else {
      debugPrint('    → Proyek SAMA, skip reset (data tetap ada)');
    }

    await _muatDataTersimpan();
    notifyListeners();
  }

  /// Reset SEMUA state ke nilai default (dipanggil saat pindah proyek)
  void resetSemuaState() {
    debugPrint('=== resetSemuaState dipanggil ===');

    // Reset input data (14 field)
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

    // Reset status simpan per menu
    _menuASudahDisimpan = false;
    _menuBSudahDisimpan = false;
    _menuCSudahDisimpan = false;
    _menuDSudahDisimpan = false;
    _menuESudahDisimpan = false;
    _menuFSudahDisimpan = false;

    // Reset hasil perhitungan
    _hasilMenuA = null;
    _hasilMenuB = null;
    _hasilMenuC = null;
    _hasilMenuD = null;
    _hasilMenuE = null;
    _hasilMenuF = null;
    _hasilMenuG = null;
    _rekapMaterial = null;

    // Reset status & pesan
    _status = StatusProses.awal;
    _pesanError = '';

    debugPrint('=== State berhasil di-reset ===');
  }

  // Status dan Pesan
  StatusProses _status = StatusProses.awal;
  StatusProses get status => _status;

  String _pesanError = '';
  String get pesanError => _pesanError;

  bool get sedangMemuat => _status == StatusProses.memuat;

  // Data Inpur - 14 Field
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

  // Getter untuk pre-fill UI
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

  // Status simpan per menu
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

  // Hasil Perhitungan
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

  // Helper Validasi Status Menu

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

  // SIMPAN MENU A
  Future<bool> simpanMenuA({
    required String pTanahStr,
    required String lTanahStr,
    required String pPondasiStr,
    required String jmlTitikTapakStr,
  }) async {
    debugPrint('=== simpanMenuA === idProyek: "$_idProyek"');
    if (_idProyek.isEmpty) {
      _setGagal('ID Proyek tidak ditemukan.');
      return false;
    }
    final pesan = _validasiMenuA(
      pTanahStr: pTanahStr,
      lTanahStr: lTanahStr,
      pPondasiStr: pPondasiStr,
      jmlTitikTapakStr: jmlTitikTapakStr,
    );
    if (pesan != null) {
      _setGagal(pesan);
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
      _debugCetakHasilA();
      await _layananProyek.simpanInputSurveyor(input);
      await _layananProyek.simpanHasilMenuA(_idProyek, _hasilMenuA!);
      await _layananHistori.catatAktivitas(
        idProyek: _idProyek,
        idPengguna: _idPengguna,
        namaAksi: 'SIMPAN_MENU_A',
        detail:
            'panjangTanah=$_pTanah, lebarTanah=$_lTanah, panjangPondasi=$_pPondasi, jumlahTitikTapak=$_jmlTitikTapak',
      );
      _menuASudahDisimpan = true;
      _setSukses();
      return true;
    } catch (e) {
      _setGagal('Gagal menyimpan: $e');
      debugPrint('ERROR Menu A: $e');
      return false;
    }
  }

  // SIMPAN MENU B
  Future<bool> simpanMenuB({
    required String pDindingStr,
    required String jmlKolomStr,
  }) async {
    debugPrint('=== simpanMenuB === idProyek: "$_idProyek"');
    if (_idProyek.isEmpty) {
      _setGagal('ID Proyek tidak ditemukan.');
      return false;
    }
    final pesan = _validasiMenuB(
      pDindingStr: pDindingStr,
      jmlKolomStr: jmlKolomStr,
    );
    if (pesan != null) {
      _setGagal(pesan);
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
      _debugCetakHasilB();
      await _layananProyek.simpanInputSurveyor(input);
      await _layananProyek.simpanHasilMenuB(_idProyek, _hasilMenuB!);
      await _layananHistori.catatAktivitas(
        idProyek: _idProyek,
        idPengguna: _idPengguna,
        namaAksi: 'SIMPAN_MENU_B',
        detail: 'panjangDinding=$_pDinding, jumlahKolomPraktis=$_jmlKolom',
      );
      _menuBSudahDisimpan = true;
      _setSukses();
      return true;
    } catch (e) {
      _setGagal('Gagal menyimpan: $e');
      debugPrint('ERROR Menu B: $e');
      return false;
    }
  }

  // SIMPAN MENU C
  Future<bool> simpanMenuC({
    required String pBangunanStr,
    required String lBangunanStr,
  }) async {
    debugPrint('=== simpanMenuC === idProyek: "$_idProyek"');
    if (_idProyek.isEmpty) {
      _setGagal('ID Proyek tidak ditemukan.');
      return false;
    }
    final pesan = _validasiMenuC(
      pBangunanStr: pBangunanStr,
      lBangunanStr: lBangunanStr,
    );
    if (pesan != null) {
      _setGagal(pesan);
      return false;
    }
    _setMemuat();
    try {
      _pBangunan = double.parse(pBangunanStr.replaceAll(',', '.'));
      _lBangunan = double.parse(lBangunanStr.replaceAll(',', '.'));
      final input = _buatInputSurveyor();
      _hasilMenuC = _hitungEngine.hitungMenuC(input);
      _debugCetakHasilC();
      await _layananProyek.simpanInputSurveyor(input);
      await _layananProyek.simpanHasilMenuC(_idProyek, _hasilMenuC!);
      await _layananHistori.catatAktivitas(
        idProyek: _idProyek,
        idPengguna: _idPengguna,
        namaAksi: 'SIMPAN_MENU_C',
        detail: 'panjangBangunan=$_pBangunan, lebarBangunan=$_lBangunan',
      );
      _menuCSudahDisimpan = true;
      _setSukses();
      return true;
    } catch (e) {
      _setGagal('Gagal menyimpan: $e');
      debugPrint('ERROR Menu C: $e');
      return false;
    }
  }

  // SIMPAN MENU D
  Future<bool> simpanMenuD({
    required String jmlPintuStr,
    required String jmlJendelaStr,
  }) async {
    debugPrint('=== simpanMenuD === idProyek: "$_idProyek"');
    if (_idProyek.isEmpty) {
      _setGagal('ID Proyek tidak ditemukan.');
      return false;
    }
    final pesan = _validasiMenuD(
      jmlPintuStr: jmlPintuStr,
      jmlJendelaStr: jmlJendelaStr,
    );
    if (pesan != null) {
      _setGagal(pesan);
      return false;
    }
    _setMemuat();
    try {
      _jmlPintu = int.parse(jmlPintuStr);
      _jmlJendela = int.parse(jmlJendelaStr);
      final input = _buatInputSurveyor();
      _hasilMenuD = _hitungEngine.hitungMenuD(input);
      _debugCetakHasilD();
      await _layananProyek.simpanInputSurveyor(input);
      await _layananProyek.simpanHasilMenuD(_idProyek, _hasilMenuD!);
      await _layananHistori.catatAktivitas(
        idProyek: _idProyek,
        idPengguna: _idPengguna,
        namaAksi: 'SIMPAN_MENU_D',
        detail: 'jumlahPintu=$_jmlPintu, jumlahJendela=$_jmlJendela',
      );
      _menuDSudahDisimpan = true;
      _setSukses();
      return true;
    } catch (e) {
      _setGagal('Gagal menyimpan: $e');
      debugPrint('ERROR Menu D: $e');
      return false;
    }
  }

  // SIMPAN MENU E
  Future<bool> simpanMenuE({
    required String pBangunanStr,
    required String lBangunanStr,
  }) async {
    debugPrint('=== simpanMenuE === idProyek: "$_idProyek"');
    if (_idProyek.isEmpty) {
      _setGagal('ID Proyek tidak ditemukan.');
      return false;
    }
    final pesan = _validasiMenuE(
      pBangunanStr: pBangunanStr,
      lBangunanStr: lBangunanStr,
    );
    if (pesan != null) {
      _setGagal(pesan);
      return false;
    }
    _setMemuat();
    try {
      _pBangunan = double.parse(pBangunanStr.replaceAll(',', '.'));
      _lBangunan = double.parse(lBangunanStr.replaceAll(',', '.'));
      final input = _buatInputSurveyor();
      _hasilMenuE = _hitungEngine.hitungMenuE(input);
      _debugCetakHasilE();
      await _layananProyek.simpanInputSurveyor(input);
      await _layananProyek.simpanHasilMenuE(_idProyek, _hasilMenuE!);
      await _layananHistori.catatAktivitas(
        idProyek: _idProyek,
        idPengguna: _idPengguna,
        namaAksi: 'SIMPAN_MENU_E',
        detail: 'panjangBangunan=$_pBangunan, lebarBangunan=$_lBangunan',
      );
      _menuESudahDisimpan = true;
      _setSukses();
      return true;
    } catch (e) {
      _setGagal('Gagal menyimpan: $e');
      debugPrint('ERROR Menu E: $e');
      return false;
    }
  }

  // SIMPAN MENU F — Finishing Cat dan Listrik
  // setelah simpan, langsung jalankan
  // kalkulasi keseluruhan (rekap 39 material + Menu G upah)
  Future<bool> simpanMenuF({
    required String jmlLampuStr,
    required String jmlSaklar1Str,
    required String jmlSaklar2Str,
    required String jmlStopKontakStr,
  }) async {
    debugPrint('=== simpanMenuF === idProyek: "$_idProyek"');
    if (_idProyek.isEmpty) {
      _setGagal('ID Proyek tidak ditemukan.');
      return false;
    }

    // Validasi Menu F 
    final pesan = _validasiMenuF(
      jmlLampuStr: jmlLampuStr,
      jmlSaklar1Str: jmlSaklar1Str,
      jmlSaklar2Str: jmlSaklar2Str,
      jmlStopKontakStr: jmlStopKontakStr,
    );
    if (pesan != null) {
      _setGagal(pesan);
      return false;
    }

    // Cegah Kalkulasi Jika Menu A-E Belum Semua Disimpan 
    if (!_menuASudahDisimpan ||
        !_menuBSudahDisimpan ||
        !_menuCSudahDisimpan ||
        !_menuDSudahDisimpan ||
        !_menuESudahDisimpan) {
      _setGagal(
        'Menu A sampai E harus disimpan terlebih dahulu sebelum Finishing.\n'
        'Periksa menu yang belum tersimpan (belum ada badge ✓ Tersimpan).',
      );
      return false;
    }

    _setMemuat();

    try {
      // parsing
      _jmlLampu = int.parse(jmlLampuStr);
      _jmlSaklar1 = int.parse(jmlSaklar1Str);
      _jmlSaklar2 = int.parse(jmlSaklar2Str);
      _jmlStopKontak = int.parse(jmlStopKontakStr);

      final input = _buatInputSurveyor();

      // ── HITUNG MENU F ─────────────────────────────────────
      _hasilMenuF = _hitungEngine.hitungMenuF(
        hasilB: _hasilMenuB!,
        hasilD: _hasilMenuD!,
        hasilE: _hasilMenuE!,
        input: input,
      );
      _debugCetakHasilF();

      // ambil harga dari database master harga
      debugPrint('=== Mengambil harga dari masterHarga ===');
      final hargaMaterial = await _layananHarga.ambilSemuaHargaMaterial();
      final hargaUpah = await _layananHarga.ambilHargaUpah();

      if (hargaUpah == null) {
        _setGagal(
          'Data harga upah belum diatur. Hubungi admin untuk mengisi masterHarga.',
        );
        return false;
      }
      debugPrint('    ✓ ${hargaMaterial.length} item harga material tersedia');
      debugPrint(
        '    ✓ Harga upah: Pekerja=${hargaUpah.pekerja}, Tukang=${hargaUpah.tukang}, Mandor=${hargaUpah.mandor}',
      );

      // kalkulasi keseluruhan 
      debugPrint('=== Menjalankan kalkulasi penuh ===');
      final (:rekap, :menuG) = _hitungEngine.hitungMaterialDanUpah(
        a: _hasilMenuA!,
        b: _hasilMenuB!,
        c: _hasilMenuC!,
        d: _hasilMenuD!,
        e: _hasilMenuE!,
        f: _hasilMenuF!,
        hargaMaterial: hargaMaterial,
        hargaUpah: hargaUpah,
      );
      _rekapMaterial = rekap;
      _hasilMenuG = menuG;
      _debugCetakHasilG();

      // simpan ke firestore
      debugPrint('=== Menyimpan semua hasil ke Firestore ===');
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
      );
      debugPrint('    ✓ Semua hasil tersimpan');

      // catat history
      await _layananHistori.catatAktivitas(
        idProyek: _idProyek,
        idPengguna: _idPengguna,
        namaAksi: 'KALKULASI_SELESAI',
        detail:
            'jumlahLampu=$_jmlLampu, saklarTunggal=$_jmlSaklar1, '
            'saklarGanda=$_jmlSaklar2, stopKontak=$_jmlStopKontak. '
            'totalBiayaMaterial=${rekap.totalBiayaMaterial.toStringAsFixed(0)}, '
            'totalBiayaUpah=${menuG.totalBiayaUpah.toStringAsFixed(0)}',
      );

      _menuFSudahDisimpan = true;
      _setSukses();
      return true;
    } catch (e) {
      _setGagal('Gagal menyimpan: $e');
      debugPrint('ERROR Menu F / Kalkulasi Penuh: $e');
      return false;
    }
  }

  // reset per menu

  void resetMenuA() {
    _pTanah = 0;
    _lTanah = 0;
    _pPondasi = 0;
    _jmlTitikTapak = 0;
    _pDinding = 0;
    _jmlKolom = 0;
    _hasilMenuA = null;
    _menuASudahDisimpan = false;
    _status = StatusProses.awal;
    _pesanError = '';
    notifyListeners();
  }

  void resetMenuB() {
    _pDinding = 0;
    _jmlKolom = 0;
    _hasilMenuB = null;
    _menuBSudahDisimpan = false;
    _status = StatusProses.awal;
    _pesanError = '';
    notifyListeners();
  }

  void resetMenuC() {
    _pBangunan = 0;
    _lBangunan = 0;
    _hasilMenuC = null;
    _menuCSudahDisimpan = false;
    _status = StatusProses.awal;
    _pesanError = '';
    notifyListeners();
  }

  void resetMenuD() {
    _jmlPintu = 0;
    _jmlJendela = 0;
    _hasilMenuD = null;
    _menuDSudahDisimpan = false;
    _status = StatusProses.awal;
    _pesanError = '';
    notifyListeners();
  }

  void resetMenuE() {
    _hasilMenuE = null;
    _menuESudahDisimpan = false;
    _status = StatusProses.awal;
    _pesanError = '';
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
    _status = StatusProses.awal;
    _pesanError = '';
    notifyListeners();
  }

  // Muat Data Tersimpan
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
      final hasilA = await _layananProyek.ambilHasilMenuA(_idProyek);
      if (hasilA != null) {
        _hasilMenuA = hasilA;
        _menuASudahDisimpan = true;
      }
      final hasilB = await _layananProyek.ambilHasilMenuB(_idProyek);
      if (hasilB != null) {
        _hasilMenuB = hasilB;
        _menuBSudahDisimpan = true;
      }
      final hasilC = await _layananProyek.ambilHasilMenuC(_idProyek);
      if (hasilC != null) {
        _hasilMenuC = hasilC;
        _menuCSudahDisimpan = true;
      }
      final hasilD = await _layananProyek.ambilHasilMenuD(_idProyek);
      if (hasilD != null) {
        _hasilMenuD = hasilD;
        _menuDSudahDisimpan = true;
      }
      final hasilE = await _layananProyek.ambilHasilMenuE(_idProyek);
      if (hasilE != null) {
        _hasilMenuE = hasilE;
        _menuESudahDisimpan = true;
      }
      final hasilF = await _layananProyek.ambilHasilMenuF(_idProyek);
      if (hasilF != null) {
        _hasilMenuF = hasilF;
        _menuFSudahDisimpan = true;
      }
      final hasilG = await _layananProyek.ambilHasilMenuG(_idProyek);
      if (hasilG != null) {
        _hasilMenuG = hasilG;
      }
      final rekap = await _layananProyek.ambilRekapMaterial(_idProyek);
      if (rekap != null) {
        _rekapMaterial = rekap;
      }
      notifyListeners();
    } catch (e, stacktrace) {
      // INI YANG KITA UBAH: Biar errornya teriak di terminal
      debugPrint('❌ GAGAL MUAT DATA DI HP: $e');
      debugPrint(stacktrace.toString());
    }
  }

  /// Re-kalkulasi material dan upah dengan harga terbaru dari Firestore
  /// Dipanggil saat membuka halaman Prediksi Pekerja atau Hasil Akhir
  Future<void> rekalkulasiDenganHargaTerbaru() async {
    if (_idProyek.isEmpty) return;

    if (_hasilMenuA == null ||
        _hasilMenuB == null ||
        _hasilMenuC == null ||
        _hasilMenuD == null ||
        _hasilMenuE == null ||
        _hasilMenuF == null) {
      debugPrint('⚠️  Tidak bisa re-kalkulasi: Data Menu A-F belum lengkap');
      return;
    }

    debugPrint('🔄 Re-kalkulasi dengan harga terbaru...');

    try {
      final hargaMaterial = await _layananHarga.ambilSemuaHargaMaterial();
      final hargaUpah = await _layananHarga.ambilHargaUpah();

      if (hargaUpah == null) {
        debugPrint('⚠️  Harga upah tidak ditemukan di database');
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
      );

      _rekapMaterial = rekap;
      _hasilMenuG = menuG;

      debugPrint('✓ Re-kalkulasi selesai');
      debugPrint(
        '  - Total Biaya Material: Rp ${rekap.totalBiayaMaterial.toStringAsFixed(0)}',
      );
      debugPrint(
        '  - Total Biaya Upah: Rp ${menuG.totalBiayaUpah.toStringAsFixed(0)}',
      );

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error re-kalkulasi: $e');
    }
  }

  /// Kalkulasi parsial untuk mendukung Cek Bahan dan Hasil Analisa
  /// Menu yang belum diisi akan dianggap 0 (tidak error)
  Future<void> kalkulasiParsial() async {
    if (_idProyek.isEmpty) return;
    if (jumlahMenuTerisi == 0) return;

    debugPrint('🔄 Kalkulasi parsial (${jumlahMenuTerisi}/6 menu)...');

    try {
      final hargaMaterial = await _layananHarga.ambilSemuaHargaMaterial();
      final hargaUpah = await _layananHarga.ambilHargaUpah();

      if (hargaUpah == null) {
        debugPrint('⚠️  Harga upah tidak ditemukan di database');
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
      );

      _rekapMaterial = rekap;
      _hasilMenuG = menuG;

      debugPrint('✓ Kalkulasi parsial selesai');

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error kalkulasi parsial: $e');
    }
  }

  /// Mulai mendengarkan perubahan harga upah secara real-time
  /// Akan otomatis re-kalkulasi setiap kali harga berubah di Firestore
  void mulaiListenHargaUpah() {
    if (_isListeningHargaUpah) {
      debugPrint('⚠️  Sudah listening harga upah');
      return;
    }

    if (_hasilMenuA == null ||
        _hasilMenuB == null ||
        _hasilMenuC == null ||
        _hasilMenuD == null ||
        _hasilMenuE == null ||
        _hasilMenuF == null) {
      debugPrint('⚠️  Tidak bisa listen: Data Menu A-F belum lengkap');
      return;
    }

    debugPrint('🎧 Mulai listen perubahan harga upah real-time...');

    _hargaUpahSubscription = _layananHarga.streamHargaUpah().listen(
      (hargaUpah) async {
        if (hargaUpah == null) {
          debugPrint('⚠️  Harga upah null dari stream');
          return;
        }

        debugPrint('📡 Harga upah berubah! Re-kalkulasi otomatis...');
        debugPrint('  - Pekerja: Rp ${hargaUpah.pekerja}');
        debugPrint('  - Tukang: Rp ${hargaUpah.tukang}');
        debugPrint('  - Mandor: Rp ${hargaUpah.mandor}');

        try {
          final hargaMaterial = await _layananHarga.ambilSemuaHargaMaterial();

          final (:rekap, :menuG) = _hitungEngine.hitungMaterialDanUpah(
            a: _hasilMenuA!,
            b: _hasilMenuB!,
            c: _hasilMenuC!,
            d: _hasilMenuD!,
            e: _hasilMenuE!,
            f: _hasilMenuF!,
            hargaMaterial: hargaMaterial,
            hargaUpah: hargaUpah,
          );

          _rekapMaterial = rekap;
          _hasilMenuG = menuG;

          debugPrint('✓ Re-kalkulasi otomatis selesai');
          notifyListeners();
        } catch (e) {
          debugPrint('❌ Error re-kalkulasi otomatis: $e');
        }
      },
      onError: (error) {
        debugPrint('❌ Error stream harga upah: $error');
      },
    );

    _isListeningHargaUpah = true;
  }

  /// Hentikan listening perubahan harga upah
  /// Dipanggil saat keluar dari halaman Prediksi Pekerja / Hasil Akhir
  void hentikanListenHargaUpah() {
    if (_hargaUpahSubscription != null) {
      debugPrint('🔇 Hentikan listen harga upah');
      _hargaUpahSubscription!.cancel();
      _hargaUpahSubscription = null;
      _isListeningHargaUpah = false;
    }
  }

  @override
  void dispose() {
    hentikanListenHargaUpah();
    super.dispose();
  }

  // Helper Status

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

  // Helper Input

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

  // Validasi

  String? _validasiMenuA({
    required String pTanahStr,
    required String lTanahStr,
    required String pPondasiStr,
    required String jmlTitikTapakStr,
  }) {
    if (pTanahStr.trim().isEmpty) return 'Panjang Tanah wajib diisi.';
    if (lTanahStr.trim().isEmpty) return 'Lebar Tanah wajib diisi.';
    if (pPondasiStr.trim().isEmpty) return 'Panjang Pondasi wajib diisi.';
    if (jmlTitikTapakStr.trim().isEmpty)
      return 'Jumlah Titik Pondasi Tapak wajib diisi.';
    if ((double.tryParse(pTanahStr.replaceAll(',', '.')) ?? 0) <= 0)
      return 'Panjang Tanah harus lebih dari 0.';
    if ((double.tryParse(lTanahStr.replaceAll(',', '.')) ?? 0) <= 0)
      return 'Lebar Tanah harus lebih dari 0.';
    if ((double.tryParse(pPondasiStr.replaceAll(',', '.')) ?? 0) <= 0)
      return 'Panjang Pondasi harus lebih dari 0.';
    if ((int.tryParse(jmlTitikTapakStr) ?? 0) <= 0)
      return 'Jumlah Titik Tapak harus bilangan bulat lebih dari 0.';
    return null;
  }

  String? _validasiMenuB({
    required String pDindingStr,
    required String jmlKolomStr,
  }) {
    if (pDindingStr.trim().isEmpty) return 'Panjang Dinding wajib diisi.';
    if (jmlKolomStr.trim().isEmpty) return 'Jumlah Kolom Praktis wajib diisi.';
    if ((double.tryParse(pDindingStr.replaceAll(',', '.')) ?? 0) <= 0)
      return 'Panjang Dinding harus lebih dari 0.';
    if ((int.tryParse(jmlKolomStr) ?? 0) <= 0)
      return 'Jumlah Kolom Praktis harus bilangan bulat lebih dari 0.';
    return null;
  }

  String? _validasiMenuC({
    required String pBangunanStr,
    required String lBangunanStr,
  }) {
    if (pBangunanStr.trim().isEmpty) return 'Panjang Bangunan wajib diisi.';
    if (lBangunanStr.trim().isEmpty) return 'Lebar Bangunan wajib diisi.';
    if ((double.tryParse(pBangunanStr.replaceAll(',', '.')) ?? 0) <= 0)
      return 'Panjang Bangunan harus lebih dari 0.';
    if ((double.tryParse(lBangunanStr.replaceAll(',', '.')) ?? 0) <= 0)
      return 'Lebar Bangunan harus lebih dari 0.';
    return null;
  }

  String? _validasiMenuD({
    required String jmlPintuStr,
    required String jmlJendelaStr,
  }) {
    if (jmlPintuStr.trim().isEmpty) return 'Jumlah Pintu wajib diisi.';
    if (jmlJendelaStr.trim().isEmpty) return 'Jumlah Jendela wajib diisi.';
    if ((int.tryParse(jmlPintuStr) ?? 0) <= 0)
      return 'Jumlah Pintu harus bilangan bulat lebih dari 0.';
    if ((int.tryParse(jmlJendelaStr) ?? 0) <= 0)
      return 'Jumlah Jendela harus bilangan bulat lebih dari 0.';
    return null;
  }

  String? _validasiMenuE({
    required String pBangunanStr,
    required String lBangunanStr,
  }) {
    if (pBangunanStr.trim().isEmpty) return 'Panjang Bangunan wajib diisi.';
    if (lBangunanStr.trim().isEmpty) return 'Lebar Bangunan wajib diisi.';
    if ((double.tryParse(pBangunanStr.replaceAll(',', '.')) ?? 0) <= 0)
      return 'Panjang Bangunan harus lebih dari 0.';
    if ((double.tryParse(lBangunanStr.replaceAll(',', '.')) ?? 0) <= 0)
      return 'Lebar Bangunan harus lebih dari 0.';
    return null;
  }

  String? _validasiMenuF({
    required String jmlLampuStr,
    required String jmlSaklar1Str,
    required String jmlSaklar2Str,
    required String jmlStopKontakStr,
  }) {
    if (jmlLampuStr.trim().isEmpty) return 'Jumlah Lampu LED wajib diisi.';
    if (jmlSaklar1Str.trim().isEmpty)
      return 'Jumlah Saklar Tunggal wajib diisi.';
    if (jmlSaklar2Str.trim().isEmpty) return 'Jumlah Saklar Ganda wajib diisi.';
    if (jmlStopKontakStr.trim().isEmpty)
      return 'Jumlah Stop Kontak wajib diisi.';
    if ((int.tryParse(jmlLampuStr) ?? -1) < 0)
      return 'Jumlah Lampu tidak boleh negatif.';
    if ((int.tryParse(jmlSaklar1Str) ?? -1) < 0)
      return 'Jumlah Saklar Tunggal tidak boleh negatif.';
    if ((int.tryParse(jmlSaklar2Str) ?? -1) < 0)
      return 'Jumlah Saklar Ganda tidak boleh negatif.';
    if ((int.tryParse(jmlStopKontakStr) ?? -1) < 0)
      return 'Jumlah Stop Kontak tidak boleh negatif.';
    return null;
  }

  // debug prin di terminal IDE

  void _debugCetakHasilA() {
    if (_hasilMenuA == null) return;
    final h = _hasilMenuA!;
    debugPrint('╔══════════════════════════════════════╗');
    debugPrint('║        HASIL MENU A - PONDASI        ║');
    debugPrint('╠══════════════════════════════════════╣');
    debugPrint(
      '║ A.1  volBersih          : ${h.volBersih.toStringAsFixed(3)} m2',
    );
    debugPrint(
      '║ A.2  volBouwplank       : ${h.volBouwplank.toStringAsFixed(3)} m\'',
    );
    debugPrint(
      '║ A.3  volGalianMenerus   : ${h.volGalianMenerus.toStringAsFixed(3)} m3',
    );
    debugPrint(
      '║ A.4  volPasirMenerus    : ${h.volPasirMenerus.toStringAsFixed(3)} m3',
    );
    debugPrint(
      '║ A.5  volAanstampMenerus : ${h.volAanstampMenerus.toStringAsFixed(3)} m3',
    );
    debugPrint(
      '║ A.6  volBatuKali        : ${h.volBatuKali.toStringAsFixed(3)} m3',
    );
    debugPrint(
      '║ A.7  volGalianTapak     : ${h.volGalianTapak.toStringAsFixed(3)} m3',
    );
    debugPrint(
      '║ A.8  volPasirTapak      : ${h.volPasirTapak.toStringAsFixed(3)} m3',
    );
    debugPrint(
      '║ A.9  volAanstampTapak   : ${h.volAanstampTapak.toStringAsFixed(3)} m3',
    );
    debugPrint(
      '║ A.10 volBetonTapak      : ${h.volBetonTapak.toStringAsFixed(3)} m3',
    );
    debugPrint(
      '║ A.11 volUrugMenerus     : ${h.volUrugMenerus.toStringAsFixed(3)} m3',
    );
    debugPrint(
      '║ A.12 volUrugTapak       : ${h.volUrugTapak.toStringAsFixed(3)} m3',
    );
    debugPrint('╚══════════════════════════════════════╝');
  }

  void _debugCetakHasilB() {
    if (_hasilMenuB == null) return;
    final h = _hasilMenuB!;
    debugPrint('╔══════════════════════════════════════╗');
    debugPrint('║    HASIL MENU B - STRUKTUR DINDING   ║');
    debugPrint('╠══════════════════════════════════════╣');
    debugPrint('║ B.1 volSloof     : ${h.volSloof.toStringAsFixed(3)} m3');
    debugPrint('║ B.2 volKolom     : ${h.volKolom.toStringAsFixed(3)} m3');
    debugPrint('║ B.3 volRingBalok : ${h.volRingBalok.toStringAsFixed(3)} m3');
    debugPrint('║ B.4 volDinding   : ${h.volDinding.toStringAsFixed(3)} m2');
    debugPrint('║ B.5 volPlester   : ${h.volPlester.toStringAsFixed(3)} m2');
    debugPrint('║ B.5 volAcian     : ${h.volAcian.toStringAsFixed(3)} m2');
    debugPrint('╚══════════════════════════════════════╝');
  }

  void _debugCetakHasilC() {
    if (_hasilMenuC == null) return;
    final h = _hasilMenuC!;
    debugPrint('╔══════════════════════════════════════╗');
    debugPrint('║   HASIL MENU C - LANTAI & TIMBUNAN   ║');
    debugPrint('╠══════════════════════════════════════╣');
    debugPrint('║ luasLantai         : ${h.luasLantai.toStringAsFixed(3)} m2');
    debugPrint('║ C.1 volTimbunan    : ${h.volTimbunan.toStringAsFixed(3)} m3');
    debugPrint(
      '║ C.2 volPasirLantai : ${h.volPasirLantai.toStringAsFixed(3)} m3',
    );
    debugPrint(
      '║ C.3 volCorLantai   : ${h.volCorLantai.toStringAsFixed(3)} m3',
    );
    debugPrint('║ C.4 volKeramik     : ${h.volKeramik.toStringAsFixed(3)} m2');
    debugPrint('╚══════════════════════════════════════╝');
  }

  void _debugCetakHasilD() {
    if (_hasilMenuD == null) return;
    final h = _hasilMenuD!;
    debugPrint('╔══════════════════════════════════════╗');
    debugPrint('║  HASIL MENU D - PINTU JENDELA KUNCI  ║');
    debugPrint('╠══════════════════════════════════════╣');
    debugPrint(
      '║ D.1 volKusenPintu     : ${h.volKusenPintu.toStringAsFixed(4)} m3',
    );
    debugPrint(
      '║ D.2 volDaunPintu      : ${h.volDaunPintu.toStringAsFixed(3)} m2',
    );
    debugPrint(
      '║ D.3 volKusenVentilasi : ${h.volKusenVentilasi.toStringAsFixed(4)} m3',
    );
    debugPrint('║ D.4 jmlKunci          : ${h.jmlKunci} buah');
    debugPrint('║ D.5 jmlEngselPintu    : ${h.jmlEngselPintu} buah');
    debugPrint(
      '║ D.6 volKusenJendela   : ${h.volKusenJendela.toStringAsFixed(4)} m3',
    );
    debugPrint(
      '║ D.7 volDaunJendela    : ${h.volDaunJendela.toStringAsFixed(3)} m2',
    );
    debugPrint('║ D.8 volKaca           : ${h.volKaca.toStringAsFixed(4)} m2');
    debugPrint('║ D.9 jmlEngselJendela  : ${h.jmlEngselJendela} buah');
    debugPrint(
      '║ D.X volKusenTotal     : ${h.volKusenTotal.toStringAsFixed(4)} m3',
    );
    debugPrint('╚══════════════════════════════════════╝');
  }

  void _debugCetakHasilE() {
    if (_hasilMenuE == null) return;
    final h = _hasilMenuE!;
    debugPrint('╔══════════════════════════════════════╗');
    debugPrint('║     HASIL MENU E - ATAP & PLAFON     ║');
    debugPrint('╠══════════════════════════════════════╣');
    debugPrint('║ E.1 volPlafon     : ${h.volPlafon.toStringAsFixed(3)} m2');
    debugPrint(
      '║ E.2 volListPlafon : ${h.volListPlafon.toStringAsFixed(3)} m\'',
    );
    debugPrint(
      '║ E.3 volRangkaAtap : ${h.volRangkaAtap.toStringAsFixed(3)} m2',
    );
    debugPrint('║ E.4 volGenteng    : ${h.volGenteng.toStringAsFixed(3)} m2');
    debugPrint(
      '║ E.5 volListplank  : ${h.volListplank.toStringAsFixed(3)} m\'',
    );
    debugPrint('║ E.6 volNok        : ${h.volNok.toStringAsFixed(3)} m\'');
    debugPrint('╚══════════════════════════════════════╝');
  }

  void _debugCetakHasilF() {
    if (_hasilMenuF == null) return;
    final h = _hasilMenuF!;
    debugPrint('╔══════════════════════════════════════╗');
    debugPrint('║  HASIL MENU F - FINISHING & LISTRIK  ║');
    debugPrint('╠══════════════════════════════════════╣');
    debugPrint('║ F.1 volCatTembok  : ${h.volCatTembok.toStringAsFixed(3)} m2');
    debugPrint('║ F.2 volCatPlafon  : ${h.volCatPlafon.toStringAsFixed(3)} m2');
    debugPrint('║ F.3 volCatKayu    : ${h.volCatKayu.toStringAsFixed(3)} m2');
    debugPrint('║ F.4 volLampu      : ${h.volLampu} buah');
    debugPrint('║ F.5 volSaklar1    : ${h.volSaklar1} buah');
    debugPrint('║ F.6 volSaklar2    : ${h.volSaklar2} buah');
    debugPrint('║ F.7 volStopKontak : ${h.volStopKontak} buah');
    debugPrint('╚══════════════════════════════════════╝');
  }

  void _debugCetakHasilG() {
    if (_hasilMenuG == null) return;
    final h = _hasilMenuG!;
    debugPrint('╔══════════════════════════════════════╗');
    debugPrint('║      HASIL MENU G - ESTIMASI UPAH    ║');
    debugPrint('╠══════════════════════════════════════╣');
    debugPrint(
      '║ totalOhPekerja    : ${h.totalOhPekerja.toStringAsFixed(2)} OH',
    );
    debugPrint(
      '║ totalOhTukang     : ${h.totalOhTukang.toStringAsFixed(2)} OH',
    );
    debugPrint(
      '║ totalOhMandor     : ${h.totalOhMandor.toStringAsFixed(2)} OH',
    );
    debugPrint(
      '║ biayaUpahPekerja  : Rp ${h.biayaUpahPekerja.toStringAsFixed(0)}',
    );
    debugPrint(
      '║ biayaUpahTukang   : Rp ${h.biayaUpahTukang.toStringAsFixed(0)}',
    );
    debugPrint(
      '║ biayaUpahMandor   : Rp ${h.biayaUpahMandor.toStringAsFixed(0)}',
    );
    debugPrint(
      '║ totalBiayaUpah    : Rp ${h.totalBiayaUpah.toStringAsFixed(0)}',
    );
    debugPrint('╠══════════════════════════════════════╣');
    if (_rekapMaterial != null) {
      debugPrint(
        '║ totalBiayaMaterial: Rp ${_rekapMaterial!.totalBiayaMaterial.toStringAsFixed(0)}',
      );
      final grandTotal = _rekapMaterial!.totalBiayaMaterial + h.totalBiayaUpah;
      debugPrint('║ GRAND TOTAL        : Rp ${grandTotal.toStringAsFixed(0)}');
    }
    debugPrint('╚══════════════════════════════════════╝');
  }

  // ── HELPER: MENU KOSONG UNTUK PARTIAL STATE ──────────────

  HasilMenuA _buatMenuAKosong() => HasilMenuA(
    volBersih: 0,
    volBouwplank: 0,
    volGalianMenerus: 0,
    volPasirMenerus: 0,
    volAanstampMenerus: 0,
    volBatuKali: 0,
    volGalianTapak: 0,
    volPasirTapak: 0,
    volAanstampTapak: 0,
    volBetonTapak: 0,
    volUrugMenerus: 0,
    volUrugTapak: 0,
    dihitungPada: DateTime.now(),
  );

  HasilMenuB _buatMenuBKosong() => HasilMenuB(
    volSloof: 0,
    volKolom: 0,
    volRingBalok: 0,
    volDinding: 0,
    volPlester: 0,
    volAcian: 0,
    dihitungPada: DateTime.now(),
  );

  HasilMenuC _buatMenuCKosong() => HasilMenuC(
    luasLantai: 0,
    volTimbunan: 0,
    volPasirLantai: 0,
    volCorLantai: 0,
    volKeramik: 0,
    dihitungPada: DateTime.now(),
  );

  HasilMenuD _buatMenuDKosong() => HasilMenuD(
    volKusenPintu: 0,
    volDaunPintu: 0,
    volKusenVentilasi: 0,
    jmlKunci: 0,
    jmlEngselPintu: 0,
    volKusenJendela: 0,
    volDaunJendela: 0,
    volKaca: 0,
    jmlEngselJendela: 0,
    volKusenTotal: 0,
    dihitungPada: DateTime.now(),
  );

  HasilMenuE _buatMenuEKosong() => HasilMenuE(
    volPlafon: 0,
    volListPlafon: 0,
    volRangkaAtap: 0,
    volGenteng: 0,
    volListplank: 0,
    volNok: 0,
    dihitungPada: DateTime.now(),
  );

  HasilMenuF _buatMenuFKosong() => HasilMenuF(
    volCatTembok: 0,
    volCatPlafon: 0,
    volCatKayu: 0,
    volLampu: 0,
    volSaklar1: 0,
    volSaklar2: 0,
    volStopKontak: 0,
    dihitungPada: DateTime.now(),
  );
}
