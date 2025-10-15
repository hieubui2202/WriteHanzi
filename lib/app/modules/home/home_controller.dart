import 'package:get/get.dart';
import 'package:myapp/app/data/models/chapter_model.dart';
import 'package:myapp/app/data/models/lesson_model.dart';
import 'package:myapp/app/data/repositories/home_repository.dart';

class HomeController extends GetxController {
  final HomeRepository _repository = Get.find<HomeRepository>();

  // Observables for state management
  final chapters = <Chapter>[].obs;
  final lessons = <Lesson>[].obs;
  final isLoadingChapters = true.obs;
  final isLoadingLessons = false.obs;
  final selectedChapter = Rx<Chapter?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchChapters();
  }

  // Fetch chapters from the repository
  void fetchChapters() async {
    try {
      isLoadingChapters.value = true;
      final chapterList = await _repository.getChapters();
      chapters.assignAll(chapterList);
      // Automatically select the first chapter and fetch its lessons
      if (chapters.isNotEmpty) {
        selectChapter(chapters.first);
      }
    } finally {
      isLoadingChapters.value = false;
    }
  }

  // Fetch lessons for a given chapter
  void fetchLessonsForChapter(String chapterId) async {
    try {
      isLoadingLessons.value = true;
      final lessonList = await _repository.getLessonsForChapter(chapterId);
      lessons.assignAll(lessonList);
    } finally {
      isLoadingLessons.value = false;
    }
  }

  // Handle chapter selection
  void selectChapter(Chapter chapter) {
    selectedChapter.value = chapter;
    fetchLessonsForChapter(chapter.id);
  }
}
