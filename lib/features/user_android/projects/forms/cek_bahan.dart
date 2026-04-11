import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../shared/services/estimasi_provider.dart';
import '../../../../shared/services/layanan_master_harga.dart';
import '../../../../shared/models/model_rekap_dan_lainnya.dart';
import '../../../../shared/utils/styles.dart';

class CekBahanPage extends StatefulWidget {
  final String projectId;
  final String projectName;
  final String clientName;

  const CekBahanPage({
    super.key,
    required this.projectId,
    required this.projectName,
    required this.clientName,
  });

  @override
  State<CekBahanPage> createState() => _CekBahanPageState();
}

class _CekBahanPageState extends State<CekBahanPage> {
  final LayananMasterHarga _layananHarga = LayananMasterHarga();
  Map<String, HargaMaterial> _materialMap = {};
  bool _isLoading = true;

  static final _formatRp = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _muatDataMaterial();
  }

  Future<void> _muatDataMaterial() async {
    try {
      final list = await _layananHarga.streamSemuaHargaMaterial().first;
      setState(() {
        _materialMap = {for (final m in list) m.id: m};
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading material: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EstimasiProvider>();
    final rekap = provider.rekapMaterial;

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
              'Cek Kebutuhan Bahan',
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(widget.projectName, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
      body: rekap == null
          ? _buildEmptyState()
          : _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppStyles.primaryGreen))
              : _buildKonten(rekap),
    );
  }

  Widget _buildKonten(RekapMaterial rekap) {
    final items = _buildDaftarItem(rekap);

    if (items.isEmpty) return _buildEmptyState();

    final totalBiayaMaterial = items.fold(0.0, (sum, item) => sum + item.totalHarga);

    return Column(
      children: [
        // header summary
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: AppStyles.primaryGreen,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${items.length} Jenis Material',
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Text(
                _formatRp.format(totalBiayaMaterial),
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        // list material
        Expanded(
          child: Container(
            color: Colors.white,
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: items.length,
              separatorBuilder: (_, __) => Divider(height: 1, thickness: 0.5, color: Colors.grey[200]),
              itemBuilder: (context, index) => _buildItemTile(items[index]),
            ),
          ),
        ),

        // footer total
        _buildFooterTotal(totalBiayaMaterial),
      ],
    );
  }

  Widget _buildItemTile(_ItemBahan item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // nama material
          Expanded(
            flex: 5,
            child: Text(
              item.nama,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
          const SizedBox(width: 12),
          // detail qty × harga = total (rata kanan)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatRp.format(item.totalHarga),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 2),
              Text(
                '${_formatQty(item.qty)} ${item.satuan} × ${_formatRp.format(item.hargaSatuan)}',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
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
          BoxShadow(color: Colors.black.withOpacity(0.08), offset: const Offset(0, -2), blurRadius: 8),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'TOTAL BIAYA MATERIAL',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.5),
          ),
          Text(
            _formatRp.format(total),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
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
            Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'Belum Ada Data Material',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              'Selesaikan input Menu A-F dan tekan\n"Simpan Data Akhir & Hitung" di halaman Finishing.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  // data build
  List<_ItemBahan> _buildDaftarItem(RekapMaterial rekap) {
    final items = <_ItemBahan>[];

    void add(String id, double qty) {
      if (qty <= 0) return;
      final material = _materialMap[id];
      if (material == null) return;
      items.add(_ItemBahan(
        nama: material.nama,
        satuan: material.satuan,
        qty: qty,
        hargaSatuan: material.hargaSatuan,
      ));
    }

    add('tanah_timbun', rekap.tanahTimbun_m3);
    add('batu_kali', rekap.batuKali_m3);
    add('kerikil', rekap.kerikil_kg);
    add('pasir_urug', rekap.pasirUrug_m3);
    add('pasir_pasang', rekap.pasirPasang_m3);
    add('pasir_beton', rekap.pasirBeton_kg);
    add('semen_pc', rekap.semen_kg);
    add('bata_merah', rekap.bataMerah_buah);
    add('besi_polos', rekap.besiPolos_kg);
    add('hollow_4x4', rekap.hollow4x4_batang);
    add('hollow_2x4', rekap.hollow2x4_batang);
    add('profil_c75', rekap.profilC75_m);
    add('reng_baja', rekap.rengBaja_m);
    add('kayu_balok_57', rekap.kayuBalok57_m3);
    add('papan_bekisting', rekap.papanBekisting_m2);
    add('balok_kayu_kelas1', rekap.balkKayuKelas1_m3);
    add('balok_kayu_kelas2', rekap.balkKayuKelas2_m3);
    add('papan_kayu_kelas2', rekap.papanKayuKelas2_m3);
    add('papan_listplank', rekap.papanListplank_m3);
    add('genteng_galvalum', rekap.gentengGalvalum_m2);
    add('nok_galvalum', rekap.nokGalvalum_m);
    add('papan_gypsum', rekap.papanGypsum_lembar);
    add('list_profil_kayu', rekap.listProfilKayu_m);
    add('kaca_5mm', rekap.kaca5mm_m2);
    add('kunci_pintu', rekap.kunciPintu_buah);
    add('engsel_pintu', rekap.engselPintu_buah);
    add('engsel_jendela', rekap.engselJendela_buah);
    add('keramik_40x40', rekap.keramik40x40_buah);
    add('plamir_tembok', rekap.plamirTembok_kg);
    add('cat_dasar_tembok', rekap.catDasarTembok_kg);
    add('cat_tembok', rekap.catTembok_kg);
    add('cat_menie', rekap.catMenie_kg);
    add('plamir_kayu', rekap.plamirKayu_kg);
    add('cat_dasar_kayu', rekap.catDasarKayu_kg);
    add('cat_kayu', rekap.catKayu_kg);
    add('lampu_led_18w', rekap.lampuLed_buah);
    add('saklar_tunggal', rekap.saklarTunggal_buah);
    add('saklar_ganda', rekap.saklarGanda_buah);
    add('stop_kontak', rekap.stopKontak_buah);

    return items;
  }

  String _formatQty(double qty) {
    return qty == qty.toInt() ? qty.toInt().toString() : qty.toStringAsFixed(2);
  }
}

// mode lokal

class _ItemBahan {
  final String nama;
  final String satuan;
  final double qty;
  final double hargaSatuan;

  double get totalHarga => qty * hargaSatuan;

  const _ItemBahan({
    required this.nama,
    required this.satuan,
    required this.qty,
    required this.hargaSatuan,
  });
}