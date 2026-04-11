import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/model_rekap_dan_lainnya.dart';
import '../../../shared/services/layanan_proyek.dart';
import '../../../shared/utils/styles.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final LayananHistori _layananHistori = LayananHistori();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  // Dual-key cache: doc.id + field uid → nama user
  final Map<String, String> _cacheNamaUser = {};
  // Cache: doc.id proyek → nama proyek
  final Map<String, String> _cacheNamaProyek = {};

  bool _dataLoaded = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _preloadSemuaData();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Preload Cache
  Future<void> _preloadSemuaData() async {
    try {
      // Fetch users dan proyek secara paralel
      final results = await Future.wait([
        FirebaseFirestore.instance.collection('users').get(),
        FirebaseFirestore.instance.collection('projects').get(),
      ]);

      final usersSnap = results[0];
      final proyekSnap = results[1];

      for (final doc in usersSnap.docs) {
        final data = doc.data();
        final nama = (data['name'] as String?)?.trim() ?? '';
        if (nama.isEmpty) continue;
        _cacheNamaUser[doc.id] = nama;
        final uid = (data['uid'] as String?)?.trim() ?? '';
        if (uid.isNotEmpty && uid != doc.id) _cacheNamaUser[uid] = nama;
      }

      for (final doc in proyekSnap.docs) {
        final namaProyek =
            (doc.data()['project_name'] as String?)?.trim() ?? '';
        if (namaProyek.isNotEmpty) _cacheNamaProyek[doc.id] = namaProyek;
      }
    } catch (e) {
      debugPrint('Gagal preload data history: $e');
    } finally {
      if (mounted) setState(() => _dataLoaded = true);
    }
  }

  String _resolveNamaUser(String id) =>
      _cacheNamaUser[id] ?? 'Pengguna Tidak Dikenal';

  String _resolveNamaProyek(String id) =>
      _cacheNamaProyek[id] ?? 'Proyek Dihapus';

  // Formatter

  String _formatNamaAksi(String namaAksi) {
    switch (namaAksi) {
      case 'KALKULASI_SELESAI':
        return 'Kalkulasi Estimasi Selesai';
      case 'SIMPAN_MENU_A':
        return 'Simpan Data Persiapan & Pondasi';
      case 'SIMPAN_MENU_B':
        return 'Simpan Data Struktur & Dinding';
      case 'SIMPAN_MENU_C':
        return 'Simpan Data Lantai & Timbunan';
      case 'SIMPAN_MENU_D':
        return 'Simpan Data Pintu & Jendela';
      case 'SIMPAN_MENU_E':
        return 'Simpan Data Atap & Plafon';
      case 'SIMPAN_MENU_F':
        return 'Simpan Data Finishing & Listrik';
      case 'BUAT_PROYEK':
        return 'Membuat Proyek Baru';
      case 'EDIT_PROYEK':
        return 'Memperbarui Data Proyek';
      case 'HAPUS_PROYEK':
        return 'Menghapus Proyek';
      default:
        final raw = namaAksi.replaceAll('_', ' ').toLowerCase();
        return '${raw[0].toUpperCase()}${raw.substring(1)}';
    }
  }

  String _relativeTime(DateTime waktu) {
    final s = DateTime.now().difference(waktu);
    if (s.inSeconds < 60) return 'Baru saja';
    if (s.inMinutes < 60) return '${s.inMinutes} mnt lalu';
    if (s.inHours < 24) return '${s.inHours} jam lalu';
    if (s.inDays < 7) return '${s.inDays} hari lalu';
    return DateFormat('dd MMM yy').format(waktu);
  }

  // Build
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
              'RIWAYAT AKTIVITAS',
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            const Text(
              'Log seluruh aktivitas surveyor secara real-time',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: 400,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari aksi, nama user, atau nama proyek...',
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
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: !_dataLoaded
                  ? const Center(child: CircularProgressIndicator())
                  : StreamBuilder<List<LogHistori>>(
                      stream: _layananHistori.streamSemuaAktivitas(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}',
                                style: const TextStyle(color: Colors.red)),
                          );
                        }

                        final semua = snapshot.data ?? [];
                        if (semua.isEmpty) return _buildEmptyState();

                        final filtered = _searchQuery.isEmpty
                            ? semua
                            : semua.where((log) {
                                final aksi = _formatNamaAksi(log.namaAksi)
                                    .toLowerCase();
                                final namaUser =
                                    _resolveNamaUser(log.idPengguna)
                                        .toLowerCase();
                                final namaProyek =
                                    _resolveNamaProyek(log.idProyek)
                                        .toLowerCase();
                                return aksi.contains(_searchQuery) ||
                                    namaUser.contains(_searchQuery) ||
                                    namaProyek.contains(_searchQuery);
                              }).toList();

                        if (filtered.isEmpty) {
                          return _buildEmptyState(
                              pesan:
                                  'Tidak ada hasil untuk "$_searchQuery"');
                        }

                        return Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10)
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Column(
                              children: [
                                _buildHeaderKolom(
                                    filtered.length, semua.length),
                                const Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: Color(0xFFCCCCCC)),
                                Expanded(
                                  child: Scrollbar(
                                    controller: _scrollController,
                                    thumbVisibility: true,
                                    interactive: true,
                                    child: ListView.separated(
                                      controller: _scrollController,
                                      itemCount: filtered.length,
                                      separatorBuilder: (_, __) => Divider(
                                          height: 1,
                                          thickness: 0.5,
                                          color: Colors.grey[200]),
                                      itemBuilder: (context, index) =>
                                          _buildBarisLog(
                                              filtered[index], index + 1),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Header Kolom
  Widget _buildHeaderKolom(int tampil, int total) {
    return Container(
      color: const Color(0xFFE3EAE6),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: [
          _headerCell('No', width: 36),
          _headerCell('Waktu', width: 120),
          const SizedBox(width: 16),
          const Expanded(
            flex: 3,
            child: Text('Aktivitas & User',
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
                Text('$tampil / $total entri',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
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

  // Baris Log
  Widget _buildBarisLog(LogHistori log, int no) {
    final namaAksi = _formatNamaAksi(log.namaAksi);
    final namaUser = _resolveNamaUser(log.idPengguna);
    final namaProyek = _resolveNamaProyek(log.idProyek);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kolom No
          SizedBox(
            width: 36,
            child: Text(no.toString(),
                style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          ),

          // Kolom Waktu
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
                Text(DateFormat('dd/MM/yy HH:mm').format(log.dibuatPada),
                    style: TextStyle(fontSize: 10, color: Colors.grey[500])),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Kolom Aktivitas & User — 2 baris bersih
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris 1: nama aksi — bold, hitam
                Text(namaAksi,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87)),
                const SizedBox(height: 3),
                // Baris 2: oleh [Nama User] — regular, abu
                Text('Oleh: $namaUser',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Kolom Proyek — nama human-readable, styling berbeda jika dihapus
          Expanded(
            flex: 2,
            child: Text(
              namaProyek,
              style: namaProyek == 'Proyek Dihapus'
                  ? TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                      fontStyle: FontStyle.italic,
                    )
                  : const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Empty State
  Widget _buildEmptyState({String? pesan}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            pesan ?? 'Belum ada riwayat aktivitas.',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}