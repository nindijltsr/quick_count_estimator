import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

const Color primaryDarkGreen = Color(0xFF0B4D3C); 

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) return const Center(child: Text("Anda belum login"));

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 40.0, right: 40.0, top: 30.0, bottom: 40.0), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header
            const Text(
              "PENGATURAN",
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Manajemen profil administrator dan informasi teknis sistem.",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 30), 

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // card profil
                Expanded(
                  flex: 5,
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser!.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return _buildLoadingCard();
                      if (!snapshot.hasData || !snapshot.data!.exists) return _buildErrorCard("Data pengguna gagal dimuat.");

                      var data = snapshot.data!.data() as Map<String, dynamic>;
                      
                      String name = data['name'] ?? 'Admin';
                      String email = data['email'] ?? currentUser!.email ?? '-';
                      String phone = data['phone_number'] ?? '-';
                      
                      String joinedDate = '-';
                      if (data['created_at'] != null) {
                        Timestamp timestamp = data['created_at'];
                        joinedDate = DateFormat('dd MMM yyyy').format(timestamp.toDate());
                      }

                      return _buildProfileCard(name, email, phone, joinedDate);
                    },
                  ),
                ),
                
                const SizedBox(width: 30),

                // card info sistem
                Expanded(
                  flex: 4,
                  child: _buildSystemInfoCard(),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // card 3
            _buildSupportCard(),
          ],
        ),
      ),
    );
  }

  // tampilan
  // profil
  Widget _buildProfileCard(String name, String email, String phone, String joinedDate) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25), 
      decoration: _mockupCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Profil Admin",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: primaryDarkGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6)
                ),
                child: const Text(
                  "Administrator", 
                  style: TextStyle(fontSize: 11, color: primaryDarkGreen, fontWeight: FontWeight.w800)
                ),
              )
            ],
          ),
          
          const SizedBox(height: 20), 

          // avatar
          Center(
            child: Column(
              children: [
                // Ring Avatar
                Container(
                  padding: const EdgeInsets.all(4), 
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryDarkGreen.withOpacity(0.3), width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 45, 
                    backgroundColor: primaryDarkGreen.withOpacity(0.1), 
                    child: const Icon(Icons.person, size: 50, color: primaryDarkGreen),
                  ),
                ),
                
                const SizedBox(height: 15),
                
                Text(
                  name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4), 
                Text(
                  email,
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          Divider(color: Colors.grey[200], thickness: 1),
          const SizedBox(height: 15),

          // Info 
          _buildCompactInfoRow("Nomor Telepon", phone, Icons.phone_android),
          const SizedBox(height: 12),
          _buildCompactInfoRow("Bergabung Sejak", joinedDate, Icons.date_range),
          
          const SizedBox(height: 25),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showEditProfileDialog(name, phone),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryDarkGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text("Perbarui Data Profil", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // card 1 info
  Widget _buildCompactInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[400]),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }

  // card 2
  Widget _buildSystemInfoCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: _mockupCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Informasi Teknis Sistem", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20), 
          
          _buildGreyInfoBox(Icons.apps, "Label Aplikasi", "Quick Count Estimator"),
          const SizedBox(height: 12),
          _buildGreyInfoBox(Icons.layers, "Versi", "1.0.0"),
          const SizedBox(height: 12),
          _buildGreyInfoBox(Icons.calendar_today, "Waktu Rilis", DateFormat('MMMM yyyy').format(DateTime.now())),
        ],
      ),
    );
  }

  Widget _buildGreyInfoBox(IconData icon, String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12), 
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryDarkGreen, size: 26),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // card 3
  Widget _buildSupportCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: _mockupCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Pusat Bantuan & Dukungan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildGreyInfoBox(Icons.email_outlined, "Email", "contoh@gmail.com")),
              const SizedBox(width: 20),
              Expanded(child: _buildGreyInfoBox(Icons.chat_bubble_outline, "WhatsApp", "08xxxxxx")),
              const SizedBox(width: 20),
              Expanded(child: _buildGreyInfoBox(Icons.language, "Situs Resmi", "www.webperusahaan.com")),
            ],
          )
        ],
      ),
    );
  }

  BoxDecoration _mockupCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Container(height: 400, decoration: _mockupCardDecoration(), child: const Center(child: CircularProgressIndicator()));
  }
  Widget _buildErrorCard(String msg) {
    return Container(height: 200, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)), child: Center(child: Text(msg, style: const TextStyle(color: Colors.red))));
  }

  // dialog edit
  void _showEditProfileDialog(String currentName, String currentPhone) {
    final nameController = TextEditingController(text: currentName);
    final phoneController = TextEditingController(text: currentPhone);
    bool isDialogLoading = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Perbarui Data Profil", style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Nama Lengkap Administrator", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: "Nomor Kontak (WhatsApp)", border: OutlineInputBorder()),
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: isDialogLoading ? null : () async {
                    if (nameController.text.isEmpty) return;
                    setDialogState(() => isDialogLoading = true);
                    try {
                      await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).update({
                        'name': nameController.text.trim(),
                        'phone_number': phoneController.text.trim(),
                      });
                      if (mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Data profil telah berhasil diperbarui."), backgroundColor: primaryDarkGreen)
                        );
                      }
                    } catch (e) {
                      setDialogState(() => isDialogLoading = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: primaryDarkGreen),
                  child: isDialogLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Simpan Perubahan", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}