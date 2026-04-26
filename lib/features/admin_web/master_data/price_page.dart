import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/model_rekap_dan_lainnya.dart';
import '../../../shared/services/layanan_master_harga.dart';
import '../../../shared/utils/styles.dart';
import '../../../shared/services/layanan_notifikasi.dart';

class PricePage extends StatefulWidget {
  const PricePage({super.key});

  @override
  State<PricePage> createState() => _PricePageState();
}

class _PricePageState extends State<PricePage> {
  final LayananMasterHarga _layananHarga = LayananMasterHarga();
   final LayananNotifikasi _layananNotif = LayananNotifikasi();
  final TextEditingController _searchController = TextEditingController();
  
  int _activeTab = 0;
  String _searchQuery = '';
  bool _isSeedLoading = false;

  final _formatRp = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final _formatTanggal = DateFormat('dd MMM yyyy, HH:mm');

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _jalankanSeedData() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Inisialisasi Data Harga'),
        content: const Text(
          'Tindakan ini akan mengisi 39 item material dan 3 data upah ke database.\n\n'
          'Jika data sudah ada, harga akan ditimpa ke nilai default.\n\n'
          'Lanjutkan?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppStyles.primaryGreen),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Inisialisasi', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (konfirmasi != true) return;

    setState(() => _isSeedLoading = true);
    try {
      final idAdmin = FirebaseAuth.instance.currentUser?.uid ?? 'system';
      await _layananHarga.seedDataDummy(idAdmin);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('39 item material & data upah berhasil diinisialisasi.'),
            backgroundColor: AppStyles.primaryGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSeedLoading = false);
    }
  }

  void _showEditMaterialDialog(HargaMaterial item) {
    final controller = TextEditingController(text: item.hargaSatuan.toStringAsFixed(0));
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit Harga Material', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 380,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.nama, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text('Satuan: ${item.satuan}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Harga Satuan (Rp)',
                      prefixText: 'Rp ',
                      border: const OutlineInputBorder(),
                      suffixText: '/ ${item.satuan}',
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Harga wajib diisi';
                      if (double.tryParse(v) == null) return 'Format angka tidak valid';
                      if (double.parse(v) <= 0) return 'Harga harus lebih dari 0';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppStyles.primaryGreen),
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => isLoading = true);

                      try {
                        final idAdmin = FirebaseAuth.instance.currentUser?.uid ?? 'system';
                        final hargaBaruVal = double.parse(controller.text);
                        
                        final hargaBaru = HargaMaterial(
                          id: item.id,
                          nama: item.nama,
                          satuan: item.satuan,
                          hargaSatuan: hargaBaruVal,
                          diperbaruidOleh: idAdmin,
                          diperbaruidPada: DateTime.now(),
                        );
                        
                        await _layananHarga.simpanHargaMaterial(hargaBaru);

                        await _layananNotif.catatPembaruan(
                          judul: 'Pembaruan Harga: ${item.nama}',
                          idAdmin: idAdmin,
                          hargaLama: item.hargaSatuan, 
                          hargaBaru: hargaBaruVal,     
                        );

                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Harga ${item.nama} berhasil diperbarui.'),
                              backgroundColor: AppStyles.primaryGreen,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => isLoading = false);
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
              child: isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUpahDialog(HargaUpah upah) {
    final pekController = TextEditingController(text: upah.pekerja.toStringAsFixed(0));
    final tukController = TextEditingController(text: upah.tukang.toStringAsFixed(0));
    final manController = TextEditingController(text: upah.mandor.toStringAsFixed(0));
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit Harga Upah Pekerja', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 380,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildUpahField(pekController, 'Upah Pekerja / OH'),
                  const SizedBox(height: 12),
                  _buildUpahField(tukController, 'Upah Tukang / OH'),
                  const SizedBox(height: 12),
                  _buildUpahField(manController, 'Upah Mandor / OH'),
                  const SizedBox(height: 10),
                  Text(
                    'OH = Orang-Hari. Nilai ini digunakan langsung dalam kalkulasi biaya upah seluruh proyek.',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600], fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppStyles.primaryGreen),
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => isLoading = true);

                      try {
                        final idAdmin = FirebaseAuth.instance.currentUser?.uid ?? 'system';
                        final pekerjaLama = upah.pekerja;
                        final tukangLama = upah.tukang;
                        final mandorLama = upah.mandor;
                        final pekerjaBaru = double.parse(pekController.text);
                        final tukangBaru = double.parse(tukController.text);
                        final mandorBaru = double.parse(manController.text);

                        final upahBaru = HargaUpah(
                          pekerja: pekerjaBaru,
                          tukang: tukangBaru,
                          mandor: mandorBaru,
                          diperbaruidOleh: idAdmin,
                          diperbaruidPada: DateTime.now(),
                        );
                        
                        await _layananHarga.simpanHargaUpah(upahBaru);

                        // Diffing upah pekerja 1 1
                        if ((pekerjaLama - pekerjaBaru).abs() > 0.01) {
                          await _layananNotif.catatPembaruan(
                            judul: 'Pembaruan Harga Upah: Pekerja',
                            idAdmin: idAdmin,
                            hargaLama: pekerjaLama,
                            hargaBaru: pekerjaBaru,
                          );
                        }
                        if ((tukangLama - tukangBaru).abs() > 0.01) {
                          await _layananNotif.catatPembaruan(
                            judul: 'Pembaruan Harga Upah: Tukang',
                            idAdmin: idAdmin,
                            hargaLama: tukangLama,
                            hargaBaru: tukangBaru,
                          );
                        }
                        if ((mandorLama - mandorBaru).abs() > 0.01) {
                          await _layananNotif.catatPembaruan(
                            judul: 'Pembaruan Harga Upah: Mandor',
                            idAdmin: idAdmin,
                            hargaLama: mandorLama,
                            hargaBaru: mandorBaru,
                          );
                        }

                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Harga upah berhasil diperbarui.'),
                              backgroundColor: AppStyles.primaryGreen,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => isLoading = false);
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
              child: isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  TextFormField _buildUpahField(TextEditingController ctrl, String label) {
    return TextFormField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        prefixText: 'Rp ',
        border: const OutlineInputBorder(),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Wajib diisi';
        if (double.tryParse(v) == null) return 'Format angka tidak valid';
        if (double.parse(v) <= 0) return 'Harus lebih dari 0';
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MASTER HARGA',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    Text(
                      'Kelola harga material dan upah tenaga kerja',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: _isSeedLoading ? null : _jalankanSeedData,
                  icon: _isSeedLoading
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.system_update_alt, size: 16),
                  label: const Text('Inisialisasi Data', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey[400]!),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTabButton(0, 'Harga Material'),
                  _buildTabButton(1, 'Harga Upah Pekerja'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (_activeTab == 0)
              SizedBox(
                width: 400,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari nama material...',
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                    prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey[500]),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey[200],
                    hoverColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                ),
              ),

            if (_activeTab == 0) const SizedBox(height: 16),

            Expanded(
              child: switch (_activeTab) {
                0 => _buildTabelMaterial(),
                _ => _buildPanelUpah(),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabelMaterial() {
    return StreamBuilder<List<HargaMaterial>>(
      stream: _layananHarga.streamSemuaHargaMaterial(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        }

        final semuaItem = snapshot.data ?? [];

        if (semuaItem.isEmpty) {
          return _buildEmptyState();
        }

        final filtered = _searchQuery.isEmpty
            ? semuaItem
            : semuaItem.where((m) => m.nama.toLowerCase().contains(_searchQuery)).toList();

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  color: Colors.grey[50],
                  child: Row(
                    children: [
                      Text(
                        '${filtered.length} dari ${semuaItem.length} item',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width - 350,
                          ),
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(const Color(0xFFE3EAE6)),
                            headingTextStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontSize: 13,
                            ),
                            headingRowHeight: 48,
                            dataRowMinHeight: 50,
                            dataRowMaxHeight: 50,
                            columnSpacing: 20,
                            dividerThickness: 1,
                            columns: const [
                              DataColumn(label: Text('No')),
                              DataColumn(label: Text('Nama Material')),
                              DataColumn(label: Text('Satuan')),
                              DataColumn(label: Text('Harga Satuan'), numeric: true),
                              DataColumn(label: Text('Terakhir Diperbarui')),
                              DataColumn(label: Text('Aksi')),
                            ],
                            rows: List.generate(filtered.length, (i) {
                              final item = filtered[i];
                              return _buildRowMaterial(i + 1, item);
                            }),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  DataRow _buildRowMaterial(int no, HargaMaterial item) {
    return DataRow(
      cells: [
        DataCell(Text(no.toString(), style: TextStyle(color: Colors.grey[600], fontSize: 13))),
        DataCell(Text(item.nama, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(item.satuan, style: const TextStyle(fontSize: 12)),
          ),
        ),
        DataCell(
          Text(
            _formatRp.format(item.hargaSatuan),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
        DataCell(
          Text(
            _formatTanggal.format(item.diperbaruidPada),
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
        DataCell(
          TextButton.icon(
            onPressed: () => _showEditMaterialDialog(item),
            icon: const Icon(Icons.edit_outlined, size: 15),
            label: const Text('Edit', style: TextStyle(fontSize: 13)),
            style: TextButton.styleFrom(
              foregroundColor: AppStyles.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPanelUpah() {
    return StreamBuilder<HargaUpah?>(
      stream: _layananHarga.streamHargaUpah(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        }

        final upah = snapshot.data;

        if (upah == null) {
          return _buildEmptyState(
            pesan: 'Data upah belum ada.\nTekan "Inisialisasi Data" untuk mengisi nilai default.',
          );
        }

        return Align(
          alignment: Alignment.topLeft,
          child: Container(
            width: 520,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE3EAE6),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: const Text(
                    'Standar Upah Harian (per OH)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                  ),
                ),

                _buildBarisUpah('Pekerja', upah.pekerja),
                const Divider(height: 1, indent: 20, endIndent: 20),
                _buildBarisUpah('Tukang', upah.tukang),
                const Divider(height: 1, indent: 20, endIndent: 20),
                _buildBarisUpah('Mandor', upah.mandor),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Terakhir diperbarui: ${_formatTanggal.format(upah.diperbaruidPada)}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500], fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Nilai ini mempengaruhi kalkulasi biaya upah di seluruh proyek secara real-time.',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600], fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        onPressed: () => _showEditUpahDialog(upah),
                        icon: const Icon(Icons.edit_outlined, size: 16, color: Colors.white),
                        label: const Text('Edit Harga Upah', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppStyles.primaryGreen,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBarisUpah(String jabatan, double nilai) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(jabatan, style: const TextStyle(fontSize: 14, color: Colors.black87)),
          Text(
            '${_formatRp.format(nilai)} / OH',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label) {
    final isActive = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isActive
              ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 1))]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.black87 : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({String? pesan}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            pesan ?? 'Belum ada data.\nTekan "Inisialisasi Data" untuk mengisi data default.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 13, height: 1.6),
          ),
        ],
      ),
    );
  }
}