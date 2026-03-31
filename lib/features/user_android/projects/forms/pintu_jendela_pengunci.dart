import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'atap_dan_plafon.dart';
import '../project_estimation_page.dart';
import '../../../../shared/utils/styles.dart';
import '../../../../shared/services/estimasi_provider.dart';

class PintuJendelaPengunciPage extends StatefulWidget {
  final String projectId;
  final String projectName;
  final String clientName;

  const PintuJendelaPengunciPage({
    super.key,
    required this.projectId,
    required this.projectName,
    required this.clientName,
  });

  @override
  State<PintuJendelaPengunciPage> createState() =>
      _PintuJendelaPengunciPageState();
}

class _PintuJendelaPengunciPageState extends State<PintuJendelaPengunciPage> {
  final _doorCountCtrl = TextEditingController();
  final _windowCountCtrl = TextEditingController();

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
    
    if (provider.jmlPintu > 0) {
      _doorCountCtrl.text = provider.jmlPintu.toString();
    }
    if (provider.jmlJendela > 0) {
      _windowCountCtrl.text = provider.jmlJendela.toString();
    }
    
    if (provider.jmlPintu > 0 || provider.jmlJendela > 0) {
      _isControllerInitialized = true;
      debugPrint('✓ Menu D: TextEditingController diisi dengan data dari provider');
    }
  }

  @override
  void dispose() {
    _doorCountCtrl.dispose();
    _windowCountCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSimpan() async {
    final provider = context.read<EstimasiProvider>();

    final berhasil = await provider.simpanMenuD(
      jmlPintuStr: _doorCountCtrl.text,
      jmlJendelaStr: _windowCountCtrl.text,
    );

    if (!mounted) return;

    if (berhasil) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Data Menu D berhasil disimpan!'),
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
    _doorCountCtrl.clear();
    _windowCountCtrl.clear();
    context.read<EstimasiProvider>().resetMenuD();
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
              'Pintu, Jendela & Pengunci',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Input jumlah kusen dan daun pintu',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
        actions: [
          Consumer<EstimasiProvider>(
            builder: (_, provider, __) {
              if (!provider.menuDSudahDisimpan) return const SizedBox();
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
                'Jumlah Pintu',
                'contoh : 5',
                _doorCountCtrl,
                isDecimal: false,
              ),
              _buildInputField(
                'Jumlah Jendela',
                'contoh : 8',
                _windowCountCtrl,
                isDecimal: false,
              ),

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

              // Tombol Lanjut
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AtapDanPlafonPage(
                          projectId: widget.projectId,
                          projectName: widget.projectName,
                          clientName: widget.clientName,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  label: const Text(
                    'Lanjut Ke Pekerjaan Atap dan Plafon',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
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