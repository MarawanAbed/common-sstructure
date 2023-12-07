import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_advanced/common.dart';
import 'package:firebase_advanced/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential> signIn(
      {required String email, required String password}) async {
    try {
       await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await DatabaseService().updateUser({
        'lastActive': DateTime.now(),
        'uId': _auth.currentUser!.uid,
        'isOnline': 'true',
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Utils.showSnackBar('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        Utils.showSnackBar('Wrong password provided for that user.');
      }
    }
    throw Exception('Failed to sign in');
  }

  Future<void> forgetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      if (kDebugMode) {
        print('Forgot password error: $e');
      }
      throw Exception('Failed to reset password');
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Utils.showSnackBar('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        Utils.showSnackBar('The account already exists for that email.');
      }
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Sign out error: $e');
      }
      throw Exception('Failed to sign out');
    }
  }

  Stream<User?> userState() {
    return _auth.authStateChanges();
  }

  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  //note if you want to use google_sign you need first to enable it in firebase console
  //and then you need to add sha key to your project in firebase console
  Future<void> handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
    } catch (e) {
      if (kDebugMode) {
        print('Google sign in error: $e');
      }
      throw Exception('Failed to sign in with Google');
    }
  }

  Future<bool> isEmailVerified() async {
    final user = _auth.currentUser!;
    await user.reload();
    return user.emailVerified;
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = _auth.currentUser!;
      if (!user.emailVerified) {
        await user.sendEmailVerification();
      } else {
        throw Exception('Email is already verified');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }
}

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser(UserEntity userEntity) async {
    final userCollection = _firestore.collection('users');
    final uid = AuthService().getCurrentUserId();
    if (uid != null) {
      final userData = await userCollection.doc(uid).get();
      if (!userData.exists) {
        final user = userEntity.toJson();
        await userCollection.doc(uid).set(user);
      }
    } else {
      throw Exception('Failed to create user');
    }
  }

  Stream<List> getAllUsers() {
    final userCollection =
        _firestore.collection('users').orderBy('lastActive', descending: true);

    return userCollection.snapshots(includeMetadataChanges: true).map(
      (querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          return querySnapshot.docs
              .map((doc) => UserEntity.fromJson(doc.data()))
              .toList();
        } else {
          return []; // Return an empty list if no users are found
        }
      },
    ).handleError((error) {
      if (kDebugMode) {
        print('Error fetching users: $error');
      }
      throw Exception('Failed to fetch users');
    });
  }

  Future<void> updateUser(Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(data);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user: $e');
      }
      throw Exception('Failed to update user');
    }
  }

  Stream<UserEntity?> getSingleUser(String uId) {
    final userDoc = _firestore.collection('users').doc(uId);

    return userDoc.snapshots().map((userSnapshot) {
      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;
        return UserEntity.fromJson(userData);
      } else {
        return null; // User not found
      }
    });
  }
}

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File imageFile) async {
    try {
      final ext = imageFile.path.split('.').last;

      final ref = _storage
          .ref()
          .child('images/${DateTime.now().millisecondsSinceEpoch}.$ext');
      await ref
          .putFile(imageFile, SettableMetadata(contentType: 'image/$ext'))
          .then((p0) {
        log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
      });
      final imageUrl = await ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Image upload error: $e');
      }
      throw Exception('Failed to upload image');
    }
  }
}
