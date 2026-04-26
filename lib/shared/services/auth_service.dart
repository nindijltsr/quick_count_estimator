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

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        final QuerySnapshot result = await _firestore
            .collection('users')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();

        if (result.docs.isEmpty) {
          await logout();
          throw "Email tidak terdaftar dalam sistem. Hubungi Admin.";
        }

        final userDoc = result.docs.first;
        final userData = userDoc.data() as Map<String, dynamic>;

        bool isActive = userData['is_active'] ?? true;
        if (!isActive) {
          await logout();
          throw "Akun dinonaktifkan. Hubungi Admin.";
        }

        await _firestore.collection('users').doc(userDoc.id).update({
          'uid': user.uid,
          'last_login': FieldValue.serverTimestamp(),
        });

        // Catat log login — UID sudah valid di titik ini
        await _catatLog(
          idPengguna: user.uid,
          namaAksi: 'LOGIN',
          detail: user.email ?? '',
        );

        String role = userData['role'] ?? 'user';
        return {'user': user, 'role': role};
      }
    } catch (e) {
      await logout();
      rethrow;
    }
    return null;
  }

  Future<void> logout() async {
    // Catat log SEBELUM session dihapus — setelah signOut UID tidak tersedia
    final user = _auth.currentUser;
    if (user != null) {
      await _catatLog(
        idPengguna: user.uid,
        namaAksi: 'LOGOUT',
        detail: user.email ?? '',
      );
    }

    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// Tulis satu entri ke riwayatAktivitas.
  /// id_proyek dikosongkan karena login/logout tidak terkait proyek spesifik.
  Future<void> _catatLog({
    required String idPengguna,
    required String namaAksi,
    String detail = '',
  }) async {
    try {
      await _firestore.collection('riwayatAktivitas').add({
        'id_proyek': '',
        'id_pengguna': idPengguna,
        'nama_aksi': namaAksi,
        'detail': detail,
        'dibuat_pada': FieldValue.serverTimestamp(),
      });
    } catch (e) {
    }
  }
}