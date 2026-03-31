import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'struktur_dan_dinding.dart';
import '../project_estimation_page.dart';
import '../../../../shared/utils/styles.dart';
import '../../../../shared/services/estimasi_provider.dart';

class PersiapanTanahFondasiPage extends StatefulWidget {
  final String projectId;
  final String projectName;
  final String clientName;

  const PersiapanTanahFondasiPage({
    super.key,
    required this.projectId,
    required this.projectName,
    required this.clientName,
  });

  @override
  State<PersiapanTanahFondasiPage> createState() =>
      _PersiapanTanahFondasiPageState();
}

class _PersiapanTanahFondasiPageState
    extends State<PersiapanTanahFondasiPage> {
  final _landLengthCtrl = TextEditingController();
  final _landWidthCtrl = TextEditingController();
  final _foundationLengthCtrl = TextEditingController();
  final _foundationPointCtrl = TextEditingController();

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
    
    if (provider.menuASudahDisimpan) {
      _landLengthCtrl.text = provider.pTanah > 0 ? provider.pTanah.toString() : '';
      _landWidthCtrl.text = provider.lTanah > 0 ? provider.lTanah.toString() : '';
      _foundationLengthCtrl.text = provider.pPondasi > 0 ? provider.pPondasi.toString() : '';
      _foundationPointCtrl.text = provider.jmlTitikTapak > 0 ? provider.jmlTitikTapak.toString() : '';
      
      _isControllerInitialized = true;
      debugPrint('✓ TextEditingController diisi dengan data dari provider');
    }
  }

  @override
  void dispose() {
    _landLengthCtrl.dispose();
    _landWidthCtrl.dispose();
    _foundationLengthCtrl.dispose();
    _foundationPointCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSimpan() async {
    final provider = context.read<EstimasiProvider>();

    final berhasil = await provider.simpanMenuA(
      pTanahStr: _landLengthCtrl.text,
      lTanahStr: _landWidthCtrl.text,
      pPondasiStr: _foundationLengthCtrl.text,
      jmlTitikTapakStr: _foundationPointCtrl.text,
    );

    if (!mounted) return;

    if (berhasil) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Data Menu A berhasil disimpan!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.pesanError),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _onReset() {
    _landLengthCtrl.clear();
    _landWidthCtrl.clear();
    _foundationLengthCtrl.clear();
    _foundationPointCtrl.clear();
    context.read<EstimasiProvider>().resetMenuA();
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
              'Persiapan Tanah dan Pondasi',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Input dimensi lahan dan galian',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
        actions: [
          Consumer<EstimasiProvider>(
            builder: (_, provider, __) {
              if (!provider.menuASudahDisimpan) return const SizedBox();
              return const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Chip(
                  label: Text(
                    '✓ Tersimpan',
                    style: TextStyle(fontSize: 11, color: Colors.white),
                  ),
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
              _buildInputField(
                'Panjang Tanah ( meter )',
                'contoh : 10.5',
                _landLengthCtrl,
                isDecimal: true,
              ),
              _buildInputField(
                'Lebar Tanah ( meter )',
                'contoh : 8',
                _landWidthCtrl,
                isDecimal: true,
              ),
              _buildInputField(
                'Panjang Pondasi ( meter )',
                'contoh : 43.2',
                _foundationLengthCtrl,
                isDecimal: true,
              ),
              _buildInputField(
                'Jumlah Titik Pondasi Tapak',
                'contoh : 4',
                _foundationPointCtrl,
                isDecimal: false,
              ),

              const SizedBox(height: 10),

              // aksi simpan data dengan indikator loading
              Consumer<EstimasiProvider>(
                builder: (_, provider, __) {
                  return SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: provider.sedangMemuat ? null : _onSimpan,
                      icon: provider.sedangMemuat
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.check, color: Colors.white),
                      label: Text(
                        provider.sedangMemuat ? 'Menyimpan...' : 'Simpan Data',
                        style: const TextStyle(
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
                  );
                },
              ),
              const SizedBox(height: 12),

              // navigasi ke halaman berikutnya
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StrukturDanDindingPage(
                          projectId: widget.projectId,
                          projectName: widget.projectName,
                          clientName: widget.clientName,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  label: const Text(
                    'Lanjut Ke Pekerjaan Dinding dan Struktur',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // navigasi ke menu estimasi dan fungsi reset input
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
                        label: Text(
                          'Menu Estimasi',
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
                        onPressed: _onReset,
                        icon: const Icon(Icons.refresh, color: Colors.red),
                        label: const Text(
                          'Reset',
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