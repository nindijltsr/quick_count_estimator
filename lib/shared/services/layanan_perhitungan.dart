// lib/shared/services/layanan_perhitungan.dart

import '../models/model_input_surveyor.dart';
import '../models/model_hasil_perhitungan.dart';
import '../models/model_rekap_dan_lainnya.dart';

class LayananPerhitungan {
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

    return HasilMenuA(volBersih: volBersih, volBouwplank: volBouwplank, volGalianMenerus: volGalianMenerus, volPasirMenerus: volPasirMenerus, volAanstampMenerus: volAanstampMenerus, volBatuKali: volBatuKali, volGalianTapak: volGalianTapak, volPasirTapak: volPasirTapak, volAanstampTapak: volAanstampTapak, volBetonTapak: volBetonTapak, volUrugMenerus: volUrugMenerus, volUrugTapak: volUrugTapak, dihitungPada: DateTime.now());
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

    return HasilMenuB(volSloof: volSloof, volKolom: volKolom, volRingBalok: volRingBalok, volDinding: volDinding, volPlester: volPlester, volAcian: volAcian, dihitungPada: DateTime.now());
  }

  HasilMenuC hitungMenuC(InputSurveyor input) {
    final double pBangunan = input.pBangunan;
    final double lBangunan = input.lBangunan;

    final double luasLantai = pBangunan * lBangunan;
    final double volTimbunan = luasLantai * 0.40;
    final double volPasirLantai = luasLantai * 0.05;
    final double volCorLantai = luasLantai * 0.05;
    final double volKeramik = luasLantai;

    return HasilMenuC(luasLantai: luasLantai, volTimbunan: volTimbunan, volPasirLantai: volPasirLantai, volCorLantai: volCorLantai, volKeramik: volKeramik, dihitungPada: DateTime.now());
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

    return HasilMenuD(volKusenPintu: volKusenPintu, volDaunPintu: volDaunPintu, volKusenVentilasi: volKusenVentilasi, jmlKunci: jmlKunci, jmlEngselPintu: jmlEngselPintu, volKusenJendela: volKusenJendela, volDaunJendela: volDaunJendela, volKaca: volKaca, jmlEngselJendela: jmlEngselJendela, volKusenTotal: volKusenTotal, dihitungPada: DateTime.now());
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

    return HasilMenuE(volPlafon: volPlafon, volListPlafon: volListPlafon, volRangkaAtap: volRangkaAtap, volGenteng: volGenteng, volListplank: volListplank, volNok: volNok, dihitungPada: DateTime.now());
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
    final int volLampu = input.jmlLampu;
    final int volSaklar1 = input.jmlSaklar1;
    final int volSaklar2 = input.jmlSaklar2;
    final int volStopKontak = input.jmlStopKontak;

    return HasilMenuF(volCatTembok: volCatTembok, volCatPlafon: volCatPlafon, volCatKayu: volCatKayu, volLampu: volLampu, volSaklar1: volSaklar1, volSaklar2: volSaklar2, volStopKontak: volStopKontak, dihitungPada: DateTime.now());
  }

  ({RekapMaterial rekap, HasilMenuG menuG}) hitungMaterialDanUpah({
    required HasilMenuA a, required HasilMenuB b, required HasilMenuC c,
    required HasilMenuD d, required HasilMenuE e, required HasilMenuF f,
    required Map<String, double> hargaMaterial, required HargaUpah hargaUpah,
  }) {
    // Akumulasi OH
    double totalOhPekerja = 0; double totalOhTukang = 0; double totalOhMandor = 0;

    totalOhPekerja += a.volBersih * 0.100; totalOhMandor += a.volBersih * 0.050;
    totalOhPekerja += a.volBouwplank * 0.100; totalOhTukang += a.volBouwplank * 0.100; totalOhMandor += a.volBouwplank * 0.005;
    
    final double volGalianTotal = a.volGalianMenerus + a.volGalianTapak;
    totalOhPekerja += volGalianTotal * 0.750; totalOhMandor += volGalianTotal * 0.025;
    
    final double volPasirTotal = a.volPasirMenerus + a.volPasirTapak;
    totalOhPekerja += volPasirTotal * 0.300; totalOhMandor += volPasirTotal * 0.010;
    
    final double volAanstampTotal = a.volAanstampMenerus + a.volAanstampTapak;
    totalOhPekerja += volAanstampTotal * 0.780; totalOhTukang += volAanstampTotal * 0.390; totalOhMandor += volAanstampTotal * 0.039;
    
    totalOhPekerja += a.volBatuKali * 1.500; totalOhTukang += a.volBatuKali * 0.750; totalOhMandor += a.volBatuKali * 0.075;
    
    final double volUrugTotal = a.volUrugMenerus + a.volUrugTapak;
    totalOhPekerja += volUrugTotal * 0.250; totalOhMandor += volUrugTotal * 0.083;
    
    totalOhPekerja += a.volBetonTapak * 1.650; totalOhTukang += a.volBetonTapak * 0.275; totalOhMandor += a.volBetonTapak * 0.083;
    
    totalOhPekerja += b.volSloof * 1.650; totalOhTukang += b.volSloof * 0.275; totalOhMandor += b.volSloof * 0.083;
    totalOhPekerja += b.volKolom * 1.650; totalOhTukang += b.volKolom * 0.275; totalOhMandor += b.volKolom * 0.083;
    totalOhPekerja += b.volRingBalok * 1.650; totalOhTukang += b.volRingBalok * 0.275; totalOhMandor += b.volRingBalok * 0.083;
    
    totalOhPekerja += b.volDinding * 0.300; totalOhTukang += b.volDinding * 0.100; totalOhMandor += b.volDinding * 0.015;
    totalOhPekerja += b.volPlester * 0.300; totalOhTukang += b.volPlester * 0.150; totalOhMandor += b.volPlester * 0.015;
    totalOhPekerja += b.volAcian * 0.200; totalOhTukang += b.volAcian * 0.100; totalOhMandor += b.volAcian * 0.010;
    
    totalOhPekerja += c.volTimbunan * 0.300; totalOhMandor += c.volTimbunan * 0.010;
    totalOhPekerja += c.volPasirLantai * 0.300; totalOhMandor += c.volPasirLantai * 0.010;
    totalOhPekerja += c.volCorLantai * 1.650; totalOhTukang += c.volCorLantai * 0.275; totalOhMandor += c.volCorLantai * 0.083;
    totalOhPekerja += c.volKeramik * 0.700; totalOhTukang += c.volKeramik * 0.350; totalOhMandor += c.volKeramik * 0.035;
    
    totalOhPekerja += d.volKusenTotal * 7.000; totalOhTukang += d.volKusenTotal * 21.000; totalOhMandor += d.volKusenTotal * 0.350;
    totalOhPekerja += d.volDaunPintu * 1.000; totalOhTukang += d.volDaunPintu * 3.000; totalOhMandor += d.volDaunPintu * 0.050;
    totalOhPekerja += d.jmlKunci * 0.005; totalOhTukang += d.jmlKunci * 0.500; totalOhMandor += d.jmlKunci * 0.003;
    totalOhPekerja += d.jmlEngselPintu * 0.015; totalOhTukang += d.jmlEngselPintu * 0.150; totalOhMandor += d.jmlEngselPintu * 0.0008;
    totalOhPekerja += d.volDaunJendela * 0.800; totalOhTukang += d.volDaunJendela * 2.400; totalOhMandor += d.volDaunJendela * 0.040;
    totalOhPekerja += d.volKaca * 0.015; totalOhTukang += d.volKaca * 0.150; totalOhMandor += d.volKaca * 0.0008;
    totalOhPekerja += d.jmlEngselJendela * 0.015; totalOhTukang += d.jmlEngselJendela * 0.150; totalOhMandor += d.jmlEngselJendela * 0.0008;
    
    totalOhPekerja += e.volPlafon * 0.050; totalOhTukang += e.volPlafon * 0.050; totalOhMandor += e.volPlafon * 0.003;
    totalOhPekerja += e.volPlafon * 0.100; totalOhTukang += e.volPlafon * 0.100; totalOhMandor += e.volPlafon * 0.005;
    totalOhPekerja += e.volListPlafon * 0.050; totalOhTukang += e.volListPlafon * 0.050; totalOhMandor += e.volListPlafon * 0.003;
    totalOhPekerja += e.volRangkaAtap * 0.200; totalOhTukang += e.volRangkaAtap * 0.200; totalOhMandor += e.volRangkaAtap * 0.010;
    totalOhPekerja += e.volGenteng * 0.120; totalOhTukang += e.volGenteng * 0.060; totalOhMandor += e.volGenteng * 0.006;
    totalOhPekerja += e.volListplank * 0.100; totalOhTukang += e.volListplank * 0.200; totalOhMandor += e.volListplank * 0.005;
    totalOhPekerja += e.volNok * 0.150; totalOhTukang += e.volNok * 0.075; totalOhMandor += e.volNok * 0.008;
    
    final double volCatTembokPlafon = f.volCatTembok + f.volCatPlafon;
    totalOhPekerja += volCatTembokPlafon * 0.020; totalOhTukang += volCatTembokPlafon * 0.063; totalOhMandor += volCatTembokPlafon * 0.0025;
    totalOhPekerja += f.volCatKayu * 0.070; totalOhTukang += f.volCatKayu * 0.009; totalOhMandor += f.volCatKayu * 0.003;

    final double biayaUpahPekerja = totalOhPekerja * hargaUpah.pekerja;
    final double biayaUpahTukang = totalOhTukang * hargaUpah.tukang;
    final double biayaUpahMandor = totalOhMandor * hargaUpah.mandor;
    final double totalBiayaUpah = biayaUpahPekerja + biayaUpahTukang + biayaUpahMandor;

    final menuG = HasilMenuG(
      totalOhPekerja: totalOhPekerja, totalOhTukang: totalOhTukang, totalOhMandor: totalOhMandor,
      biayaUpahPekerja: biayaUpahPekerja, biayaUpahTukang: biayaUpahTukang, biayaUpahMandor: biayaUpahMandor,
      totalBiayaUpah: totalBiayaUpah, dihitungPada: DateTime.now(),
    );

    // rekap material & hitung rincian biaya UI
    double hp(String id) => hargaMaterial[id] ?? 0;

    final double tanahTimbun = c.volTimbunan * 1.200;
    final double batuKali = (a.volAanstampMenerus + a.volAanstampTapak) * 1.200 + a.volBatuKali * 1.200;
    final double kerikil = a.volBetonTapak * 1029 + (b.volSloof + b.volKolom + b.volRingBalok) * 1029 + c.volCorLantai * 999;
    final double pasirUrug = (a.volPasirMenerus + a.volPasirTapak) * 1.200 + (a.volAanstampMenerus + a.volAanstampTapak) * 0.432 + c.volPasirLantai * 1.200;
    final double pasirPasang = a.volBatuKali * 0.520 + b.volDinding * 0.043 + b.volPlester * 0.024 + c.volKeramik * 0.045;
    final double pasirBeton = a.volBetonTapak * 760 + (b.volSloof + b.volKolom + b.volRingBalok) * 760 + c.volCorLantai * 869;
    final double semen = a.volBatuKali * 163.0 + (a.volBetonTapak + b.volSloof + b.volKolom + b.volRingBalok) * 326 + b.volDinding * 11.5 + b.volPlester * 6.24 + b.volAcian * 3.25 + c.volCorLantai * 247 + c.volKeramik * 9.80;
    final double bataMerah = b.volDinding * 70;
    final double besiPolos = b.volSloof * 80.94 + b.volKolom * 203.6 + b.volRingBalok * 194.0;
    final double hollow4x4 = e.volPlafon * 0.400;
    final double hollow2x4 = e.volPlafon * 0.400;
    final double profilC75 = e.volRangkaAtap * 1.250;
    final double rengBaja = e.volRangkaAtap * 1.500;
    final double kayuBalok57 = a.volBouwplank * 0.012;
    final double papanBekisting = a.volBouwplank * 0.007 + b.volSloof * 13.33 + b.volKolom * 15.4 + b.volRingBalok * 13.33;
    final double balkKayuKelas1 = d.volKusenTotal * 1.100;
    final double balkKayuKelas2 = d.volDaunPintu * 0.040;
    final double papanKayuKelas2 = d.volDaunJendela * 0.024;
    final double papanListplank = e.volListplank * 0.011;
    final double gentengGalvalum = e.volGenteng * 1.050;
    final double nokGalvalum = e.volNok * 1.050;
    final double papanGypsum = e.volPlafon * 0.364;
    final double listProfilKayu = e.volListPlafon * 1.050;
    final double kaca5mm = d.volKaca * 1.100;
    final double kunciPintu = d.jmlKunci.toDouble();
    final double engselPintu = d.jmlEngselPintu.toDouble();
    final double engselJendela = d.jmlEngselJendela.toDouble();
    final double keramik = c.volKeramik * 6.63;
    final double plamirTembok = volCatTembokPlafon * 0.100;
    final double catDasarTembok = volCatTembokPlafon * 0.100;
    final double catTembok = volCatTembokPlafon * 0.260;
    final double catMenie = f.volCatKayu * 0.200;
    final double plamirKayu = f.volCatKayu * 0.150;
    final double catDasarKayu = f.volCatKayu * 0.170;
    final double catKayu = f.volCatKayu * 0.260;
    final double lampuLed = f.volLampu.toDouble();
    final double saklarTunggal = f.volSaklar1.toDouble();
    final double saklarGanda = f.volSaklar2.toDouble();
    final double stopKontak = f.volStopKontak.toDouble();

    // Hitung Total Keseluruhan
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

    // Hitung Rincian Kartu UI
    final biayaPasirPondasi = ((a.volPasirMenerus + a.volPasirTapak) * 1.200 * hp('pasir_urug')) + (c.volPasirLantai * 1.200 * hp('pasir_urug'));
    final biayaAanstamping = (a.volAanstampMenerus + a.volAanstampTapak) * 1.200 * hp('batu_kali') + (a.volAanstampMenerus + a.volAanstampTapak) * 0.432 * hp('pasir_urug');
    final biayaBatuKali = (a.volBatuKali * 1.200 * hp('batu_kali')) + (a.volBatuKali * 163.0 * hp('semen_pc')) + (a.volBatuKali * 0.520 * hp('pasir_pasang'));
    final biayaBetonTapak = (a.volBetonTapak * 1029 * hp('kerikil')) + (a.volBetonTapak * 760 * hp('pasir_beton')) + (a.volBetonTapak * 326 * hp('semen_pc'));
    final biayaBesi = besiPolos * hp('besi_polos');
    final biayaDinding = (bataMerah * hp('bata_merah')) + (b.volDinding * 11.5 * hp('semen_pc')) + (b.volDinding * 0.043 * hp('pasir_pasang'));
    final biayaSemenPlester = (b.volPlester * 6.24 * hp('semen_pc')) + (b.volPlester * 0.024 * hp('pasir_pasang')) + (b.volAcian * 3.25 * hp('semen_pc'));
    final biayaTanahTimbun = tanahTimbun * hp('tanah_timbun');
    final biayaKeramik = (keramik * hp('keramik_40x40')) + (c.volKeramik * 9.80 * hp('semen_pc')) + (c.volKeramik * 0.045 * hp('pasir_pasang'));
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
    required InputSurveyor input, required Map<String, double> hargaMaterial, required HargaUpah hargaUpah,
  }) async {
    final a = hitungMenuA(input); final b = hitungMenuB(input); final c = hitungMenuC(input);
    final d = hitungMenuD(input); final e = hitungMenuE(input); final f = hitungMenuF(hasilB: b, hasilD: d, hasilE: e, input: input);
    final (:rekap, :menuG) = hitungMaterialDanUpah(a: a, b: b, c: c, d: d, e: e, f: f, hargaMaterial: hargaMaterial, hargaUpah: hargaUpah);
    return (a: a, b: b, c: c, d: d, e: e, f: f, g: menuG, rekap: rekap);
  }
}