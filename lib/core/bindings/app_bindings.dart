import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../data/cache/progress_cache.dart';
import '../../data/repositories/character_repository_impl.dart';
import '../../data/repositories/progress_repository_impl.dart';
import '../../data/repositories/unit_repository_impl.dart';
import '../../domain/repositories/character_repository.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/repositories/unit_repository.dart';
import '../../presentation/controllers/auth_controller.dart';
import '../../presentation/controllers/practice_controller.dart';
import '../../presentation/controllers/progress_controller.dart';
import '../../presentation/controllers/review_controller.dart';
import '../../presentation/controllers/writing_session_controller.dart';
import '../services/audio_service.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AudioService(), permanent: true);

    Get.lazyPut<FirebaseAuth>(() => FirebaseAuth.instance, fenix: true);
    Get.lazyPut<FirebaseFirestore>(() => FirebaseFirestore.instance, fenix: true);

    Get.lazyPut<UnitRepository>(() => UnitRepositoryImpl(
          firestore: Get.find<FirebaseFirestore>(),
          cache: Get.find<ProgressCache>(),
        ));
    Get.lazyPut<CharacterRepository>(() => CharacterRepositoryImpl(
          firestore: Get.find<FirebaseFirestore>(),
          cache: Get.find<ProgressCache>(),
        ));
    Get.lazyPut<ProgressRepository>(() => ProgressRepositoryImpl(
          firestore: Get.find<FirebaseFirestore>(),
          cache: Get.find<ProgressCache>(),
        ));

    Get.put<AuthController>(AuthController(Get.find<FirebaseAuth>()));
    Get.put<ProgressController>(ProgressController(
      unitRepository: Get.find<UnitRepository>(),
      characterRepository: Get.find<CharacterRepository>(),
      progressRepository: Get.find<ProgressRepository>(),
      authController: Get.find<AuthController>(),
    ), permanent: true);
    Get.put<PracticeController>(PracticeController(
      audioService: Get.find<AudioService>(),
      progressController: Get.find<ProgressController>(),
    ));
    Get.put<ReviewController>(ReviewController(
      progressController: Get.find<ProgressController>(),
    ));
    Get.put<WritingSessionController>(WritingSessionController());
  }
}
