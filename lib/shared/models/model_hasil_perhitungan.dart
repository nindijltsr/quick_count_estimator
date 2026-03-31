import 'package:cloud_firestore/cloud_firestore.dart';

// menu a — persiapan, tanah dan pondasi
class HasilMenuA {
  final double volBersih;          // m2 - pembersihan lapangan
  final double volBouwplank;       // m' - bouwplank
  final double volGalianMenerus;   // m3 - galian tanah menerus
  final double volPasirMenerus;    // m3 - urugan pasir menerus
  final double volAanstampMenerus; // m3 - aanstamping menerus
  final double volBatuKali;        // m3 - pasangan batu kali 1:4
  final double volGalianTapak;     // m3 - galian tanah tapak
  final double volPasirTapak;      // m3 - urugan pasir tapak
  final double volAanstampTapak;   // m3 - aanstamping tapak
  final double volBetonTapak;      // m3 - beton pondasi tapak k-175
  final double volUrugMenerus;     // m3 - urugan kembali menerus
  final double volUrugTapak;       // m3 - urugan kembali tapak
  final DateTime dihitungPada;

  const HasilMenuA({
    required this.volBersih,
    required this.volBouwplank,
    required this.volGalianMenerus,
    required this.volPasirMenerus,
    required this.volAanstampMenerus,
    required this.volBatuKali,
    required this.volGalianTapak,
    required this.volPasirTapak,
    required this.volAanstampTapak,
    required this.volBetonTapak,
    required this.volUrugMenerus,
    required this.volUrugTapak,
    required this.dihitungPada,
  });

  factory HasilMenuA.dariFirestore(Map<String, dynamic> data) {
    return HasilMenuA(
      volBersih: (data['volBersih'] as num).toDouble(),
      volBouwplank: (data['volBouwplank'] as num).toDouble(),
      volGalianMenerus: (data['volGalianMenerus'] as num).toDouble(),
      volPasirMenerus: (data['volPasirMenerus'] as num).toDouble(),
      volAanstampMenerus: (data['volAanstampMenerus'] as num).toDouble(),
      volBatuKali: (data['volBatuKali'] as num).toDouble(),
      volGalianTapak: (data['volGalianTapak'] as num).toDouble(),
      volPasirTapak: (data['volPasirTapak'] as num).toDouble(),
      volAanstampTapak: (data['volAanstampTapak'] as num).toDouble(),
      volBetonTapak: (data['volBetonTapak'] as num).toDouble(),
      volUrugMenerus: (data['volUrugMenerus'] as num).toDouble(),
      volUrugTapak: (data['volUrugTapak'] as num).toDouble(),
      dihitungPada: (data['dihitung_pada'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> keFirestore() => {
        'volBersih': volBersih,
        'volBouwplank': volBouwplank,
        'volGalianMenerus': volGalianMenerus,
        'volPasirMenerus': volPasirMenerus,
        'volAanstampMenerus': volAanstampMenerus,
        'volBatuKali': volBatuKali,
        'volGalianTapak': volGalianTapak,
        'volPasirTapak': volPasirTapak,
        'volAanstampTapak': volAanstampTapak,
        'volBetonTapak': volBetonTapak,
        'volUrugMenerus': volUrugMenerus,
        'volUrugTapak': volUrugTapak,
        'dihitung_pada': Timestamp.fromDate(dihitungPada),
      };
}

// menu b — struktur dan dinding
class HasilMenuB {
  final double volSloof;      // m3 - sloof beton k-175 (15/20)
  final double volKolom;      // m3 - kolom praktis (13/13)
  final double volRingBalok;  // m3 - ring balok (15/15)
  final double volDinding;    // m2 - pasangan dinding bata 1:4
  final double volPlester;    // m2 - plesteran 1:4
  final double volAcian;      // m2 - acian 
  final DateTime dihitungPada;

  const HasilMenuB({
    required this.volSloof,
    required this.volKolom,
    required this.volRingBalok,
    required this.volDinding,
    required this.volPlester,
    required this.volAcian,
    required this.dihitungPada,
  });

  factory HasilMenuB.dariFirestore(Map<String, dynamic> data) {
    return HasilMenuB(
      volSloof: (data['volSloof'] as num).toDouble(),
      volKolom: (data['volKolom'] as num).toDouble(),
      volRingBalok: (data['volRingBalok'] as num).toDouble(),
      volDinding: (data['volDinding'] as num).toDouble(),
      volPlester: (data['volPlester'] as num).toDouble(),
      volAcian: (data['volAcian'] as num).toDouble(),
      dihitungPada: (data['dihitung_pada'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> keFirestore() => {
        'volSloof': volSloof,
        'volKolom': volKolom,
        'volRingBalok': volRingBalok,
        'volDinding': volDinding,
        'volPlester': volPlester,
        'volAcian': volAcian,
        'dihitung_pada': Timestamp.fromDate(dihitungPada),
      };
}

// menu c — lantai dan timbunan
class HasilMenuC {
  final double luasLantai;      // m2 - luas lantai bangunan
  final double volTimbunan;     // m3 - timbunan tanah bawah lantai
  final double volPasirLantai;  // m3 - urugan pasir bawah lantai
  final double volCorLantai;    // m3 - cor lantai kerja 1:3:6
  final double volKeramik;      // m2 - pasangan keramik 40x40
  final DateTime dihitungPada;

  const HasilMenuC({
    required this.luasLantai,
    required this.volTimbunan,
    required this.volPasirLantai,
    required this.volCorLantai,
    required this.volKeramik,
    required this.dihitungPada,
  });

  factory HasilMenuC.dariFirestore(Map<String, dynamic> data) {
    return HasilMenuC(
      luasLantai: (data['luasLantai'] as num).toDouble(),
      volTimbunan: (data['volTimbunan'] as num).toDouble(),
      volPasirLantai: (data['volPasirLantai'] as num).toDouble(),
      volCorLantai: (data['volCorLantai'] as num).toDouble(),
      volKeramik: (data['volKeramik'] as num).toDouble(),
      dihitungPada: (data['dihitung_pada'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> keFirestore() => {
        'luasLantai': luasLantai,
        'volTimbunan': volTimbunan,
        'volPasirLantai': volPasirLantai,
        'volCorLantai': volCorLantai,
        'volKeramik': volKeramik,
        'dihitung_pada': Timestamp.fromDate(dihitungPada),
      };
}

// menu d — pintu, jendela dan pengunci
class HasilMenuD {
  final double volKusenPintu;      // m3 - volume kusen pintu
  final double volDaunPintu;       // m2 - volume daun pintu
  final double volKusenVentilasi;  // m3 - volume kusen ventilasi
  final int jmlKunci;              // buah - jumlah kunci pintu
  final int jmlEngselPintu;        // buah - jumlah engsel pintu
  final double volKusenJendela;    // m3 - volume kusen jendela
  final double volDaunJendela;     // m2 - volume daun jendela
  final double volKaca;            // m2 - volume kaca jendela
  final int jmlEngselJendela;      // buah - jumlah engsel jendela
  final double volKusenTotal;      // m3 - akumulasi volume seluruh kusen
  final DateTime dihitungPada;

  const HasilMenuD({
    required this.volKusenPintu,
    required this.volDaunPintu,
    required this.volKusenVentilasi,
    required this.jmlKunci,
    required this.jmlEngselPintu,
    required this.volKusenJendela,
    required this.volDaunJendela,
    required this.volKaca,
    required this.jmlEngselJendela,
    required this.volKusenTotal,
    required this.dihitungPada,
  });

  factory HasilMenuD.dariFirestore(Map<String, dynamic> data) {
    return HasilMenuD(
      volKusenPintu: (data['volKusenPintu'] as num).toDouble(),
      volDaunPintu: (data['volDaunPintu'] as num).toDouble(),
      volKusenVentilasi: (data['volKusenVentilasi'] as num).toDouble(),
      jmlKunci: data['jmlKunci'] as int,
      jmlEngselPintu: data['jmlEngselPintu'] as int,
      volKusenJendela: (data['volKusenJendela'] as num).toDouble(),
      volDaunJendela: (data['volDaunJendela'] as num).toDouble(),
      volKaca: (data['volKaca'] as num).toDouble(),
      jmlEngselJendela: data['jmlEngselJendela'] as int,
      volKusenTotal: (data['volKusenTotal'] as num).toDouble(),
      dihitungPada: (data['dihitung_pada'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> keFirestore() => {
        'volKusenPintu': volKusenPintu,
        'volDaunPintu': volDaunPintu,
        'volKusenVentilasi': volKusenVentilasi,
        'jmlKunci': jmlKunci,
        'jmlEngselPintu': jmlEngselPintu,
        'volKusenJendela': volKusenJendela,
        'volDaunJendela': volDaunJendela,
        'volKaca': volKaca,
        'jmlEngselJendela': jmlEngselJendela,
        'volKusenTotal': volKusenTotal,
        'dihitung_pada': Timestamp.fromDate(dihitungPada),
      };
}

// menu e — atap dan plafon
class HasilMenuE {
  final double volPlafon;      // m2 - luas plafon
  final double volListPlafon;  // m' - panjang list plafon
  final double volRangkaAtap;  // m2 - luas rangka atap miring
  final double volGenteng;     // m2 - luas penutup atap genteng
  final double volListplank;   // m' - panjang listplank
  final double volNok;         // m' - panjang nok/bubungan
  final DateTime dihitungPada;

  const HasilMenuE({
    required this.volPlafon,
    required this.volListPlafon,
    required this.volRangkaAtap,
    required this.volGenteng,
    required this.volListplank,
    required this.volNok,
    required this.dihitungPada,
  });

  factory HasilMenuE.dariFirestore(Map<String, dynamic> data) {
    return HasilMenuE(
      volPlafon: (data['volPlafon'] as num).toDouble(),
      volListPlafon: (data['volListPlafon'] as num).toDouble(),
      volRangkaAtap: (data['volRangkaAtap'] as num).toDouble(),
      volGenteng: (data['volGenteng'] as num).toDouble(),
      volListplank: (data['volListplank'] as num).toDouble(),
      volNok: (data['volNok'] as num).toDouble(),
      dihitungPada: (data['dihitung_pada'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> keFirestore() => {
        'volPlafon': volPlafon,
        'volListPlafon': volListPlafon,
        'volRangkaAtap': volRangkaAtap,
        'volGenteng': volGenteng,
        'volListplank': volListplank,
        'volNok': volNok,
        'dihitung_pada': Timestamp.fromDate(dihitungPada),
      };
}

// menu f — finishing cat dan listrik
class HasilMenuF {
  final double volCatTembok;    // m2 - volume pengecatan tembok
  final double volCatPlafon;   // m2 - volume pengecatan plafon
  final double volCatKayu;     // m2 - volume pengecatan kusen dan daun
  final int volLampu;          // buah - jumlah titik lampu
  final int volSaklar1;        // buah - jumlah saklar tunggal
  final int volSaklar2;        // buah - jumlah saklar ganda
  final int volStopKontak;     // buah - jumlah titik stop kontak
  final DateTime dihitungPada;

  const HasilMenuF({
    required this.volCatTembok,
    required this.volCatPlafon,
    required this.volCatKayu,
    required this.volLampu,
    required this.volSaklar1,
    required this.volSaklar2,
    required this.volStopKontak,
    required this.dihitungPada,
  });

  factory HasilMenuF.dariFirestore(Map<String, dynamic> data) {
    return HasilMenuF(
      volCatTembok: (data['volCatTembok'] as num).toDouble(),
      volCatPlafon: (data['volCatPlafon'] as num).toDouble(),
      volCatKayu: (data['volCatKayu'] as num).toDouble(),
      volLampu: data['volLampu'] as int,
      volSaklar1: data['volSaklar1'] as int,
      volSaklar2: data['volSaklar2'] as int,
      volStopKontak: data['volStopKontak'] as int,
      dihitungPada: (data['dihitung_pada'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> keFirestore() => {
        'volCatTembok': volCatTembok,
        'volCatPlafon': volCatPlafon,
        'volCatKayu': volCatKayu,
        'volLampu': volLampu,
        'volSaklar1': volSaklar1,
        'volSaklar2': volSaklar2,
        'volStopKontak': volStopKontak,
        'dihitung_pada': Timestamp.fromDate(dihitungPada),
      };
}

// menu g — estimasi upah tenaga kerja
class HasilMenuG {
  final double totalOhPekerja;    // oh - akumulasi hari orang pekerja
  final double totalOhTukang;     // oh - akumulasi hari orang tukang
  final double totalOhMandor;     // oh - akumulasi hari orang mandor
  final double biayaUpahPekerja;  // rp - total biaya upah pekerja
  final double biayaUpahTukang;   // rp - total biaya upah tukang
  final double biayaUpahMandor;   // rp - total biaya upah mandor
  final double totalBiayaUpah;    // rp - total keseluruhan biaya upah
  final DateTime dihitungPada;

  const HasilMenuG({
    required this.totalOhPekerja,
    required this.totalOhTukang,
    required this.totalOhMandor,
    required this.biayaUpahPekerja,
    required this.biayaUpahTukang,
    required this.biayaUpahMandor,
    required this.totalBiayaUpah,
    required this.dihitungPada,
  });

  factory HasilMenuG.dariFirestore(Map<String, dynamic> data) {
    return HasilMenuG(
      totalOhPekerja: (data['totalOhPekerja'] as num).toDouble(),
      totalOhTukang: (data['totalOhTukang'] as num).toDouble(),
      totalOhMandor: (data['totalOhMandor'] as num).toDouble(),
      biayaUpahPekerja: (data['biayaUpahPekerja'] as num).toDouble(),
      biayaUpahTukang: (data['biayaUpahTukang'] as num).toDouble(),
      biayaUpahMandor: (data['biayaUpahMandor'] as num).toDouble(),
      totalBiayaUpah: (data['totalBiayaUpah'] as num).toDouble(),
      dihitungPada: (data['dihitung_pada'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> keFirestore() => {
        'totalOhPekerja': totalOhPekerja,
        'totalOhTukang': totalOhTukang,
        'totalOhMandor': totalOhMandor,
        'biayaUpahPekerja': biayaUpahPekerja,
        'biayaUpahTukang': biayaUpahTukang,
        'biayaUpahMandor': biayaUpahMandor,
        'totalBiayaUpah': totalBiayaUpah,
        'dihitung_pada': Timestamp.fromDate(dihitungPada),
      };
}