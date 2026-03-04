import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../shared/utils/styles.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/services/user_service.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // helper format tanggal
  String _formatDate(DateTime? date) {
    if (date == null) return "-";
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  // add user
  void _showAddUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    String selectedRole = 'user';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Tambah Pengguna Baru"),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Nama Lengkap", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                      validator: (value) => value!.isEmpty ? "Nama wajib diisi" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: "Email Google", border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
                      validator: (value) => value!.isEmpty ? "Email wajib diisi" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: "Nomor Telepon / WA", border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)),
                      validator: (value) => value!.isEmpty ? "Nomor telepon wajib diisi" : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: const InputDecoration(labelText: "Jabatan / Role", border: OutlineInputBorder(), prefixIcon: Icon(Icons.badge)),
                      items: const [
                        DropdownMenuItem(value: 'user', child: Text("Surveyor (User)")),
                        DropdownMenuItem(value: 'admin', child: Text("Admin")),
                      ],
                      onChanged: (value) {
                        if (value != null) selectedRole = value;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppStyles.primaryGreen),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  UserModel newUser = UserModel(
                    uid: '', 
                    email: emailController.text.trim().toLowerCase(),
                    name: nameController.text.trim(),
                    phoneNumber: phoneController.text.trim(),
                    role: selectedRole,
                    isActive: true,
                    createdAt: DateTime.now(),
                  );
                  await _userService.addUser(newUser);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil menambahkan pengguna!"), backgroundColor: Colors.green));
                  }
                }
              },
              child: const Text("Simpan", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // edit user
  void _showEditUserDialog(UserModel user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.phoneNumber);
    String selectedRole = user.role;
    bool currentStatus = user.isActive; 
    
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Edit Data Pengguna"),
              content: SizedBox(
                width: 400,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: "Nama Lengkap", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                          validator: (value) => value!.isEmpty ? "Nama wajib diisi" : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(labelText: "Email Google", border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
                          validator: (value) => value!.isEmpty ? "Email wajib diisi" : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: phoneController,
                          decoration: const InputDecoration(labelText: "Nomor Telepon / WA", border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)),
                          validator: (value) => value!.isEmpty ? "Nomor telepon wajib diisi" : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedRole,
                          decoration: const InputDecoration(labelText: "Jabatan / Role", border: OutlineInputBorder(), prefixIcon: Icon(Icons.badge)),
                          items: const [
                            DropdownMenuItem(value: 'user', child: Text("Surveyor (User)")),
                            DropdownMenuItem(value: 'admin', child: Text("Admin")),
                          ],
                          onChanged: (value) {
                            if (value != null) selectedRole = value;
                          },
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text("Status Akun Aktif"),
                          subtitle: Text(currentStatus ? "User bisa akses aplikasi" : "User diblokir"),
                          value: currentStatus,
                          activeColor: AppStyles.primaryGreen,
                          onChanged: (bool val) {
                            setDialogState(() {
                              currentStatus = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppStyles.primaryGreen),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      UserModel updatedUser = UserModel(
                        uid: user.uid,
                        email: emailController.text.trim().toLowerCase(),
                        name: nameController.text.trim(),
                        phoneNumber: phoneController.text.trim(),
                        role: selectedRole,
                        isActive: currentStatus, 
                        createdAt: user.createdAt,
                      );
                      await _userService.updateUser(updatedUser);
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data berhasil diperbarui!")));
                      }
                    }
                  },
                  child: const Text("Update", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  // delete user
  void _confirmDelete(String uid, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Pengguna"),
        content: Text("Yakin ingin menghapus data $name?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _userService.deleteUser(uid);
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          )
        ],
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
            // header + btn tambah
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MANAJEMEN AKUN', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    Text('Kelola Akun Pengguna (Whitelist)', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _showAddUserDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Tambah Pengguna'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.primaryGreen, 
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // search bar
            SizedBox(
              width: 400,
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Cari nama atau email...',
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
              child: StreamBuilder<List<UserModel>>(
                stream: _userService.getUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Belum ada data pengguna."));

                  final users = snapshot.data!.where((user) {
                    return user.name.toLowerCase().contains(_searchQuery) || user.email.toLowerCase().contains(_searchQuery);
                  }).toList();

                  return Align(
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
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(const Color(0xFFE3EAE6)), 
                                  columnSpacing: 20,
                                  columns: const [
                                    DataColumn(label: Text('No', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Nama Lengkap', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('No. HP', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Jabatan', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Tanggal Dibuat', style: TextStyle(fontWeight: FontWeight.bold))), 
                                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                                  ],
                                  rows: List.generate(users.length, (index) => _buildRow(index + 1, users[index])),
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

  // row tabel
  DataRow _buildRow(int no, UserModel user) {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    final isCurrentUser = user.email == currentUserEmail;

    return DataRow(cells: [
      DataCell(Text(no.toString())),
      DataCell(Text(user.name)),
      DataCell(Text(user.email)),
      DataCell(Text(user.phoneNumber)),
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: user.role == 'admin' ? Colors.blue[50] : Colors.purple[50], borderRadius: BorderRadius.circular(6)),
          child: Text(user.role.toUpperCase(), style: TextStyle(color: user.role == 'admin' ? Colors.blue : Colors.purple, fontSize: 11, fontWeight: FontWeight.bold)),
        )
      ),
      DataCell(Text(_formatDate(user.createdAt))), 
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: user.isActive ? Colors.green[50] : Colors.red[50],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            user.isActive ? 'Aktif' : 'Non-aktif',
            style: TextStyle(color: user.isActive ? Colors.green[800] : Colors.red[800], fontSize: 12, fontWeight: FontWeight.w500),
          ),
        )
      ),
      DataCell(
        isCurrentUser
        ? const Text("(Akun Saya)", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 12))
        : Row(
            mainAxisSize: MainAxisSize.min, 
            children: [
              IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blue), onPressed: () => _showEditUserDialog(user)),
              IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _confirmDelete(user.uid, user.name)),
            ],
          )
      ),
    ]);
  }
}