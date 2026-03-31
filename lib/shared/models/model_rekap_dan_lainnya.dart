import 'package:cloud_firestore/cloud_firestore.dart';

/// rekapitulasi total kebutuhan material berdasarkan koefisien ahsp
class RekapMaterial {

  // material tanah dan batuan
  final double tanahTimbun_m3;
  final double batuKali_m3;
  final double kerikil_kg;

  // material pasir
  final double pasirUrug_m3;
  final double pasirPasang_m3;
  final double pasirBeton_kg;

  // material semen dan bata
  final double semen_kg;
  final double bataMerah_buah;

  // material besi dan baja profil
  final double besiPolos_kg;
  final double hollow4x4_batang;
  final double hollow2x4_batang;
  final double profilC75_m;
  final double rengBaja_m;

  // material kayu konstruksi
  final double kayuBalok57_m3;
  final double papanBekisting_m2;
  final double balkKayuKelas1_m3;
  final double balkKayuKelas2_m3;
  final double papanKayuKelas2_m3;
  final double papanListplank_m3;

  // material atap dan plafon
  final double gentengGalvalum_m2;
  final double nokGalvalum_m;
  final double papanGypsum_lembar;
  final double listProfilKayu_m;

  // material kaca dan aksesoris pintu/jendela
  final double kaca5mm_m2;
  final double kunciPintu_buah;
  final double engselPintu_buah;
  final double engselJendela_buah;

  // material lantai
  final double keramik40x40_buah;

  // material finishing dan pengecatan
  final double plamirTembok_kg;
  final double catDasarTembok_kg;
  final double catTembok_kg;
  final double catMenie_kg;
  final double plamirKayu_kg;
  final double catDasarKayu_kg;
  final double catKayu_kg;

  // komponen instalasi listrik
  final double lampuLed_buah;
  final double saklarTunggal_buah;
  final double saklarGanda_buah;
  final double stopKontak_buah;

  final double totalBiayaMaterial;
  final DateTime dihitungPada;

  // === TAMBAHAN BARU: RINCIAN BIAYA UNTUK UI ===
  final double biayaPasirPondasi;
  final double biayaAanstamping;
  final double biayaBatuKali;
  final double biayaBetonTapak;
  final double biayaBesi;
  final double biayaDinding;
  final double biayaSemenPlester;
  final double biayaTanahTimbun;
  final double biayaKeramik;
  final double biayaKusen;
  final double biayaDaunPintu;
  final double biayaDaunJendela;
  final double biayaKaca;
  final double biayaKunci;
  final double biayaEngsel;
  final double biayaRangkaPlafon;
  final double biayaGypsum;
  final double biayaListPlafon;
  final double biayaAtap;
  final double biayaListplank;
  final double biayaCatTembok;
  final double biayaCatKayu;
  final double biayaListrik;

  const RekapMaterial({
    required this.tanahTimbun_m3, required this.batuKali_m3, required this.kerikil_kg,
    required this.pasirUrug_m3, required this.pasirPasang_m3, required this.pasirBeton_kg,
    required this.semen_kg, required this.bataMerah_buah, required this.besiPolos_kg,
    required this.hollow4x4_batang, required this.hollow2x4_batang, required this.profilC75_m,
    required this.rengBaja_m, required this.kayuBalok57_m3, required this.papanBekisting_m2,
    required this.balkKayuKelas1_m3, required this.balkKayuKelas2_m3, required this.papanKayuKelas2_m3,
    required this.papanListplank_m3, required this.gentengGalvalum_m2, required this.nokGalvalum_m,
    required this.papanGypsum_lembar, required this.listProfilKayu_m, required this.kaca5mm_m2,
    required this.kunciPintu_buah, required this.engselPintu_buah, required this.engselJendela_buah,
    required this.keramik40x40_buah, required this.plamirTembok_kg, required this.catDasarTembok_kg,
    required this.catTembok_kg, required this.catMenie_kg, required this.plamirKayu_kg,
    required this.catDasarKayu_kg, required this.catKayu_kg, required this.lampuLed_buah,
    required this.saklarTunggal_buah, required this.saklarGanda_buah, required this.stopKontak_buah,
    required this.totalBiayaMaterial, required this.dihitungPada,
    
    // Rincian
    required this.biayaPasirPondasi, required this.biayaAanstamping, required this.biayaBatuKali,
    required this.biayaBetonTapak, required this.biayaBesi, required this.biayaDinding,
    required this.biayaSemenPlester, required this.biayaTanahTimbun, required this.biayaKeramik,
    required this.biayaKusen, required this.biayaDaunPintu, required this.biayaDaunJendela,
    required this.biayaKaca, required this.biayaKunci, required this.biayaEngsel,
    required this.biayaRangkaPlafon, required this.biayaGypsum, required this.biayaListPlafon,
    required this.biayaAtap, required this.biayaListplank, required this.biayaCatTembok,
    required this.biayaCatKayu, required this.biayaListrik,
  });

  factory RekapMaterial.dariFirestore(Map<String, dynamic> d) {
    double g(String k) => (d[k] as num?)?.toDouble() ?? 0.0;
    return RekapMaterial(
      tanahTimbun_m3: g('tanahTimbun_m3'), batuKali_m3: g('batuKali_m3'), kerikil_kg: g('kerikil_kg'),
      pasirUrug_m3: g('pasirUrug_m3'), pasirPasang_m3: g('pasirPasang_m3'), pasirBeton_kg: g('pasirBeton_kg'),
      semen_kg: g('semen_kg'), bataMerah_buah: g('bataMerah_buah'), besiPolos_kg: g('besiPolos_kg'),
      hollow4x4_batang: g('hollow4x4_batang'), hollow2x4_batang: g('hollow2x4_batang'), profilC75_m: g('profilC75_m'),
      rengBaja_m: g('rengBaja_m'), kayuBalok57_m3: g('kayuBalok57_m3'), papanBekisting_m2: g('papanBekisting_m2'),
      balkKayuKelas1_m3: g('balkKayuKelas1_m3'), balkKayuKelas2_m3: g('balkKayuKelas2_m3'), papanKayuKelas2_m3: g('papanKayuKelas2_m3'),
      papanListplank_m3: g('papanListplank_m3'), gentengGalvalum_m2: g('gentengGalvalum_m2'), nokGalvalum_m: g('nokGalvalum_m'),
      papanGypsum_lembar: g('papanGypsum_lembar'), listProfilKayu_m: g('listProfilKayu_m'), kaca5mm_m2: g('kaca5mm_m2'),
      kunciPintu_buah: g('kunciPintu_buah'), engselPintu_buah: g('engselPintu_buah'), engselJendela_buah: g('engselJendela_buah'),
      keramik40x40_buah: g('keramik40x40_buah'), plamirTembok_kg: g('plamirTembok_kg'), catDasarTembok_kg: g('catDasarTembok_kg'),
      catTembok_kg: g('catTembok_kg'), catMenie_kg: g('catMenie_kg'), plamirKayu_kg: g('plamirKayu_kg'),
      catDasarKayu_kg: g('catDasarKayu_kg'), catKayu_kg: g('catKayu_kg'), lampuLed_buah: g('lampuLed_buah'),
      saklarTunggal_buah: g('saklarTunggal_buah'), saklarGanda_buah: g('saklarGanda_buah'), stopKontak_buah: g('stopKontak_buah'),
      totalBiayaMaterial: g('totalBiayaMaterial'), dihitungPada: (d['dihitung_pada'] as Timestamp).toDate(),
      biayaPasirPondasi: g('biayaPasirPondasi'), biayaAanstamping: g('biayaAanstamping'), biayaBatuKali: g('biayaBatuKali'),
      biayaBetonTapak: g('biayaBetonTapak'), biayaBesi: g('biayaBesi'), biayaDinding: g('biayaDinding'),
      biayaSemenPlester: g('biayaSemenPlester'), biayaTanahTimbun: g('biayaTanahTimbun'), biayaKeramik: g('biayaKeramik'),
      biayaKusen: g('biayaKusen'), biayaDaunPintu: g('biayaDaunPintu'), biayaDaunJendela: g('biayaDaunJendela'),
      biayaKaca: g('biayaKaca'), biayaKunci: g('biayaKunci'), biayaEngsel: g('biayaEngsel'),
      biayaRangkaPlafon: g('biayaRangkaPlafon'), biayaGypsum: g('biayaGypsum'), biayaListPlafon: g('biayaListPlafon'),
      biayaAtap: g('biayaAtap'), biayaListplank: g('biayaListplank'), biayaCatTembok: g('biayaCatTembok'),
      biayaCatKayu: g('biayaCatKayu'), biayaListrik: g('biayaListrik'),
    );
  }

  Map<String, dynamic> keFirestore() => {
        'tanahTimbun_m3': tanahTimbun_m3, 'batuKali_m3': batuKali_m3, 'kerikil_kg': kerikil_kg,
        'pasirUrug_m3': pasirUrug_m3, 'pasirPasang_m3': pasirPasang_m3, 'pasirBeton_kg': pasirBeton_kg,
        'semen_kg': semen_kg, 'bataMerah_buah': bataMerah_buah, 'besiPolos_kg': besiPolos_kg,
        'hollow4x4_batang': hollow4x4_batang, 'hollow2x4_batang': hollow2x4_batang, 'profilC75_m': profilC75_m,
        'rengBaja_m': rengBaja_m, 'kayuBalok57_m3': kayuBalok57_m3, 'papanBekisting_m2': papanBekisting_m2,
        'balkKayuKelas1_m3': balkKayuKelas1_m3, 'balkKayuKelas2_m3': balkKayuKelas2_m3, 'papanKayuKelas2_m3': papanKayuKelas2_m3,
        'papanListplank_m3': papanListplank_m3, 'gentengGalvalum_m2': gentengGalvalum_m2, 'nokGalvalum_m': nokGalvalum_m,
        'papanGypsum_lembar': papanGypsum_lembar, 'listProfilKayu_m': listProfilKayu_m, 'kaca5mm_m2': kaca5mm_m2,
        'kunciPintu_buah': kunciPintu_buah, 'engselPintu_buah': engselPintu_buah, 'engselJendela_buah': engselJendela_buah,
        'keramik40x40_buah': keramik40x40_buah, 'plamirTembok_kg': plamirTembok_kg, 'catDasarTembok_kg': catDasarTembok_kg,
        'catTembok_kg': catTembok_kg, 'catMenie_kg': catMenie_kg, 'plamirKayu_kg': plamirKayu_kg,
        'catDasarKayu_kg': catDasarKayu_kg, 'catKayu_kg': catKayu_kg, 'lampuLed_buah': lampuLed_buah,
        'saklarTunggal_buah': saklarTunggal_buah, 'saklarGanda_buah': saklarGanda_buah, 'stopKontak_buah': stopKontak_buah,
        'totalBiayaMaterial': totalBiayaMaterial, 'dihitung_pada': Timestamp.fromDate(dihitungPada),
        'biayaPasirPondasi': biayaPasirPondasi, 'biayaAanstamping': biayaAanstamping, 'biayaBatuKali': biayaBatuKali,
        'biayaBetonTapak': biayaBetonTapak, 'biayaBesi': biayaBesi, 'biayaDinding': biayaDinding,
        'biayaSemenPlester': biayaSemenPlester, 'biayaTanahTimbun': biayaTanahTimbun, 'biayaKeramik': biayaKeramik,
        'biayaKusen': biayaKusen, 'biayaDaunPintu': biayaDaunPintu, 'biayaDaunJendela': biayaDaunJendela,
        'biayaKaca': biayaKaca, 'biayaKunci': biayaKunci, 'biayaEngsel': biayaEngsel,
        'biayaRangkaPlafon': biayaRangkaPlafon, 'biayaGypsum': biayaGypsum, 'biayaListPlafon': biayaListPlafon,
        'biayaAtap': biayaAtap, 'biayaListplank': biayaListplank, 'biayaCatTembok': biayaCatTembok,
        'biayaCatKayu': biayaCatKayu, 'biayaListrik': biayaListrik,
      };
}

class HargaMaterial {
  final String id; final String nama; final String satuan; final double hargaSatuan;
  final String diperbaruidOleh; final DateTime diperbaruidPada;
  const HargaMaterial({required this.id, required this.nama, required this.satuan, required this.hargaSatuan, required this.diperbaruidOleh, required this.diperbaruidPada});
  factory HargaMaterial.dariFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return HargaMaterial(id: doc.id, nama: d['nama'] as String, satuan: d['satuan'] as String, hargaSatuan: (d['harga_satuan'] as num).toDouble(), diperbaruidOleh: d['diperbarui_oleh'] as String? ?? '', diperbaruidPada: (d['diperbarui_pada'] as Timestamp).toDate());
  }
  Map<String, dynamic> keFirestore() => {'id': id, 'nama': nama, 'satuan': satuan, 'harga_satuan': hargaSatuan, 'diperbarui_oleh': diperbaruidOleh, 'diperbarui_pada': Timestamp.fromDate(diperbaruidPada)};
}

class HargaUpah {
  final double pekerja; final double tukang; final double mandor;
  final String diperbaruidOleh; final DateTime diperbaruidPada;
  const HargaUpah({required this.pekerja, required this.tukang, required this.mandor, required this.diperbaruidOleh, required this.diperbaruidPada});
  factory HargaUpah.dariFirestore(Map<String, dynamic> d) {
    return HargaUpah(pekerja: (d['pekerja'] as num).toDouble(), tukang: (d['tukang'] as num).toDouble(), mandor: (d['mandor'] as num).toDouble(), diperbaruidOleh: d['diperbarui_oleh'] as String? ?? '', diperbaruidPada: (d['diperbarui_pada'] as Timestamp).toDate());
  }
  Map<String, dynamic> keFirestore() => {'pekerja': pekerja, 'tukang': tukang, 'mandor': mandor, 'diperbarui_oleh': diperbaruidOleh, 'diperbarui_pada': Timestamp.fromDate(diperbaruidPada)};
}

class LogHistori {
  final String id; final String idProyek; final String idPengguna; final String namaAksi; final String detail; final DateTime dibuatPada;
  const LogHistori({required this.id, required this.idProyek, required this.idPengguna, required this.namaAksi, required this.detail, required this.dibuatPada});
  factory LogHistori.dariFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return LogHistori(id: doc.id, idProyek: d['id_proyek'] as String, idPengguna: d['id_pengguna'] as String, namaAksi: d['nama_aksi'] as String, detail: d['detail'] as String? ?? '', dibuatPada: (d['dibuat_pada'] as Timestamp).toDate());
  }
  Map<String, dynamic> keFirestore() => {'id_proyek': idProyek, 'id_pengguna': idPengguna, 'nama_aksi': namaAksi, 'detail': detail, 'dibuat_pada': Timestamp.fromDate(dibuatPada)};
}