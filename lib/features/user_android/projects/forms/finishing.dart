import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'prediksi_pekerja.dart';
import '../project_estimation_page.dart';
import '../../../../shared/utils/styles.dart';
import '../../../../shared/services/estimasi_provider.dart';

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

  bool _isControllerInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateControllersFromProvider();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isControllerInitialized) {
      _updateControllersFromProvider();
    }
  }

  void _updateControllersFromProvider() {
    final provider = context.read<EstimasiProvider>();
    
    if (provider.jmlLampu > 0) {
      _lampCtrl.text = provider.jmlLampu.toString();
    }
    if (provider.jmlSaklar1 > 0) {
      _singleSwitchCtrl.text = provider.jmlSaklar1.toString();
    }
    if (provider.jmlSaklar2 > 0) {
      _doubleSwitchCtrl.text = provider.jmlSaklar2.toString();
    }
    if (provider.jmlStopKontak > 0) {
      _socketCtrl.text = provider.jmlStopKontak.toString();
    }
    
    if (provider.jmlLampu > 0 || provider.jmlSaklar1 > 0 || 
        provider.jmlSaklar2 > 0 || provider.jmlStopKontak > 0) {
      _isControllerInitialized = true;
      debugPrint('✓ Menu F: TextEditingController diisi dengan data dari provider');
    }
  }

  @override
  void dispose() {
    _lampCtrl.dispose();
    _singleSwitchCtrl.dispose();
    _doubleSwitchCtrl.dispose();
    _socketCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSimpan() async {
    final provider = context.read<EstimasiProvider>();
    final berhasil = await provider.simpanMenuF(
      jmlLampuStr: _lampCtrl.text,
      jmlSaklar1Str: _singleSwitchCtrl.text,
      jmlSaklar2Str: _doubleSwitchCtrl.text,
      jmlStopKontakStr: _socketCtrl.text,
    );
    if (!mounted) return;
    if (berhasil) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Kalkulasi selesai! Semua data berhasil disimpan.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.pesanError),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _onReset() {
    _lampCtrl.clear();
    _singleSwitchCtrl.clear();
    _doubleSwitchCtrl.clear();
    _socketCtrl.clear();
    context.read<EstimasiProvider>().resetMenuF();
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
            Text('Pekerjaan Finishing',
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            Text('Pengecatan dan titik instalasi listrik',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
        actions: [
          Consumer<EstimasiProvider>(
            builder: (_, provider, __) {
              if (!provider.menuFSudahDisimpan) return const SizedBox();
              return const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Chip(
                  label: Text('✓ Selesai',
                      style: TextStyle(fontSize: 11, color: Colors.white)),
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.zero,
                ),
              );
            },
          ),
        ],
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
              // Info box
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[100]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange[400], size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Volume pengecatan dihitung otomatis:\n'
                        '• Cat Tembok  → dari luas dinding (Menu B)\n'
                        '• Cat Plafon  → dari luas plafon (Menu E)\n'
                        '• Cat Kayu    → dari luas pintu & jendela (Menu D)\n\n'
                        'Isi data instalasi listrik di bawah ini.',
                        style: TextStyle(fontSize: 12, color: Colors.orange[800]),
                      ),
                    ),
                  ],
                ),
              ),

              _buildInputField('Jumlah Lampu LED', 'contoh : 12', _lampCtrl),
              _buildInputField('Jumlah Saklar Tunggal', 'contoh : 4', _singleSwitchCtrl),
              _buildInputField('Jumlah Saklar Ganda', 'contoh : 3', _doubleSwitchCtrl),
              _buildInputField('Jumlah Stop Kontak', 'contoh : 8', _socketCtrl),

              const SizedBox(height: 10),

              // Tombol Simpan
              Consumer<EstimasiProvider>(
                builder: (_, provider, __) {
                  return SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: provider.sedangMemuat ? null : _onSimpan,
                      icon: provider.sedangMemuat
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.check, color: Colors.white),
                      label: Text(
                        provider.sedangMemuat
                            ? 'Menghitung semua material...'
                            : 'Simpan Data Akhir & Hitung',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppStyles.primaryGreen,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Tombol Lanjut Ke Prediksi Pekerja
              Consumer<EstimasiProvider>(
                builder: (_, provider, __) {
                  return SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: provider.menuFSudahDisimpan
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PrediksiPekerjaPage(
                                    projectId: widget.projectId,
                                    projectName: widget.projectName,
                                    clientName: widget.clientName,
                                  ),
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.engineering, color: Colors.white),
                      label: const Text(
                        'Lanjut Ke Prediksi Pekerja',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: provider.menuFSudahDisimpan
                            ? Colors.indigo[600]
                            : Colors.grey[400],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Tombol Menu Estimasi & Reset
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
                        icon: Icon(Icons.home_outlined, color: Colors.grey[700]),
                        label: Text('Menu Estimasi',
                            style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
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
                        onPressed: _onReset,
                        icon: const Icon(Icons.refresh, color: Colors.red),
                        label: const Text('Reset',
                            style: TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[50],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
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

  Widget _buildInputField(String label, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppStyles.primaryGreen, width: 1.5)),
            ),
          ),
        ],
      ),
    );
  }
}