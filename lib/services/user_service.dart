import 'package:cloud_firestore/cloud_firestore.dart';
// Pastikan path ini sesuai dengan letak user_model.dart kamu
// Kalau merah, hapus baris ini lalu tekan Ctrl + . di "UserModel" bawah untuk auto-import
import '../models/user_model.dart'; 

class UserService {
  // Mengarah ke koleksi 'users' di Firestore
  final CollectionReference _userCollection = 
      FirebaseFirestore.instance.collection('users');

  // 1. TAMBAH USER (Create)
  Future<void> addUser(UserModel user) async {
    // Kita biarkan Firestore membuat ID dokumen otomatis, 
    // atau bisa pakai user.email sebagai ID kalau mau unik per email
    await _userCollection.add(user.toMap());
  }

  // 2. AMBIL DATA REALTIME (Read Stream)
  Stream<List<UserModel>> getUsers() {
    // Diurutkan berdasarkan tanggal dibuat (terbaru di atas)
    return _userCollection
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // Mengubah data JSON Firestore menjadi Object UserModel
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // 3. UPDATE USER (Edit)
  Future<void> updateUser(UserModel user) async {
    await _userCollection.doc(user.uid).update(user.toMap());
  }
  
  // 4. GANTI STATUS AKTIF/NON-AKTIF (Toggle)
  Future<void> toggleUserStatus(String uid, bool currentStatus) async {
    await _userCollection.doc(uid).update({
      'is_active': !currentStatus,
    });
  }

  // 5. HAPUS USER (Delete)
  Future<void> deleteUser(String uid) async {
    await _userCollection.doc(uid).delete();
  }
}