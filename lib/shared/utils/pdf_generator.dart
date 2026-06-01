import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/model_hasil_perhitungan.dart';
import '../models/model_rekap_dan_lainnya.dart';

// Warna tema — senada AppStyles.primaryGreen
const _hijauGelap = PdfColor.fromInt(0xFF1B5E20);
const _hijauMuda = PdfColor.fromInt(0xFFE8F5E9);
const _abuAbu = PdfColor.fromInt(0xFFF5F5F5);

/// DTO — semua data yang dibutuhkan PDF generator.
class DataPdfRAB {
  final String namaProyek;
  final String namaKlien;
  final String namaSurveyor;
  final DateTime tanggalDibuat;
  final HasilMenuA? menuA;
  final HasilMenuB? menuB;
  final HasilMenuC? menuC;
  final HasilMenuD? menuD;
  final HasilMenuE? menuE;
  final HasilMenuF? menuF;
  final HasilMenuG? menuG;
  final RekapMaterial? rekap;
  final Map<String, double> snapshotHarga;
  final Map<String, double> snapshotKoefisien;
  final double? overrideTotalMaterial;

  const DataPdfRAB({
    required this.namaProyek,
    required this.namaKlien,
    required this.namaSurveyor,
    required this.tanggalDibuat,
    this.menuA,
    this.menuB,
    this.menuC,
    this.menuD,
    this.menuE,
    this.menuF,
    this.menuG,
    this.rekap,
    this.snapshotHarga = const {},
    this.snapshotKoefisien = const {},
    this.overrideTotalMaterial,
  });
}

/// Entry point — panggil ini dari tombol PDF.
Future<void> generateRABPdf({required DataPdfRAB data}) async {
  final doc = await _buildDocument(data);
  await Printing.layoutPdf(
    onLayout: (format) async => doc.save(),
    name: 'QuickCount_${data.namaProyek.replaceAll(' ', '_')}.pdf',
  );
}

// ─── BUILDER UTAMA ────────────────────────────────────────────────────────────

Future<pw.Document> _buildDocument(DataPdfRAB d) async {
  await initializeDateFormatting('id_ID');
  final font = await PdfGoogleFonts.nunitoRegular();
  final fontBold = await PdfGoogleFonts.nunitoBold();
  final doc = pw.Document();

  final fmtRp = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  final fmtOh = NumberFormat('#,##0.00', 'id_ID');
  final fmtAngka = NumberFormat('#,##0.##', 'id_ID');
  final fmtTgl = DateFormat('dd MMMM yyyy', 'id_ID');

  double hp(String id) => d.snapshotHarga[id] ?? 0;
  double k(String key) => d.snapshotKoefisien[key] ?? 0;

  final barisMaterial = <_Baris>[];
  if (d.menuA != null) barisMaterial.addAll(_barisA(d.menuA!, hp, k));
  if (d.menuB != null) barisMaterial.addAll(_barisB(d.menuB!, hp, k));
  if (d.menuC != null) barisMaterial.addAll(_barisC(d.menuC!, hp, k));
  if (d.menuD != null) barisMaterial.addAll(_barisD(d.menuD!, hp, k));
  if (d.menuE != null) barisMaterial.addAll(_barisE(d.menuE!, hp, k));
  if (d.menuF != null) barisMaterial.addAll(_barisF(d.menuF!, hp, k));

  double manualTotalMat = 0;
  for (final b in barisMaterial) {
    if (!b.isGroup) manualTotalMat += (b.vol * b.hargaSatuan);
  }

  final totalMaterial = d.overrideTotalMaterial ?? d.rekap?.totalBiayaMaterial ?? manualTotalMat;
  final totalUpah = d.menuG?.totalBiayaUpah ?? 0;
  final grandTotal = totalMaterial + totalUpah;

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(36, 36, 36, 40),
      theme: pw.ThemeData.withFont(base: font, bold: fontBold),
      header: (_) => _header(d, fmtTgl, font, fontBold),
      footer: (ctx) => _footer(ctx, font),
      build: (_) => [
        pw.SizedBox(height: 14),

        // Tabel material (jika ada menu yang diisi)
        if (barisMaterial.isNotEmpty) ...[
          _labelSeksi('RINCIAN BIAYA MATERIAL', fontBold),
          pw.SizedBox(height: 6),
          _tabelMaterial(barisMaterial, fmtRp, fmtAngka, font, fontBold),
          pw.SizedBox(height: 6),
          _rowSubTotal(
            'Sub Total Biaya Material',
            totalMaterial,
            fmtRp,
            fontBold,
          ),
          pw.SizedBox(height: 18),
        ],

        // Tabel upah
        if (d.menuG != null) ...[
          _labelSeksi('RINCIAN BIAYA UPAH TENAGA KERJA', fontBold),
          pw.SizedBox(height: 6),
          _tabelUpah(d.menuG!, fmtRp, fmtOh, font, fontBold),
          pw.SizedBox(height: 6),
          _rowSubTotal('Sub Total Biaya Upah', totalUpah, fmtRp, fontBold),
          pw.SizedBox(height: 18),
        ],

        _boxGrandTotal(grandTotal, fmtRp, fontBold),
        pw.SizedBox(height: 14),
        _boxDisclaimer(font, fontBold),
      ],
    ),
  );

  return doc;
}

// ─── HEADER ───────────────────────────────────────────────────────────────────

pw.Widget _header(
  DataPdfRAB d,
  DateFormat fmtTgl,
  pw.Font font,
  pw.Font fontBold,
) {
  return pw.Column(
    children: [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'ESTIMASI CEPAT (QUICK COUNT)',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 13,
                  letterSpacing: 0.8,
                ),
              ),
              pw.Text(
                'BIAYA KONSTRUKSI',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400, width: 0.8),
              borderRadius: pw.BorderRadius.circular(3),
            ),
            child: pw.Text(
              'DOKUMEN ESTIMASI — BUKAN RAB RESMI',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 7.5,
                color: PdfColors.grey600,
              ),
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 8),
      pw.Divider(thickness: 1.5, color: _hijauGelap),
      pw.SizedBox(height: 7),
      pw.Row(
        children: [
          _infoKol('Nama Proyek', d.namaProyek, font, fontBold),
          _infoKol('Klien / Pemilik', d.namaKlien, font, fontBold),
          _infoKol(
            'Surveyor',
            d.namaSurveyor.isNotEmpty ? d.namaSurveyor : '-',
            font,
            fontBold,
          ),
          _infoKol(
            'Tanggal Dibuat',
            fmtTgl.format(d.tanggalDibuat),
            font,
            fontBold,
          ),
        ],
      ),
      pw.SizedBox(height: 10),
      pw.Divider(thickness: 0.5, color: PdfColors.grey400),
    ],
  );
}

pw.Widget _infoKol(String label, String nilai, pw.Font font, pw.Font fontBold) {
  return pw.Expanded(
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            font: font,
            fontSize: 7,
            color: PdfColors.grey600,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(nilai, style: pw.TextStyle(font: fontBold, fontSize: 8.5)),
      ],
    ),
  );
}

// ─── FOOTER ───────────────────────────────────────────────────────────────────

pw.Widget _footer(pw.Context ctx, pw.Font font) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(
        'Quick Count Estimator — Sistem Estimasi Konstruksi',
        style: pw.TextStyle(font: font, fontSize: 7, color: PdfColors.grey500),
      ),
      pw.Text(
        'Hal. ${ctx.pageNumber} / ${ctx.pagesCount}',
        style: pw.TextStyle(font: font, fontSize: 7, color: PdfColors.grey500),
      ),
    ],
  );
}

// ─── TABEL MATERIAL ───────────────────────────────────────────────────────────

pw.Widget _tabelMaterial(
  List<_Baris> baris,
  NumberFormat fmtRp,
  NumberFormat fmtAngka,
  pw.Font font,
  pw.Font fontBold,
) {
  pw.Widget hd(String t, {pw.Alignment al = pw.Alignment.center}) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
    child: pw.Align(
      alignment: al,
      child: pw.Text(
        t,
        style: pw.TextStyle(
          font: fontBold,
          fontSize: 7.5,
          color: PdfColors.white,
        ),
      ),
    ),
  );

  pw.Widget sel(
    String t, {
    pw.Alignment al = pw.Alignment.centerLeft,
    bool bold = false,
  }) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3.5),
    child: pw.Align(
      alignment: al,
      child: pw.Text(
        t,
        style: pw.TextStyle(font: bold ? fontBold : font, fontSize: 7.5),
      ),
    ),
  );

  final rows = <pw.TableRow>[
    pw.TableRow(
      decoration: const pw.BoxDecoration(color: _hijauGelap),
      children: [
        hd('No'),
        hd('Uraian Pekerjaan', al: pw.Alignment.centerLeft),
        hd('Vol'),
        hd('Sat'),
        hd('Harga Satuan (Rp)', al: pw.Alignment.centerRight),
        hd('Jumlah Harga (Rp)', al: pw.Alignment.centerRight),
      ],
    ),
  ];

  int no = 0;
  int dataRowIdx = 0;

  for (final b in baris) {
    if (b.isGroup) {
      rows.add(
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _hijauMuda),
          children: [
            sel(''),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 4,
              ),
              child: pw.Text(
                b.uraian,
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 7.5,
                  color: _hijauGelap,
                ),
              ),
            ),
            sel(''),
            sel(''),
            sel(''),
            sel(''),
          ],
        ),
      );
      no = 0;
      dataRowIdx = 0;
    } else {
      no++;
      dataRowIdx++;
      final jumlah = b.vol * b.hargaSatuan;
      final isZebra = dataRowIdx % 2 == 0;
      rows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: isZebra ? _abuAbu : PdfColors.white,
          ),
          children: [
            sel('$no', al: pw.Alignment.center),
            sel(b.uraian),
            sel(fmtAngka.format(b.vol), al: pw.Alignment.center),
            sel(b.sat, al: pw.Alignment.center),
            sel(
              b.hargaSatuan > 0 ? fmtRp.format(b.hargaSatuan) : '—',
              al: pw.Alignment.centerRight,
            ),
            sel(
              jumlah > 0 ? fmtRp.format(jumlah) : '—',
              al: pw.Alignment.centerRight,
            ),
          ],
        ),
      );
    }
  }

  return pw.Table(
    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
    columnWidths: {
      0: const pw.FixedColumnWidth(22),
      1: const pw.FlexColumnWidth(4),
      2: const pw.FixedColumnWidth(38),
      3: const pw.FixedColumnWidth(26),
      4: const pw.FixedColumnWidth(88),
      5: const pw.FixedColumnWidth(88),
    },
    children: rows,
  );
}

// ─── TABEL UPAH ───────────────────────────────────────────────────────────────

pw.Widget _tabelUpah(
  HasilMenuG g,
  NumberFormat fmtRp,
  NumberFormat fmtOh,
  pw.Font font,
  pw.Font fontBold,
) {
  pw.Widget hd(String t, {pw.Alignment al = pw.Alignment.center}) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
    child: pw.Align(
      alignment: al,
      child: pw.Text(
        t,
        style: pw.TextStyle(
          font: fontBold,
          fontSize: 7.5,
          color: PdfColors.white,
        ),
      ),
    ),
  );

  pw.Widget sel(String t, {pw.Alignment al = pw.Alignment.centerLeft}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3.5),
        child: pw.Align(
          alignment: al,
          child: pw.Text(t, style: pw.TextStyle(font: font, fontSize: 7.5)),
        ),
      );

  final tarifPekerja = g.totalOhPekerja > 0
      ? g.biayaUpahPekerja / g.totalOhPekerja
      : 0.0;
  final tarifTukang = g.totalOhTukang > 0
      ? g.biayaUpahTukang / g.totalOhTukang
      : 0.0;
  final tarifMandor = g.totalOhMandor > 0
      ? g.biayaUpahMandor / g.totalOhMandor
      : 0.0;

  final data = [
    [
      'Pekerja',
      fmtOh.format(g.totalOhPekerja),
      fmtRp.format(tarifPekerja),
      fmtRp.format(g.biayaUpahPekerja),
    ],
    [
      'Tukang',
      fmtOh.format(g.totalOhTukang),
      fmtRp.format(tarifTukang),
      fmtRp.format(g.biayaUpahTukang),
    ],
    [
      'Mandor',
      fmtOh.format(g.totalOhMandor),
      fmtRp.format(tarifMandor),
      fmtRp.format(g.biayaUpahMandor),
    ],
  ];

  return pw.Table(
    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
    columnWidths: {
      0: const pw.FlexColumnWidth(2),
      1: const pw.FlexColumnWidth(2),
      2: const pw.FlexColumnWidth(3),
      3: const pw.FlexColumnWidth(3),
    },
    children: [
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: _hijauGelap),
        children: [
          hd('Jenis Tenaga Kerja', al: pw.Alignment.centerLeft),
          hd('Total OH'),
          hd('Tarif / OH (Rp)'),
          hd('Jumlah Biaya (Rp)'),
        ],
      ),
      ...data.asMap().entries.map((e) {
        final isZebra = e.key % 2 == 1;
        final r = e.value;
        return pw.TableRow(
          decoration: pw.BoxDecoration(
            color: isZebra ? _abuAbu : PdfColors.white,
          ),
          children: [
            sel(r[0]),
            sel(r[1], al: pw.Alignment.center),
            sel(r[2], al: pw.Alignment.centerRight),
            sel(r[3], al: pw.Alignment.centerRight),
          ],
        );
      }),
    ],
  );
}

// ─── KOMPONEN LAYOUT ──────────────────────────────────────────────────────────

pw.Widget _labelSeksi(String judul, pw.Font fontBold) => pw.Text(
  judul,
  style: pw.TextStyle(
    font: fontBold,
    fontSize: 8.5,
    letterSpacing: 0.6,
    color: _hijauGelap,
  ),
);

pw.Widget _rowSubTotal(
  String label,
  double nilai,
  NumberFormat fmtRp,
  pw.Font fontBold,
) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.end,
    children: [
      pw.Text('$label   ', style: pw.TextStyle(font: fontBold, fontSize: 8.5)),
      pw.Container(
        width: 155,
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
        ),
        child: pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            fmtRp.format(nilai),
            style: pw.TextStyle(font: fontBold, fontSize: 8.5),
          ),
        ),
      ),
    ],
  );
}

pw.Widget _boxGrandTotal(double total, NumberFormat fmtRp, pw.Font fontBold) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    decoration: const pw.BoxDecoration(
      color: _hijauGelap,
      borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'GRAND TOTAL ESTIMASI  (Material + Upah Tenaga Kerja)',
          style: pw.TextStyle(
            font: fontBold,
            fontSize: 9.5,
            color: PdfColors.white,
          ),
        ),
        pw.Text(
          fmtRp.format(total),
          style: pw.TextStyle(
            font: fontBold,
            fontSize: 12,
            color: PdfColors.white,
          ),
        ),
      ],
    ),
  );
}

pw.Widget _boxDisclaimer(pw.Font font, pw.Font fontBold) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      color: PdfColor.fromInt(0xFFFFFDE7),
      border: pw.Border.all(color: PdfColors.orange700, width: 0.8),
      borderRadius: pw.BorderRadius.circular(3),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'CATATAN PENTING',
          style: pw.TextStyle(
            font: fontBold,
            fontSize: 8,
            color: PdfColors.orange900,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Dokumen ini merupakan Estimasi Cepat (Quick Count) berbasis rule-system dan snapshot '
          'harga rata-rata pasar. Ini BUKAN dokumen RAB detail/kontrak yang mengikat secara hukum. '
          'Diperlukan survei lapangan lebih lanjut dan perhitungan detail oleh profesional '
          'untuk menerbitkan RAB resmi.',
          style: pw.TextStyle(
            font: font,
            fontSize: 7.5,
            lineSpacing: 1.8,
            color: PdfColors.grey800,
          ),
        ),
      ],
    ),
  );
}

// ─── MODEL INTERNAL ───────────────────────────────────────────────────────────

class _Baris {
  final String uraian;
  final double vol;
  final String sat;
  final double hargaSatuan;
  final bool isGroup;

  const _Baris(this.uraian, this.vol, this.sat, this.hargaSatuan)
    : isGroup = false;
  const _Baris.group(this.uraian)
    : vol = 0,
      sat = '',
      hargaSatuan = 0,
      isGroup = true;
}

// ─── BARIS PER MENU ───────────────────────────────────────────────────────────

List<_Baris> _barisA(
  HasilMenuA a,
  double Function(String) hp,
  double Function(String) k,
) => [
  const _Baris.group('A.  PERSIAPAN, TANAH & PONDASI'),
  _Baris('Pembersihan Lapangan', a.volBersih, 'm²', 0),
  _Baris(
    'Pemasangan Bouwplank',
    a.volBouwplank,
    'm\'',
    hp('kayu_balok_57') * k('mat_kayu_balok57') +
        hp('papan_bekisting') * k('mat_papan_bekisting_bouwplank'),
  ),
  _Baris('Galian Tanah Pondasi Menerus', a.volGalianMenerus, 'm³', 0),
  _Baris('Galian Tanah Pondasi Tapak', a.volGalianTapak, 'm³', 0),
  _Baris(
    'Urugan Pasir Pondasi Menerus',
    a.volPasirMenerus,
    'm³',
    hp('pasir_urug') * k('mat_pasir_urug'),
  ),
  _Baris(
    'Urugan Pasir Pondasi Tapak',
    a.volPasirTapak,
    'm³',
    hp('pasir_urug') * k('mat_pasir_urug'),
  ),
  _Baris(
    'Aanstamping / Batu Kosong Menerus',
    a.volAanstampMenerus,
    'm³',
    hp('pasir_urug') * k('mat_aanstamp_pasir_urug'),
  ),
  _Baris(
    'Aanstamping / Batu Kosong Tapak',
    a.volAanstampTapak,
    'm³',
    hp('pasir_urug') * k('mat_aanstamp_pasir_urug'),
  ),
  _Baris(
    'Pasangan Batu Kali 1:4 (termasuk Aanstamping)',
    a.volAanstampMenerus + a.volAanstampTapak + a.volBatuKali,
    'm³',
    hp('batu_kali') * k('mat_batu_kali'),
  ),
  _Baris(
    'Pasangan Batu Kali — Semen PC',
    a.volBatuKali,
    'm³',
    hp('semen_pc') * k('mat_semen_batu_kali') +
        hp('pasir_pasang') * k('mat_pasir_pasang_batu_kali'),
  ),
  _Baris(
    'Beton Pondasi Tapak K-175',
    a.volBetonTapak,
    'm³',
    hp('kerikil') * k('mat_kerikil_beton') +
        hp('pasir_beton') * k('mat_pasir_beton') +
        hp('semen_pc') * k('mat_semen_beton'),
  ),
  _Baris('Urugan Kembali Galian Menerus', a.volUrugMenerus, 'm³', 0),
  _Baris('Urugan Kembali Galian Tapak', a.volUrugTapak, 'm³', 0),
];

List<_Baris> _barisB(
  HasilMenuB b,
  double Function(String) hp,
  double Function(String) k,
) => [
  const _Baris.group('B.  STRUKTUR & DINDING'),
  _Baris(
    'Sloof Beton Bertulang 15/20',
    b.volSloof,
    'm³',
    hp('besi_polos') * k('mat_besi_sloof') +
        hp('kerikil') * k('mat_kerikil_beton') +
        hp('pasir_beton') * k('mat_pasir_beton') +
        hp('semen_pc') * k('mat_semen_beton'),
  ),
  _Baris(
    'Kolom Beton Bertulang 13/13',
    b.volKolom,
    'm³',
    hp('besi_polos') * k('mat_besi_kolom') +
        hp('kerikil') * k('mat_kerikil_beton') +
        hp('pasir_beton') * k('mat_pasir_beton') +
        hp('semen_pc') * k('mat_semen_beton'),
  ),
  _Baris(
    'Ring Balok 15/15',
    b.volRingBalok,
    'm³',
    hp('besi_polos') * k('mat_besi_ring_balok') +
        hp('kerikil') * k('mat_kerikil_beton') +
        hp('pasir_beton') * k('mat_pasir_beton') +
        hp('semen_pc') * k('mat_semen_beton'),
  ),
  _Baris(
    'Pasangan Dinding Bata 1:4',
    b.volDinding,
    'm²',
    hp('bata_merah') * k('mat_bata_merah') +
        hp('semen_pc') * k('mat_semen_dinding') +
        hp('pasir_pasang') * k('mat_pasir_pasang_dinding'),
  ),
  _Baris(
    'Plesteran Dinding (2 sisi)',
    b.volPlester,
    'm²',
    hp('semen_pc') * k('mat_semen_plester') +
        hp('pasir_pasang') * k('mat_pasir_pasang_plester'),
  ),
  _Baris(
    'Acian Dinding',
    b.volAcian,
    'm²',
    hp('semen_pc') * k('mat_semen_acian'),
  ),
];

List<_Baris> _barisC(
  HasilMenuC c,
  double Function(String) hp,
  double Function(String) k,
) => [
  const _Baris.group('C.  LANTAI & TIMBUNAN'),
  _Baris(
    'Timbunan Tanah Bawah Lantai',
    c.volTimbunan,
    'm³',
    hp('tanah_timbun') * k('mat_tanah_timbun'),
  ),
  _Baris(
    'Urugan Pasir Bawah Lantai',
    c.volPasirLantai,
    'm³',
    hp('pasir_urug') * k('mat_pasir_urug'),
  ),
  _Baris(
    'Cor Lantai Kerja 1:3:6',
    c.volCorLantai,
    'm³',
    hp('kerikil') * k('mat_kerikil_lantai') +
        hp('pasir_beton') * k('mat_pasir_beton_lantai') +
        hp('semen_pc') * k('mat_semen_lantai'),
  ),
  _Baris(
    'Pasangan Keramik Lantai 40×40',
    c.volKeramik,
    'm²',
    hp('keramik_40x40') * k('mat_keramik') +
        hp('semen_pc') * k('mat_semen_keramik') +
        hp('pasir_pasang') * k('mat_pasir_pasang_keramik'),
  ),
];

List<_Baris> _barisD(
  HasilMenuD d,
  double Function(String) hp,
  double Function(String) k,
) => [
  const _Baris.group('D.  PINTU, JENDELA & PENGUNCI'),
  // FIX: mat_balk_kayu_kelas1 (bukan mat_kusen_kayu)
  _Baris(
    'Kusen Pintu (Kayu Kls I)',
    d.volKusenPintu,
    'm³',
    hp('balok_kayu_kelas1') * k('mat_balk_kayu_kelas1'),
  ),
  _Baris(
    'Kusen Ventilasi (Kayu Kls I)',
    d.volKusenVentilasi,
    'm³',
    hp('balok_kayu_kelas1') * k('mat_balk_kayu_kelas1'),
  ),
  _Baris(
    'Kusen Jendela (Kayu Kls I)',
    d.volKusenJendela,
    'm³',
    hp('balok_kayu_kelas1') * k('mat_balk_kayu_kelas1'),
  ),
  // FIX: mat_balk_kayu_kelas2 (bukan mat_daun_pintu_kayu)
  _Baris(
    'Daun Pintu (Kayu Kls II)',
    d.volDaunPintu,
    'm²',
    hp('balok_kayu_kelas2') * k('mat_balk_kayu_kelas2'),
  ),
  // FIX: mat_papan_kayu_kelas2 (bukan mat_daun_jendela_kayu)
  _Baris(
    'Daun Jendela (Kayu Kls II)',
    d.volDaunJendela,
    'm²',
    hp('papan_kayu_kelas2') * k('mat_papan_kayu_kelas2'),
  ),
  _Baris('Kaca Polos 5mm', d.volKaca, 'm²', hp('kaca_5mm') * k('mat_kaca_5mm')),
  _Baris(
    'Kunci Pintu Silinder',
    d.jmlKunci.toDouble(),
    'buah',
    hp('kunci_pintu'),
  ),
  _Baris(
    'Engsel Pintu',
    d.jmlEngselPintu.toDouble(),
    'buah',
    hp('engsel_pintu'),
  ),
  _Baris(
    'Engsel Jendela',
    d.jmlEngselJendela.toDouble(),
    'buah',
    hp('engsel_jendela'),
  ),
];

List<_Baris> _barisE(
  HasilMenuE e,
  double Function(String) hp,
  double Function(String) k,
) => [
  const _Baris.group('E.  ATAP & PLAFON'),
  // FIX: mat_hollow_4x4 (bukan mat_hollow4x4_plafon)
  _Baris(
    'Rangka Plafon Hollow 4×4',
    e.volPlafon,
    'm²',
    hp('hollow_4x4') * k('mat_hollow_4x4'),
  ),
  // FIX: mat_hollow_2x4 (bukan mat_hollow2x4_plafon)
  _Baris(
    'Rangka Plafon Hollow 2×4',
    e.volPlafon,
    'm²',
    hp('hollow_2x4') * k('mat_hollow_2x4'),
  ),
  // FIX: mat_papan_gypsum (bukan mat_gypsum_plafon)
  _Baris(
    'Papan Gypsum 9mm',
    e.volPlafon,
    'm²',
    hp('papan_gypsum') * k('mat_papan_gypsum'),
  ),
  _Baris(
    'List Profil Kayu Plafon',
    e.volListPlafon,
    'm\'',
    hp('list_profil_kayu') * k('mat_list_profil_kayu'),
  ),
  _Baris(
    'Rangka Atap Baja Ringan Profil C-75',
    e.volRangkaAtap,
    'm\'',
    hp('profil_c75') * k('mat_profil_c75'),
  ),
  _Baris(
    'Reng Baja Ringan',
    e.volRangkaAtap,
    'm\'',
    hp('reng_baja') * k('mat_reng_baja'),
  ),
  _Baris(
    'Genteng Metal Galvalum',
    e.volGenteng,
    'm²',
    hp('genteng_galvalum') * k('mat_genteng_galvalum'),
  ),
  _Baris(
    'Nok / Bubungan Galvalum',
    e.volNok,
    'm\'',
    hp('nok_galvalum') * k('mat_nok_galvalum'),
  ),
  // FIX: mat_papan_listplank (bukan mat_listplank)
  _Baris(
    'Papan Listplank 2.5/25',
    e.volListplank,
    'm\'',
    hp('papan_listplank') * k('mat_papan_listplank'),
  ),
];

List<_Baris> _barisF(
  HasilMenuF f,
  double Function(String) hp,
  double Function(String) k,
) => [
  const _Baris.group('F.  FINISHING, CAT & INSTALASI LISTRIK'),
  _Baris(
    'Plamir Tembok',
    f.volCatTembok,
    'm²',
    hp('plamir_tembok') * k('mat_plamir_tembok'),
  ),
  _Baris(
    'Cat Dasar Tembok',
    f.volCatTembok,
    'm²',
    hp('cat_dasar_tembok') * k('mat_cat_dasar_tembok'),
  ),
  _Baris(
    'Cat Tembok (Warna)',
    f.volCatTembok,
    'm²',
    hp('cat_tembok') * k('mat_cat_tembok'),
  ),
  _Baris(
    'Cat Plafon',
    f.volCatPlafon,
    'm²',
    hp('cat_tembok') * k('mat_cat_tembok'),
  ),
  // FIX: mat_cat_menie (bukan mat_cat_menie_kayu)
  _Baris(
    'Cat Menie Kayu',
    f.volCatKayu,
    'm²',
    hp('cat_menie') * k('mat_cat_menie'),
  ),
  _Baris(
    'Cat Kayu / Gloss',
    f.volCatKayu,
    'm²',
    hp('cat_kayu') * k('mat_cat_kayu'),
  ),
  _Baris('Lampu LED 18W', f.volLampu.toDouble(), 'buah', hp('lampu_led_18w')),
  _Baris(
    'Saklar Tunggal',
    f.volSaklar1.toDouble(),
    'buah',
    hp('saklar_tunggal'),
  ),
  _Baris('Saklar Ganda', f.volSaklar2.toDouble(), 'buah', hp('saklar_ganda')),
  _Baris('Stop Kontak', f.volStopKontak.toDouble(), 'buah', hp('stop_kontak')),
];
