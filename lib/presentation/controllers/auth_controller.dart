import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../pages/splash/routes.dart';
import 'progress_controller.dart';

class AuthController extends GetxController {
  AuthController(this._auth);

  final FirebaseAuth _auth;

  final Rx<User?> firebaseUser = Rx<User?>(null);
  final RxBool loading = false.obs;
  ProgressController? _progressController;

  void attachProgressController(ProgressController controller) {
    _progressController = controller;
    final user = firebaseUser.value;
    if (user != null) {
      controller.bootstrap();
    }
  }

  @override
  void onReady() {
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, (user) {
      if (user == null) {
        Get.offAllNamed(AppRoutes.auth);
      } else {
        _progressController?.bootstrap();
        Get.offAllNamed(AppRoutes.home);
      }
    });
    super.onReady();
  }

  Future<void> signInWithGoogle() async {
    try {
      loading.value = true;
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        loading.value = false;
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
    } finally {
      loading.value = false;
    }
  }

  Future<void> signInAnonymously() async {
    try {
      loading.value = true;
      await _auth.signInAnonymously();
    } finally {
      loading.value = false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }
}
