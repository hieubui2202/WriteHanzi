import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:myapp/src/models/user_profile.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  // Initialize with the correct database URL
  final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: 'https://testlogin-4767c-default-rtdb.firebaseio.com/');

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
    final dbRef = _database.ref('users/${user.uid}');
    debugPrint('Fetching profile for user: ${user.uid}');

    DataSnapshot snapshot;
    try {
      snapshot = await dbRef.get();
      debugPrint('Realtime Database get() succeeded for ${user.uid}.');
    } on MissingPluginException catch (e) {
      debugPrint(
        'Realtime Database get() missing on this platform, falling back to once(): $e',
      );
      final event = await dbRef.once(DatabaseEventType.value);
      snapshot = event.snapshot;
    }

    if (snapshot.exists && snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      debugPrint('Profile loaded from database for ${user.uid}.');
      return UserProfile.fromMap(data, user.uid);
    } else {
      final newUserProfile = UserProfile(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? 'Anonymous User',
        photoURL: user.photoURL,
        xp: 0,
        streak: 0,
        progress: {},
      );
      await dbRef.set(newUserProfile.toMap());
      debugPrint('Created default profile for ${user.uid}.');
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
          progress: {},
          photoURL: null,
        );
        await _database.ref('users/${user.uid}').set(newUserProfile.toMap());
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
    _user = null;
    _userProfile = null;
    notifyListeners();
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
