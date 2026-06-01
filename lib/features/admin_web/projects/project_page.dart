import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/models/project_model.dart';
import '../../../shared/services/project_service.dart';
import '../../../shared/utils/styles.dart';
import 'project_detail_page.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  final ProjectService _projectService = ProjectService();

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'MANAJEMEN DATA PROYEK',
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            const SizedBox(height: 5),
            const Text(
              'Daftar seluruh proyek konstruksi yang telah melalui tahap survei lapangan.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 25),

            // Search bar
            SizedBox(
              width: 400,
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Cari berdasarkan nama proyek, klien, atau surveyor...',
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                  prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey[500]),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
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
            const SizedBox(height: 20),

            // Tabel
            Expanded(
              child: StreamBuilder<List<ProjectModel>>(
                stream: _projectService.getAllProjects(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Data proyek belum tersedia.'));
                  }

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
                          Text("Hasil pencarian untuk '$_searchQuery' tidak ditemukan.",
                              style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    );
                  }

                  return Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10)
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
                                constraints: BoxConstraints(
                                    minWidth:
                                        MediaQuery.of(context).size.width - 350),
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(
                                      const Color(0xFFE3EAE6)),
                                  headingTextStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                      fontSize: 13),
                                  headingRowHeight: 55,
                                  dataRowColor:
                                      WidgetStateProperty.resolveWith<Color?>(
                                          (states) => Colors.white),
                                  dataRowMinHeight: 55,
                                  dataRowMaxHeight: 55,
                                  columnSpacing: 25,
                                  dividerThickness: 1,
                                  columns: const [
                                    DataColumn(label: Text('No.')),
                                    DataColumn(label: Text('Nama Proyek')),
                                    DataColumn(label: Text('Nama Klien')),
                                    DataColumn(label: Text('Surveyor')),
                                    DataColumn(label: Text('Tanggal Survey')),
                                    DataColumn(label: Text('Status Estimasi')),
                                    DataColumn(label: Text('Tindakan')),
                                  ],
                                  rows: List.generate(
                                    filteredProjects.length,
                                    (index) {
                                      final project = filteredProjects[index];
                                      final number = index + 1;
                                      final formattedDate =
                                          DateFormat('dd/MM/yyyy')
                                              .format(project.createdAt);

                                      return DataRow(cells: [
                                        DataCell(Text(number.toString(),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold))),
                                        DataCell(Text(project.projectName)),
                                        DataCell(Text(project.clientName)),
                                        DataCell(Text(project.surveyorName)),
                                        DataCell(Text(formattedDate)),
                                        DataCell(_buildStatusBadge(
                                            project.statusPerhitungan)),
                                        DataCell(
                                          ElevatedButton.icon(
                                            onPressed: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    ProjectDetailPage(
                                                        project: project),
                                              ),
                                            ),
                                            icon: const Icon(
                                                Icons.remove_red_eye,
                                                size: 14,
                                                color: Colors.white),
                                            label: const Text('Lihat Detail',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF1B5E20),
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 12),
                                              shape: const StadiumBorder(),
                                            ),
                                          ),
                                        ),
                                      ]);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
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

  Widget _buildStatusBadge(String status) {
    final Color bgColor;
    final Color textColor;
    final String label;

    switch (status) {
      case 'selesai':
        bgColor = Colors.green[50]!;
        textColor = Colors.green[800]!;
        label = 'Selesai';
        break;
      case 'sedang_berjalan':
        bgColor = Colors.orange[50]!;
        textColor = Colors.orange[800]!;
        label = 'Dalam Proses';
        break;
      default:
        bgColor = Colors.grey[100]!;
        textColor = Colors.grey[600]!;
        label = 'Belum Dimulai';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration:
          BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: textColor)),
    );
  }
}