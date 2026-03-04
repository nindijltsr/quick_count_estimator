import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //header
            const Text(
              'Riwayat Aktivitas',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            const Text(
              'Melihat riwayat aktivitas pengguna',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 30),

          // search bar
            SizedBox(
              width: 400, 
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari nama...',
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                  prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey[500]),
                  filled: true,
                  fillColor: Colors.grey[200],
                  hoverColor: Colors.transparent, 
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // tabel dinamis
            Expanded(
              child: Align(
                alignment: Alignment.topCenter, 
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical, 
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal, 
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 350),
                            child: _buildHistoryTable(),
                          ),
                        ),
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
  }

  // ui tabel
  Widget _buildHistoryTable() {
    // data dummy
    final List<Map<String, String>> dummyHistory = [
      {"no": "1", "nama": "Admin Sistem", "aktivitas": "Tambah Proyek Baru", "tanggal": "dd/mm/yyy"},
      {"no": "2", "nama": "Akira Tanaka", "aktivitas": "Edit Proyek", "tanggal": "dd/mm/yyy"},
      {"no": "3", "nama": "Mei Chen", "aktivitas": "Hapus Proyek", "tanggal": "dd/mm/yyy"},
      {"no": "4", "nama": "Luca Rossi", "aktivitas": "Login", "tanggal": "dd/mm/yyy"},
      {"no": "5", "nama": "Sofia Dimitrov", "aktivitas": "Logout", "tanggal": "dd/mm/yyy"},
    ];

    return DataTable(
      headingRowColor: WidgetStateProperty.all(const Color(0xFFE3EAE6)),
      headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13),
      headingRowHeight: 55,
      dataRowColor: WidgetStateProperty.resolveWith<Color?>((states) => Colors.white),
      dataRowMinHeight: 55, 
      dataRowMaxHeight: 55,
      columnSpacing: 25,
      dividerThickness: 1, 
      columns: const [
        DataColumn(label: Text('Nomor')),
        DataColumn(label: Text('Nama Pengguna')),
        DataColumn(label: Text('Aktivitas')),
        DataColumn(label: Text('Tanggal')),
      ],
      rows: dummyHistory.map((item) {
        return DataRow(cells: [
          DataCell(Text(item['no']!)),
          DataCell(Text(item['nama']!)),
          DataCell(Text(item['aktivitas']!)),
          DataCell(Text(item['tanggal']!)),
        ]);
      }).toList(),
    );
  }
}