import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/app/modules/home/home_controller.dart';
import 'package:myapp/app/routes/app_pages.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HSK Helper'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn một chương',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Obx(() {
              if (controller.isLoadingChapters.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = controller.chapters[index];
                    return Obx(() {
                      final isSelected = controller.selectedChapter.value?.id == chapter.id;
                      return GestureDetector(
                        onTap: () => controller.selectChapter(chapter),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.deepPurple : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              chapter.title,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    });
                  },
                ),
              );
            }),
            const SizedBox(height: 20),
            const Text(
              'Các bài học có sẵn',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Obx(() {
                if (controller.isLoadingLessons.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.lessons.isEmpty) {
                  return const Center(child: Text('Không có bài học nào cho chương này.'));
                }
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1, // Adjusted for better fit
                  ),
                  itemCount: controller.lessons.length,
                  itemBuilder: (context, index) {
                    final lesson = controller.lessons[index];
                    return GestureDetector(
                      onTap: () => Get.toNamed(Routes.characterList, arguments: lesson.characters),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.book_outlined, size: 30, color: Colors.deepPurple),
                              const SizedBox(height: 8),
                              Text(
                                lesson.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
