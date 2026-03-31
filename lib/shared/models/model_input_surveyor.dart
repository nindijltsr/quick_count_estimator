import 'package:cloud_firestore/cloud_firestore.dart';

/// model untuk 14 data input utama dari user
class InputSurveyor {
  final String idProyek;

  // dimensi lahan
  final double pTanah;        
  final double lTanah;        

  // dimensi pondasi
  final double pPondasi;      
  final int jmlTitikTapak;    

  // dimensi dinding & kolom 
  final double pDinding;      
  final int jmlKolom;         

  // dimensi bangunan utama
  final double pBangunan;     
  final double lBangunan;     

  // kuantitas pintu & jendela
  final int jmlPintu;         
  final int jmlJendela;       

  // kuantitas material instalasi listrik
  final int jmlLampu;         
  final int jmlSaklar1;       
  final int jmlSaklar2;       
  final int jmlStopKontak;    

  final DateTime dibuatPada;
  final DateTime diperbaruidPada;

  const InputSurveyor({
    required this.idProyek,
    required this.pTanah,
    required this.lTanah,
    required this.pPondasi,
    required this.jmlTitikTapak,
    required this.pDinding,
    required this.jmlKolom,
    required this.pBangunan,
    required this.lBangunan,
    required this.jmlPintu,
    required this.jmlJendela,
    required this.jmlLampu,
    required this.jmlSaklar1,
    required this.jmlSaklar2,
    required this.jmlStopKontak,
    required this.dibuatPada,
    required this.diperbaruidPada,
  });

  /// konversi dari snapshot firestore ke bentuk model internal
  factory InputSurveyor.dariFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return InputSurveyor(
      idProyek: doc.reference.parent.parent!.id,
      pTanah: (d['panjangTanah'] as num).toDouble(),
      lTanah: (d['lebarTanah'] as num).toDouble(),
      pPondasi: (d['panjangPondasi'] as num).toDouble(),
      jmlTitikTapak: d['jumlahTitikTapak'] as int,
      pDinding: (d['panjangDinding'] as num).toDouble(),
      jmlKolom: d['jumlahKolomPraktis'] as int,
      pBangunan: (d['panjangBangunan'] as num).toDouble(),
      lBangunan: (d['lebarBangunan'] as num).toDouble(),
      jmlPintu: d['jumlahPintu'] as int,
      jmlJendela: d['jumlahJendela'] as int,
      jmlLampu: d['jumlahLampu'] as int,
      jmlSaklar1: d['jumlahSaklarTunggal'] as int,
      jmlSaklar2: d['jumlahSaklarGanda'] as int,
      jmlStopKontak: d['jumlahStopKontak'] as int,
      dibuatPada: (d['dibuat_pada'] as Timestamp).toDate(),
      diperbaruidPada: (d['diperbarui_pada'] as Timestamp).toDate(),
    );
  }

  /// pemetaan data internal ke format firestore
  /// key menggunakan format deskriptif
  Map<String, dynamic> keFirestore() {
    return {
      // data lahan
      'panjangTanah': pTanah,
      'lebarTanah': lTanah,

      // data pondasi
      'panjangPondasi': pPondasi,
      'jumlahTitikTapak': jmlTitikTapak,

      // data dinding & kolom
      'panjangDinding': pDinding,
      'jumlahKolomPraktis': jmlKolom,

      // data bangunan
      'panjangBangunan': pBangunan,
      'lebarBangunan': lBangunan,

      // data pintu & jendela
      'jumlahPintu': jmlPintu,
      'jumlahJendela': jmlJendela,

      // data titik listrik
      'jumlahLampu': jmlLampu,
      'jumlahSaklarTunggal': jmlSaklar1,
      'jumlahSaklarGanda': jmlSaklar2,
      'jumlahStopKontak': jmlStopKontak,

      // metadata waktu
      'dibuat_pada': Timestamp.fromDate(dibuatPada),
      'diperbarui_pada': Timestamp.fromDate(diperbaruidPada),
    };
  }
}