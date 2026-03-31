import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
    _loadMaterialData();
  }

  Future<void> _loadMaterialData() async {
    try {
      final materials = await _layananHarga.streamSemuaHargaMaterial().first;
      final map = <String, HargaMaterial>{};
      for (final material in materials) {
        map[material.id] = material;
      }
      setState(() {
        _materialMap = map;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading material data: $e');
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
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              widget.projectName,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
      body: rekap == null
          ? _buildEmptyState()
          : _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppStyles.primaryGreen),
                )
              : _buildMaterialList(rekap),
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
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

  Widget _buildMaterialList(RekapMaterial rekap) {
    final materials = _buildMaterialItems(rekap);

    if (materials.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppStyles.primaryGreen,
                AppStyles.primaryGreen.withOpacity(0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                'Total ${materials.length} Jenis Bahan',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: materials.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 0.5,
              color: Colors.grey[300],
            ),
            itemBuilder: (context, index) {
              final item = materials[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: Text(
                  item['nama']!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item['jumlah']!,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppStyles.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['satuan']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<Map<String, String>> _buildMaterialItems(RekapMaterial rekap) {
    final items = <Map<String, String>>[];

    void addItem(String id, double jumlah) {
      if (jumlah <= 0) return;
      final material = _materialMap[id];
      if (material == null) return;

      items.add({
        'nama': material.nama,
        'jumlah': _formatJumlah(jumlah),
        'satuan': material.satuan,
      });
    }

    addItem('tanah_timbun', rekap.tanahTimbun_m3);
    addItem('batu_kali', rekap.batuKali_m3);
    addItem('kerikil', rekap.kerikil_kg);
    addItem('pasir_urug', rekap.pasirUrug_m3);
    addItem('pasir_pasang', rekap.pasirPasang_m3);
    addItem('pasir_beton', rekap.pasirBeton_kg);
    addItem('semen_pc', rekap.semen_kg);
    addItem('bata_merah', rekap.bataMerah_buah);
    addItem('besi_polos', rekap.besiPolos_kg);
    addItem('hollow_4x4', rekap.hollow4x4_batang);
    addItem('hollow_2x4', rekap.hollow2x4_batang);
    addItem('profil_c75', rekap.profilC75_m);
    addItem('reng_baja', rekap.rengBaja_m);
    addItem('kayu_balok_57', rekap.kayuBalok57_m3);
    addItem('papan_bekisting', rekap.papanBekisting_m2);
    addItem('balok_kayu_kelas1', rekap.balkKayuKelas1_m3);
    addItem('balok_kayu_kelas2', rekap.balkKayuKelas2_m3);
    addItem('papan_kayu_kelas2', rekap.papanKayuKelas2_m3);
    addItem('papan_listplank', rekap.papanListplank_m3);
    addItem('genteng_galvalum', rekap.gentengGalvalum_m2);
    addItem('nok_galvalum', rekap.nokGalvalum_m);
    addItem('papan_gypsum', rekap.papanGypsum_lembar);
    addItem('list_profil_kayu', rekap.listProfilKayu_m);
    addItem('kaca_5mm', rekap.kaca5mm_m2);
    addItem('kunci_pintu', rekap.kunciPintu_buah);
    addItem('engsel_pintu', rekap.engselPintu_buah);
    addItem('engsel_jendela', rekap.engselJendela_buah);
    addItem('keramik_40x40', rekap.keramik40x40_buah);
    addItem('plamir_tembok', rekap.plamirTembok_kg);
    addItem('cat_dasar_tembok', rekap.catDasarTembok_kg);
    addItem('cat_tembok', rekap.catTembok_kg);
    addItem('cat_menie', rekap.catMenie_kg);
    addItem('plamir_kayu', rekap.plamirKayu_kg);
    addItem('cat_dasar_kayu', rekap.catDasarKayu_kg);
    addItem('cat_kayu', rekap.catKayu_kg);
    addItem('lampu_led_18w', rekap.lampuLed_buah);
    addItem('saklar_tunggal', rekap.saklarTunggal_buah);
    addItem('saklar_ganda', rekap.saklarGanda_buah);
    addItem('stop_kontak', rekap.stopKontak_buah);

    return items;
  }

  String _formatJumlah(double jumlah) {
    if (jumlah == jumlah.toInt()) {
      return jumlah.toInt().toString();
    }
    return jumlah.toStringAsFixed(2);
  }
}