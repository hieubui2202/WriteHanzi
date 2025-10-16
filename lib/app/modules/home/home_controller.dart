import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:myapp/app/data/models/chapter_model.dart';
import 'package:myapp/app/data/models/hanzi_character.dart';
import 'package:myapp/app/data/models/lesson_model.dart';
import 'package:myapp/app/data/repositories/home_repository.dart';
import 'package:myapp/src/models/user_profile.dart';

class HomeController extends GetxController {
  HomeController()
      : _repository = Get.find<HomeRepository>(),
        _auth = FirebaseAuth.instance,
        _firestore = FirebaseFirestore.instance,
        _googleSignIn = GoogleSignIn();

  final HomeRepository _repository;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  final chapters = <Chapter>[].obs;
  final lessons = <Lesson>[].obs;
  final isLoadingChapters = true.obs;
  final isLoadingLessons = false.obs;
  final isLoadingProfile = false.obs;
  final isSigningIn = false.obs;
  final isSigningInGuest = false.obs;
  final selectedChapter = Rx<Chapter?>(null);
  final firebaseUser = Rx<User?>(null);
  final profile = Rx<UserProfile?>(null);
  final nextCharacter = Rx<HanziCharacter?>(null);
  final overallProgress = 0.0.obs;
  final completedCharacters = 0.obs;
  final totalCharacters = 0.obs;
  final signInError = RxnString();

  StreamSubscription<User?>? _authSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _profileSub;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.value = _auth.currentUser;
    _authSub = _auth.authStateChanges().listen(_handleAuthChange);
    fetchChapters();
    if (_auth.currentUser != null) {
      _listenToProfile(_auth.currentUser!.uid);
    }
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _profileSub?.cancel();
    super.onClose();
  }

  Future<void> fetchChapters() async {
    try {
      isLoadingChapters.value = true;
      final chapterList = await _repository.getChapters();
      chapters.assignAll(chapterList);
      if (selectedChapter.value == null && chapters.isNotEmpty) {
        selectChapter(chapters.first);
      }
    } finally {
      isLoadingChapters.value = false;
    }
  }

  Future<void> fetchLessonsForChapter(String chapterId) async {
    try {
      isLoadingLessons.value = true;
      final lessonList = await _repository.getLessonsForChapter(chapterId);
      lessons.assignAll(lessonList);
    } finally {
      isLoadingLessons.value = false;
      _recomputeProgress();
    }
  }

  void selectChapter(Chapter chapter) {
    selectedChapter.value = chapter;
    fetchLessonsForChapter(chapter.id);
  }

  Future<void> refreshCurrent() async {
    if (selectedChapter.value == null) {
      await fetchChapters();
      return;
    }
    await fetchLessonsForChapter(selectedChapter.value!.id);
  }

  Future<void> signInWithGoogle() async {
    if (isSigningIn.value) {
      return;
    }
    signInError.value = null;
    try {
      isSigningIn.value = true;
      final googleAccount = await _googleSignIn.signIn();
      if (googleAccount == null) {
        return;
      }
      final googleAuth = await googleAccount.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
    } on PlatformException catch (error) {
      signInError.value = _mapSignInError(error);
      await _fallbackToAnonymousIfNeeded(error);
    } catch (error) {
      signInError.value = error.toString();
    } finally {
      isSigningIn.value = false;
    }
  }

  Future<void> signInAnonymously() async {
    if (isSigningInGuest.value) {
      return;
    }
    signInError.value = null;
    try {
      isSigningInGuest.value = true;
      await _auth.signInAnonymously();
    } catch (error) {
      signInError.value = error.toString();
    } finally {
      isSigningInGuest.value = false;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  bool isCharacterCompleted(HanziCharacter character) {
    final data = profile.value?.progress[character.id];
    if (data is Map<String, dynamic>) {
      final completed = data['completed'];
      if (completed is bool) {
        return completed;
      }
    }
    return false;
  }

  Future<void> _fallbackToAnonymousIfNeeded(PlatformException error) async {
    final message = error.message ?? '';
    final code = error.code;
    final isDeveloperError =
        code == GoogleSignIn.kSignInFailedError && message.contains('DEVELOPER_ERROR');
    if (!isDeveloperError) {
      return;
    }
    if (_auth.currentUser != null) {
      return;
    }
    try {
      await _auth.signInAnonymously();
      signInError.value =
          'Không thể đăng nhập Google trên thiết bị này. Đã chuyển sang chế độ khách, bạn vẫn có thể lưu tiến trình.';
    } catch (_) {}
  }

  String _mapSignInError(PlatformException error) {
    if ((error.code == GoogleSignIn.kSignInCanceledError)) {
      return 'Bạn đã huỷ đăng nhập.';
    }
    final message = error.message ?? '';
    if (message.contains('DEVELOPER_ERROR') || message.contains('SERVICE_INVALID')) {
      return 'Google Play Services không khả dụng trên thiết bị này. Hãy thử đăng nhập lại hoặc dùng chế độ khách.';
    }
    return error.message ?? 'Không thể đăng nhập bằng Google.';
  }

  double lessonProgress(Lesson lesson) {
    if (lesson.characters.isEmpty) {
      return 0;
    }
    final completed = lesson.characters
        .where((character) => isCharacterCompleted(character))
        .length;
    return completed / lesson.characters.length;
  }

  String lessonProgressLabel(Lesson lesson) {
    final completedCount = lesson.characters
        .where((character) => isCharacterCompleted(character))
        .length;
    return '$completedCount/${lesson.characters.length}';
  }

  void _handleAuthChange(User? user) {
    firebaseUser.value = user;
    _profileSub?.cancel();
    if (user == null) {
      profile.value = null;
      _recomputeProgress();
      return;
    }
    _listenToProfile(user.uid);
  }

  void _listenToProfile(String uid) {
    isLoadingProfile.value = true;
    _profileSub = _firestore.collection('users').doc(uid).snapshots().listen(
      (snapshot) {
        final data = snapshot.data();
        if (data == null) {
          profile.value = UserProfile(
            id: uid,
            email: '',
            displayName: 'Learner',
            photoURL: null,
            xp: 0,
            streak: 0,
            progress: const <String, dynamic>{},
          );
        } else {
          profile.value = UserProfile.fromMap(data, uid);
        }
        isLoadingProfile.value = false;
        _recomputeProgress();
      },
      onError: (_) {
        isLoadingProfile.value = false;
      },
    );
  }

  void _recomputeProgress() {
    final allLessons = lessons.toList(growable: false);
    final progressData = profile.value?.progress ?? const <String, dynamic>{};

    var total = 0;
    var completed = 0;
    HanziCharacter? next;

    for (final lesson in allLessons) {
      for (final character in lesson.characters) {
        total += 1;
        final entry = progressData[character.id];
        final isComplete = entry is Map<String, dynamic> && entry['completed'] == true;
        if (isComplete) {
          completed += 1;
        } else if (next == null) {
          next = character;
        }
      }
    }

    totalCharacters.value = total;
    completedCharacters.value = completed;
    overallProgress.value = total == 0 ? 0 : completed / total;

    if (next != null) {
      nextCharacter.value = next;
    } else if (allLessons.isNotEmpty && allLessons.first.characters.isNotEmpty) {
      nextCharacter.value = allLessons.first.characters.first;
    } else {
      nextCharacter.value = null;
    }
  }
}
