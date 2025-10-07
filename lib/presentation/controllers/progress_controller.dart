import 'dart:math';

import 'package:get/get.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/character.dart';
import '../../domain/entities/character_progress.dart';
import '../../domain/entities/unit_model.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/character_repository.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/repositories/unit_repository.dart';
import 'auth_controller.dart';

class ProgressController extends GetxController {
  ProgressController({
    required this.unitRepository,
    required this.characterRepository,
    required this.progressRepository,
    required this.authController,
  });

  final UnitRepository unitRepository;
  final CharacterRepository characterRepository;
  final ProgressRepository progressRepository;
  final AuthController authController;

  final RxList<UnitModel> units = <UnitModel>[].obs;
  final RxList<Character> characters = <Character>[].obs;
  final Rx<UserProfile?> userProfile = Rx<UserProfile?>(null);
  final RxBool loading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    ever(authController.firebaseUser, (_) => bootstrap());
  }

  Future<void> bootstrap() async {
    final user = authController.firebaseUser.value;
    if (user == null) {
      return;
    }
    loading.value = true;
    errorMessage.value = '';
    try {
      final result = await Future.wait([
        unitRepository.fetchUnits(),
        characterRepository.fetchCharacters(),
        progressRepository.loadProfile(
          user.uid,
          guest: user.isAnonymous,
        ),
      ]);
      units.assignAll(result[0] as List<UnitModel>);
      characters.assignAll(result[1] as List<Character>);
      userProfile.value = result[2] as UserProfile;
    } catch (error) {
      errorMessage.value = error.toString();
    } finally {
      loading.value = false;
    }
  }

  List<Character> charactersForUnit(String unitId) {
    return characters.where((c) => c.unitId == unitId).toList();
  }

  Character pickNextCharacter(String unitId) {
    final unitChars = charactersForUnit(unitId);
    unitChars.shuffle();
    return unitChars.first;
  }

  CharacterProgress characterProgress(String unitId, String hanzi) {
    final profile = userProfile.value;
    final unitMap = profile?.progress[unitId];
    if (unitMap is Map<String, dynamic>) {
      final map = unitMap[hanzi];
      if (map is Map<String, dynamic>) {
        return CharacterProgress(
          completed: map['completed'] == true,
          score: (map['score'] as num?)?.toDouble() ?? 0,
          mistakes: (map['mistakes'] as num?)?.toInt() ?? 0,
          lastReview: map['lastReview'] != null
              ? DateTime.tryParse(map['lastReview'].toString())
              : null,
        );
      }
    }
    return const CharacterProgress(
      completed: false,
      score: 0,
      mistakes: 0,
      lastReview: null,
    );
  }

  Future<void> updateProgress({
    required UnitModel unit,
    required Character character,
    required double score,
    required bool completed,
    required int mistakes,
    required int xpEarned,
  }) async {
    final user = authController.firebaseUser.value;
    if (user == null) {
      throw AppException('Not authenticated');
    }

    final profile = userProfile.value ??
        UserProfile(
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
          avatarUrl: user.photoURL,
          xp: 0,
          streakDays: 0,
          lastActive: DateTime.now(),
          progress: {},
          guest: user.isAnonymous,
        );

    final newXp = profile.xp + xpEarned;
    final today = DateTime.now();
    final streak = _calculateStreak(profile.lastActive, today, profile.streakDays, completed);

    final unitProgress = Map<String, Map<String, dynamic>>.from(profile.progress);
    final unitMap = Map<String, dynamic>.from(unitProgress[unit.id] ?? {});
    unitMap[character.hanzi] = {
      'completed': completed,
      'score': score,
      'mistakes': mistakes,
      'lastReview': today.toIso8601String(),
    };
    unitProgress[unit.id] = unitMap;

    final updatedProfile = profile.copyWith(
      xp: newXp,
      streakDays: streak,
      lastActive: today,
      progress: unitProgress,
    );
    userProfile.value = updatedProfile;

    if (!user.isAnonymous) {
      await progressRepository.updateProgress(
        uid: user.uid,
        unitId: unit.id,
        hanzi: character.hanzi,
        payload: unitMap[character.hanzi] as Map<String, dynamic>,
      );
      await progressRepository.updateMeta(
        uid: user.uid,
        xp: newXp,
        streakDays: streak,
        lastActive: today,
      );
    }
  }

  int _calculateStreak(DateTime? lastActive, DateTime today, int currentStreak, bool completed) {
    if (!completed) return currentStreak;
    if (lastActive == null) return max(1, currentStreak);
    final difference = today.difference(DateTime(lastActive.year, lastActive.month, lastActive.day)).inDays;
    if (difference == 0) {
      return currentStreak;
    } else if (difference == 1) {
      return currentStreak + 1;
    } else {
      return 1;
    }
  }
}
