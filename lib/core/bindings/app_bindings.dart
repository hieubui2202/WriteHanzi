import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../data/cache/progress_cache.dart';
import '../../data/repositories/character_repository_impl.dart';
import '../../data/repositories/progress_repository_impl.dart';
import '../../data/repositories/unit_repository_impl.dart';
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

    Get.lazyPut(() => FirebaseAuth.instance, fenix: true);
    Get.lazyPut(() => FirebaseFirestore.instance, fenix: true);

    Get.lazyPut(() => UnitRepositoryImpl(
          firestore: Get.find(),
          cache: Get.find<ProgressCache>(),
        ));
    Get.lazyPut(() => CharacterRepositoryImpl(
          firestore: Get.find(),
          cache: Get.find<ProgressCache>(),
        ));
    Get.lazyPut(() => ProgressRepositoryImpl(
          firestore: Get.find(),
          cache: Get.find<ProgressCache>(),
        ));

    Get.put(AuthController(Get.find()));
    Get.put(ProgressController(
      unitRepository: Get.find(),
      characterRepository: Get.find(),
      progressRepository: Get.find(),
      authController: Get.find(),
    ), permanent: true);
    Get.put(PracticeController(
      audioService: Get.find(),
      progressController: Get.find(),
    ));
    Get.put(ReviewController(progressController: Get.find()));
    Get.put(WritingSessionController());
  }
}
