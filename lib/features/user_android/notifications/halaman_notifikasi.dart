import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/services/layanan_notifikasi.dart';
import '../../../shared/utils/styles.dart';

class HalamanNotifikasi extends StatefulWidget {
  const HalamanNotifikasi({super.key});

  @override
  State<HalamanNotifikasi> createState() => _HalamanNotifikasiState();
}

class _HalamanNotifikasiState extends State<HalamanNotifikasi> {
  static final _formatRp = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  static final _formatTanggal = DateFormat('dd MMM yyyy, HH:mm');

  final LayananNotifikasi _layananNotif = LayananNotifikasi();

  late Future<List<RiwayatMaster>> _futureRiwayat;

  @override
  void initState() {
    super.initState();
    // ambil semua riwayat
    _futureRiwayat = _layananNotif.ambilRiwayatTerbaru(limit: 50);
  }

  // helper format rupiah
  String _formatNilaiRiwayat(double nilai, {required bool isKoefisien}) {
    if (isKoefisien) {
      if (nilai == nilai.truncateToDouble()) return nilai.toInt().toString();
      return nilai.toString()
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }
    return _formatRp.format(nilai);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Riwayat Pembaruan Master',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
      body: FutureBuilder<List<RiwayatMaster>>(
        future: _futureRiwayat,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Gagal memuat riwayat.\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            );
          }

          final list = snapshot.data ?? [];

          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat pembaruan.',
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _buildItemRiwayat(list[i]),
          );
        },
      ),
    );
  }

  Widget _buildItemRiwayat(RiwayatMaster item) {
    final adaPerubahanHarga = item.hargaLama != null && item.hargaBaru != null;
    final isKoefisien = item.judul.toLowerCase().contains('koefisien');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green[50],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.edit_note,
                color: AppStyles.primaryGreen, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.judul,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTanggal.format(item.tanggal),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                if (adaPerubahanHarga) ...[
                  const SizedBox(height: 6),
                  _buildChipPerubahanHarga(item.hargaLama!, item.hargaBaru!, isKoefisien: isKoefisien),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item.oleh,
            style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildChipPerubahanHarga(double lama, double baru, {required bool isKoefisien}) {
    final selisih = baru - lama;
    final naik = selisih >= 0;
    
    // hitung persentase perubahan, hindari pembagian dengan nol
    final persen = lama == 0 ? 0.0 : (selisih / lama) * 100;

    final label =
        '${_formatNilaiRiwayat(lama, isKoefisien: isKoefisien)} → '
        '${_formatNilaiRiwayat(baru, isKoefisien: isKoefisien)} '
        '(${naik ? '+' : ''}${persen.toStringAsFixed(1)}%)';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: naik ? Colors.red[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: naik ? Colors.red.shade200 : Colors.green.shade200,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: naik ? Colors.red[700] : Colors.green[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}