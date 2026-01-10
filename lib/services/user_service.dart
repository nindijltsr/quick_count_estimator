import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart'; 

class UserService {
  final CollectionReference _userCollection = 
      FirebaseFirestore.instance.collection('users');

  // add user
  Future<void> addUser(UserModel user) async {
    await _userCollection.add(user.toMap());
  }

  Stream<List<UserModel>> getUsers() {
    return _userCollection
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // update user
  Future<void> updateUser(UserModel user) async {
    await _userCollection.doc(user.uid).update(user.toMap());
  }
  
  // status 
  Future<void> toggleUserStatus(String uid, bool currentStatus) async {
    await _userCollection.doc(uid).update({
      'is_active': !currentStatus,
    });
  }

  // delete
  Future<void> deleteUser(String uid) async {
    await _userCollection.doc(uid).delete();
  }
}