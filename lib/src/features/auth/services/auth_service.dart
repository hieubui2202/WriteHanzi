import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:myapp/src/models/user_profile.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  UserProfile? _userProfile;

  User? get user => _user;
  UserProfile? get userProfile => _userProfile;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    if (user != null) {
      try {
        _userProfile = await _getOrCreateUserProfile(user);
      } catch (e) {
        debugPrint("Error in _onAuthStateChanged: $e");
        _userProfile = null;
      }
    } else {
      _userProfile = null;
    }
    notifyListeners();
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // User canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      _user = userCredential.user;

      if (_user != null) {
        _userProfile = await _getOrCreateUserProfile(_user!);
      }

      notifyListeners();
      return _user;
    } catch (e) {
      debugPrint('Error during Google Sign-In: $e');
      return null;
    }
  }

  Future<UserProfile> _getOrCreateUserProfile(User user) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final snapshot = await docRef.get();

    if (snapshot.exists && snapshot.data() != null) {
      final data = snapshot.data()!;
      return UserProfile.fromMap(data, user.uid);
    } else {
      final newUserProfile = UserProfile(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? 'Anonymous User',
        photoURL: user.photoURL,
        xp: 0,
        streak: 0,
        progress: const {},
      );
      await docRef.set(newUserProfile.toMap());
      return newUserProfile;
    }
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Error signing in with email: ${e.message}');
      throw Exception('Error signing in with email: ${e.message}');
    }
  }

  Future<User?> createUserWithEmailAndPassword(
      String email, String password, String displayName) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;
      if (user != null) {
        final newUserProfile = UserProfile(
          id: user.uid,
          email: email,
          displayName: displayName,
          xp: 0,
          streak: 0,
          progress: const {},
          photoURL: null,
        );
        await _firestore.collection('users').doc(user.uid).set(newUserProfile.toMap());
        _userProfile = newUserProfile;
      }
      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Error creating user: ${e.message}');
      throw Exception('Error creating user: ${e.message}');
    }
  }

  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      final User? user = userCredential.user;
      if (user != null) {
        _userProfile = await _getOrCreateUserProfile(user);
      }
      return user;
    } catch (e) {
      debugPrint('Error signing in anonymously: $e');
      throw Exception('Error signing in anonymously: $e');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Stream<UserProfile?> get userProfileStream {
    return _auth.authStateChanges().asyncMap((user) {
      if (user != null) {
        return _getOrCreateUserProfile(user);
      }
      return null;
    });
  }
}
