import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../shared/models/model_koefisien.dart';
import '../../../shared/services/koefisien_provider.dart';
import '../../../shared/services/layanan_notifikasi.dart'; 
import '../../../shared/utils/styles.dart';

class KoefisienPage extends StatefulWidget {
  const KoefisienPage({super.key});

  @override
  State<KoefisienPage> createState() => _KoefisienPageState();
}

class _KoefisienPageState extends State<KoefisienPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, TextEditingController> _controllers = {};

  static const _tabMaterial = 'Koefisien Material';
  static const _tabOhPekerja = 'OH Pekerja';
  static const _tabOhTukang = 'OH Tukang';
  static const _tabOhMandor = 'OH Mandor';

  bool _adaPerubahan = false;
  bool _menyimpan = false;
  final LayananNotifikasi _layananNotif = LayananNotifikasi();

  // Label per key untuk 4 kategori
  static const Map<String, String> _labelMaterial = {
    'mat_tanah_timbun': 'Tanah Timbun (×vol)',
    'mat_batu_kali': 'Batu Kali & Aanstamp (×vol)',
    'mat_aanstamp_pasir_urug': 'Aanstamp → Pasir Urug (×vol)',
    'mat_pasir_urug': 'Pasir Urug (×vol)',
    'mat_pasir_pasang_batu_kali': 'Pasir Pasang – Batu Kali (×m³)',
    'mat_pasir_beton': 'Pasir Beton – Beton (×m³)',
    'mat_kerikil_beton': 'Kerikil – Beton Tapak/Struktur (×m³)',
    'mat_kerikil_lantai': 'Kerikil – Cor Lantai (×m³)',
    'mat_pasir_beton_lantai': 'Pasir Beton – Cor Lantai (×m³)',
    'mat_semen_batu_kali': 'Semen – Batu Kali (kg/m³)',
    'mat_semen_beton': 'Semen – Beton Struktur (kg/m³)',
    'mat_semen_dinding': 'Semen – Pasangan Dinding (kg/m²)',
    'mat_semen_plester': 'Semen – Plesteran (kg/m²)',
    'mat_semen_acian': 'Semen – Acian (kg/m²)',
    'mat_semen_lantai': 'Semen – Cor Lantai (kg/m³)',
    'mat_semen_keramik': 'Semen – Pasang Keramik (kg/m²)',
    'mat_pasir_pasang_dinding': 'Pasir Pasang – Dinding (m³/m²)',
    'mat_pasir_pasang_plester': 'Pasir Pasang – Plester (m³/m²)',
    'mat_pasir_pasang_keramik': 'Pasir Pasang – Keramik (m³/m²)',
    'mat_bata_merah': 'Bata Merah (buah/m²)',
    'mat_besi_sloof': 'Besi – Sloof (kg/m³)',
    'mat_besi_kolom': 'Besi – Kolom (kg/m³)',
    'mat_besi_ring_balok': 'Besi – Ring Balok (kg/m³)',
    'mat_keramik': 'Keramik 40×40 (buah/m²)',
    'mat_balk_kayu_kelas1': 'Balok Kayu Kls 1 – Kusen (×vol)',
    'mat_balk_kayu_kelas2': 'Balok Kayu Kls 2 – Daun Pintu (×m²)',
    'mat_papan_kayu_kelas2': 'Papan Kayu Kls 2 – Daun Jendela (×m²)',
    'mat_kaca_5mm': 'Kaca 5mm (×vol)',
    'mat_hollow_4x4': 'Hollow 4×4 – Plafon (×m²)',
    'mat_hollow_2x4': 'Hollow 2×4 – Plafon (×m²)',
    'mat_profil_c75': 'Profil C75 – Rangka Atap (×m²)',
    'mat_reng_baja': 'Reng Baja – Rangka Atap (×m²)',
    'mat_kayu_balok57': 'Kayu Balok 5/7 – Bouwplank (×m\')',
    'mat_papan_bekisting_bouwplank': 'Papan Bekisting – Bouwplank (×m\')',
    'mat_papan_bekisting_sloof': 'Papan Bekisting – Sloof (×m³)',
    'mat_papan_bekisting_kolom': 'Papan Bekisting – Kolom (×m³)',
    'mat_papan_bekisting_ring': 'Papan Bekisting – Ring Balok (×m³)',
    'mat_papan_listplank': 'Papan Listplank (×m\')',
    'mat_genteng_galvalum': 'Genteng Galvalum (×m²)',
    'mat_nok_galvalum': 'Nok Galvalum (×m\')',
    'mat_papan_gypsum': 'Papan Gypsum (lembar/m²)',
    'mat_list_profil_kayu': 'List Profil Kayu – Plafon (×m\')',
    'mat_plamir_tembok': 'Plamir Tembok (kg/m²)',
    'mat_cat_dasar_tembok': 'Cat Dasar Tembok (kg/m²)',
    'mat_cat_tembok': 'Cat Tembok (kg/m²)',
    'mat_cat_menie': 'Cat Menie Kayu (kg/m²)',
    'mat_plamir_kayu': 'Plamir Kayu (kg/m²)',
    'mat_cat_dasar_kayu': 'Cat Dasar Kayu (kg/m²)',
    'mat_cat_kayu': 'Cat Kayu (kg/m²)',
  };

  static const Map<String, String> _labelOhPekerja = {
    'oh_pekerja_bersih': 'Bersih Lahan',
    'oh_pekerja_bouwplank': 'Bouwplank',
    'oh_pekerja_galian': 'Galian Tanah',
    'oh_pekerja_pasir_urug': 'Pasir Urug',
    'oh_pekerja_aanstamp': 'Aanstamping',
    'oh_pekerja_batu_kali': 'Pasangan Batu Kali',
    'oh_pekerja_urug': 'Urugan Tanah',
    'oh_pekerja_beton_tapak': 'Beton Tapak',
    'oh_pekerja_sloof': 'Sloof',
    'oh_pekerja_kolom': 'Kolom Praktis',
    'oh_pekerja_ring_balok': 'Ring Balok',
    'oh_pekerja_dinding': 'Pasangan Dinding',
    'oh_pekerja_plester': 'Plesteran',
    'oh_pekerja_acian': 'Acian',
    'oh_pekerja_timbunan': 'Timbunan',
    'oh_pekerja_pasir_lantai': 'Pasir Lantai',
    'oh_pekerja_cor_lantai': 'Cor Lantai',
    'oh_pekerja_keramik': 'Pasang Keramik',
    'oh_pekerja_kusen': 'Pasang Kusen',
    'oh_pekerja_daun_pintu': 'Pasang Daun Pintu',
    'oh_pekerja_kunci': 'Pasang Kunci',
    'oh_pekerja_engsel_pintu': 'Pasang Engsel Pintu',
    'oh_pekerja_daun_jendela': 'Pasang Daun Jendela',
    'oh_pekerja_kaca': 'Pasang Kaca',
    'oh_pekerja_engsel_jendela': 'Pasang Engsel Jendela',
    'oh_pekerja_rangka_plafon': 'Rangka Plafon (Hollow)',
    'oh_pekerja_gypsum': 'Pasang Gypsum',
    'oh_pekerja_list_plafon': 'List Profil Plafon',
    'oh_pekerja_rangka_atap': 'Rangka Atap',
    'oh_pekerja_genteng': 'Pasang Genteng',
    'oh_pekerja_listplank': 'Listplank',
    'oh_pekerja_nok': 'Nok Atap',
    'oh_pekerja_cat_tembok': 'Cat Tembok & Plafon',
    'oh_pekerja_cat_kayu': 'Cat Kayu',
  };

  static const Map<String, String> _labelOhTukang = {
    'oh_tukang_bouwplank': 'Bouwplank',
    'oh_tukang_aanstamp': 'Aanstamping',
    'oh_tukang_batu_kali': 'Pasangan Batu Kali',
    'oh_tukang_beton_tapak': 'Beton Tapak',
    'oh_tukang_sloof': 'Sloof',
    'oh_tukang_kolom': 'Kolom Praktis',
    'oh_tukang_ring_balok': 'Ring Balok',
    'oh_tukang_dinding': 'Pasangan Dinding',
    'oh_tukang_plester': 'Plesteran',
    'oh_tukang_acian': 'Acian',
    'oh_tukang_cor_lantai': 'Cor Lantai',
    'oh_tukang_keramik': 'Pasang Keramik',
    'oh_tukang_kusen': 'Pasang Kusen',
    'oh_tukang_daun_pintu': 'Pasang Daun Pintu',
    'oh_tukang_kunci': 'Pasang Kunci',
    'oh_tukang_engsel_pintu': 'Pasang Engsel Pintu',
    'oh_tukang_daun_jendela': 'Pasang Daun Jendela',
    'oh_tukang_kaca': 'Pasang Kaca',
    'oh_tukang_engsel_jendela': 'Pasang Engsel Jendela',
    'oh_tukang_rangka_plafon': 'Rangka Plafon (Hollow)',
    'oh_tukang_gypsum': 'Pasang Gypsum',
    'oh_tukang_list_plafon': 'List Profil Plafon',
    'oh_tukang_rangka_atap': 'Rangka Atap',
    'oh_tukang_genteng': 'Pasang Genteng',
    'oh_tukang_listplank': 'Listplank',
    'oh_tukang_nok': 'Nok Atap',
    'oh_tukang_cat_tembok': 'Cat Tembok & Plafon',
    'oh_tukang_cat_kayu': 'Cat Kayu',
  };

  static const Map<String, String> _labelOhMandor = {
    'oh_mandor_bersih': 'Bersih Lahan',
    'oh_mandor_bouwplank': 'Bouwplank',
    'oh_mandor_galian': 'Galian Tanah',
    'oh_mandor_pasir_urug': 'Pasir Urug',
    'oh_mandor_aanstamp': 'Aanstamping',
    'oh_mandor_batu_kali': 'Pasangan Batu Kali',
    'oh_mandor_urug': 'Urugan Tanah',
    'oh_mandor_beton_tapak': 'Beton Tapak',
    'oh_mandor_sloof': 'Sloof',
    'oh_mandor_kolom': 'Kolom Praktis',
    'oh_mandor_ring_balok': 'Ring Balok',
    'oh_mandor_dinding': 'Pasangan Dinding',
    'oh_mandor_plester': 'Plesteran',
    'oh_mandor_acian': 'Acian',
    'oh_mandor_timbunan': 'Timbunan',
    'oh_mandor_pasir_lantai': 'Pasir Lantai',
    'oh_mandor_cor_lantai': 'Cor Lantai',
    'oh_mandor_keramik': 'Pasang Keramik',
    'oh_mandor_kusen': 'Pasang Kusen',
    'oh_mandor_daun_pintu': 'Pasang Daun Pintu',
    'oh_mandor_kunci': 'Pasang Kunci',
    'oh_mandor_engsel_pintu': 'Pasang Engsel Pintu',
    'oh_mandor_daun_jendela': 'Pasang Daun Jendela',
    'oh_mandor_kaca': 'Pasang Kaca',
    'oh_mandor_engsel_jendela': 'Pasang Engsel Jendela',
    'oh_mandor_rangka_plafon': 'Rangka Plafon (Hollow)',
    'oh_mandor_gypsum': 'Pasang Gypsum',
    'oh_mandor_list_plafon': 'List Profil Plafon',
    'oh_mandor_rangka_atap': 'Rangka Atap',
    'oh_mandor_genteng': 'Pasang Genteng',
    'oh_mandor_listplank': 'Listplank',
    'oh_mandor_nok': 'Nok Atap',
    'oh_mandor_cat_tembok': 'Cat Tembok & Plafon',
    'oh_mandor_cat_kayu': 'Cat Kayu',
  };

  static Map<String, String> get _semuaLabel => {
        ..._labelMaterial,
        ..._labelOhPekerja,
        ..._labelOhTukang,
        ..._labelOhMandor,
      };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _inisialisasiControllers();
  }

  void _inisialisasiControllers() {
    final k = context.read<KoefisienProvider>().aktif;
    final semua = k.keFirestore()..remove('diperbarui_pada');
    for (final entry in semua.entries) {
      final nilai = (entry.value as num?)?.toDouble() ?? 0.0;
      _controllers[entry.key] =
          TextEditingController(text: _formatNilai(nilai))
            ..addListener(() => setState(() => _adaPerubahan = true));
    }
  }

  String _formatNilai(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toString().replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  double _parseNilai(String key) {
    return double.tryParse(
          _controllers[key]?.text.replaceAll(',', '.') ?? '',
        ) ??
        (const KoefisienAktif().keFirestore()[key] as num?)?.toDouble() ??
        0.0;
  }

  KoefisienAktif _bacaDariControllers() {
    double g(String k) => _parseNilai(k);
    return KoefisienAktif(
      matTanahTimbun: g('mat_tanah_timbun'),
      matBatuKali: g('mat_batu_kali'),
      matAanstampPasirUrug: g('mat_aanstamp_pasir_urug'),
      matPasirUrug: g('mat_pasir_urug'),
      matPasirPasangBatuKali: g('mat_pasir_pasang_batu_kali'),
      matPasirBeton: g('mat_pasir_beton'),
      matKerikilBeton: g('mat_kerikil_beton'),
      matKerikilLantai: g('mat_kerikil_lantai'),
      matPasirBetonLantai: g('mat_pasir_beton_lantai'),
      matSemenBatuKali: g('mat_semen_batu_kali'),
      matSemenBeton: g('mat_semen_beton'),
      matSemenDinding: g('mat_semen_dinding'),
      matSemenPlester: g('mat_semen_plester'),
      matSemenAcian: g('mat_semen_acian'),
      matSemenLantai: g('mat_semen_lantai'),
      matSemenKeramik: g('mat_semen_keramik'),
      matPasirPasangDinding: g('mat_pasir_pasang_dinding'),
      matPasirPasangPlester: g('mat_pasir_pasang_plester'),
      matPasirPasangKeramik: g('mat_pasir_pasang_keramik'),
      matBataMerah: g('mat_bata_merah'),
      matBesiSloof: g('mat_besi_sloof'),
      matBesiKolom: g('mat_besi_kolom'),
      matBesiRingBalok: g('mat_besi_ring_balok'),
      matKeramik: g('mat_keramik'),
      matBalkKayuKelas1: g('mat_balk_kayu_kelas1'),
      matBalkKayuKelas2: g('mat_balk_kayu_kelas2'),
      matPapanKayuKelas2: g('mat_papan_kayu_kelas2'),
      matKaca5mm: g('mat_kaca_5mm'),
      matHollow4x4: g('mat_hollow_4x4'),
      matHollow2x4: g('mat_hollow_2x4'),
      matProfilC75: g('mat_profil_c75'),
      matRengBaja: g('mat_reng_baja'),
      matKayuBalok57: g('mat_kayu_balok57'),
      matPapanBekisting1: g('mat_papan_bekisting_bouwplank'),
      matPapanBekistingSloof: g('mat_papan_bekisting_sloof'),
      matPapanBekistingKolom: g('mat_papan_bekisting_kolom'),
      matPapanBekistingRing: g('mat_papan_bekisting_ring'),
      matPapanListplank: g('mat_papan_listplank'),
      matGentengGalvalum: g('mat_genteng_galvalum'),
      matNokGalvalum: g('mat_nok_galvalum'),
      matPapanGypsum: g('mat_papan_gypsum'),
      matListProfilKayu: g('mat_list_profil_kayu'),
      matPlamirTembok: g('mat_plamir_tembok'),
      matCatDasarTembok: g('mat_cat_dasar_tembok'),
      matCatTembok: g('mat_cat_tembok'),
      matCatMenie: g('mat_cat_menie'),
      matPlamirKayu: g('mat_plamir_kayu'),
      matCatDasarKayu: g('mat_cat_dasar_kayu'),
      matCatKayu: g('mat_cat_kayu'),
      ohPekerjaBersih: g('oh_pekerja_bersih'),
      ohPekerjaBouwplank: g('oh_pekerja_bouwplank'),
      ohPekerjaGalian: g('oh_pekerja_galian'),
      ohPekerjaPasirUrug: g('oh_pekerja_pasir_urug'),
      ohPekerjaAanstamp: g('oh_pekerja_aanstamp'),
      ohPekerjaBatuKali: g('oh_pekerja_batu_kali'),
      ohPekerjaUrug: g('oh_pekerja_urug'),
      ohPekerjaBetonTapak: g('oh_pekerja_beton_tapak'),
      ohPekerjaSloof: g('oh_pekerja_sloof'),
      ohPekerjaKolom: g('oh_pekerja_kolom'),
      ohPekerjaRingBalok: g('oh_pekerja_ring_balok'),
      ohPekerjaDinding: g('oh_pekerja_dinding'),
      ohPekerjaPlester: g('oh_pekerja_plester'),
      ohPekerjaAcian: g('oh_pekerja_acian'),
      ohPekerjaTimbunan: g('oh_pekerja_timbunan'),
      ohPekerjaPasirLantai: g('oh_pekerja_pasir_lantai'),
      ohPekerjaCorLantai: g('oh_pekerja_cor_lantai'),
      ohPekerjaKeramik: g('oh_pekerja_keramik'),
      ohPekerjaKusen: g('oh_pekerja_kusen'),
      ohPekerjaDaunPintu: g('oh_pekerja_daun_pintu'),
      ohPekerjaKunci: g('oh_pekerja_kunci'),
      ohPekerjaEngselPintu: g('oh_pekerja_engsel_pintu'),
      ohPekerjaDaunJendela: g('oh_pekerja_daun_jendela'),
      ohPekerjaKaca: g('oh_pekerja_kaca'),
      ohPekerjaEngselJendela: g('oh_pekerja_engsel_jendela'),
      ohPekerjaRangkaPlafon: g('oh_pekerja_rangka_plafon'),
      ohPekerjaGypsum: g('oh_pekerja_gypsum'),
      ohPekerjaListPlafon: g('oh_pekerja_list_plafon'),
      ohPekerjaRangkaAtap: g('oh_pekerja_rangka_atap'),
      ohPekerjaGenteng: g('oh_pekerja_genteng'),
      ohPekerjaListplank: g('oh_pekerja_listplank'),
      ohPekerjaNok: g('oh_pekerja_nok'),
      ohPekerjaCatTembok: g('oh_pekerja_cat_tembok'),
      ohPekerjaCatKayu: g('oh_pekerja_cat_kayu'),
      ohTukangBouwplank: g('oh_tukang_bouwplank'),
      ohTukangAanstamp: g('oh_tukang_aanstamp'),
      ohTukangBatuKali: g('oh_tukang_batu_kali'),
      ohTukangBetonTapak: g('oh_tukang_beton_tapak'),
      ohTukangSloof: g('oh_tukang_sloof'),
      ohTukangKolom: g('oh_tukang_kolom'),
      ohTukangRingBalok: g('oh_tukang_ring_balok'),
      ohTukangDinding: g('oh_tukang_dinding'),
      ohTukangPlester: g('oh_tukang_plester'),
      ohTukangAcian: g('oh_tukang_acian'),
      ohTukangCorLantai: g('oh_tukang_cor_lantai'),
      ohTukangKeramik: g('oh_tukang_keramik'),
      ohTukangKusen: g('oh_tukang_kusen'),
      ohTukangDaunPintu: g('oh_tukang_daun_pintu'),
      ohTukangKunci: g('oh_tukang_kunci'),
      ohTukangEngselPintu: g('oh_tukang_engsel_pintu'),
      ohTukangDaunJendela: g('oh_tukang_daun_jendela'),
      ohTukangKaca: g('oh_tukang_kaca'),
      ohTukangEngselJendela: g('oh_tukang_engsel_jendela'),
      ohTukangRangkaPlafon: g('oh_tukang_rangka_plafon'),
      ohTukangGypsum: g('oh_tukang_gypsum'),
      ohTukangListPlafon: g('oh_tukang_list_plafon'),
      ohTukangRangkaAtap: g('oh_tukang_rangka_atap'),
      ohTukangGenteng: g('oh_tukang_genteng'),
      ohTukangListplank: g('oh_tukang_listplank'),
      ohTukangNok: g('oh_tukang_nok'),
      ohTukangCatTembok: g('oh_tukang_cat_tembok'),
      ohTukangCatKayu: g('oh_tukang_cat_kayu'),
      ohMandorBersih: g('oh_mandor_bersih'),
      ohMandorBouwplank: g('oh_mandor_bouwplank'),
      ohMandorGalian: g('oh_mandor_galian'),
      ohMandorPasirUrug: g('oh_mandor_pasir_urug'),
      ohMandorAanstamp: g('oh_mandor_aanstamp'),
      ohMandorBatuKali: g('oh_mandor_batu_kali'),
      ohMandorUrug: g('oh_mandor_urug'),
      ohMandorBetonTapak: g('oh_mandor_beton_tapak'),
      ohMandorSloof: g('oh_mandor_sloof'),
      ohMandorKolom: g('oh_mandor_kolom'),
      ohMandorRingBalok: g('oh_mandor_ring_balok'),
      ohMandorDinding: g('oh_mandor_dinding'),
      ohMandorPlester: g('oh_mandor_plester'),
      ohMandorAcian: g('oh_mandor_acian'),
      ohMandorTimbunan: g('oh_mandor_timbunan'),
      ohMandorPasirLantai: g('oh_mandor_pasir_lantai'),
      ohMandorCorLantai: g('oh_mandor_cor_lantai'),
      ohMandorKeramik: g('oh_mandor_keramik'),
      ohMandorKusen: g('oh_mandor_kusen'),
      ohMandorDaunPintu: g('oh_mandor_daun_pintu'),
      ohMandorKunci: g('oh_mandor_kunci'),
      ohMandorEngselPintu: g('oh_mandor_engsel_pintu'),
      ohMandorDaunJendela: g('oh_mandor_daun_jendela'),
      ohMandorKaca: g('oh_mandor_kaca'),
      ohMandorEngselJendela: g('oh_mandor_engsel_jendela'),
      ohMandorRangkaPlafon: g('oh_mandor_rangka_plafon'),
      ohMandorGypsum: g('oh_mandor_gypsum'),
      ohMandorListPlafon: g('oh_mandor_list_plafon'),
      ohMandorRangkaAtap: g('oh_mandor_rangka_atap'),
      ohMandorGenteng: g('oh_mandor_genteng'),
      ohMandorListplank: g('oh_mandor_listplank'),
      ohMandorNok: g('oh_mandor_nok'),
      ohMandorCatTembok: g('oh_mandor_cat_tembok'),
      ohMandorCatKayu: g('oh_mandor_cat_kayu'),
    );
  }

  Future<void> _simpan() async {
    setState(() => _menyimpan = true);
    try {
      final koefisienBaru = _bacaDariControllers();
      final idAdmin = FirebaseAuth.instance.currentUser?.uid ?? 'admin';

      // Tangkap nilai lama SEBELUM simpan pakai snapshot lama
      final mapLama = context.read<KoefisienProvider>().aktif.keFirestore()
        ..remove('diperbarui_pada');

      await context.read<KoefisienProvider>().simpanDanRefresh(
            koefisien: koefisienBaru,
            idAdmin: idAdmin,
          );

      // bandingkan lama vs baru
      final mapBaru = koefisienBaru.keFirestore()..remove('diperbarui_pada');
      
      for (final key in mapLama.keys) {
        final valLama = (mapLama[key] as num?)?.toDouble() ?? 0.0;
        final valBaru = (mapBaru[key] as num?)?.toDouble() ?? 0.0;
        
        // Lewati jika tidak berubah 
        if ((valLama - valBaru).abs() < 1e-10) continue;

         final namaLabel = _semuaLabel[key] ?? key;
        final tipeLabel = switch (_tabController.index) {
          0 => 'Koefisien Material',
          1 => 'Koefisien OH Pekerja',
          2 => 'Koefisien OH Tukang',
          3 => 'Koefisien OH Mandor',
          _ => 'Koefisien SNI',
        };

        await _layananNotif.catatPembaruan(
          judul: 'Pembaruan $tipeLabel: $namaLabel',
          idAdmin: idAdmin,
          hargaLama: valLama,
          hargaBaru: valBaru,
        );
      }

      if (mounted) {
        setState(() => _adaPerubahan = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Koefisien berhasil disimpan & dicatat ke Riwayat'),
            backgroundColor: AppStyles.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _menyimpan = false);
    }
  }

  void _resetKeDefault() {
    const fb = KoefisienAktif();
    final semua = fb.keFirestore()..remove('diperbarui_pada');
    for (final entry in semua.entries) {
      final nilai = (entry.value as num?)?.toDouble() ?? 0.0;
      _controllers[entry.key]?.text = _formatNilai(nilai);
    }
    setState(() => _adaPerubahan = true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KOEFISIEN SNI',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2),
                ),
                Text(
                  'Faktor kebutuhan material & upah (OH) per satuan volume',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            Row(
              children: [
                if (_adaPerubahan)
                  TextButton.icon(
                    onPressed: _resetKeDefault,
                    icon: const Icon(Icons.restore, size: 16),
                    label: const Text('Reset Default'),
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[600]),
                  ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: (_adaPerubahan && !_menyimpan) ? _simpan : null,
                  icon: _menyimpan
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save_outlined, size: 16),
                  label: const Text('Simpan Perubahan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.primaryGreen,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (_adaPerubahan)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              border: Border.all(color: Colors.amber.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber_rounded,
                    size: 14, color: Colors.amber[700]),
                const SizedBox(width: 6),
                Text(
                  'Ada perubahan belum disimpan. Perubahan hanya berlaku untuk proyek baru.',
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.amber[800],
                      fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),

        // Tab bar
        TabBar(
          controller: _tabController,
          labelColor: AppStyles.primaryGreen,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppStyles.primaryGreen,
          tabs: const [
            Tab(text: _tabMaterial),
            Tab(text: _tabOhPekerja),
            Tab(text: _tabOhTukang),
            Tab(text: _tabOhMandor),
          ],
        ),
        const Divider(height: 1),
        const SizedBox(height: 8),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildGrid(_labelMaterial),
              _buildGrid(_labelOhPekerja),
              _buildGrid(_labelOhTukang),
              _buildGrid(_labelOhMandor),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGrid(Map<String, String> labels) {
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Wrap(
          spacing: 16,
          runSpacing: 12,
          children:
              labels.entries.map((e) => _buildFieldTile(e.key, e.value)).toList(),
        ),
      ),
    );
  }

  Widget _buildFieldTile(String key, String label) {
    return SizedBox(
      width: 320,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(
            key,
            style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 36,
            child: TextField(
              controller: _controllers[key],
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide:
                      const BorderSide(color: AppStyles.primaryGreen),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}