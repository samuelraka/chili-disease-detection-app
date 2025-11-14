import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';


class FirebaseService {
  // Instance Firebase
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static final FirebaseStorage storage = FirebaseStorage.instance;

  // Getter user saat ini
  static User? get currentUser => auth.currentUser;

  // Collection
  static CollectionReference get usersCollection => firestore.collection('users');
  static CollectionReference get detectionHistory => firestore.collection('detection_history');

  // Authentication
  static Future<UserCredential?> signUp(String email, String password) async {
    try {
      return await auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print('Error signing up: $e');
      return null;
    }
  }

  static Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    await auth.signOut();
  }

  // Firestore
  static Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await usersCollection.doc(userId).set(data, SetOptions(merge: true));
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }

  static Future<void> addDetectionRecord(Map<String, dynamic> data) async {
    try {
      await detectionHistory.add(data);
    } catch (e) {
      print('Error adding detection record: $e');
    }
  }

  // Storage
  static Future<String?> uploadImage(File imageFile) async {
    try {
      final userId = currentUser?.uid;
      if (userId == null) return null;

      final ref = storage
          .ref()
          .child('detection_images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  static Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting image: $e');
    }
  }
}
