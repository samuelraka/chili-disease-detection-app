import 'package:shared_preferences/shared_preferences.dart';
import '../utils/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges(); 
  // Register user dan simpan profile ke Firestore
  static Future<bool> saveAccount(String username, String email, String password) async {
    try {
      // Cek apakah username sudah ada di Firestore (unik hanya di Firestore, bukan di Auth)
      final query = await FirebaseService.usersCollection
          .where('username', isEqualTo: username)
          .get();

      if (query.docs.isNotEmpty) {
        throw Exception('username-already-in-use');
      }

      // Buat user di Firebase Auth
      final result = await FirebaseService.signUp(email, password);
      if (result?.user == null) return false;

      // Simpan data user di Firestore
      await FirebaseService.usersCollection
          .doc(result!.user!.uid)
          .set({
        'username': username,
        'email': email,
        'createdAt': DateTime.now().toIso8601String(),
      });

      return true;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.message}');
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('email-already-in-use');
        case 'invalid-email':
          throw Exception('invalid-email');
        case 'weak-password':
          throw Exception('weak-password');
        default:
          throw Exception('auth-error');
      }
    } catch (e) {
      print('Error saving account: $e');
      if (e.toString().contains('username-already-in-use')) {
        throw Exception('username-already-in-use');
      }
      throw Exception('database-error');
    }
  }

  // Login pakai email & password
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  static Future<void> logout() async {
    await FirebaseService.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    await prefs.remove('uid');
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', value);
  }

  static Future<void> saveUID(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', uid);
  }

  static Future<String?> getUID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid');
  }

  static Future<String?> getCurrentUsername() async {
    try {
      final user = FirebaseService.currentUser;
      if (user != null) {
        final userDoc = await FirebaseService.usersCollection.doc(user.uid).get();
        if (userDoc.exists) {
          return (userDoc.data() as Map<String, dynamic>?)?['username'];
        }
      }
      return null;
    } catch (e) {
      print('Error getting username: $e');
      return null;
    }
  }
}
