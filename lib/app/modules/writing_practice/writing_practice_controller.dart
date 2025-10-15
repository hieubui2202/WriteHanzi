
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:myapp/app/data/models/hanzi_character.dart';

class WritingPracticeController extends GetxController {
  // The character to practice, received from the previous screen.
  late final HanziCharacter character;

  // Rx variables for reactive state management.
  final RxList<List<Offset>> lines = <List<Offset>>[].obs;
  final Rx<Color> selectedColor = const Color(0xFF444444).obs;
  final RxDouble strokeWidth = 5.0.obs;

  late final List<Path> referencePaths;
  late final Rect referenceBounds;

  @override
  void onInit() {
    super.onInit();
    // Safely retrieve the character passed as an argument.
    if (Get.arguments is HanziCharacter) {
      character = Get.arguments as HanziCharacter;
      _prepareReferencePaths();
    } else {
      referencePaths = const [];
      referenceBounds = const Rect.fromLTWH(0, 0, 1, 1);
      // If no character is passed, navigate back or show an error.
      // This is a defensive measure.
      Get.back();
      Get.snackbar('Lỗi', 'Không có ký tự nào được chọn để luyện tập.');
    }
  }

  void _prepareReferencePaths() {
    final paths = <Path>[];
    for (final raw in character.svgList) {
      final data = raw.trim();
      if (data.isEmpty) continue;
      try {
        paths.add(parseSvgPathData(data));
      } catch (e) {
        debugPrint('Không thể phân tích SVG cho ${character.id}: $e');
      }
    }

    referencePaths = paths;
    referenceBounds = _calculateBounds(paths);
  }

  Rect _calculateBounds(List<Path> paths) {
    if (paths.isEmpty) {
      return const Rect.fromLTWH(0, 0, 1, 1);
    }
    Rect bounds = paths.first.getBounds();
    for (final path in paths.skip(1)) {
      bounds = bounds.expandToInclude(path.getBounds());
    }
    final width = bounds.width == 0 ? 1.0 : bounds.width;
    final height = bounds.height == 0 ? 1.0 : bounds.height;
    return Rect.fromLTWH(bounds.left, bounds.top, width, height);
  }

  // Methods to interact with the drawing canvas.
  void startNewLine(Offset point) {
    lines.add([point]);
  }

  void addPointToLine(Offset point) {
    if (lines.isEmpty) {
      lines.add([point]);
      return;
    }
    final updated = List<Offset>.from(lines.last)..add(point);
    lines[lines.length - 1] = updated;
  }

  void clearCanvas() {
    lines.clear();
  }

  void undoLastStroke() {
    if (lines.isEmpty) {
      return;
    }
    lines.removeLast();
  }

  // Methods to change drawing properties.
  void changeColor(Color newColor) {
    selectedColor.value = newColor;
  }

  void changeStrokeWidth(double newWidth) {
    strokeWidth.value = newWidth;
  }

   // In a real app, this would involve more complex logic, maybe AI-based.
  void checkDrawing() {
    // For now, this is just a placeholder.
    Get.snackbar(
      'Kiểm tra hoàn tất',
      'Làm tốt lắm! Hãy tiếp tục luyện tập.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
