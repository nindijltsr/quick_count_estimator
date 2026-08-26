import '../models/model_input_surveyor.dart';
import '../models/model_hasil_perhitungan.dart';
import '../models/model_rekap_dan_lainnya.dart';
import '../models/model_koefisien.dart';

class LayananPerhitungan {
  /// Koefisien geometri bangunan 
  HasilMenuA hitungMenuA(InputSurveyor input) {
    final double pTanah = input.pTanah;
    final double lTanah = input.lTanah;
    final double pPondasi = input.pPondasi;
    final int jmlTitikTapak = input.jmlTitikTapak;

    final double volBersih = pTanah * lTanah;
    final double volBouwplank = (pTanah + lTanah) * 2;
    final double volGalianMenerus = pPondasi * 0.80 * 0.85;
    final double volPasirMenerus = pPondasi * 1.00 * 0.05;
    final double volAanstampMenerus = pPondasi * 1.00 * 0.10;
    final double volBatuKali = pPondasi * 0.48;
    final double volGalianTapak = jmlTitikTapak * 1.5;
    final double volPasirTapak = jmlTitikTapak * 0.072;
    final double volAanstampTapak = jmlTitikTapak * 0.144;
    final double volBetonTapak = jmlTitikTapak * 0.3335;
    final double volUrugMenerus = volGalianMenerus * 0.25;
    final double volUrugTapak = volGalianTapak * 0.75;

    return HasilMenuA(
      volBersih: volBersih, volBouwplank: volBouwplank,
      volGalianMenerus: volGalianMenerus, volPasirMenerus: volPasirMenerus,
      volAanstampMenerus: volAanstampMenerus, volBatuKali: volBatuKali,
      volGalianTapak: volGalianTapak, volPasirTapak: volPasirTapak,
      volAanstampTapak: volAanstampTapak, volBetonTapak: volBetonTapak,
      volUrugMenerus: volUrugMenerus, volUrugTapak: volUrugTapak,
      dihitungPada: DateTime.now(),
    );
  }

  HasilMenuB hitungMenuB(InputSurveyor input) {
    final double pDinding = input.pDinding;
    final int jmlKolom = input.jmlKolom;

    final double volSloof = pDinding * 0.15 * 0.20;
    final double volKolom = jmlKolom * 0.13 * 0.13 * 3.60;
    final double volRingBalok = pDinding * 0.15 * 0.15;
    final double volDinding = (pDinding * 3.60) * 0.825;
    final double volPlester = volDinding * 2;
    final double volAcian = volDinding * 2;

    return HasilMenuB(
      volSloof: volSloof, volKolom: volKolom, volRingBalok: volRingBalok,
      volDinding: volDinding, volPlester: volPlester, volAcian: volAcian,
      dihitungPada: DateTime.now(),
    );
  }

  HasilMenuC hitungMenuC(InputSurveyor input) {
    final double pBangunan = input.pBangunan;
    final double lBangunan = input.lBangunan;

    final double luasLantai = pBangunan * lBangunan;
    final double volTimbunan = luasLantai * 0.40;
    final double volPasirLantai = luasLantai * 0.05;
    final double volCorLantai = luasLantai * 0.05;
    final double volKeramik = luasLantai;

    return HasilMenuC(
      luasLantai: luasLantai, volTimbunan: volTimbunan,
      volPasirLantai: volPasirLantai, volCorLantai: volCorLantai,
      volKeramik: volKeramik, dihitungPada: DateTime.now(),
    );
  }

  HasilMenuD hitungMenuD(InputSurveyor input) {
    final int jmlPintu = input.jmlPintu;
    final int jmlJendela = input.jmlJendela;

    final double volKusenPintu = jmlPintu * (5.36 * 0.13 * 0.06);
    final double volDaunPintu = jmlPintu * (2.10 * 0.80);
    final double volKusenVentilasi = jmlPintu * (3.08 * 0.13 * 0.06);
    final int jmlKunci = jmlPintu * 1;
    final int jmlEngselPintu = jmlPintu * 3;
    final double volKusenJendela = jmlJendela * (5.40 * 0.13 * 0.06);
    final double volDaunJendela = jmlJendela * (0.80 * 0.60);
    final double volKaca = jmlJendela * (0.68 * 0.46);
    final int jmlEngselJendela = jmlJendela * 2;
    final double volKusenTotal = volKusenPintu + volKusenVentilasi + volKusenJendela;

    return HasilMenuD(
      volKusenPintu: volKusenPintu, volDaunPintu: volDaunPintu,
      volKusenVentilasi: volKusenVentilasi, jmlKunci: jmlKunci,
      jmlEngselPintu: jmlEngselPintu, volKusenJendela: volKusenJendela,
      volDaunJendela: volDaunJendela, volKaca: volKaca,
      jmlEngselJendela: jmlEngselJendela, volKusenTotal: volKusenTotal,
      dihitungPada: DateTime.now(),
    );
  }

  HasilMenuE hitungMenuE(InputSurveyor input) {
    final double pBangunan = input.pBangunan;
    final double lBangunan = input.lBangunan;

    final double volPlafon = pBangunan * lBangunan;
    final double volListPlafon = 2 * (pBangunan + lBangunan);
    final double volRangkaAtap = ((pBangunan + 2) * (lBangunan + 2)) / 0.866;
    final double volGenteng = volRangkaAtap;
    final double volListplank = 2 * ((pBangunan + 2) + (lBangunan + 2));
    final double volNok = pBangunan + 2;

    return HasilMenuE(
      volPlafon: volPlafon, volListPlafon: volListPlafon,
      volRangkaAtap: volRangkaAtap, volGenteng: volGenteng,
      volListplank: volListplank, volNok: volNok,
      dihitungPada: DateTime.now(),
    );
  }

  HasilMenuF hitungMenuF({
    required HasilMenuB hasilB,
    required HasilMenuD hasilD,
    required HasilMenuE hasilE,
    required InputSurveyor input,
  }) {
    final double volCatTembok = hasilB.volDinding;
    final double volCatPlafon = hasilE.volPlafon;
    final double volCatKayu = hasilD.volDaunPintu + hasilD.volDaunJendela;
    return HasilMenuF(
      volCatTembok: volCatTembok, volCatPlafon: volCatPlafon,
      volCatKayu: volCatKayu, volLampu: input.jmlLampu,
      volSaklar1: input.jmlSaklar1, volSaklar2: input.jmlSaklar2,
      volStopKontak: input.jmlStopKontak, dihitungPada: DateTime.now(),
    );
  }

  /// Kalkulasi material & upah menggunakan koefisien
  ({RekapMaterial rekap, HasilMenuG menuG}) hitungMaterialDanUpah({
    required HasilMenuA a, required HasilMenuB b, required HasilMenuC c,
    required HasilMenuD d, required HasilMenuE e, required HasilMenuF f,
    required Map<String, double> hargaMaterial,
    required HargaUpah hargaUpah,
    required KoefisienAktif k,
  }) {
    // ── Akumulasi OH ──
    double totalOhPekerja = 0;
    double totalOhTukang = 0;
    double totalOhMandor = 0;

    totalOhPekerja += a.volBersih * k.ohPekerjaBersih;
    totalOhMandor += a.volBersih * k.ohMandorBersih;

    totalOhPekerja += a.volBouwplank * k.ohPekerjaBouwplank;
    totalOhTukang += a.volBouwplank * k.ohTukangBouwplank;
    totalOhMandor += a.volBouwplank * k.ohMandorBouwplank;

    final double volGalianTotal = a.volGalianMenerus + a.volGalianTapak;
    totalOhPekerja += volGalianTotal * k.ohPekerjaGalian;
    totalOhMandor += volGalianTotal * k.ohMandorGalian;

    final double volPasirTotal = a.volPasirMenerus + a.volPasirTapak;
    totalOhPekerja += volPasirTotal * k.ohPekerjaPasirUrug;
    totalOhMandor += volPasirTotal * k.ohMandorPasirUrug;

    final double volAanstampTotal = a.volAanstampMenerus + a.volAanstampTapak;
    totalOhPekerja += volAanstampTotal * k.ohPekerjaAanstamp;
    totalOhTukang += volAanstampTotal * k.ohTukangAanstamp;
    totalOhMandor += volAanstampTotal * k.ohMandorAanstamp;

    totalOhPekerja += a.volBatuKali * k.ohPekerjaBatuKali;
    totalOhTukang += a.volBatuKali * k.ohTukangBatuKali;
    totalOhMandor += a.volBatuKali * k.ohMandorBatuKali;

    final double volUrugTotal = a.volUrugMenerus + a.volUrugTapak;
    totalOhPekerja += volUrugTotal * k.ohPekerjaUrug;
    totalOhMandor += volUrugTotal * k.ohMandorUrug;

    totalOhPekerja += a.volBetonTapak * k.ohPekerjaBetonTapak;
    totalOhTukang += a.volBetonTapak * k.ohTukangBetonTapak;
    totalOhMandor += a.volBetonTapak * k.ohMandorBetonTapak;

    totalOhPekerja += b.volSloof * k.ohPekerjaSloof;
    totalOhTukang += b.volSloof * k.ohTukangSloof;
    totalOhMandor += b.volSloof * k.ohMandorSloof;

    totalOhPekerja += b.volKolom * k.ohPekerjaKolom;
    totalOhTukang += b.volKolom * k.ohTukangKolom;
    totalOhMandor += b.volKolom * k.ohMandorKolom;

    totalOhPekerja += b.volRingBalok * k.ohPekerjaRingBalok;
    totalOhTukang += b.volRingBalok * k.ohTukangRingBalok;
    totalOhMandor += b.volRingBalok * k.ohMandorRingBalok;

    totalOhPekerja += b.volDinding * k.ohPekerjaDinding;
    totalOhTukang += b.volDinding * k.ohTukangDinding;
    totalOhMandor += b.volDinding * k.ohMandorDinding;

    totalOhPekerja += b.volPlester * k.ohPekerjaPlester;
    totalOhTukang += b.volPlester * k.ohTukangPlester;
    totalOhMandor += b.volPlester * k.ohMandorPlester;

    totalOhPekerja += b.volAcian * k.ohPekerjaAcian;
    totalOhTukang += b.volAcian * k.ohTukangAcian;
    totalOhMandor += b.volAcian * k.ohMandorAcian;

    totalOhPekerja += c.volTimbunan * k.ohPekerjaTimbunan;
    totalOhMandor += c.volTimbunan * k.ohMandorTimbunan;

    totalOhPekerja += c.volPasirLantai * k.ohPekerjaPasirLantai;
    totalOhMandor += c.volPasirLantai * k.ohMandorPasirLantai;

    totalOhPekerja += c.volCorLantai * k.ohPekerjaCorLantai;
    totalOhTukang += c.volCorLantai * k.ohTukangCorLantai;
    totalOhMandor += c.volCorLantai * k.ohMandorCorLantai;

    totalOhPekerja += c.volKeramik * k.ohPekerjaKeramik;
    totalOhTukang += c.volKeramik * k.ohTukangKeramik;
    totalOhMandor += c.volKeramik * k.ohMandorKeramik;

    totalOhPekerja += d.volKusenTotal * k.ohPekerjaKusen;
    totalOhTukang += d.volKusenTotal * k.ohTukangKusen;
    totalOhMandor += d.volKusenTotal * k.ohMandorKusen;

    totalOhPekerja += d.volDaunPintu * k.ohPekerjaDaunPintu;
    totalOhTukang += d.volDaunPintu * k.ohTukangDaunPintu;
    totalOhMandor += d.volDaunPintu * k.ohMandorDaunPintu;

    totalOhPekerja += d.jmlKunci * k.ohPekerjaKunci;
    totalOhTukang += d.jmlKunci * k.ohTukangKunci;
    totalOhMandor += d.jmlKunci * k.ohMandorKunci;

    totalOhPekerja += d.jmlEngselPintu * k.ohPekerjaEngselPintu;
    totalOhTukang += d.jmlEngselPintu * k.ohTukangEngselPintu;
    totalOhMandor += d.jmlEngselPintu * k.ohMandorEngselPintu;

    totalOhPekerja += d.volDaunJendela * k.ohPekerjaDaunJendela;
    totalOhTukang += d.volDaunJendela * k.ohTukangDaunJendela;
    totalOhMandor += d.volDaunJendela * k.ohMandorDaunJendela;

    totalOhPekerja += d.volKaca * k.ohPekerjaKaca;
    totalOhTukang += d.volKaca * k.ohTukangKaca;
    totalOhMandor += d.volKaca * k.ohMandorKaca;

    totalOhPekerja += d.jmlEngselJendela * k.ohPekerjaEngselJendela;
    totalOhTukang += d.jmlEngselJendela * k.ohTukangEngselJendela;
    totalOhMandor += d.jmlEngselJendela * k.ohMandorEngselJendela;

    // Rangka plafon (pasang hollow) & gypsum — 2 pekerjaan terpisah
    totalOhPekerja += e.volPlafon * k.ohPekerjaRangkaPlafon;
    totalOhTukang += e.volPlafon * k.ohTukangRangkaPlafon;
    totalOhMandor += e.volPlafon * k.ohMandorRangkaPlafon;

    totalOhPekerja += e.volPlafon * k.ohPekerjaGypsum;
    totalOhTukang += e.volPlafon * k.ohTukangGypsum;
    totalOhMandor += e.volPlafon * k.ohMandorGypsum;

    totalOhPekerja += e.volListPlafon * k.ohPekerjaListPlafon;
    totalOhTukang += e.volListPlafon * k.ohTukangListPlafon;
    totalOhMandor += e.volListPlafon * k.ohMandorListPlafon;

    totalOhPekerja += e.volRangkaAtap * k.ohPekerjaRangkaAtap;
    totalOhTukang += e.volRangkaAtap * k.ohTukangRangkaAtap;
    totalOhMandor += e.volRangkaAtap * k.ohMandorRangkaAtap;

    totalOhPekerja += e.volGenteng * k.ohPekerjaGenteng;
    totalOhTukang += e.volGenteng * k.ohTukangGenteng;
    totalOhMandor += e.volGenteng * k.ohMandorGenteng;

    totalOhPekerja += e.volListplank * k.ohPekerjaListplank;
    totalOhTukang += e.volListplank * k.ohTukangListplank;
    totalOhMandor += e.volListplank * k.ohMandorListplank;

    totalOhPekerja += e.volNok * k.ohPekerjaNok;
    totalOhTukang += e.volNok * k.ohTukangNok;
    totalOhMandor += e.volNok * k.ohMandorNok;

    final double volCatTembokPlafon = f.volCatTembok + f.volCatPlafon;
    totalOhPekerja += volCatTembokPlafon * k.ohPekerjaCatTembok;
    totalOhTukang += volCatTembokPlafon * k.ohTukangCatTembok;
    totalOhMandor += volCatTembokPlafon * k.ohMandorCatTembok;

    totalOhPekerja += f.volCatKayu * k.ohPekerjaCatKayu;
    totalOhTukang += f.volCatKayu * k.ohTukangCatKayu;
    totalOhMandor += f.volCatKayu * k.ohMandorCatKayu;

    final double biayaUpahPekerja = totalOhPekerja * hargaUpah.pekerja;
    final double biayaUpahTukang = totalOhTukang * hargaUpah.tukang;
    final double biayaUpahMandor = totalOhMandor * hargaUpah.mandor;
    final double totalBiayaUpah = biayaUpahPekerja + biayaUpahTukang + biayaUpahMandor;

    final menuG = HasilMenuG(
      totalOhPekerja: totalOhPekerja, totalOhTukang: totalOhTukang, totalOhMandor: totalOhMandor,
      biayaUpahPekerja: biayaUpahPekerja, biayaUpahTukang: biayaUpahTukang, biayaUpahMandor: biayaUpahMandor,
      totalBiayaUpah: totalBiayaUpah, dihitungPada: DateTime.now(),
    );

    // ── Rekap Material (menggunakan koefisien dari k) ──
    double hp(String id) => hargaMaterial[id] ?? 0;

    final double tanahTimbun = c.volTimbunan * k.matTanahTimbun;
    final double batuKali = (a.volAanstampMenerus + a.volAanstampTapak) * k.matBatuKali + a.volBatuKali * k.matBatuKali;
    final double kerikil = a.volBetonTapak * k.matKerikilBeton + (b.volSloof + b.volKolom + b.volRingBalok) * k.matKerikilBeton + c.volCorLantai * k.matKerikilLantai;
    final double pasirUrug = (a.volPasirMenerus + a.volPasirTapak) * k.matPasirUrug + (a.volAanstampMenerus + a.volAanstampTapak) * k.matAanstampPasirUrug + c.volPasirLantai * k.matPasirUrug;
    final double pasirPasang = a.volBatuKali * k.matPasirPasangBatuKali + b.volDinding * k.matPasirPasangDinding + b.volPlester * k.matPasirPasangPlester + c.volKeramik * k.matPasirPasangKeramik;
    final double pasirBeton = a.volBetonTapak * k.matPasirBeton + (b.volSloof + b.volKolom + b.volRingBalok) * k.matPasirBeton + c.volCorLantai * k.matPasirBetonLantai;
    final double semen = a.volBatuKali * k.matSemenBatuKali + (a.volBetonTapak + b.volSloof + b.volKolom + b.volRingBalok) * k.matSemenBeton + b.volDinding * k.matSemenDinding + b.volPlester * k.matSemenPlester + b.volAcian * k.matSemenAcian + c.volCorLantai * k.matSemenLantai + c.volKeramik * k.matSemenKeramik;
    final double bataMerah = b.volDinding * k.matBataMerah;
    final double besiPolos = b.volSloof * k.matBesiSloof + b.volKolom * k.matBesiKolom + b.volRingBalok * k.matBesiRingBalok;
    final double hollow4x4 = e.volPlafon * k.matHollow4x4;
    final double hollow2x4 = e.volPlafon * k.matHollow2x4;
    final double profilC75 = e.volRangkaAtap * k.matProfilC75;
    final double rengBaja = e.volRangkaAtap * k.matRengBaja;
    final double kayuBalok57 = a.volBouwplank * k.matKayuBalok57;
    final double papanBekisting = a.volBouwplank * k.matPapanBekisting1 + b.volSloof * k.matPapanBekistingSloof + b.volKolom * k.matPapanBekistingKolom + b.volRingBalok * k.matPapanBekistingRing;
    final double balkKayuKelas1 = d.volKusenTotal * k.matBalkKayuKelas1;
    final double balkKayuKelas2 = d.volDaunPintu * k.matBalkKayuKelas2;
    final double papanKayuKelas2 = d.volDaunJendela * k.matPapanKayuKelas2;
    final double papanListplank = e.volListplank * k.matPapanListplank;
    final double gentengGalvalum = e.volGenteng * k.matGentengGalvalum;
    final double nokGalvalum = e.volNok * k.matNokGalvalum;
    final double papanGypsum = e.volPlafon * k.matPapanGypsum;
    final double listProfilKayu = e.volListPlafon * k.matListProfilKayu;
    final double kaca5mm = d.volKaca * k.matKaca5mm;
    final double kunciPintu = d.jmlKunci.toDouble();
    final double engselPintu = d.jmlEngselPintu.toDouble();
    final double engselJendela = d.jmlEngselJendela.toDouble();
    final double keramik = c.volKeramik * k.matKeramik;
    final double plamirTembok = volCatTembokPlafon * k.matPlamirTembok;
    final double catDasarTembok = volCatTembokPlafon * k.matCatDasarTembok;
    final double catTembok = volCatTembokPlafon * k.matCatTembok;
    final double catMenie = f.volCatKayu * k.matCatMenie;
    final double plamirKayu = f.volCatKayu * k.matPlamirKayu;
    final double catDasarKayu = f.volCatKayu * k.matCatDasarKayu;
    final double catKayu = f.volCatKayu * k.matCatKayu;
    final double lampuLed = f.volLampu.toDouble();
    final double saklarTunggal = f.volSaklar1.toDouble();
    final double saklarGanda = f.volSaklar2.toDouble();
    final double stopKontak = f.volStopKontak.toDouble();

    final double totalBiaya =
        tanahTimbun * hp('tanah_timbun') + batuKali * hp('batu_kali') + kerikil * hp('kerikil') +
        pasirUrug * hp('pasir_urug') + pasirPasang * hp('pasir_pasang') + pasirBeton * hp('pasir_beton') +
        semen * hp('semen_pc') + bataMerah * hp('bata_merah') + besiPolos * hp('besi_polos') +
        hollow4x4 * hp('hollow_4x4') + hollow2x4 * hp('hollow_2x4') + profilC75 * hp('profil_c75') +
        rengBaja * hp('reng_baja') + kayuBalok57 * hp('kayu_balok_57') + papanBekisting * hp('papan_bekisting') +
        balkKayuKelas1 * hp('balok_kayu_kelas1') + balkKayuKelas2 * hp('balok_kayu_kelas2') + papanKayuKelas2 * hp('papan_kayu_kelas2') +
        papanListplank * hp('papan_listplank') + gentengGalvalum * hp('genteng_galvalum') + nokGalvalum * hp('nok_galvalum') +
        papanGypsum * hp('papan_gypsum') + listProfilKayu * hp('list_profil_kayu') + kaca5mm * hp('kaca_5mm') +
        kunciPintu * hp('kunci_pintu') + engselPintu * hp('engsel_pintu') + engselJendela * hp('engsel_jendela') +
        keramik * hp('keramik_40x40') + plamirTembok * hp('plamir_tembok') + catDasarTembok * hp('cat_dasar_tembok') +
        catTembok * hp('cat_tembok') + catMenie * hp('cat_menie') + plamirKayu * hp('plamir_kayu') +
        catDasarKayu * hp('cat_dasar_kayu') + catKayu * hp('cat_kayu') + lampuLed * hp('lampu_led_18w') +
        saklarTunggal * hp('saklar_tunggal') + saklarGanda * hp('saklar_ganda') + stopKontak * hp('stop_kontak');

    // Rincian kartu UI (sama persis logikanya, hanya koefisien dari k)
    final biayaPasirPondasi = ((a.volPasirMenerus + a.volPasirTapak) * k.matPasirUrug * hp('pasir_urug')) + (c.volPasirLantai * k.matPasirUrug * hp('pasir_urug'));
    final biayaAanstamping = (a.volAanstampMenerus + a.volAanstampTapak) * k.matBatuKali * hp('batu_kali') + (a.volAanstampMenerus + a.volAanstampTapak) * k.matAanstampPasirUrug * hp('pasir_urug');
    final biayaBatuKali = (a.volBatuKali * k.matBatuKali * hp('batu_kali')) + (a.volBatuKali * k.matSemenBatuKali * hp('semen_pc')) + (a.volBatuKali * k.matPasirPasangBatuKali * hp('pasir_pasang'));
    final biayaBetonTapak = (a.volBetonTapak * k.matKerikilBeton * hp('kerikil')) + (a.volBetonTapak * k.matPasirBeton * hp('pasir_beton')) + (a.volBetonTapak * k.matSemenBeton * hp('semen_pc'));
    final biayaBesi = besiPolos * hp('besi_polos');
    final biayaDinding = (bataMerah * hp('bata_merah')) + (b.volDinding * k.matSemenDinding * hp('semen_pc')) + (b.volDinding * k.matPasirPasangDinding * hp('pasir_pasang'));
    final biayaSemenPlester = (b.volPlester * k.matSemenPlester * hp('semen_pc')) + (b.volPlester * k.matPasirPasangPlester * hp('pasir_pasang')) + (b.volAcian * k.matSemenAcian * hp('semen_pc'));
    final biayaTanahTimbun = tanahTimbun * hp('tanah_timbun');
    final biayaKeramik = (keramik * hp('keramik_40x40')) + (c.volKeramik * k.matSemenKeramik * hp('semen_pc')) + (c.volKeramik * k.matPasirPasangKeramik * hp('pasir_pasang'));
    final biayaKusen = balkKayuKelas1 * hp('balok_kayu_kelas1');
    final biayaDaunPintu = balkKayuKelas2 * hp('balok_kayu_kelas2');
    final biayaDaunJendela = papanKayuKelas2 * hp('papan_kayu_kelas2');
    final biayaKaca = kaca5mm * hp('kaca_5mm');
    final biayaKunci = kunciPintu * hp('kunci_pintu');
    final biayaEngsel = (engselPintu * hp('engsel_pintu')) + (engselJendela * hp('engsel_jendela'));
    final biayaRangkaPlafon = (hollow4x4 * hp('hollow_4x4')) + (hollow2x4 * hp('hollow_2x4'));
    final biayaGypsum = papanGypsum * hp('papan_gypsum');
    final biayaListPlafon = listProfilKayu * hp('list_profil_kayu');
    final biayaAtap = (profilC75 * hp('profil_c75')) + (rengBaja * hp('reng_baja')) + (gentengGalvalum * hp('genteng_galvalum')) + (nokGalvalum * hp('nok_galvalum'));
    final biayaListplank = papanListplank * hp('papan_listplank');
    final biayaCatTembok = (plamirTembok * hp('plamir_tembok')) + (catDasarTembok * hp('cat_dasar_tembok')) + (catTembok * hp('cat_tembok'));
    final biayaCatKayu = (catMenie * hp('cat_menie')) + (plamirKayu * hp('plamir_kayu')) + (catDasarKayu * hp('cat_dasar_kayu')) + (catKayu * hp('cat_kayu'));
    final biayaListrik = (lampuLed * hp('lampu_led_18w')) + (saklarTunggal * hp('saklar_tunggal')) + (saklarGanda * hp('saklar_ganda')) + (stopKontak * hp('stop_kontak'));

    final rekap = RekapMaterial(
      tanahTimbun_m3: tanahTimbun, batuKali_m3: batuKali, kerikil_kg: kerikil,
      pasirUrug_m3: pasirUrug, pasirPasang_m3: pasirPasang, pasirBeton_kg: pasirBeton,
      semen_kg: semen, bataMerah_buah: bataMerah, besiPolos_kg: besiPolos,
      hollow4x4_batang: hollow4x4, hollow2x4_batang: hollow2x4, profilC75_m: profilC75,
      rengBaja_m: rengBaja, kayuBalok57_m3: kayuBalok57, papanBekisting_m2: papanBekisting,
      balkKayuKelas1_m3: balkKayuKelas1, balkKayuKelas2_m3: balkKayuKelas2, papanKayuKelas2_m3: papanKayuKelas2,
      papanListplank_m3: papanListplank, gentengGalvalum_m2: gentengGalvalum, nokGalvalum_m: nokGalvalum,
      papanGypsum_lembar: papanGypsum, listProfilKayu_m: listProfilKayu, kaca5mm_m2: kaca5mm,
      kunciPintu_buah: kunciPintu, engselPintu_buah: engselPintu, engselJendela_buah: engselJendela,
      keramik40x40_buah: keramik, plamirTembok_kg: plamirTembok, catDasarTembok_kg: catDasarTembok,
      catTembok_kg: catTembok, catMenie_kg: catMenie, plamirKayu_kg: plamirKayu,
      catDasarKayu_kg: catDasarKayu, catKayu_kg: catKayu, lampuLed_buah: lampuLed,
      saklarTunggal_buah: saklarTunggal, saklarGanda_buah: saklarGanda, stopKontak_buah: stopKontak,
      totalBiayaMaterial: totalBiaya, dihitungPada: DateTime.now(),
      biayaPasirPondasi: biayaPasirPondasi, biayaAanstamping: biayaAanstamping, biayaBatuKali: biayaBatuKali,
      biayaBetonTapak: biayaBetonTapak, biayaBesi: biayaBesi, biayaDinding: biayaDinding,
      biayaSemenPlester: biayaSemenPlester, biayaTanahTimbun: biayaTanahTimbun, biayaKeramik: biayaKeramik,
      biayaKusen: biayaKusen, biayaDaunPintu: biayaDaunPintu, biayaDaunJendela: biayaDaunJendela,
      biayaKaca: biayaKaca, biayaKunci: biayaKunci, biayaEngsel: biayaEngsel,
      biayaRangkaPlafon: biayaRangkaPlafon, biayaGypsum: biayaGypsum, biayaListPlafon: biayaListPlafon,
      biayaAtap: biayaAtap, biayaListplank: biayaListplank, biayaCatTembok: biayaCatTembok,
      biayaCatKayu: biayaCatKayu, biayaListrik: biayaListrik,
    );

    return (rekap: rekap, menuG: menuG);
  }

  Future<({HasilMenuA a, HasilMenuB b, HasilMenuC c, HasilMenuD d, HasilMenuE e, HasilMenuF f, HasilMenuG g, RekapMaterial rekap})> hitungSemua({
    required InputSurveyor input,
    required Map<String, double> hargaMaterial,
    required HargaUpah hargaUpah,
    required KoefisienAktif k,
  }) async {
    final a = hitungMenuA(input); final b = hitungMenuB(input); final c = hitungMenuC(input);
    final d = hitungMenuD(input); final e = hitungMenuE(input);
    final f = hitungMenuF(hasilB: b, hasilD: d, hasilE: e, input: input);
    final (:rekap, :menuG) = hitungMaterialDanUpah(
      a: a, b: b, c: c, d: d, e: e, f: f,
      hargaMaterial: hargaMaterial, hargaUpah: hargaUpah, k: k,
    );
    return (a: a, b: b, c: c, d: d, e: e, f: f, g: menuG, rekap: rekap);
  }
}