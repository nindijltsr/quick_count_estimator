import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../shared/utils/styles.dart';
import '../../../shared/services/layanan_notifikasi.dart';
import '../notifications/halaman_notifikasi.dart';

class UserDashboard extends StatefulWidget {
  final Function(int) onNavigate;

  const UserDashboard({super.key, required this.onNavigate});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final LayananNotifikasi _layananNotif = LayananNotifikasi();
  static final _formatTanggal = DateFormat('dd MMM yyyy, HH:mm');
  static final _formatRp = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  DateTime? _lastSeen;
  bool _adaUpdateBaruLokal = false;
  DateTime? _waktuServerTerbaru; 

  @override
  void initState() {
    super.initState();
    _muatLastSeen();
  }

  Future<void> _muatLastSeen() async {
    final lastSeen = await _layananNotif.bacaLastSeen();
    if (mounted) setState(() => _lastSeen = lastSeen);
  }

  void _showInstructionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lightbulb_outline, color: AppStyles.primaryGreen),
            SizedBox(width: 10),
            Text(
              "Cara Menggunakan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBulletPoint("Buka menu Proyek di bawah."),
            _buildBulletPoint("Klik tombol + untuk buat proyek baru."),
            _buildBulletPoint("Input data pekerjaan klien."),
            _buildBulletPoint("Sistem akan hitung estimasi otomatis."),
            _buildBulletPoint("Hasil hitung akan muncul di daftar."),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "Paham",
              style: TextStyle(
                color: AppStyles.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showNotifikasiBottomSheet() async {
    // read lokal - waktu server
    final waktuTandai = _waktuServerTerbaru ?? DateTime.now();
    setState(() {
      _lastSeen = waktuTandai;
      _adaUpdateBaruLokal = false;
    });

    // simpan ke device / sharedPreference - waktu server
    await _layananNotif.tandaiSudahDibaca(waktuTandai);

    // ambil data riwayat - firebase
    final riwayat = await _layananNotif.ambilRiwayatTerbaru(limit: 3);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.update,
                    color: AppStyles.primaryGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Pembaruan Master Terbaru',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close, size: 20),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const Divider(),
              if (riwayat.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'Belum ada riwayat pembaruan.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: riwayat.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) => _buildMiniRowRiwayat(riwayat[i]),
                ),

              if (riwayat.isNotEmpty) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HalamanNotifikasi(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppStyles.primaryGreen,
                      side: const BorderSide(color: AppStyles.primaryGreen),
                    ),
                    child: const Text('Lihat Semua Notifikasi'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniRowRiwayat(RiwayatMaster item) {
    final adaPerubahanHarga = item.hargaLama != null && item.hargaBaru != null;
    final isKoefisien = item.judul.toLowerCase().contains('koefisien');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green[50],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.edit_note,
              color: AppStyles.primaryGreen,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.judul,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTanggal.format(item.tanggal),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                if (adaPerubahanHarga) ...[
                  const SizedBox(height: 4),
                  _buildMiniChipPerubahanHarga(
                    item.hargaLama!,
                    item.hargaBaru!,
                    isKoefisien: isKoefisien,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNilaiRiwayat(double nilai, {required bool isKoefisien}) {
    if (isKoefisien) {
      if (nilai == nilai.truncateToDouble()) return nilai.toInt().toString();
      return nilai
          .toString()
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }
    return _formatRp.format(nilai);
  }

  Widget _buildMiniChipPerubahanHarga(
    double lama,
    double baru, {
    required bool isKoefisien,
  }) {
    final selisih = baru - lama;
    final naik = selisih >= 0;
    final persen = lama == 0 ? 0.0 : (selisih / lama) * 100;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: naik ? Colors.red[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: naik ? Colors.red.shade200 : Colors.green.shade200,
        ),
      ),
      child: Text(
        '${_formatNilaiRiwayat(lama, isKoefisien: isKoefisien)} → '
        '${_formatNilaiRiwayat(baru, isKoefisien: isKoefisien)} '
        '(${naik ? '+' : ''}${persen.toStringAsFixed(1)}%)',
        style: TextStyle(
          fontSize: 10,
          color: naik ? Colors.red[700] : Colors.green[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text("Memuat..."));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                bottom: 15,
                left: 20,
                right: 10,
              ),
              decoration: const BoxDecoration(
                color: AppStyles.primaryGreen,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      "QUICK COUNT ESTIMATOR",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 1.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StreamBuilder<DateTime?>(
                        stream: _layananNotif.streamLastMasterUpdate(),
                        builder: (context, snapshot) {
                          final lastMaster = snapshot.data;

                          if (lastMaster != null &&
                              lastMaster != _waktuServerTerbaru) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted)
                                setState(
                                  () => _waktuServerTerbaru = lastMaster,
                                );
                            });
                          }

                          if (lastMaster != null &&
                              (_lastSeen == null ||
                                  lastMaster.isAfter(_lastSeen!))) {
                            _adaUpdateBaruLokal = true;
                          }

                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.white,
                                ),
                                onPressed: _showNotifikasiBottomSheet,
                                tooltip: 'Pembaruan Master',
                              ),
                              if (_adaUpdateBaruLokal)
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.help_outline,
                          color: Colors.white,
                        ),
                        onPressed: () => _showInstructionDialog(context),
                        tooltip: 'Bantuan',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('email', isEqualTo: currentUser.email)
                        .limit(1)
                        .snapshots(),
                    builder: (context, userSnapshot) {
                      String name = 'Surveyor';
                      if (userSnapshot.hasData &&
                          userSnapshot.data!.docs.isNotEmpty) {
                        final userData =
                            userSnapshot.data!.docs.first.data()
                                as Map<String, dynamic>;
                        name = userData['name'] ?? 'Surveyor';
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Halo, $name! 👋",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Siap menghitung estimasi hari ini?",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 25),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.assignment,
                                color: AppStyles.primaryGreen,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Total Estimasi Disimpan",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('projects')
                                        .where(
                                          'user_id',
                                          isEqualTo: currentUser.uid,
                                        )
                                        .snapshots(),
                                    builder: (context, projSnapshot) {
                                      int count = 0;
                                      if (projSnapshot.hasData) {
                                        count = projSnapshot.data!.docs.length;
                                      }
                                      return Text(
                                        "$count Dokumen",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => widget.onNavigate(1),
                            icon: const Icon(Icons.add),
                            label: const Text("Mulai Estimasi Baru"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppStyles.primaryGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Estimasi Terakhir",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => widget.onNavigate(1),
                        child: const Text(
                          "Lihat Semua",
                          style: TextStyle(color: AppStyles.primaryGreen),
                        ),
                      ),
                    ],
                  ),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('projects')
                        .where('user_id', isEqualTo: currentUser.uid)
                        .orderBy('updated_at', descending: true)
                        .limit(2)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              "Belum ada riwayat estimasi.",
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: snapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return _buildMiniProjectCard(
                            data['project_name'] ?? 'Tanpa Nama',
                            data['client_name'] ?? '-',
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniProjectCard(String title, String client) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.folder_outlined,
            color: AppStyles.primaryGreen,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          "Klien: $client",
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () => widget.onNavigate(1),
      ),
    );
  }
}
