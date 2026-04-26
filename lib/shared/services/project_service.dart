import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/project_model.dart';

class ProjectService {
  final CollectionReference _projectCollection =
      FirebaseFirestore.instance.collection('projects');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addProject({
    required String projectName,
    required String clientName,
    required String address,
    required String phoneNumber,
  }) async {
    User? user = _auth.currentUser;
    if (user == null) throw "User not authenticated";

    String surveyorName = user.displayName ?? user.email ?? 'Surveyor';
    String surveyorEmail = user.email ?? 'no-email@test.com';

    try {
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        Map<String, dynamic> data =
            userQuery.docs.first.data() as Map<String, dynamic>;
        if (data.containsKey('name') && data['name'] != null) {
          surveyorName = data['name'];
        }
      }
    } catch (_) {}

    final docRef = await _projectCollection.add({
      'user_id': user.uid,
      'surveyor_name': surveyorName,
      'surveyor_email': surveyorEmail,
      'project_name': projectName,
      'client_name': clientName,
      'address': address,
      'phone_number': phoneNumber,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });

    // Catat log pembuatan proyek
    await FirebaseFirestore.instance.collection('riwayatAktivitas').add({
      'id_proyek': docRef.id,
      'id_pengguna': user.uid,
      'nama_aksi': 'BUAT_PROYEK',
      'detail': projectName,
      'dibuat_pada': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<ProjectModel>> getProjectsForUser() {
    User? user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _projectCollection
        .where('user_id', isEqualTo: user.uid)
        .orderBy('updated_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProjectModel.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Stream<List<ProjectModel>> getAllProjects() {
    return _projectCollection
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProjectModel.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  /// [projectNameLama] dipakai untuk menyusun detail log perubahan nama.
  Future<void> updateProject({
    required String projectId,
    required String projectName,
    required String projectNameLama,
    required String clientName,
    required String address,
    required String phoneNumber,
  }) async {
    final user = _auth.currentUser;

    await _projectCollection.doc(projectId).update({
      'project_name': projectName,
      'client_name': clientName,
      'address': address,
      'phone_number': phoneNumber,
      'updated_at': FieldValue.serverTimestamp(),
    });

    if (user != null) {
      final namaBerubah = projectName.trim() != projectNameLama.trim();
      final detail = namaBerubah
          ? '$projectNameLama -> $projectName'
          : projectName;

      await FirebaseFirestore.instance.collection('riwayatAktivitas').add({
        'id_proyek': projectId,
        'id_pengguna': user.uid,
        'nama_aksi': 'EDIT_PROYEK',
        'detail': detail,
        'dibuat_pada': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Menghapus proyek utama beserta seluruh sub-collection di dalamnya.
  /// [projectName] wajib diisi agar log mencatat nama proyek sebelum data hilang.
  Future<void> deleteProject({
    required String projectId,
    required String projectName,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final batch = FirebaseFirestore.instance.batch();
    final projectRef = _projectCollection.doc(projectId);

    try {
      batch.delete(projectRef.collection('inputUser').doc('data'));

      const hasilMenuDocs = [
        'persiapan_tanah_pondasi',
        'struktur_dan_dinding',
        'lantai_dan_timbunan',
        'pintu_jendela_pengunci',
        'atap_dan_plafon',
        'finishing_cat_listrik',
        'estimasi_upah',
      ];

      for (final docName in hasilMenuDocs) {
        batch.delete(projectRef.collection('hasil_perhitungan').doc(docName));
      }
      batch.delete(projectRef.collection('rekap_akhir').doc('material'));
      batch.delete(projectRef);
      await batch.commit();

      // Catat log SETELAH batch commit — nama proyek disimpan di detail
      // karena dokumen proyek sudah terhapus dari Firestore
      if (user != null) {
        await FirebaseFirestore.instance.collection('riwayatAktivitas').add({
          'id_proyek': projectId,
          'id_pengguna': user.uid,
          'nama_aksi': 'HAPUS_PROYEK',
          'detail': projectName,
          'dibuat_pada': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Gagal menghapus proyek beserta isinya: $e');
    }
  }
}