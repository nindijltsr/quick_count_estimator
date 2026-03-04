import 'package:flutter/material.dart';
import '../../../shared/utils/styles.dart'; 

class PricePage extends StatefulWidget {
  const PricePage({super.key});

  @override
  State<PricePage> createState() => _PricePageState();
}

class _PricePageState extends State<PricePage> {
  // 0 = Harga Material, 1 = Harga Upah Pekerja
  int _activeTab = 0;

  //notif dummy
  void _showDummyEditDialog(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Fitur Edit '$name' akan segera hadir."),
        backgroundColor: AppStyles.primaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
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
            //header
            const Text(
              'MASTER HARGA',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            const Text(
              'Kelola data harga material dan upah tenaga kerja',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 30),

            // style switch tab 
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[200], 
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTabButton(0, "Harga Material"),
                  _buildTabButton(1, "Harga Upah Pekerja"),
                ],
              ),
            ),
            const SizedBox(height: 25),

            if (_activeTab == 0)
              Container(
                width: 400, 
                margin: const EdgeInsets.only(bottom: 20),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari material...',
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
                            child: _activeTab == 0 ? _buildMaterialTable() : _buildWageTable(),
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

  // ui btn tab
  Widget _buildTabButton(int index, String label) {
    bool isActive = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), 
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent, 
          borderRadius: BorderRadius.circular(6),
          boxShadow: isActive 
              ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))] 
              : [], 
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? Colors.black87 : Colors.grey[600], 
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // tab 1 material
  Widget _buildMaterialTable() {
    final List<Map<String, String>> dummyMaterial = [
      {"no": "1", "nama": "Bata Merah", "satuan": "Buah", "harga": "Rp. xx"},
      {"no": "2", "nama": "Batu Kali", "satuan": "M³", "harga": "Rp. xx"},
      {"no": "3", "nama": "Besi Beton", "satuan": "Kg", "harga": "Rp. xx"},
      {"no": "4", "nama": "Kayu Balok", "satuan": "M³", "harga": "Rp. xx"},
      {"no": "5", "nama": "Semen (40 Kg)", "satuan": "Sak", "harga": "Rp. xx"},
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
        DataColumn(label: Text('Nama Material')),
        DataColumn(label: Text('Satuan')),
        DataColumn(label: Text('Harga Satuan')),
        DataColumn(label: Text('Aksi')),
      ],
      rows: dummyMaterial.map((item) {
        return DataRow(cells: [
          DataCell(Text(item['no']!)),
          DataCell(Text(item['nama']!)),
          DataCell(Text(item['satuan']!)),
          DataCell(Text(item['harga']!)),
          DataCell(IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.deepPurple), 
            onPressed: () => _showDummyEditDialog(item['nama']!),
          )),
        ]);
      }).toList(),
    );
  }

  // tab 2 upah
  Widget _buildWageTable() {
    final List<Map<String, String>> dummyUpah = [
      {"no": "1", "pekerja": "Pekerja", "satuan": "Hari", "harga": "Rp. xx"},
      {"no": "2", "pekerja": "Tukang", "satuan": "Hari", "harga": "Rp. xx"},
      {"no": "3", "pekerja": "Mandor", "satuan": "Hari", "harga": "Rp. xx"},
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
        DataColumn(label: Text('Jenis Pekerja')),
        DataColumn(label: Text('Satuan')),
        DataColumn(label: Text('Harga')),
        DataColumn(label: Text('Aksi')),
      ],
      rows: dummyUpah.map((item) {
        return DataRow(cells: [
          DataCell(Text(item['no']!)),
          DataCell(Text(item['pekerja']!)),
          DataCell(Text(item['satuan']!)),
          DataCell(Text(item['harga']!)),
          DataCell(IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.deepPurple), 
            onPressed: () => _showDummyEditDialog(item['pekerja']!),
          )),
        ]);
      }).toList(),
    );
  }
}