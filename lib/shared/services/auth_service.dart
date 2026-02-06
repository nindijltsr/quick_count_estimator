import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        final QuerySnapshot result = await _firestore
            .collection('users')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();

        if (result.docs.isEmpty) {
          await logout();
          throw "Email tidak terdaftar dalam sistem.";
        }

        final userData = result.docs.first.data() as Map<String, dynamic>;

        bool isActive = userData['is_active'] ?? false;
        if (!isActive) {
          await logout();
          throw "Akun dinonaktifkan. Hubungi Admin.";
        }

        await _firestore.collection('users').doc(result.docs.first.id).update({
          'uid': user.uid,
          'last_login': FieldValue.serverTimestamp(),
        });

        String role = userData['role'] ?? 'user';
        return {
          'user': user,
          'role': role,
        };
      }
    } catch (e) {
      rethrow; 
    }
    return null;
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}