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
        Map<String, dynamic> data = userQuery.docs.first.data() as Map<String, dynamic>;
        if (data.containsKey('name') && data['name'] != null) {
          surveyorName = data['name'];
        }
      }
    } catch (e) {
    }

    await _projectCollection.add({
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

  Future<void> updateProject({
    required String projectId,
    required String projectName,
    required String clientName,
    required String address,
    required String phoneNumber,
  }) async {
    await _projectCollection.doc(projectId).update({
      'project_name': projectName,
      'client_name': clientName,
      'address': address,
      'phone_number': phoneNumber,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteProject(String projectId) async {
    await _projectCollection.doc(projectId).delete();
  }
}