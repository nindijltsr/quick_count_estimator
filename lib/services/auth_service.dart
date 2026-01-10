import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Login Google: Mengembalikan Map berisi User dan Role
  // Contoh return: {'user': UserObject, 'role': 'admin'}
  Future<Map<String, dynamic>?> loginWithGoogle() async {
    try {
      // 1. Google Sign In Flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 2. Firebase Auth
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // 3. Cek Whitelist (Cari Email di Firestore)
        final QuerySnapshot result = await _firestore
            .collection('users')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();

        // Validasi: Apakah Email ada?
        if (result.docs.isEmpty) {
          await logout();
          throw "Email tidak terdaftar dalam sistem.";
        }

        final userData = result.docs.first.data() as Map<String, dynamic>;

        // Validasi: Apakah Status Aktif?
        bool isActive = userData['is_active'] ?? false;
        if (!isActive) {
          await logout();
          throw "Akun dinonaktifkan. Hubungi Admin.";
        }

        // Update data terakhir login
        await _firestore.collection('users').doc(result.docs.first.id).update({
          'uid': user.uid,
          'last_login': FieldValue.serverTimestamp(),
        });

        // KEMBALIKAN DATA USER & ROLE (PENTING!)
        String role = userData['role'] ?? 'user';
        return {
          'user': user,
          'role': role,
        };
      }
    } catch (e) {
      rethrow; // Lempar error ke UI
    }
    return null;
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}