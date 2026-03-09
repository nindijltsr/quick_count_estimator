import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../project_estimation_page.dart';

import '../../../../shared/utils/styles.dart';

class FinishingPage extends StatefulWidget {
  final String projectId;
  final String projectName;
  final String clientName;

  const FinishingPage({
    super.key,
    required this.projectId,
    required this.projectName,
    required this.clientName,
  });

  @override
  State<FinishingPage> createState() => _FinishingPageState();
}

class _FinishingPageState extends State<FinishingPage> {
  final _lampCtrl = TextEditingController();
  final _singleSwitchCtrl = TextEditingController();
  final _doubleSwitchCtrl = TextEditingController();
  final _socketCtrl = TextEditingController();

  @override
  void dispose() {
    _lampCtrl.dispose();
    _singleSwitchCtrl.dispose();
    _doubleSwitchCtrl.dispose();
    _socketCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pekerjaan Finishing",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              "Pengecatan dan titik instalasi listrik",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputField(
                "Jumlah Lampu LED",
                "contoh : 12",
                _lampCtrl,
                isDecimal: false,
              ),
              _buildInputField(
                "Jumlah Saklar Tunggal",
                "contoh : 4",
                _singleSwitchCtrl,
                isDecimal: false,
              ),
              _buildInputField(
                "Jumlah Saklar Ganda",
                "contoh : 3",
                _doubleSwitchCtrl,
                isDecimal: false,
              ),
              _buildInputField(
                "Jumlah Stop Kontak",
                "contoh : 8",
                _socketCtrl,
                isDecimal: false,
              ),
              const SizedBox(height: 10),

              // btn simpan
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Data Finishing disimpan sementara!"),
                      backgroundColor: Colors.green,
                    ),
                  ),
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text(
                    "Simpan Data Akhir",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // btn next ke pekerja
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Menuju Prediksi Pekerja... (Segera Hadir)",
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.engineering, color: Colors.white),
                  label: const Text(
                    "Lanjut Ke Prediksi Pekerja",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProjectEstimationPage(
                                projectId: widget.projectId,
                                projectName: widget.projectName,
                                clientName: widget.clientName,
                              ),
                            ),
                            (route) => route.isFirst,
                          );
                        },
                        icon: Icon(
                          Icons.home_outlined,
                          color: Colors.grey[700],
                        ),
                        label: Text(
                          "Menu Estimasi",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _lampCtrl.clear();
                          _singleSwitchCtrl.clear();
                          _doubleSwitchCtrl.clear();
                          _socketCtrl.clear();
                        },
                        icon: const Icon(Icons.refresh, color: Colors.red),
                        label: const Text(
                          "Reset",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[50],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isDecimal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: isDecimal
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.number,
            inputFormatters: isDecimal
                ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
                : [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppStyles.primaryGreen,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}