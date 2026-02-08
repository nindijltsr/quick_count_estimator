import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import '../../../shared/models/project_model.dart';
import '../../../shared/services/project_service.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  final ProjectService _projectService = ProjectService();
  

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    // 2. Listener untuk mendeteksi ketikan user
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], 
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "DAFTAR PROYEK",
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.w900, 
                letterSpacing: 0.5,
                color: Color(0xFF263238) 
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Semua proyek yang telah di-survey oleh tim",
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 25),

            // --- SEARCH BAR ---
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!), 
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
                ],
              ),
              child: TextField(
                controller: _searchController, 
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Cari Proyek, Klien, atau Surveyor...",
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchQuery.isNotEmpty 
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = "");
                        },
                      ) 
                    : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- TABEL DATA ---
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10), 
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08), 
                      blurRadius: 15, 
                      offset: const Offset(0, 5)
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: StreamBuilder<List<ProjectModel>>(
                    stream: _projectService.getAllProjects(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text("Belum ada data proyek."));
                      }

                      // 3. LOGIC FILTERING (PENCARIAN)
                      final allProjects = snapshot.data!;
                      final filteredProjects = allProjects.where((project) {
                        final name = project.projectName.toLowerCase();
                        final client = project.clientName.toLowerCase();
                        final surveyor = project.surveyorName.toLowerCase();
                        
                        return name.contains(_searchQuery) || 
                               client.contains(_searchQuery) || 
                               surveyor.contains(_searchQuery);
                      }).toList();

                      if (filteredProjects.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 40, color: Colors.grey[400]),
                              const SizedBox(height: 10),
                              Text(
                                "Pencarian '$_searchQuery' tidak ditemukan.",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(const Color(0xFFCFD8DC)), 
                          headingTextStyle: const TextStyle(
                            fontWeight: FontWeight.bold, 
                            color: Colors.black87, 
                            fontSize: 13
                          ),
                          headingRowHeight: 55,

                          dataRowColor: MaterialStateProperty.resolveWith<Color?>((states) => Colors.white),
                          dataRowMinHeight: 55, 
                          dataRowMaxHeight: 55,
                          columnSpacing: 25,
                          dividerThickness: 1, 
                          
                          columns: const [
                            DataColumn(label: Text("Nomor")), 
                            DataColumn(label: Text("Nama Proyek")),
                            DataColumn(label: Text("Nama Klien")),
                            DataColumn(label: Text("Surveyor")),
                            DataColumn(label: Text("Tanggal")),
                            DataColumn(label: Text("Aksi")),
                          ],
                          
                          rows: List.generate(filteredProjects.length, (index) {
                            final project = filteredProjects[index];
                            final number = index + 1;
                            String formattedDate = DateFormat('dd/MM/yyyy').format(project.createdAt);

                            return DataRow(cells: [
                              DataCell(Text(number.toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text(project.projectName, style: const TextStyle(fontWeight: FontWeight.w600))),
                              DataCell(Text(project.clientName)),
                              DataCell(Text(project.surveyorName)),
                              DataCell(Text(formattedDate)),

                              DataCell(
                                ElevatedButton.icon(
                                  onPressed: () {
                                     ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Fitur Detail (Coming Soon)"))
                                      );
                                  },
                                  icon: const Icon(Icons.remove_red_eye, size: 14, color: Colors.white),
                                  label: const Text("Detail", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1B5E20), 
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    shape: const StadiumBorder(), 
                                  ),
                                ),
                              ),
                            ]);
                          }),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}