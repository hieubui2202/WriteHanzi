import 'package:characters/characters.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:myapp/app/data/models/chapter_model.dart';
import 'package:myapp/app/data/models/hanzi_character.dart';
import 'package:myapp/app/data/models/lesson_model.dart';
import 'package:myapp/app/modules/home/home_controller.dart';
import 'package:myapp/app/routes/app_pages.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  Color get _backgroundTop => const Color(0xFF101522);
  Color get _backgroundBottom => const Color(0xFF0B0E16);
  Color get _primary => const Color(0xFF18E06F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_backgroundTop, _backgroundBottom],
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            final user = controller.firebaseUser.value;
            if (user == null) {
              return _buildSignIn(context);
            }
            return _buildDashboard(context);
          }),
        ),
      ),
    );
  }

  Widget _buildSignIn(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.draw_outlined, size: 72, color: Colors.white70),
                const SizedBox(height: 18),
                const Text(
                  'Sign in to track your progress',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Đăng nhập bằng Google để lưu XP, streak và những ký tự bạn đã luyện.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.72), height: 1.4),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: controller.isSigningIn.value
                        ? null
                        : () => controller.signInWithGoogle(),
                    icon: const Icon(Icons.login, color: Colors.black),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        controller.isSigningIn.value ? 'Đang đăng nhập...' : 'Đăng nhập với Google',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Hoặc',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: controller.isSigningInGuest.value
                        ? null
                        : () => controller.signInAnonymously(),
                    icon: Icon(
                      Icons.person_outline,
                      color: Colors.white.withOpacity(0.85),
                    ),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        controller.isSigningInGuest.value
                            ? 'Đang tạo tài khoản khách...'
                            : 'Tiếp tục không cần Google',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.28)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                if (controller.signInError.value != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    controller.signInError.value!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                  ),
                ],
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoadingChapters.value || controller.isLoadingProfile.value;
      return RefreshIndicator(
        color: _primary,
        onRefresh: controller.refreshCurrent,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserHeader(),
                    const SizedBox(height: 24),
                    _buildProgressCard(),
                    const SizedBox(height: 32),
                    _buildChapterSelector(),
                  ],
                ),
              ),
            ),
            if (isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white70),
                ),
              )
            else if (controller.lessons.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'Chưa có bài học trong chương này.',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                sliver: _buildLessonsList(),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildUserHeader() {
    return Obx(() {
      final profile = controller.profile.value;
      final name = profile?.displayName?.isNotEmpty == true ? profile!.displayName! : 'Learner';
      final xp = profile?.xp ?? 0;
      final streak = profile?.streak ?? 0;

      return Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withOpacity(0.12),
            backgroundImage: profile?.photoURL != null && profile!.photoURL!.isNotEmpty
                ? NetworkImage(profile.photoURL!)
                : null,
            child: profile?.photoURL != null && profile!.photoURL!.isNotEmpty
                ? null
                : Text(
                    name.characters.first.toUpperCase(),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào, $name',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _statChip(icon: Icons.bolt, label: '$xp XP'),
                    const SizedBox(width: 10),
                    _statChip(icon: Icons.local_fire_department, label: '${streak}d streak'),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: controller.signOut,
            icon: Icon(Icons.logout, color: Colors.white.withOpacity(0.72)),
            tooltip: 'Đăng xuất',
          )
        ],
      );
    });
  }

  Widget _statChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: _primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Obx(() {
      final nextCharacter = controller.nextCharacter.value;
      final progress = controller.overallProgress.value.clamp(0.0, 1.0);
      final completed = controller.completedCharacters.value;
      final total = controller.totalCharacters.value;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tiến độ học tập',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.08),
              color: _primary,
              borderRadius: BorderRadius.circular(12),
            ),
            const SizedBox(height: 12),
            Text(
              total == 0 ? 'Hãy chọn một bài học để bắt đầu.' : 'Đã hoàn thành $completed/$total ký tự.',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: nextCharacter == null
                    ? null
                    : () {
                        Get.toNamed(Routes.writingPractice, arguments: nextCharacter.id);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  nextCharacter == null ? 'Chọn bài học để luyện' : 'Tiếp tục với "${nextCharacter.word.isNotEmpty ? nextCharacter.word : nextCharacter.character}"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildChapterSelector() {
    return Obx(() {
      if (controller.isLoadingChapters.value && controller.chapters.isEmpty) {
        return const SizedBox.shrink();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chương',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 46,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controller.chapters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final chapter = controller.chapters[index];
                final isSelected = controller.selectedChapter.value?.id == chapter.id;
                return GestureDetector(
                  onTap: () => controller.selectChapter(chapter),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: isSelected ? _primary : Colors.white.withOpacity(0.06),
                    ),
                    child: Center(
                      child: Text(
                        chapter.title,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  SliverList _buildLessonsList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final lesson = controller.lessons[index];
          return _LessonCard(
            lesson: lesson,
            progress: controller.lessonProgress(lesson),
            progressLabel: controller.lessonProgressLabel(lesson),
            isCharacterCompleted: controller.isCharacterCompleted,
            onOpen: () => Get.toNamed(Routes.characterList, arguments: lesson.characters),
            primary: _primary,
            isLast: index == controller.lessons.length - 1,
          );
        },
        childCount: controller.lessons.length,
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.lesson,
    required this.progress,
    required this.progressLabel,
    required this.isCharacterCompleted,
    required this.onOpen,
    required this.primary,
    required this.isLast,
  });

  final Lesson lesson;
  final double progress;
  final String progressLabel;
  final bool Function(HanziCharacter) isCharacterCompleted;
  final VoidCallback onOpen;
  final Color primary;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
      child: Material(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.menu_book_rounded, color: primary, size: 26),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        lesson.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white54),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0, 1),
                    minHeight: 8,
                    backgroundColor: Colors.white.withOpacity(0.08),
                    color: primary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tiến độ bài học: $progressLabel ký tự',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: lesson.characters
                      .map(
                        (character) {
                          final completed = isCharacterCompleted(character);
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: completed
                                  ? primary.withOpacity(0.16)
                                  : Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: completed ? primary : Colors.white.withOpacity(0.05),
                                width: completed ? 1.2 : 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  character.character,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontFamily: 'NotoSansSC',
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  character.pinyin,
                                  style: TextStyle(
                                    color: completed ? Colors.black.withOpacity(0.7) : Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                                if (completed) ...[
                                  const SizedBox(width: 6),
                                  Icon(Icons.check_circle, size: 16, color: Colors.black.withOpacity(0.7)),
                                ],
                              ],
                            ),
                          );
                        },
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
