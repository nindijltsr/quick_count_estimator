import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'hasil_akhir.dart';
import '../project_estimation_page.dart';
import '../../../../shared/services/estimasi_provider.dart';
import '../../../../shared/utils/styles.dart';

class PrediksiPekerjaPage extends StatefulWidget {
  final String projectId;
  final String projectName;
  final String clientName;

  const PrediksiPekerjaPage({
    super.key,
    required this.projectId,
    required this.projectName,
    required this.clientName,
  });

  @override
  State<PrediksiPekerjaPage> createState() => _PrediksiPekerjaPageState();
}

class _PrediksiPekerjaPageState extends State<PrediksiPekerjaPage> {
  static final _formatRp = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  static final _formatOh = NumberFormat('#,##0.00', 'id_ID');

  static const int _stdPekerja = 3;
  static const int _stdTukang = 2;
  static const int _stdMandor = 1;

  // Variabel untuk nyimpan provider biar aman pas halaman ditutup
  late EstimasiProvider _provider;

  @override
  void initState() {
    super.initState();
    // Simpan provider saat context masih hidup
    _provider = context.read<EstimasiProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.rekalkulasiDenganHargaTerbaru();
      // _provider.mulaiListenHargaUpah();
    });
  }

  @override
  void dispose() {
    // Gunakan variabel yang udah disimpan, aman dari crash!
    // _provider.hentikanListenHargaUpah();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EstimasiProvider>();
    final hasilG = provider.hasilMenuG;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Prediksi Kebutuhan Pekerja',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            Text(
              widget.projectName,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
      body: hasilG == null
          ? _buildEmptyState()
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    children: [
                      _buildBebanKerjaSection(hasilG),
                      _buildDivider(),
                      _buildEstimasiDurasiSection(hasilG),
                      _buildDivider(),
                      _buildRincianUpahSection(hasilG),
                    ],
                  ),
                ),
                _buildTotalFooter(hasilG),
                _buildActionButtons(),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.engineering_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'Belum Ada Data Prediksi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Selesaikan input Menu A-F, lalu tekan\n"Simpan Data Akhir & Hitung" di halaman Finishing.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text('Kembali', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBebanKerjaSection(dynamic hasilG) {
    final totalOh =
        hasilG.totalOhPekerja + hasilG.totalOhTukang + hasilG.totalOhMandor;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BEBAN KERJA TOTAL',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          _buildDataRow(
            'Pekerja',
            '${_formatOh.format(hasilG.totalOhPekerja)} OH',
          ),
          const SizedBox(height: 10),
          _buildDataRow(
            'Tukang',
            '${_formatOh.format(hasilG.totalOhTukang)} OH',
          ),
          const SizedBox(height: 10),
          _buildDataRow(
            'Mandor',
            '${_formatOh.format(hasilG.totalOhMandor)} OH',
          ),
          const Divider(height: 20, thickness: 0.5, color: Colors.grey),
          _buildDataRow(
            'Total Keseluruhan',
            '${_formatOh.format(totalOh)} OH',
            valueStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstimasiDurasiSection(dynamic hasilG) {
    final totalOh =
        hasilG.totalOhPekerja + hasilG.totalOhTukang + hasilG.totalOhMandor;
    final totalTimStandar = _stdPekerja + _stdTukang + _stdMandor;
    final estimasiHari = (totalOh / totalTimStandar).ceil();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ESTIMASI DURASI',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          _buildDataRow('Total Beban Kerja', '${_formatOh.format(totalOh)} OH'),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Standar Tim',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              Text(
                '$totalTimStandar Orang',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              'Standar tim: $_stdPekerja Pekerja + $_stdTukang Tukang + $_stdMandor Mandor',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Text(
                  'Perhitungan:',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_formatOh.format(totalOh)} OH ÷ $totalTimStandar Orang = $estimasiHari Hari',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildDataRow(
            'Estimasi Durasi',
            '$estimasiHari Hari Kerja',
            valueStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRincianUpahSection(dynamic hasilG) {
    final upahPekerjaPerOh = hasilG.totalOhPekerja > 0
        ? hasilG.biayaUpahPekerja / hasilG.totalOhPekerja
        : 0;
    final upahTukangPerOh = hasilG.totalOhTukang > 0
        ? hasilG.biayaUpahTukang / hasilG.totalOhTukang
        : 0;
    final upahMandorPerOh = hasilG.totalOhMandor > 0
        ? hasilG.biayaUpahMandor / hasilG.totalOhMandor
        : 0;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RINCIAN UPAH PER PEKERJAAN',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'OH adalah akumulasi beban kerja dari seluruh item pekerjaan',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _buildUpahDetailRow(
            'Pekerja',
            hasilG.totalOhPekerja,
            upahPekerjaPerOh,
            hasilG.biayaUpahPekerja,
          ),
          const SizedBox(height: 12),
          _buildUpahDetailRow(
            'Tukang',
            hasilG.totalOhTukang,
            upahTukangPerOh,
            hasilG.biayaUpahTukang,
          ),
          const SizedBox(height: 12),
          _buildUpahDetailRow(
            'Mandor',
            hasilG.totalOhMandor,
            upahMandorPerOh,
            hasilG.biayaUpahMandor,
          ),
        ],
      ),
    );
  }

  Widget _buildUpahDetailRow(
    String jenis,
    double totalOh,
    double upahPerOh,
    double totalBiaya,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              jenis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              _formatRp.format(totalBiaya),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${_formatOh.format(totalOh)} OH × ${_formatRp.format(upahPerOh)}/OH',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildDataRow(String label, String value, {TextStyle? valueStyle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        Text(
          value,
          style:
              valueStyle ??
              const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 8, color: Colors.grey[50]);
  }

  Widget _buildTotalFooter(dynamic hasilG) {
    return Container(
      decoration: BoxDecoration(
        color: AppStyles.primaryGreen,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'TOTAL BIAYA UPAH',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            _formatRp.format(hasilG.totalBiayaUpah),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey[400]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Kembali',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HasilAkhirPage(
                      projectId: widget.projectId,
                      projectName: widget.projectName,
                      clientName: widget.clientName,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Lihat Hasil Akhir',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
