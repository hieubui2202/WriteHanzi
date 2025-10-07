import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:myapp/src/models/user_profile.dart';

class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => 'AuthFailure: $message';
}

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
    } on PlatformException catch (e) {
      if (e.code == GoogleSignIn.kNetworkError) {
        throw const AuthFailure(
          'Không thể kết nối tới Google. Vui lòng kiểm tra mạng và thử lại.',
        );
      }

      final message = e.message ?? '';
      if (message.contains('com.google.android.gms')) {
        throw const AuthFailure(
          'Thiết bị này thiếu Google Play services nên không thể đăng nhập bằng Google. Vui lòng cài đặt Google Play services hoặc chọn cách đăng nhập khác.',
        );
      }

      throw AuthFailure(
        'Đăng nhập Google thất bại: ${e.message ?? 'Vui lòng thử lại sau.'}',
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(
        'Không thể xác thực với Google: ${e.message ?? 'Vui lòng thử lại.'}',
      );
    } catch (e) {
      debugPrint('Error during Google Sign-In: $e');
      throw const AuthFailure(
        'Có lỗi không xác định khi đăng nhập Google. Vui lòng thử lại.',
      );
    }
  }

  Future<UserProfile> _getOrCreateUserProfile(User user) async {
    final docRef = _firestore.collection('users').doc(user.uid);

    try {
      final snapshot = await docRef.get();

      if (snapshot.exists) {
        return UserProfile.fromMap(snapshot.data()!, snapshot.id);
      }

      final newUserProfile = UserProfile(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? 'Anonymous User',
        photoURL: user.photoURL,
        xp: 0,
        streak: 0,
        progress: {},
      );

      await docRef.set(newUserProfile.toMap());
      return newUserProfile;
    } on FirebaseException catch (e) {
      throw AuthFailure(
        e.message ?? 'Không thể tải dữ liệu người dùng lúc này.',
      );
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
      throw AuthFailure(
        e.message ?? 'Không thể đăng nhập bằng email và mật khẩu.',
      );
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
          uid: user.uid,
          email: email,
          displayName: displayName,
          xp: 0,
          streak: 0,
          progress: {},
          photoURL: null,
        );
        await _firestore.collection('users').doc(user.uid).set(newUserProfile.toMap());
        _userProfile = newUserProfile;
      }
      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Error creating user: ${e.message}');
      throw AuthFailure(
        e.message ?? 'Không thể tạo tài khoản mới. Vui lòng thử lại.',
      );
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
    } on FirebaseAuthException catch (e) {
      debugPrint('Error signing in anonymously: ${e.message}');
      throw AuthFailure(
        e.message ?? 'Không thể đăng nhập ẩn danh lúc này.',
      );
    } catch (e) {
      debugPrint('Error signing in anonymously: $e');
      throw const AuthFailure(
        'Có lỗi khi đăng nhập ẩn danh. Vui lòng thử lại sau.',
      );
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
