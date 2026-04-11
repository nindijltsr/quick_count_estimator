import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/model_rekap_dan_lainnya.dart';

class LayananMasterHarga {
  final FirebaseFirestore _db;

  LayananMasterHarga({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  // referensi koleksi harga material
  CollectionReference<Map<String, dynamic>> get _refHargaMaterial =>
      _db.collection('master_harga').doc('harga_material').collection('item');

  // referensi dokumen harga upah
  DocumentReference<Map<String, dynamic>> get _refHargaUpah =>
      _db.collection('master_harga').doc('harga_upah');

  // mengambil seluruh data harga material dalam bentuk map
  Future<Map<String, double>> ambilSemuaHargaMaterial() async {
    final snapshot = await _refHargaMaterial.get();
    final Map<String, double> hasil = {};
    for (final doc in snapshot.docs) {
      hasil[doc.id] = (doc.data()['harga_satuan'] as num).toDouble();
    }
    return hasil;
  }

  // mengambil data harga material tunggal berdasarkan id
  Future<HargaMaterial?> ambilHargaMaterial(String id) async {
    final doc = await _refHargaMaterial.doc(id).get();
    if (!doc.exists) return null;
    return HargaMaterial.dariFirestore(doc);
  }

  // aliran data real-time seluruh harga material untuk dashboard admin
  Stream<List<HargaMaterial>> streamSemuaHargaMaterial() {
    return _refHargaMaterial.orderBy('nama').snapshots().map(
          (snap) => snap.docs.map((d) => HargaMaterial.dariFirestore(d)).toList(),
        );
  }

  // pembaruan atau pembuatan data harga material baru
  Future<void> simpanHargaMaterial(HargaMaterial harga) async {
    await _refHargaMaterial.doc(harga.id).set(harga.keFirestore());
  }

  // mengambil data harga upah tenaga kerja (pekerja, tukang, mandor)
  Future<HargaUpah?> ambilHargaUpah() async {
    final doc = await _refHargaUpah.get();
    if (!doc.exists || doc.data() == null) return null;
    return HargaUpah.dariFirestore(doc.data()!);
  }

  // aliran data real-time harga upah tenaga kerja
  Stream<HargaUpah?> streamHargaUpah() {
    return _refHargaUpah.snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return HargaUpah.dariFirestore(doc.data()!);
    });
  }

  // pembaruan data harga upah tenaga kerja
  Future<void> simpanHargaUpah(HargaUpah upah) async {
    await _refHargaUpah.set(upah.keFirestore());
  }

  // inisialisasi data awal (seed) untuk keperluan pengujian sistem
  Future<void> seedDataDummy(String idAdmin) async {
    final batch = _db.batch();
    final sekarang = DateTime.now();

    // inisialisasi batch 39 data material
    final daftarMaterial = _daftarHargaDummy(idAdmin, sekarang);
    for (final m in daftarMaterial) {
      batch.set(_refHargaMaterial.doc(m.id), m.keFirestore());
    }

    // inisialisasi data upah standar
    final upah = HargaUpah(
      pekerja: 97000,
      tukang: 110000,
      mandor: 115000,
      diperbaruidOleh: idAdmin,
      diperbaruidPada: sekarang,
    );
    batch.set(_refHargaUpah, upah.keFirestore());

    await batch.commit();
  }

  // daftar konstanta harga material untuk data dummy
  List<HargaMaterial> _daftarHargaDummy(String idAdmin, DateTime waktu) {
    HargaMaterial h(String id, String nama, String satuan, double harga) =>
        HargaMaterial(
          id: id,
          nama: nama,
          satuan: satuan,
          hargaSatuan: harga,
          diperbaruidOleh: idAdmin,
          diperbaruidPada: waktu,
        );

    return [
      // kategori tanah dan batuan
      h('tanah_timbun', 'Tanah Timbun', 'm3', 127000),
      h('batu_kali', 'Batu Kali', 'm3', 255000),
      h('kerikil', 'Kerikil', 'kg', 600),

      // kategori pasir
      h('pasir_urug', 'Pasir Urug', 'm3', 220000),
      h('pasir_pasang', 'Pasir Pasang', 'm3', 260000),
      h('pasir_beton', 'Pasir Beton', 'kg', 350),

      // kategori semen dan bata
      h('semen_pc', 'Semen (PC)', 'kg', 1500),
      h('bata_merah', 'Bata Merah', 'buah', 1000),

      // kategori besi dan logam konstruksi
      h('besi_polos', 'Besi Polos (Tulangan)', 'kg', 12500),
      h('hollow_4x4', 'Besi Hollow 4x4 cm', 'batang', 85000),
      h('hollow_2x4', 'Besi Hollow 2x4 cm', 'batang', 65000),
      h('profil_c75', 'Profil Baja Ringan C-75', 'm\'', 28000),
      h('reng_baja', 'Reng Baja Ringan', 'm\'', 15000),

      // kategori kayu dan bekisting
      h('kayu_balok_57', 'Kayu Balok 5/7 (Patok)', 'm3', 4500000),
      h('papan_bekisting', 'Papan Bekisting 2/20', 'm2', 55000),
      h('balok_kayu_kelas1', 'Balok Kayu Kelas I (Kusen)', 'm3', 9000000),
      h('balok_kayu_kelas2', 'Balok Kayu Kelas II (Daun Pintu)', 'm3', 6500000),
      h('papan_kayu_kelas2', 'Papan Kayu Kelas II (Daun Jendela)', 'm3', 6500000),
      h('papan_listplank', 'Papan Listplank 2.5/25 cm', 'm\'', 35000),

      // kategori atap dan plafon
      h('genteng_galvalum', 'Genteng Galvalum (Metal)', 'm2', 75000),
      h('nok_galvalum', 'Nok/Bubungan Galvalum', 'm\'', 45000),
      h('papan_gypsum', 'Papan Gypsum 9mm', 'lembar', 85000),
      h('list_profil_kayu', 'List Profil Kayu', 'm\'', 18000),

      // kategori kaca dan aksesoris pintu/jendela
      h('kaca_5mm', 'Kaca Polos 5mm', 'm2', 90000),
      h('kunci_pintu', 'Kunci Pintu Silinder', 'buah', 120000),
      h('engsel_pintu', 'Engsel Pintu', 'buah', 25000),
      h('engsel_jendela', 'Engsel Jendela', 'buah', 20000),

      // kategori lantai
      h('keramik_40x40', 'Keramik 40x40 cm', 'buah', 8500),

      // kategori pengecatan dan finishing
      h('plamir_tembok', 'Plamir Tembok', 'kg', 18000),
      h('cat_dasar_tembok', 'Cat Dasar Tembok', 'kg', 22000),
      h('cat_tembok', 'Cat Tembok (Warna)', 'kg', 45000),
      h('cat_menie', 'Cat Menie Kayu', 'kg', 35000),
      h('plamir_kayu', 'Plamir Kayu', 'kg', 28000),
      h('cat_dasar_kayu', 'Cat Dasar Kayu', 'kg', 40000),
      h('cat_kayu', 'Cat Kayu/Gloss', 'kg', 55000),

      // kategori komponen listrik
      h('lampu_led_18w', 'Lampu LED 18 Watt', 'buah', 35000),
      h('saklar_tunggal', 'Saklar Tunggal', 'buah', 25000),
      h('saklar_ganda', 'Saklar Ganda', 'buah', 35000),
      h('stop_kontak', 'Stop Kontak', 'buah', 30000),
    ];
  }
}