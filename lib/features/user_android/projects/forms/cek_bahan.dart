import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../shared/services/estimasi_provider.dart';
import '../../../../shared/models/model_rekap_dan_lainnya.dart';
import '../../../../shared/utils/styles.dart';

class CekBahanPage extends StatelessWidget {
  final String projectId;
  final String projectName;
  final String clientName;

  const CekBahanPage({
    super.key,
    required this.projectId,
    required this.projectName,
    required this.clientName,
  });

  static final _formatRp =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EstimasiProvider>();
    final rekap = provider.rekapMaterial;
    final snapshotHarga = provider.snapshotHargaMaterial;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
              const Text('Cek Kebutuhan Bahan',
                  style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              Text(projectName,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          bottom: const TabBar(
            labelColor: AppStyles.primaryGreen,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppStyles.primaryGreen,
            indicatorWeight: 2.5,
            labelStyle:
                TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            unselectedLabelStyle: TextStyle(fontSize: 13),
            tabs: [
              Tab(text: '📦  Kebutuhan Material'),
              Tab(text: '💰  Estimasi Biaya'),
            ],
          ),
        ),
        body: rekap == null
            ? _buildEmptyState(context)
            : TabBarView(
                children: [
                  _buildTabLogistik(rekap),
                  _buildTabFinansial(rekap, snapshotHarga),
                ],
              ),
      ),
    );
  }

  //TAB 1: Kebutuhan Material (tanpa harga)

  Widget _buildTabLogistik(RekapMaterial rekap) {
    final items = _buildDaftarItem(rekap);
    if (items.isEmpty) return _buildEmptyState(null);

    return Column(
      children: [
        // Info jumlah jenis
        Container(
          width: double.infinity,
          color: Colors.white,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            '${items.length} jenis material dibutuhkan',
            style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic),
          ),
        ),
        const Divider(height: 1),

        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, thickness: 0.5, color: Colors.grey[200]),
            itemBuilder: (_, i) => _buildTileLogistik(items[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildTileLogistik(_ItemBahan item) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 12, top: 4),
            decoration: const BoxDecoration(
              color: AppStyles.primaryGreen,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(item.nama,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87)),
          ),
          const SizedBox(width: 8),
          // Volume + Satuan — TANPA harga
          RichText(
            textAlign: TextAlign.right,
            text: TextSpan(
              children: [
                TextSpan(
                  text: _formatQty(item.qty),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                TextSpan(
                  text: '  ${item.satuan}',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TAB 2: Estimasi Biaya 

  Widget _buildTabFinansial(
      RekapMaterial rekap, Map<String, double> snapshotHarga) {
    final items = _buildDaftarItem(rekap);
    if (items.isEmpty) return _buildEmptyState(null);

    // Inject harga dari snapshot
    final itemsWithHarga = items.map((item) {
      final harga = snapshotHarga[item.idMaterial] ?? 0.0;
      return _ItemBahan(
        nama: item.nama,
        satuan: item.satuan,
        qty: item.qty,
        idMaterial: item.idMaterial,
        hargaSatuan: harga,
      );
    }).toList();

    final totalBiaya = itemsWithHarga.fold(
        0.0, (sum, item) => sum + item.qty * item.hargaSatuan);

    return Column(
      children: [
        // Header sub-total
        Container(
          width: double.infinity,
          color: Colors.white,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${itemsWithHarga.length} jenis material',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              Text(
                snapshotHarga.isEmpty
                    ? 'Snapshot belum tersedia'
                    : _formatRp.format(totalBiaya),
                style: TextStyle(
                    fontSize: 12,
                    color: snapshotHarga.isEmpty
                        ? Colors.orange[700]
                        : Colors.grey[700],
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Header kolom tabel
        Container(
          color: const Color(0xFFE3EAE6),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Expanded(
                  flex: 5,
                  child: Text('Material',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87))),
              _thCell('Volume', flex: 2),
              _thCell('Harga Sat.', flex: 3),
              _thCell('Total', flex: 3),
            ],
          ),
        ),

        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: itemsWithHarga.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, thickness: 0.5, color: Colors.grey[200]),
            itemBuilder: (_, i) =>
                _buildTileFinansial(itemsWithHarga[i]),
          ),
        ),

        // Sticky footer total biaya
        _buildFooterTotal(totalBiaya),
      ],
    );
  }

  Widget _buildTileFinansial(_ItemBahan item) {
    final totalItem = item.qty * item.hargaSatuan;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(item.nama,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87)),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${_formatQty(item.qty)}\n${item.satuan}',
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  height: 1.4),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              item.hargaSatuan > 0
                  ? _formatRp.format(item.hargaSatuan)
                  : '-',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              totalItem > 0 ? _formatRp.format(totalItem) : '-',
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterTotal(double total) {
    return Container(
      decoration: BoxDecoration(
        color: AppStyles.primaryGreen,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, -2),
              blurRadius: 6),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('TOTAL BIAYA MATERIAL',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.4)),
            Text(_formatRp.format(total),
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }

  // Data builder 

  List<_ItemBahan> _buildDaftarItem(RekapMaterial rekap) {
    final items = <_ItemBahan>[];

    void add(String id, String nama, String satuan, double qty) {
      if (qty <= 0) return;
      items.add(_ItemBahan(
          nama: nama,
          satuan: satuan,
          qty: qty,
          idMaterial: id,
          hargaSatuan: 0));
    }

    // Urutan sesuai kelompok pekerjaan — nama sinkron dengan Web Admin
    add('tanah_timbun', 'Tanah Timbun', 'm³', rekap.tanahTimbun_m3);
    add('batu_kali', 'Batu Kali', 'm³', rekap.batuKali_m3);
    add('kerikil', 'Kerikil', 'kg', rekap.kerikil_kg);
    add('pasir_urug', 'Pasir Urug', 'm³', rekap.pasirUrug_m3);
    add('pasir_pasang', 'Pasir Pasang', 'm³', rekap.pasirPasang_m3);
    add('pasir_beton', 'Pasir Beton', 'kg', rekap.pasirBeton_kg);
    add('semen_pc', 'Semen PC', 'kg', rekap.semen_kg);
    add('bata_merah', 'Bata Merah', 'buah', rekap.bataMerah_buah);
    add('besi_polos', 'Besi Tulangan Polos', 'kg', rekap.besiPolos_kg);
    add('kayu_balok_57', 'Kayu Balok 5/7', 'm³', rekap.kayuBalok57_m3);
    add('papan_bekisting', 'Papan Bekisting', 'm²', rekap.papanBekisting_m2);
    add('balok_kayu_kelas1', 'Balok Kayu Kelas I (Kusen)', 'm³',
        rekap.balkKayuKelas1_m3);
    add('balok_kayu_kelas2', 'Balok Kayu Kelas II (Daun Pintu)', 'm³',
        rekap.balkKayuKelas2_m3);
    add('papan_kayu_kelas2', 'Papan Kayu Kelas II (Daun Jendela)', 'm³',
        rekap.papanKayuKelas2_m3);
    add('kaca_5mm', 'Kaca Polos 5mm', 'm²', rekap.kaca5mm_m2);
    add('kunci_pintu', 'Kunci Pintu Silinder', 'buah', rekap.kunciPintu_buah);
    add('engsel_pintu', 'Engsel Pintu', 'buah', rekap.engselPintu_buah);
    add('engsel_jendela', 'Engsel Jendela', 'buah', rekap.engselJendela_buah);
    add('hollow_4x4', 'Besi Hollow 4×4 cm', 'batang', rekap.hollow4x4_batang);
    add('hollow_2x4', 'Besi Hollow 2×4 cm', 'batang', rekap.hollow2x4_batang);
    add('papan_gypsum', 'Papan Gypsum 9mm', 'lembar', rekap.papanGypsum_lembar);
    add('list_profil_kayu', 'List Profil Kayu Plafon', 'm\'',
        rekap.listProfilKayu_m);
    add('profil_c75', 'Profil Baja Ringan C-75', 'm\'', rekap.profilC75_m);
    add('reng_baja', 'Reng Baja Ringan', 'm\'', rekap.rengBaja_m);
    add('genteng_galvalum', 'Genteng Galvalum', 'm²', rekap.gentengGalvalum_m2);
    add('nok_galvalum', 'Nok / Bubungan Galvalum', 'm\'', rekap.nokGalvalum_m);
    add('papan_listplank', 'Papan Listplank', 'm\'', rekap.papanListplank_m3);
    add('keramik_40x40', 'Keramik Lantai 40×40', 'buah', rekap.keramik40x40_buah);
    add('plamir_tembok', 'Plamir Tembok', 'kg', rekap.plamirTembok_kg);
    add('cat_dasar_tembok', 'Cat Dasar Tembok', 'kg', rekap.catDasarTembok_kg);
    add('cat_tembok', 'Cat Tembok', 'kg', rekap.catTembok_kg);
    add('cat_menie', 'Cat Menie Kayu', 'kg', rekap.catMenie_kg);
    add('plamir_kayu', 'Plamir Kayu', 'kg', rekap.plamirKayu_kg);
    add('cat_dasar_kayu', 'Cat Dasar Kayu', 'kg', rekap.catDasarKayu_kg);
    add('cat_kayu', 'Cat Kayu / Gloss', 'kg', rekap.catKayu_kg);
    add('lampu_led_18w', 'Lampu LED 18 Watt', 'buah', rekap.lampuLed_buah);
    add('saklar_tunggal', 'Saklar Tunggal', 'buah', rekap.saklarTunggal_buah);
    add('saklar_ganda', 'Saklar Ganda', 'buah', rekap.saklarGanda_buah);
    add('stop_kontak', 'Stop Kontak', 'buah', rekap.stopKontak_buah);

    return items;
  }

  // Shared helpers

  Widget _thCell(String label, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(label,
          textAlign: TextAlign.right,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.black87)),
    );
  }

  String _formatQty(double qty) =>
      qty == qty.toInt() ? qty.toInt().toString() : qty.toStringAsFixed(2);

  Widget _buildEmptyState(BuildContext? context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('Belum Ada Data Material',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54)),
            const SizedBox(height: 8),
            Text(
              'Selesaikan input Menu A-F dan tekan\n"Simpan Data Akhir & Hitung" di halaman Finishing.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
            if (context != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.primaryGreen,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text('Kembali',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ItemBahan {
  final String nama;
  final String satuan;
  final double qty;
  final String idMaterial;
  final double hargaSatuan;

  double get totalHarga => qty * hargaSatuan;

  const _ItemBahan({
    required this.nama,
    required this.satuan,
    required this.qty,
    required this.idMaterial,
    required this.hargaSatuan,
  });
}