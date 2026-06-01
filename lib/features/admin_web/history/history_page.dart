import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/model_rekap_dan_lainnya.dart';
import '../../../shared/services/layanan_proyek.dart';
import '../../../shared/services/layanan_notifikasi.dart';
import '../../../shared/utils/styles.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Tab Riwayat Aktivitas
  final LayananHistori _layananHistori = LayananHistori();
  final TextEditingController _searchAktivitasController =
      TextEditingController();
  String _searchAktivitas = '';
  bool _sortAktivitasTerbaru = true;
  final ScrollController _scrollAktivitas = ScrollController();
  final Map<String, String> _cacheNamaUser = {};
  final Map<String, String> _cacheNamaProyek = {};
  bool _dataLoaded = false;

  // Tab Riwayat Pembaruan Master
  final LayananNotifikasi _layananNotif = LayananNotifikasi();
  final TextEditingController _searchMasterController =
      TextEditingController();
  String _searchMaster = '';
  bool _sortMasterTerbaru = true;
  final ScrollController _scrollMaster = ScrollController();

  static final _formatRp =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  static final _formatTanggal = DateFormat('dd/MM/yy HH:mm');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _preloadSemuaData();
    _searchAktivitasController.addListener(() =>
        setState(() => _searchAktivitas =
            _searchAktivitasController.text.toLowerCase()));
    _searchMasterController.addListener(() =>
        setState(
            () => _searchMaster = _searchMasterController.text.toLowerCase()));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchAktivitasController.dispose();
    _searchMasterController.dispose();
    _scrollAktivitas.dispose();
    _scrollMaster.dispose();
    super.dispose();
  }

  Future<void> _preloadSemuaData() async {
    try {
      final results = await Future.wait([
        FirebaseFirestore.instance.collection('users').get(),
        FirebaseFirestore.instance.collection('projects').get(),
      ]);
      for (final doc in results[0].docs) {
        final data = doc.data();
        final nama = (data['name'] as String?)?.trim() ?? '';
        if (nama.isEmpty) continue;
        _cacheNamaUser[doc.id] = nama;
        final uid = (data['uid'] as String?)?.trim() ?? '';
        if (uid.isNotEmpty && uid != doc.id) _cacheNamaUser[uid] = nama;
      }
      for (final doc in results[1].docs) {
        final nama = (doc.data()['project_name'] as String?)?.trim() ?? '';
        if (nama.isNotEmpty) _cacheNamaProyek[doc.id] = nama;
      }
    } catch (e) {
      debugPrint('Gagal preload data history: $e');
    } finally {
      if (mounted) setState(() => _dataLoaded = true);
    }
  }

  // helper tab 1
  String _resolveNamaUser(String id) =>
      _cacheNamaUser[id] ?? 'Pengguna Tidak Teridentifikasi';

  String _resolveNamaProyek(String id, {String? detail}) {
    if (id.isEmpty) return '-';
    return _cacheNamaProyek[id] ?? detail ?? 'Data Proyek Terhapus';
  }

  String _formatNamaAksi(String namaAksi) {
    switch (namaAksi) {
      case 'LOGIN':         return 'Masuk ke Sistem';
      case 'LOGOUT':        return 'Keluar dari Sistem';
      case 'BUAT_PROYEK':   return 'Pembuatan Proyek Baru';
      case 'HAPUS_PROYEK':  return 'Penghapusan Proyek';
      case 'EDIT_PROYEK':   return 'Pembaruan Data Proyek';
      case 'KALKULASI_SELESAI': return 'Penyelesaian Kalkulasi Estimasi';
      case 'REFRESH_MASTER':    return 'Sinkronisasi Data Master';
      case 'SIMPAN_MENU_A': return 'Penyimpanan Data Persiapan & Pondasi';
      case 'SIMPAN_MENU_B': return 'Penyimpanan Data Struktur & Dinding';
      case 'SIMPAN_MENU_C': return 'Penyimpanan Data Lantai & Timbunan';
      case 'SIMPAN_MENU_D': return 'Penyimpanan Data Pintu & Jendela';
      case 'SIMPAN_MENU_E': return 'Penyimpanan Data Atap & Plafon';
      case 'SIMPAN_MENU_F': return 'Penyimpanan Data Finishing & Listrik';
      default:
        final raw = namaAksi.replaceAll('_', ' ').toLowerCase();
        return '${raw[0].toUpperCase()}${raw.substring(1)}';
    }
  }

  // helper tab 2
  String _formatNilaiMaster(double nilai, {required bool isKoefisien}) {
    if (isKoefisien) {
      if (nilai == nilai.truncateToDouble()) return nilai.toInt().toString();
      return nilai
          .toString()
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }
    return _formatRp.format(nilai);
  }

  String _relativeTime(DateTime waktu) {
    final s = DateTime.now().difference(waktu);
    if (s.inSeconds < 60) return 'Baru saja';
    if (s.inMinutes < 60) return '${s.inMinutes} mnt lalu';
    if (s.inHours < 24) return '${s.inHours} jam lalu';
    if (s.inDays < 7) return '${s.inDays} hari lalu';
    return DateFormat('dd MMM yy').format(waktu);
  }

  // build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'RIWAYAT',
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            const Text(
              'Log aktivitas surveyor dan pembaruan data master.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Tab bar 
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(4),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 1)),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.black87,
                unselectedLabelColor: Colors.grey[600],
                labelStyle: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(fontSize: 13),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Riwayat Aktivitas'),
                  Tab(text: 'Riwayat Pembaruan Data'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTabAktivitas(),
                  _buildTabMaster(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //TAB 1: Riwayat Aktivitas
  Widget _buildTabAktivitas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 380,
              child: _buildSearchField(
                controller: _searchAktivitasController,
                hint: 'Cari aktivitas, nama pengguna, atau nama proyek...',
              ),
            ),
            const Spacer(),
            _buildSortToggle(
              terbaru: _sortAktivitasTerbaru,
              onTerbaru: () => setState(() => _sortAktivitasTerbaru = true),
              onTerlama: () => setState(() => _sortAktivitasTerbaru = false),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: !_dataLoaded
              ? const Center(child: CircularProgressIndicator())
              : StreamBuilder<List<LogHistori>>(
                  stream: _layananHistori.streamSemuaAktivitas(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                          child: Text('Error: ${snapshot.error}',
                              style: const TextStyle(color: Colors.red)));
                    }
                    final semua = snapshot.data ?? [];
                    if (semua.isEmpty) {
                      return _buildEmptyState(
                          'Belum ada riwayat aktivitas.',
                          Icons.history_toggle_off);
                    }
                    final sorted = List<LogHistori>.from(semua)
                      ..sort((a, b) => _sortAktivitasTerbaru
                          ? b.dibuatPada.compareTo(a.dibuatPada)
                          : a.dibuatPada.compareTo(b.dibuatPada));
                    final filtered = _searchAktivitas.isEmpty
                        ? sorted
                        : sorted.where((log) {
                            final aksi =
                                _formatNamaAksi(log.namaAksi).toLowerCase();
                            final user =
                                _resolveNamaUser(log.idPengguna).toLowerCase();
                            final proyek = _resolveNamaProyek(log.idProyek,
                                    detail: log.detail)
                                .toLowerCase();
                            return aksi.contains(_searchAktivitas) ||
                                user.contains(_searchAktivitas) ||
                                proyek.contains(_searchAktivitas);
                          }).toList();
                    if (filtered.isEmpty) {
                      return _buildEmptyState(
                          'Tidak ada hasil untuk "$_searchAktivitas".',
                          Icons.search_off);
                    }
                    return _buildTabelAktivitas(filtered, semua.length);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTabelAktivitas(List<LogHistori> filtered, int total) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Container(
              color: const Color(0xFFE3EAE6),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                children: [
                  _headerCell('No', width: 36),
                  _headerCell('Waktu', width: 120),
                  const SizedBox(width: 16),
                  const Expanded(
                    flex: 3,
                    child: Text('Aktivitas & Pengguna',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.black87)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Proyek',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.black87)),
                        Text('${filtered.length} / $total Entri',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFCCCCCC)),
            Expanded(
              child: Scrollbar(
                controller: _scrollAktivitas,
                thumbVisibility: true,
                interactive: true,
                child: ListView.separated(
                  controller: _scrollAktivitas,
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, thickness: 0.5, color: Colors.grey[200]),
                  itemBuilder: (_, i) =>
                      _buildBarisAktivitas(filtered[i], i + 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarisAktivitas(LogHistori log, int no) {
    final namaAksi = _formatNamaAksi(log.namaAksi);
    final namaUser = _resolveNamaUser(log.idPengguna);

    final String namaProyek;
    final bool isProyekDihapus;
    if (log.namaAksi == 'EDIT_PROYEK' && log.detail.isNotEmpty) {
      namaProyek = log.detail;
      isProyekDihapus = false;
    } else {
      namaProyek = _resolveNamaProyek(log.idProyek, detail: log.detail);
      isProyekDihapus =
          log.idProyek.isNotEmpty && _cacheNamaProyek[log.idProyek] == null;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 36,
            child: Text(no.toString(),
                style: TextStyle(fontSize: 13, color: const Color.fromARGB(255, 0, 0, 0))),
          ),
          SizedBox(
            width: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_relativeTime(log.dibuatPada),
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87)),
                const SizedBox(height: 2),
                Text(_formatTanggal.format(log.dibuatPada),
                    style: TextStyle(fontSize: 10, color: Colors.grey[500])),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(namaAksi,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87)),
                const SizedBox(height: 3),
                Text('Oleh: $namaUser',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              namaProyek,
              style: log.idProyek.isEmpty
                  ? TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                      fontStyle: FontStyle.italic)
                  : log.namaAksi == 'EDIT_PROYEK'
                      ? const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87)
                      : isProyekDihapus
                          ? TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                              fontStyle: FontStyle.italic)
                          : const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  //TAB 2: Riwayat Pembaruan Master
  Widget _buildTabMaster() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 380,
              child: _buildSearchField(
                controller: _searchMasterController,
                hint: 'Cari judul pembaruan data...',
              ),
            ),
            const Spacer(),
            _buildSortToggle(
              terbaru: _sortMasterTerbaru,
              onTerbaru: () => setState(() => _sortMasterTerbaru = true),
              onTerlama: () => setState(() => _sortMasterTerbaru = false),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: StreamBuilder<List<RiwayatMaster>>(
            stream: _layananNotif.streamRiwayatMaster(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                    child: Text('Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red)));
              }
              final semua = snapshot.data ?? [];
              if (semua.isEmpty) {
                return _buildEmptyState(
                    'Belum ada riwayat pembaruan master.', Icons.update_disabled);
              }
              final sorted = List<RiwayatMaster>.from(semua)
                ..sort((a, b) => _sortMasterTerbaru
                    ? b.tanggal.compareTo(a.tanggal)
                    : a.tanggal.compareTo(b.tanggal));
              final filtered = _searchMaster.isEmpty
                  ? sorted
                  : sorted
                      .where((r) =>
                          r.judul.toLowerCase().contains(_searchMaster))
                      .toList();
              if (filtered.isEmpty) {
                return _buildEmptyState(
                    'Tidak ada hasil untuk "$_searchMaster".', Icons.search_off);
              }
              return _buildTabelMaster(filtered, semua.length);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTabelMaster(List<RiwayatMaster> filtered, int total) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Container(
              color: const Color(0xFFE3EAE6),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                children: [
                  _headerCell('No', width: 36),
                  _headerCell('Waktu', width: 120),
                  const SizedBox(width: 16),
                  const Expanded(
                    flex: 3,
                    child: Text('Judul Pembaruan',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.black87)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Perubahan Nilai',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.black87)),
                        Text('${filtered.length} / $total Entri',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFCCCCCC)),
            Expanded(
              child: Scrollbar(
                controller: _scrollMaster,
                thumbVisibility: true,
                interactive: true,
                child: ListView.separated(
                  controller: _scrollMaster,
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, thickness: 0.5, color: Colors.grey[200]),
                  itemBuilder: (_, i) => _buildBarisMaster(filtered[i], i + 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarisMaster(RiwayatMaster item, int no) {
    final adaHarga = item.hargaLama != null && item.hargaBaru != null;
    final isKoefisien = item.judul.toLowerCase().contains('koefisien');

    Widget perubahanWidget;
    if (adaHarga) {
      final lama = item.hargaLama!;
      final baru = item.hargaBaru!;
      final selisih = baru - lama;
      final naik = selisih >= 0;
      final persen = lama == 0 ? 0.0 : (selisih / lama) * 100;
      perubahanWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            lama == 0
                ? '${_formatNilaiMaster(baru, isKoefisien: isKoefisien)} (Baru)'
                : '${_formatNilaiMaster(lama, isKoefisien: isKoefisien)} → ${_formatNilaiMaster(baru, isKoefisien: isKoefisien)}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          if (lama != 0)
            Text(
              '${naik ? '▲' : '▼'} ${naik ? '+' : ''}${persen.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 11,
                color: naik ? Colors.red[600] : Colors.green[600],
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      );
    } else {
      perubahanWidget =
          Text('—', style: TextStyle(color: Colors.grey[400], fontSize: 13));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 36,
            child: Text(no.toString(),
                style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          ),
          SizedBox(
            width: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_relativeTime(item.tanggal),
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87)),
                const SizedBox(height: 2),
                Text(_formatTanggal.format(item.tanggal),
                    style: TextStyle(fontSize: 10, color: Colors.grey[500])),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(item.judul,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: perubahanWidget),
        ],
      ),
    );
  }

  //Shared Widgets

  Widget _buildSearchField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
        prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey[500]),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () => controller.clear(),
              )
            : null,
        filled: true,
        fillColor: Colors.grey[200],
        hoverColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildSortToggle({
    required bool terbaru,
    required VoidCallback onTerbaru,
    required VoidCallback onTerlama,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          _buildSortButton(
              label: 'Terbaru',
              icon: Icons.arrow_downward,
              aktif: terbaru,
              onTap: onTerbaru),
          Container(width: 1, height: 32, color: Colors.grey[300]),
          _buildSortButton(
              label: 'Terlama',
              icon: Icons.arrow_upward,
              aktif: !terbaru,
              onTap: onTerlama),
        ],
      ),
    );
  }

  Widget _buildSortButton({
    required String label,
    required IconData icon,
    required bool aktif,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: aktif ? AppStyles.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 13, color: aktif ? Colors.white : Colors.grey[600]),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: aktif ? FontWeight.w600 : FontWeight.normal,
                    color: aktif ? Colors.white : Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(String label, {required double width}) {
    return SizedBox(
      width: width,
      child: Text(label,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
    );
  }

  Widget _buildEmptyState(String pesan, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(pesan,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[500])),
        ],
      ),
    );
  }
}