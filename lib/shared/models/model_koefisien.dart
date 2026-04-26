import 'package:cloud_firestore/cloud_firestore.dart';

/// Seluruh nilai koefisien material & OH yang bisa diedit admin.
/// Nilai di sini adalah fallback jika Firestore kosong.
/// Ref: layanan_perhitungan.dart — hitungMaterialDanUpah & hitungMenu*
class KoefisienAktif {
  // ── Koefisien Material (faktor kebutuhan per satuan volume) ──

  // Menu A — Pondasi
  final double matTanahTimbun;        // volTimbunan × 1.200
  final double matBatuKali;           // (aanstamp + batuKali) × 1.200
  final double matAanstampPasirUrug;  // volAanstamp × 0.432
  final double matPasirUrug;          // volPasir × 1.200
  final double matPasirPasangBatuKali;
  final double matPasirBeton;         // volBeton × 760
  final double matKerikilBeton;       // volBeton × 1029
  final double matKerikilLantai;      // volCorLantai × 999
  final double matPasirBetonLantai;   // volCorLantai × 869
  final double matSemenBatuKali;      // 163.0
  final double matSemenBeton;         // 326.0
  
  // Menu B - Dinding
  final double matSemenDinding;       // 11.5
  final double matSemenPlester;       // 6.24
  final double matSemenAcian;         // 3.25
  final double matSemenLantai;        // 247.0
  final double matSemenKeramik;       // 9.80
  final double matPasirPasangDinding; // 0.043
  final double matPasirPasangPlester; // 0.024
  final double matPasirPasangKeramik; // 0.045
  final double matBataMerah;          // 70.0
  final double matBesiSloof;          // 80.94
  final double matBesiKolom;          // 203.6
  final double matBesiRingBalok;      // 194.0

  // Menu C — Lantai
  final double matKeramik;            // volKeramik × 6.63

  // Menu D — Pintu & Jendela
  final double matBalkKayuKelas1;     // volKusenTotal × 1.100
  final double matBalkKayuKelas2;     // volDaunPintu × 0.040
  final double matPapanKayuKelas2;    // volDaunJendela × 0.024
  final double matKaca5mm;            // volKaca × 1.100

  // Menu E — Atap & Plafon
  final double matHollow4x4;          // volPlafon × 0.400
  final double matHollow2x4;          // volPlafon × 0.400
  final double matProfilC75;          // volRangkaAtap × 1.250
  final double matRengBaja;           // volRangkaAtap × 1.500
  final double matKayuBalok57;        // volBouwplank × 0.012
  final double matPapanBekisting1;    // volBouwplank × 0.007
  final double matPapanBekisting2;    // volSloof/Kolom/RingBalok × variatif
  final double matPapanBekistingSloof;
  final double matPapanBekistingKolom;
  final double matPapanBekistingRing;
  final double matPapanListplank;     // volListplank × 0.011
  final double matGentengGalvalum;    // volGenteng × 1.050
  final double matNokGalvalum;        // volNok × 1.050
  final double matPapanGypsum;        // volPlafon × 0.364
  final double matListProfilKayu;     // volListPlafon × 1.050

  // Menu F — Finishing
  final double matPlamirTembok;       // volCatTembokPlafon × 0.100
  final double matCatDasarTembok;     // × 0.100
  final double matCatTembok;          // × 0.260
  final double matCatMenie;           // volCatKayu × 0.200
  final double matPlamirKayu;         // × 0.150
  final double matCatDasarKayu;       // × 0.170
  final double matCatKayu;            // × 0.260

  // ── Koefisien OH Pekerja ──
  final double ohPekerjaBersih;
  final double ohPekerjaBouwplank;
  final double ohPekerjaGalian;
  final double ohPekerjaPasirUrug;
  final double ohPekerjaAanstamp;
  final double ohPekerjaBatuKali;
  final double ohPekerjaUrug;
  final double ohPekerjaBetonTapak;
  final double ohPekerjaSloof;
  final double ohPekerjaKolom;
  final double ohPekerjaRingBalok;
  final double ohPekerjaDinding;
  final double ohPekerjaPlester;
  final double ohPekerjaAcian;
  final double ohPekerjaTimbunan;
  final double ohPekerjaPasirLantai;
  final double ohPekerjaCorLantai;
  final double ohPekerjaKeramik;
  final double ohPekerjaKusen;
  final double ohPekerjaDaunPintu;
  final double ohPekerjaKunci;
  final double ohPekerjaEngselPintu;
  final double ohPekerjaDaunJendela;
  final double ohPekerjaKaca;
  final double ohPekerjaEngselJendela;
  final double ohPekerjaRangkaPlafon;
  final double ohPekerjaGypsum;
  final double ohPekerjaListPlafon;
  final double ohPekerjaRangkaAtap;
  final double ohPekerjaGenteng;
  final double ohPekerjaListplank;
  final double ohPekerjaNok;
  final double ohPekerjaCatTembok;
  final double ohPekerjaCatKayu;

  // ── Koefisien OH Tukang ──
  final double ohTukangBouwplank;
  final double ohTukangAanstamp;
  final double ohTukangBatuKali;
  final double ohTukangBetonTapak;
  final double ohTukangSloof;
  final double ohTukangKolom;
  final double ohTukangRingBalok;
  final double ohTukangDinding;
  final double ohTukangPlester;
  final double ohTukangAcian;
  final double ohTukangCorLantai;
  final double ohTukangKeramik;
  final double ohTukangKusen;
  final double ohTukangDaunPintu;
  final double ohTukangKunci;
  final double ohTukangEngselPintu;
  final double ohTukangDaunJendela;
  final double ohTukangKaca;
  final double ohTukangEngselJendela;
  final double ohTukangRangkaPlafon;
  final double ohTukangGypsum;
  final double ohTukangListPlafon;
  final double ohTukangRangkaAtap;
  final double ohTukangGenteng;
  final double ohTukangListplank;
  final double ohTukangNok;
  final double ohTukangCatTembok;
  final double ohTukangCatKayu;

  // ── Koefisien OH Mandor ──
  final double ohMandorBersih;
  final double ohMandorBouwplank;
  final double ohMandorGalian;
  final double ohMandorPasirUrug;
  final double ohMandorAanstamp;
  final double ohMandorBatuKali;
  final double ohMandorUrug;
  final double ohMandorBetonTapak;
  final double ohMandorSloof;
  final double ohMandorKolom;
  final double ohMandorRingBalok;
  final double ohMandorDinding;
  final double ohMandorPlester;
  final double ohMandorAcian;
  final double ohMandorTimbunan;
  final double ohMandorPasirLantai;
  final double ohMandorCorLantai;
  final double ohMandorKeramik;
  final double ohMandorKusen;
  final double ohMandorDaunPintu;
  final double ohMandorKunci;
  final double ohMandorEngselPintu;
  final double ohMandorDaunJendela;
  final double ohMandorKaca;
  final double ohMandorEngselJendela;
  final double ohMandorRangkaPlafon;
  final double ohMandorGypsum;
  final double ohMandorListPlafon;
  final double ohMandorRangkaAtap;
  final double ohMandorGenteng;
  final double ohMandorListplank;
  final double ohMandorNok;
  final double ohMandorCatTembok;
  final double ohMandorCatKayu;

  const KoefisienAktif({
    // Material
    this.matTanahTimbun = 1.200,
    this.matBatuKali = 1.200,
    this.matAanstampPasirUrug = 0.432,
    this.matPasirUrug = 1.200,
    this.matPasirPasangBatuKali = 0.520,
    this.matPasirBeton = 760.0,
    this.matKerikilBeton = 1029.0,
    this.matKerikilLantai = 999.0,
    this.matPasirBetonLantai = 869.0,
    this.matSemenBatuKali = 163.0,
    this.matSemenBeton = 326.0,
    this.matSemenDinding = 11.5,
    this.matSemenPlester = 6.24,
    this.matSemenAcian = 3.25,
    this.matSemenLantai = 247.0,
    this.matSemenKeramik = 9.80,
    this.matPasirPasangDinding = 0.043,
    this.matPasirPasangPlester = 0.024,
    this.matPasirPasangKeramik = 0.045,
    this.matBataMerah = 70.0,
    this.matBesiSloof = 80.94,
    this.matBesiKolom = 203.6,
    this.matBesiRingBalok = 194.0,
    this.matKeramik = 6.63,
    this.matBalkKayuKelas1 = 1.100,
    this.matBalkKayuKelas2 = 0.040,
    this.matPapanKayuKelas2 = 0.024,
    this.matKaca5mm = 1.100,
    this.matHollow4x4 = 0.400,
    this.matHollow2x4 = 0.400,
    this.matProfilC75 = 1.250,
    this.matRengBaja = 1.500,
    this.matKayuBalok57 = 0.012,
    this.matPapanBekisting1 = 0.007,
    this.matPapanBekisting2 = 0.0,
    this.matPapanBekistingSloof = 13.33,
    this.matPapanBekistingKolom = 15.4,
    this.matPapanBekistingRing = 13.33,
    this.matPapanListplank = 0.011,
    this.matGentengGalvalum = 1.050,
    this.matNokGalvalum = 1.050,
    this.matPapanGypsum = 0.364,
    this.matListProfilKayu = 1.050,
    this.matPlamirTembok = 0.100,
    this.matCatDasarTembok = 0.100,
    this.matCatTembok = 0.260,
    this.matCatMenie = 0.200,
    this.matPlamirKayu = 0.150,
    this.matCatDasarKayu = 0.170,
    this.matCatKayu = 0.260,
    // OH Pekerja
    this.ohPekerjaBersih = 0.100,
    this.ohPekerjaBouwplank = 0.100,
    this.ohPekerjaGalian = 0.750,
    this.ohPekerjaPasirUrug = 0.300,
    this.ohPekerjaAanstamp = 0.780,
    this.ohPekerjaBatuKali = 1.500,
    this.ohPekerjaUrug = 0.250,
    this.ohPekerjaBetonTapak = 1.650,
    this.ohPekerjaSloof = 1.650,
    this.ohPekerjaKolom = 1.650,
    this.ohPekerjaRingBalok = 1.650,
    this.ohPekerjaDinding = 0.300,
    this.ohPekerjaPlester = 0.300,
    this.ohPekerjaAcian = 0.200,
    this.ohPekerjaTimbunan = 0.300,
    this.ohPekerjaPasirLantai = 0.300,
    this.ohPekerjaCorLantai = 1.650,
    this.ohPekerjaKeramik = 0.700,
    this.ohPekerjaKusen = 7.000,
    this.ohPekerjaDaunPintu = 1.000,
    this.ohPekerjaKunci = 0.005,
    this.ohPekerjaEngselPintu = 0.015,
    this.ohPekerjaDaunJendela = 0.800,
    this.ohPekerjaKaca = 0.015,
    this.ohPekerjaEngselJendela = 0.015,
    this.ohPekerjaRangkaPlafon = 0.050,
    this.ohPekerjaGypsum = 0.100,
    this.ohPekerjaListPlafon = 0.050,
    this.ohPekerjaRangkaAtap = 0.200,
    this.ohPekerjaGenteng = 0.120,
    this.ohPekerjaListplank = 0.100,
    this.ohPekerjaNok = 0.150,
    this.ohPekerjaCatTembok = 0.020,
    this.ohPekerjaCatKayu = 0.070,
    // OH Tukang
    this.ohTukangBouwplank = 0.100,
    this.ohTukangAanstamp = 0.390,
    this.ohTukangBatuKali = 0.750,
    this.ohTukangBetonTapak = 0.275,
    this.ohTukangSloof = 0.275,
    this.ohTukangKolom = 0.275,
    this.ohTukangRingBalok = 0.275,
    this.ohTukangDinding = 0.100,
    this.ohTukangPlester = 0.150,
    this.ohTukangAcian = 0.100,
    this.ohTukangCorLantai = 0.275,
    this.ohTukangKeramik = 0.350,
    this.ohTukangKusen = 21.000,
    this.ohTukangDaunPintu = 3.000,
    this.ohTukangKunci = 0.500,
    this.ohTukangEngselPintu = 0.150,
    this.ohTukangDaunJendela = 2.400,
    this.ohTukangKaca = 0.150,
    this.ohTukangEngselJendela = 0.150,
    this.ohTukangRangkaPlafon = 0.050,
    this.ohTukangGypsum = 0.100,
    this.ohTukangListPlafon = 0.050,
    this.ohTukangRangkaAtap = 0.200,
    this.ohTukangGenteng = 0.060,
    this.ohTukangListplank = 0.200,
    this.ohTukangNok = 0.075,
    this.ohTukangCatTembok = 0.063,
    this.ohTukangCatKayu = 0.009,
    // OH Mandor
    this.ohMandorBersih = 0.050,
    this.ohMandorBouwplank = 0.005,
    this.ohMandorGalian = 0.025,
    this.ohMandorPasirUrug = 0.010,
    this.ohMandorAanstamp = 0.039,
    this.ohMandorBatuKali = 0.075,
    this.ohMandorUrug = 0.083,
    this.ohMandorBetonTapak = 0.083,
    this.ohMandorSloof = 0.083,
    this.ohMandorKolom = 0.083,
    this.ohMandorRingBalok = 0.083,
    this.ohMandorDinding = 0.015,
    this.ohMandorPlester = 0.015,
    this.ohMandorAcian = 0.010,
    this.ohMandorTimbunan = 0.010,
    this.ohMandorPasirLantai = 0.010,
    this.ohMandorCorLantai = 0.083,
    this.ohMandorKeramik = 0.035,
    this.ohMandorKusen = 0.350,
    this.ohMandorDaunPintu = 0.050,
    this.ohMandorKunci = 0.003,
    this.ohMandorEngselPintu = 0.0008,
    this.ohMandorDaunJendela = 0.040,
    this.ohMandorKaca = 0.0008,
    this.ohMandorEngselJendela = 0.0008,
    this.ohMandorRangkaPlafon = 0.003,
    this.ohMandorGypsum = 0.005,
    this.ohMandorListPlafon = 0.003,
    this.ohMandorRangkaAtap = 0.010,
    this.ohMandorGenteng = 0.006,
    this.ohMandorListplank = 0.005,
    this.ohMandorNok = 0.008,
    this.ohMandorCatTembok = 0.0025,
    this.ohMandorCatKayu = 0.003,
  });

  /// Buat dari Map Firestore. Field tidak ditemukan → pakai nilai default.
  factory KoefisienAktif.dariFirestore(Map<String, dynamic> d) {
    double g(String k, double def) => (d[k] as num?)?.toDouble() ?? def;
    const fb = KoefisienAktif(); // nilai default sebagai referensi fallback
    return KoefisienAktif(
      matTanahTimbun: g('mat_tanah_timbun', fb.matTanahTimbun),
      matBatuKali: g('mat_batu_kali', fb.matBatuKali),
      matAanstampPasirUrug: g('mat_aanstamp_pasir_urug', fb.matAanstampPasirUrug),
      matPasirUrug: g('mat_pasir_urug', fb.matPasirUrug),
      matPasirPasangBatuKali: g('mat_pasir_pasang_batu_kali', fb.matPasirPasangBatuKali),
      matPasirBeton: g('mat_pasir_beton', fb.matPasirBeton),
      matKerikilBeton: g('mat_kerikil_beton', fb.matKerikilBeton),
      matKerikilLantai: g('mat_kerikil_lantai', fb.matKerikilLantai),
      matPasirBetonLantai: g('mat_pasir_beton_lantai', fb.matPasirBetonLantai),
      matSemenBatuKali: g('mat_semen_batu_kali', fb.matSemenBatuKali),
      matSemenBeton: g('mat_semen_beton', fb.matSemenBeton),
      matSemenDinding: g('mat_semen_dinding', fb.matSemenDinding),
      matSemenPlester: g('mat_semen_plester', fb.matSemenPlester),
      matSemenAcian: g('mat_semen_acian', fb.matSemenAcian),
      matSemenLantai: g('mat_semen_lantai', fb.matSemenLantai),
      matSemenKeramik: g('mat_semen_keramik', fb.matSemenKeramik),
      matPasirPasangDinding: g('mat_pasir_pasang_dinding', fb.matPasirPasangDinding),
      matPasirPasangPlester: g('mat_pasir_pasang_plester', fb.matPasirPasangPlester),
      matPasirPasangKeramik: g('mat_pasir_pasang_keramik', fb.matPasirPasangKeramik),
      matBataMerah: g('mat_bata_merah', fb.matBataMerah),
      matBesiSloof: g('mat_besi_sloof', fb.matBesiSloof),
      matBesiKolom: g('mat_besi_kolom', fb.matBesiKolom),
      matBesiRingBalok: g('mat_besi_ring_balok', fb.matBesiRingBalok),
      matKeramik: g('mat_keramik', fb.matKeramik),
      matBalkKayuKelas1: g('mat_balk_kayu_kelas1', fb.matBalkKayuKelas1),
      matBalkKayuKelas2: g('mat_balk_kayu_kelas2', fb.matBalkKayuKelas2),
      matPapanKayuKelas2: g('mat_papan_kayu_kelas2', fb.matPapanKayuKelas2),
      matKaca5mm: g('mat_kaca_5mm', fb.matKaca5mm),
      matHollow4x4: g('mat_hollow_4x4', fb.matHollow4x4),
      matHollow2x4: g('mat_hollow_2x4', fb.matHollow2x4),
      matProfilC75: g('mat_profil_c75', fb.matProfilC75),
      matRengBaja: g('mat_reng_baja', fb.matRengBaja),
      matKayuBalok57: g('mat_kayu_balok57', fb.matKayuBalok57),
      matPapanBekisting1: g('mat_papan_bekisting_bouwplank', fb.matPapanBekisting1),
      matPapanBekistingSloof: g('mat_papan_bekisting_sloof', fb.matPapanBekistingSloof),
      matPapanBekistingKolom: g('mat_papan_bekisting_kolom', fb.matPapanBekistingKolom),
      matPapanBekistingRing: g('mat_papan_bekisting_ring', fb.matPapanBekistingRing),
      matPapanListplank: g('mat_papan_listplank', fb.matPapanListplank),
      matGentengGalvalum: g('mat_genteng_galvalum', fb.matGentengGalvalum),
      matNokGalvalum: g('mat_nok_galvalum', fb.matNokGalvalum),
      matPapanGypsum: g('mat_papan_gypsum', fb.matPapanGypsum),
      matListProfilKayu: g('mat_list_profil_kayu', fb.matListProfilKayu),
      matPlamirTembok: g('mat_plamir_tembok', fb.matPlamirTembok),
      matCatDasarTembok: g('mat_cat_dasar_tembok', fb.matCatDasarTembok),
      matCatTembok: g('mat_cat_tembok', fb.matCatTembok),
      matCatMenie: g('mat_cat_menie', fb.matCatMenie),
      matPlamirKayu: g('mat_plamir_kayu', fb.matPlamirKayu),
      matCatDasarKayu: g('mat_cat_dasar_kayu', fb.matCatDasarKayu),
      matCatKayu: g('mat_cat_kayu', fb.matCatKayu),
      ohPekerjaBersih: g('oh_pekerja_bersih', fb.ohPekerjaBersih),
      ohPekerjaBouwplank: g('oh_pekerja_bouwplank', fb.ohPekerjaBouwplank),
      ohPekerjaGalian: g('oh_pekerja_galian', fb.ohPekerjaGalian),
      ohPekerjaPasirUrug: g('oh_pekerja_pasir_urug', fb.ohPekerjaPasirUrug),
      ohPekerjaAanstamp: g('oh_pekerja_aanstamp', fb.ohPekerjaAanstamp),
      ohPekerjaBatuKali: g('oh_pekerja_batu_kali', fb.ohPekerjaBatuKali),
      ohPekerjaUrug: g('oh_pekerja_urug', fb.ohPekerjaUrug),
      ohPekerjaBetonTapak: g('oh_pekerja_beton_tapak', fb.ohPekerjaBetonTapak),
      ohPekerjaSloof: g('oh_pekerja_sloof', fb.ohPekerjaSloof),
      ohPekerjaKolom: g('oh_pekerja_kolom', fb.ohPekerjaKolom),
      ohPekerjaRingBalok: g('oh_pekerja_ring_balok', fb.ohPekerjaRingBalok),
      ohPekerjaDinding: g('oh_pekerja_dinding', fb.ohPekerjaDinding),
      ohPekerjaPlester: g('oh_pekerja_plester', fb.ohPekerjaPlester),
      ohPekerjaAcian: g('oh_pekerja_acian', fb.ohPekerjaAcian),
      ohPekerjaTimbunan: g('oh_pekerja_timbunan', fb.ohPekerjaTimbunan),
      ohPekerjaPasirLantai: g('oh_pekerja_pasir_lantai', fb.ohPekerjaPasirLantai),
      ohPekerjaCorLantai: g('oh_pekerja_cor_lantai', fb.ohPekerjaCorLantai),
      ohPekerjaKeramik: g('oh_pekerja_keramik', fb.ohPekerjaKeramik),
      ohPekerjaKusen: g('oh_pekerja_kusen', fb.ohPekerjaKusen),
      ohPekerjaDaunPintu: g('oh_pekerja_daun_pintu', fb.ohPekerjaDaunPintu),
      ohPekerjaKunci: g('oh_pekerja_kunci', fb.ohPekerjaKunci),
      ohPekerjaEngselPintu: g('oh_pekerja_engsel_pintu', fb.ohPekerjaEngselPintu),
      ohPekerjaDaunJendela: g('oh_pekerja_daun_jendela', fb.ohPekerjaDaunJendela),
      ohPekerjaKaca: g('oh_pekerja_kaca', fb.ohPekerjaKaca),
      ohPekerjaEngselJendela: g('oh_pekerja_engsel_jendela', fb.ohPekerjaEngselJendela),
      ohPekerjaRangkaPlafon: g('oh_pekerja_rangka_plafon', fb.ohPekerjaRangkaPlafon),
      ohPekerjaGypsum: g('oh_pekerja_gypsum', fb.ohPekerjaGypsum),
      ohPekerjaListPlafon: g('oh_pekerja_list_plafon', fb.ohPekerjaListPlafon),
      ohPekerjaRangkaAtap: g('oh_pekerja_rangka_atap', fb.ohPekerjaRangkaAtap),
      ohPekerjaGenteng: g('oh_pekerja_genteng', fb.ohPekerjaGenteng),
      ohPekerjaListplank: g('oh_pekerja_listplank', fb.ohPekerjaListplank),
      ohPekerjaNok: g('oh_pekerja_nok', fb.ohPekerjaNok),
      ohPekerjaCatTembok: g('oh_pekerja_cat_tembok', fb.ohPekerjaCatTembok),
      ohPekerjaCatKayu: g('oh_pekerja_cat_kayu', fb.ohPekerjaCatKayu),
      ohTukangBouwplank: g('oh_tukang_bouwplank', fb.ohTukangBouwplank),
      ohTukangAanstamp: g('oh_tukang_aanstamp', fb.ohTukangAanstamp),
      ohTukangBatuKali: g('oh_tukang_batu_kali', fb.ohTukangBatuKali),
      ohTukangBetonTapak: g('oh_tukang_beton_tapak', fb.ohTukangBetonTapak),
      ohTukangSloof: g('oh_tukang_sloof', fb.ohTukangSloof),
      ohTukangKolom: g('oh_tukang_kolom', fb.ohTukangKolom),
      ohTukangRingBalok: g('oh_tukang_ring_balok', fb.ohTukangRingBalok),
      ohTukangDinding: g('oh_tukang_dinding', fb.ohTukangDinding),
      ohTukangPlester: g('oh_tukang_plester', fb.ohTukangPlester),
      ohTukangAcian: g('oh_tukang_acian', fb.ohTukangAcian),
      ohTukangCorLantai: g('oh_tukang_cor_lantai', fb.ohTukangCorLantai),
      ohTukangKeramik: g('oh_tukang_keramik', fb.ohTukangKeramik),
      ohTukangKusen: g('oh_tukang_kusen', fb.ohTukangKusen),
      ohTukangDaunPintu: g('oh_tukang_daun_pintu', fb.ohTukangDaunPintu),
      ohTukangKunci: g('oh_tukang_kunci', fb.ohTukangKunci),
      ohTukangEngselPintu: g('oh_tukang_engsel_pintu', fb.ohTukangEngselPintu),
      ohTukangDaunJendela: g('oh_tukang_daun_jendela', fb.ohTukangDaunJendela),
      ohTukangKaca: g('oh_tukang_kaca', fb.ohTukangKaca),
      ohTukangEngselJendela: g('oh_tukang_engsel_jendela', fb.ohTukangEngselJendela),
      ohTukangRangkaPlafon: g('oh_tukang_rangka_plafon', fb.ohTukangRangkaPlafon),
      ohTukangGypsum: g('oh_tukang_gypsum', fb.ohTukangGypsum),
      ohTukangListPlafon: g('oh_tukang_list_plafon', fb.ohTukangListPlafon),
      ohTukangRangkaAtap: g('oh_tukang_rangka_atap', fb.ohTukangRangkaAtap),
      ohTukangGenteng: g('oh_tukang_genteng', fb.ohTukangGenteng),
      ohTukangListplank: g('oh_tukang_listplank', fb.ohTukangListplank),
      ohTukangNok: g('oh_tukang_nok', fb.ohTukangNok),
      ohTukangCatTembok: g('oh_tukang_cat_tembok', fb.ohTukangCatTembok),
      ohTukangCatKayu: g('oh_tukang_cat_kayu', fb.ohTukangCatKayu),
      ohMandorBersih: g('oh_mandor_bersih', fb.ohMandorBersih),
      ohMandorBouwplank: g('oh_mandor_bouwplank', fb.ohMandorBouwplank),
      ohMandorGalian: g('oh_mandor_galian', fb.ohMandorGalian),
      ohMandorPasirUrug: g('oh_mandor_pasir_urug', fb.ohMandorPasirUrug),
      ohMandorAanstamp: g('oh_mandor_aanstamp', fb.ohMandorAanstamp),
      ohMandorBatuKali: g('oh_mandor_batu_kali', fb.ohMandorBatuKali),
      ohMandorUrug: g('oh_mandor_urug', fb.ohMandorUrug),
      ohMandorBetonTapak: g('oh_mandor_beton_tapak', fb.ohMandorBetonTapak),
      ohMandorSloof: g('oh_mandor_sloof', fb.ohMandorSloof),
      ohMandorKolom: g('oh_mandor_kolom', fb.ohMandorKolom),
      ohMandorRingBalok: g('oh_mandor_ring_balok', fb.ohMandorRingBalok),
      ohMandorDinding: g('oh_mandor_dinding', fb.ohMandorDinding),
      ohMandorPlester: g('oh_mandor_plester', fb.ohMandorPlester),
      ohMandorAcian: g('oh_mandor_acian', fb.ohMandorAcian),
      ohMandorTimbunan: g('oh_mandor_timbunan', fb.ohMandorTimbunan),
      ohMandorPasirLantai: g('oh_mandor_pasir_lantai', fb.ohMandorPasirLantai),
      ohMandorCorLantai: g('oh_mandor_cor_lantai', fb.ohMandorCorLantai),
      ohMandorKeramik: g('oh_mandor_keramik', fb.ohMandorKeramik),
      ohMandorKusen: g('oh_mandor_kusen', fb.ohMandorKusen),
      ohMandorDaunPintu: g('oh_mandor_daun_pintu', fb.ohMandorDaunPintu),
      ohMandorKunci: g('oh_mandor_kunci', fb.ohMandorKunci),
      ohMandorEngselPintu: g('oh_mandor_engsel_pintu', fb.ohMandorEngselPintu),
      ohMandorDaunJendela: g('oh_mandor_daun_jendela', fb.ohMandorDaunJendela),
      ohMandorKaca: g('oh_mandor_kaca', fb.ohMandorKaca),
      ohMandorEngselJendela: g('oh_mandor_engsel_jendela', fb.ohMandorEngselJendela),
      ohMandorRangkaPlafon: g('oh_mandor_rangka_plafon', fb.ohMandorRangkaPlafon),
      ohMandorGypsum: g('oh_mandor_gypsum', fb.ohMandorGypsum),
      ohMandorListPlafon: g('oh_mandor_list_plafon', fb.ohMandorListPlafon),
      ohMandorRangkaAtap: g('oh_mandor_rangka_atap', fb.ohMandorRangkaAtap),
      ohMandorGenteng: g('oh_mandor_genteng', fb.ohMandorGenteng),
      ohMandorListplank: g('oh_mandor_listplank', fb.ohMandorListplank),
      ohMandorNok: g('oh_mandor_nok', fb.ohMandorNok),
      ohMandorCatTembok: g('oh_mandor_cat_tembok', fb.ohMandorCatTembok),
      ohMandorCatKayu: g('oh_mandor_cat_kayu', fb.ohMandorCatKayu),
    );
  }

  /// Konversi ke Map untuk Firestore & snapshot proyek.
  Map<String, dynamic> keFirestore() => {
    'mat_tanah_timbun': matTanahTimbun,
    'mat_batu_kali': matBatuKali,
    'mat_aanstamp_pasir_urug': matAanstampPasirUrug,
    'mat_pasir_urug': matPasirUrug,
    'mat_pasir_pasang_batu_kali': matPasirPasangBatuKali,
    'mat_pasir_beton': matPasirBeton,
    'mat_kerikil_beton': matKerikilBeton,
    'mat_kerikil_lantai': matKerikilLantai,
    'mat_pasir_beton_lantai': matPasirBetonLantai,
    'mat_semen_batu_kali': matSemenBatuKali,
    'mat_semen_beton': matSemenBeton,
    'mat_semen_dinding': matSemenDinding,
    'mat_semen_plester': matSemenPlester,
    'mat_semen_acian': matSemenAcian,
    'mat_semen_lantai': matSemenLantai,
    'mat_semen_keramik': matSemenKeramik,
    'mat_pasir_pasang_dinding': matPasirPasangDinding,
    'mat_pasir_pasang_plester': matPasirPasangPlester,
    'mat_pasir_pasang_keramik': matPasirPasangKeramik,
    'mat_bata_merah': matBataMerah,
    'mat_besi_sloof': matBesiSloof,
    'mat_besi_kolom': matBesiKolom,
    'mat_besi_ring_balok': matBesiRingBalok,
    'mat_keramik': matKeramik,
    'mat_balk_kayu_kelas1': matBalkKayuKelas1,
    'mat_balk_kayu_kelas2': matBalkKayuKelas2,
    'mat_papan_kayu_kelas2': matPapanKayuKelas2,
    'mat_kaca_5mm': matKaca5mm,
    'mat_hollow_4x4': matHollow4x4,
    'mat_hollow_2x4': matHollow2x4,
    'mat_profil_c75': matProfilC75,
    'mat_reng_baja': matRengBaja,
    'mat_kayu_balok57': matKayuBalok57,
    'mat_papan_bekisting_bouwplank': matPapanBekisting1,
    'mat_papan_bekisting_sloof': matPapanBekistingSloof,
    'mat_papan_bekisting_kolom': matPapanBekistingKolom,
    'mat_papan_bekisting_ring': matPapanBekistingRing,
    'mat_papan_listplank': matPapanListplank,
    'mat_genteng_galvalum': matGentengGalvalum,
    'mat_nok_galvalum': matNokGalvalum,
    'mat_papan_gypsum': matPapanGypsum,
    'mat_list_profil_kayu': matListProfilKayu,
    'mat_plamir_tembok': matPlamirTembok,
    'mat_cat_dasar_tembok': matCatDasarTembok,
    'mat_cat_tembok': matCatTembok,
    'mat_cat_menie': matCatMenie,
    'mat_plamir_kayu': matPlamirKayu,
    'mat_cat_dasar_kayu': matCatDasarKayu,
    'mat_cat_kayu': matCatKayu,
    'oh_pekerja_bersih': ohPekerjaBersih,
    'oh_pekerja_bouwplank': ohPekerjaBouwplank,
    'oh_pekerja_galian': ohPekerjaGalian,
    'oh_pekerja_pasir_urug': ohPekerjaPasirUrug,
    'oh_pekerja_aanstamp': ohPekerjaAanstamp,
    'oh_pekerja_batu_kali': ohPekerjaBatuKali,
    'oh_pekerja_urug': ohPekerjaUrug,
    'oh_pekerja_beton_tapak': ohPekerjaBetonTapak,
    'oh_pekerja_sloof': ohPekerjaSloof,
    'oh_pekerja_kolom': ohPekerjaKolom,
    'oh_pekerja_ring_balok': ohPekerjaRingBalok,
    'oh_pekerja_dinding': ohPekerjaDinding,
    'oh_pekerja_plester': ohPekerjaPlester,
    'oh_pekerja_acian': ohPekerjaAcian,
    'oh_pekerja_timbunan': ohPekerjaTimbunan,
    'oh_pekerja_pasir_lantai': ohPekerjaPasirLantai,
    'oh_pekerja_cor_lantai': ohPekerjaCorLantai,
    'oh_pekerja_keramik': ohPekerjaKeramik,
    'oh_pekerja_kusen': ohPekerjaKusen,
    'oh_pekerja_daun_pintu': ohPekerjaDaunPintu,
    'oh_pekerja_kunci': ohPekerjaKunci,
    'oh_pekerja_engsel_pintu': ohPekerjaEngselPintu,
    'oh_pekerja_daun_jendela': ohPekerjaDaunJendela,
    'oh_pekerja_kaca': ohPekerjaKaca,
    'oh_pekerja_engsel_jendela': ohPekerjaEngselJendela,
    'oh_pekerja_rangka_plafon': ohPekerjaRangkaPlafon,
    'oh_pekerja_gypsum': ohPekerjaGypsum,
    'oh_pekerja_list_plafon': ohPekerjaListPlafon,
    'oh_pekerja_rangka_atap': ohPekerjaRangkaAtap,
    'oh_pekerja_genteng': ohPekerjaGenteng,
    'oh_pekerja_listplank': ohPekerjaListplank,
    'oh_pekerja_nok': ohPekerjaNok,
    'oh_pekerja_cat_tembok': ohPekerjaCatTembok,
    'oh_pekerja_cat_kayu': ohPekerjaCatKayu,
    'oh_tukang_bouwplank': ohTukangBouwplank,
    'oh_tukang_aanstamp': ohTukangAanstamp,
    'oh_tukang_batu_kali': ohTukangBatuKali,
    'oh_tukang_beton_tapak': ohTukangBetonTapak,
    'oh_tukang_sloof': ohTukangSloof,
    'oh_tukang_kolom': ohTukangKolom,
    'oh_tukang_ring_balok': ohTukangRingBalok,
    'oh_tukang_dinding': ohTukangDinding,
    'oh_tukang_plester': ohTukangPlester,
    'oh_tukang_acian': ohTukangAcian,
    'oh_tukang_cor_lantai': ohTukangCorLantai,
    'oh_tukang_keramik': ohTukangKeramik,
    'oh_tukang_kusen': ohTukangKusen,
    'oh_tukang_daun_pintu': ohTukangDaunPintu,
    'oh_tukang_kunci': ohTukangKunci,
    'oh_tukang_engsel_pintu': ohTukangEngselPintu,
    'oh_tukang_daun_jendela': ohTukangDaunJendela,
    'oh_tukang_kaca': ohTukangKaca,
    'oh_tukang_engsel_jendela': ohTukangEngselJendela,
    'oh_tukang_rangka_plafon': ohTukangRangkaPlafon,
    'oh_tukang_gypsum': ohTukangGypsum,
    'oh_tukang_list_plafon': ohTukangListPlafon,
    'oh_tukang_rangka_atap': ohTukangRangkaAtap,
    'oh_tukang_genteng': ohTukangGenteng,
    'oh_tukang_listplank': ohTukangListplank,
    'oh_tukang_nok': ohTukangNok,
    'oh_tukang_cat_tembok': ohTukangCatTembok,
    'oh_tukang_cat_kayu': ohTukangCatKayu,
    'oh_mandor_bersih': ohMandorBersih,
    'oh_mandor_bouwplank': ohMandorBouwplank,
    'oh_mandor_galian': ohMandorGalian,
    'oh_mandor_pasir_urug': ohMandorPasirUrug,
    'oh_mandor_aanstamp': ohMandorAanstamp,
    'oh_mandor_batu_kali': ohMandorBatuKali,
    'oh_mandor_urug': ohMandorUrug,
    'oh_mandor_beton_tapak': ohMandorBetonTapak,
    'oh_mandor_sloof': ohMandorSloof,
    'oh_mandor_kolom': ohMandorKolom,
    'oh_mandor_ring_balok': ohMandorRingBalok,
    'oh_mandor_dinding': ohMandorDinding,
    'oh_mandor_plester': ohMandorPlester,
    'oh_mandor_acian': ohMandorAcian,
    'oh_mandor_timbunan': ohMandorTimbunan,
    'oh_mandor_pasir_lantai': ohMandorPasirLantai,
    'oh_mandor_cor_lantai': ohMandorCorLantai,
    'oh_mandor_keramik': ohMandorKeramik,
    'oh_mandor_kusen': ohMandorKusen,
    'oh_mandor_daun_pintu': ohMandorDaunPintu,
    'oh_mandor_kunci': ohMandorKunci,
    'oh_mandor_engsel_pintu': ohMandorEngselPintu,
    'oh_mandor_daun_jendela': ohMandorDaunJendela,
    'oh_mandor_kaca': ohMandorKaca,
    'oh_mandor_engsel_jendela': ohMandorEngselJendela,
    'oh_mandor_rangka_plafon': ohMandorRangkaPlafon,
    'oh_mandor_gypsum': ohMandorGypsum,
    'oh_mandor_list_plafon': ohMandorListPlafon,
    'oh_mandor_rangka_atap': ohMandorRangkaAtap,
    'oh_mandor_genteng': ohMandorGenteng,
    'oh_mandor_listplank': ohMandorListplank,
    'oh_mandor_nok': ohMandorNok,
    'oh_mandor_cat_tembok': ohMandorCatTembok,
    'oh_mandor_cat_kayu': ohMandorCatKayu,
    'diperbarui_pada': Timestamp.now(),
  };
}