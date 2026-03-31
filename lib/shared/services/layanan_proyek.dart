import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/model_input_surveyor.dart';
import '../models/model_hasil_perhitungan.dart';
import '../models/model_rekap_dan_lainnya.dart';

class _NamaKoleksi {
  static const inputUser = 'inputUser';
  static const hasilPerhitungan = 'hasil_perhitungan';
  static const rekapAkhir = 'rekap_akhir';
}

class _NamaDokumen {
  static const data = 'data';
  static const material = 'material';

  static const menuA = 'persiapan_tanah_pondasi';
  static const menuB = 'struktur_dan_dinding';
  static const menuC = 'lantai_dan_timbunan';
  static const menuD = 'pintu_jendela_pengunci';
  static const menuE = 'atap_dan_plafon';
  static const menuF = 'finishing_cat_listrik';
  static const menuG = 'estimasi_upah';
}

class LayananProyek {
  final FirebaseFirestore _db;

  LayananProyek({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _refInputUser(String idProyek) =>
      _db.collection('projects')
          .doc(idProyek)
          .collection(_NamaKoleksi.inputUser)
          .doc(_NamaDokumen.data);

  DocumentReference<Map<String, dynamic>> _refHasilMenu(
          String idProyek, String namaMenu) =>
      _db.collection('projects')
          .doc(idProyek)
          .collection(_NamaKoleksi.hasilPerhitungan)
          .doc(namaMenu);

  DocumentReference<Map<String, dynamic>> _refRekapMaterial(
          String idProyek) =>
      _db.collection('projects')
          .doc(idProyek)
          .collection(_NamaKoleksi.rekapAkhir)
          .doc(_NamaDokumen.material);

  DocumentReference<Map<String, dynamic>> _refProyek(String idProyek) =>
      _db.collection('projects').doc(idProyek);

  // penyimpanan data input pengguna 

  Future<void> simpanInputSurveyor(InputSurveyor input) async {
    await _refInputUser(input.idProyek).set(
      input.keFirestore(),
      SetOptions(merge: true),
    );
  }

  // pengambilan data input pengguna 

  Future<InputSurveyor?> ambilInputSurveyor(String idProyek) async {
    final doc = await _refInputUser(idProyek).get();
    if (!doc.exists) return null;
    return InputSurveyor.dariFirestore(doc);
  }

  // penyimpanan hasil kalkulasi per modul (iteratif)

  Future<void> simpanHasilMenuA(String idProyek, HasilMenuA hasil) async {
    await _refHasilMenu(idProyek, _NamaDokumen.menuA).set(hasil.keFirestore());
    await _tandaiStatusProyek(idProyek);
  }

  Future<void> simpanHasilMenuB(String idProyek, HasilMenuB hasil) async {
    await _refHasilMenu(idProyek, _NamaDokumen.menuB).set(hasil.keFirestore());
    await _tandaiStatusProyek(idProyek);
  }

  Future<void> simpanHasilMenuC(String idProyek, HasilMenuC hasil) async {
    await _refHasilMenu(idProyek, _NamaDokumen.menuC).set(hasil.keFirestore());
    await _tandaiStatusProyek(idProyek);
  }

  Future<void> simpanHasilMenuD(String idProyek, HasilMenuD hasil) async {
    await _refHasilMenu(idProyek, _NamaDokumen.menuD).set(hasil.keFirestore());
    await _tandaiStatusProyek(idProyek);
  }

  Future<void> simpanHasilMenuE(String idProyek, HasilMenuE hasil) async {
    await _refHasilMenu(idProyek, _NamaDokumen.menuE).set(hasil.keFirestore());
    await _tandaiStatusProyek(idProyek);
  }

  Future<void> simpanHasilMenuF(String idProyek, HasilMenuF hasil) async {
    await _refHasilMenu(idProyek, _NamaDokumen.menuF).set(hasil.keFirestore());
    await _tandaiStatusProyek(idProyek);
  }

  // operasi batch penyimpanan data menyeluruh 

  Future<void> simpanSemuaHasil({
    required String idProyek,
    required HasilMenuA menuA,
    required HasilMenuB menuB,
    required HasilMenuC menuC,
    required HasilMenuD menuD,
    required HasilMenuE menuE,
    required HasilMenuF menuF,
    required HasilMenuG menuG,
    required RekapMaterial rekap,
  }) async {
    final batch = _db.batch();

    batch.set(_refHasilMenu(idProyek, _NamaDokumen.menuA), menuA.keFirestore());
    batch.set(_refHasilMenu(idProyek, _NamaDokumen.menuB), menuB.keFirestore());
    batch.set(_refHasilMenu(idProyek, _NamaDokumen.menuC), menuC.keFirestore());
    batch.set(_refHasilMenu(idProyek, _NamaDokumen.menuD), menuD.keFirestore());
    batch.set(_refHasilMenu(idProyek, _NamaDokumen.menuE), menuE.keFirestore());
    batch.set(_refHasilMenu(idProyek, _NamaDokumen.menuF), menuF.keFirestore());
    batch.set(_refHasilMenu(idProyek, _NamaDokumen.menuG), menuG.keFirestore());
    batch.set(_refRekapMaterial(idProyek), rekap.keFirestore());

    batch.update(_refProyek(idProyek), {
      'status_perhitungan': 'selesai',
      'updated_at': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // pengambilan data hasil kalkulasi per modul

  Future<HasilMenuA?> ambilHasilMenuA(String idProyek) async {
    final doc = await _refHasilMenu(idProyek, _NamaDokumen.menuA).get();
    if (!doc.exists || doc.data() == null) return null;
    return HasilMenuA.dariFirestore(doc.data()!);
  }

  Future<HasilMenuB?> ambilHasilMenuB(String idProyek) async {
    final doc = await _refHasilMenu(idProyek, _NamaDokumen.menuB).get();
    if (!doc.exists || doc.data() == null) return null;
    return HasilMenuB.dariFirestore(doc.data()!);
  }

  Future<HasilMenuC?> ambilHasilMenuC(String idProyek) async {
    final doc = await _refHasilMenu(idProyek, _NamaDokumen.menuC).get();
    if (!doc.exists || doc.data() == null) return null;
    return HasilMenuC.dariFirestore(doc.data()!);
  }

  Future<HasilMenuD?> ambilHasilMenuD(String idProyek) async {
    final doc = await _refHasilMenu(idProyek, _NamaDokumen.menuD).get();
    if (!doc.exists || doc.data() == null) return null;
    return HasilMenuD.dariFirestore(doc.data()!);
  }

  Future<HasilMenuE?> ambilHasilMenuE(String idProyek) async {
    final doc = await _refHasilMenu(idProyek, _NamaDokumen.menuE).get();
    if (!doc.exists || doc.data() == null) return null;
    return HasilMenuE.dariFirestore(doc.data()!);
  }

  Future<HasilMenuF?> ambilHasilMenuF(String idProyek) async {
    final doc = await _refHasilMenu(idProyek, _NamaDokumen.menuF).get();
    if (!doc.exists || doc.data() == null) return null;
    return HasilMenuF.dariFirestore(doc.data()!);
  }

  Future<HasilMenuG?> ambilHasilMenuG(String idProyek) async {
    final doc = await _refHasilMenu(idProyek, _NamaDokumen.menuG).get();
    if (!doc.exists || doc.data() == null) return null;
    return HasilMenuG.dariFirestore(doc.data()!);
  }

  Future<RekapMaterial?> ambilRekapMaterial(String idProyek) async {
    final doc = await _refRekapMaterial(idProyek).get();
    if (!doc.exists || doc.data() == null) return null;
    return RekapMaterial.dariFirestore(doc.data()!);
  }

  // pemantauan real-time status proyek

  Stream<String> streamStatusPerhitungan(String idProyek) {
    return _refProyek(idProyek).snapshots().map((doc) {
      if (!doc.exists) return 'belum';
      return (doc.data()?['status_perhitungan'] as String?) ?? 'belum';
    });
  }

  // helper operasional internal

  Future<void> _tandaiStatusProyek(String idProyek) async {
    await _refProyek(idProyek).update({
      'status_perhitungan': 'sedang_berjalan',
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
}

// layanan manajemen log histori aktivitas 
class LayananHistori {
  final FirebaseFirestore _db;

  LayananHistori({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  // pencatatan aktivitas pengguna
  Future<void> catatAktivitas({
    required String idProyek,
    required String idPengguna,
    required String namaAksi,
    String detail = '',
  }) async {
    await _db.collection('riwayatAktivitas').add({
      'id_proyek': idProyek,
      'id_pengguna': idPengguna,
      'nama_aksi': namaAksi,
      'detail': detail,
      'dibuat_pada': FieldValue.serverTimestamp(),
    });
  }

  // aliran data real-time riwayat proyek
  Stream<List<LogHistori>> streamHistoriProyek(String idProyek) {
    return _db
        .collection('riwayatAktivitas')
        .where('id_proyek', isEqualTo: idProyek)
        .orderBy('dibuat_pada', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => LogHistori.dariFirestore(d)).toList());
  }
}