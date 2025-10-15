
import 'dart:ui';
import 'package:get/get.dart';
import 'package:myapp/app/data/models/hanzi_character.dart';

class WritingPracticeController extends GetxController {
  // The character to practice, received from the previous screen.
  late final HanziCharacter character;

  // Rx variables for reactive state management.
  final RxList<List<Offset>> lines = <List<Offset>>[[]].obs;
  final Rx<Color> selectedColor = const Color(0xFF444444).obs;
  final RxDouble strokeWidth = 5.0.obs;

  @override
  void onInit() {
    super.onInit();
    // Safely retrieve the character passed as an argument.
    if (Get.arguments is HanziCharacter) {
      character = Get.arguments;
    } else {
      // If no character is passed, navigate back or show an error.
      // This is a defensive measure.
      Get.back();
      Get.snackbar('Lỗi', 'Không có ký tự nào được chọn để luyện tập.');
    }
  }

  // Methods to interact with the drawing canvas.
  void startNewLine(Offset point) {
    lines.add([point]);
  }

  void addPointToLine(Offset point) {
    // We need to create a new list for the reactive update to trigger.
    List<Offset> lastLine = List.from(lines.last);
    lastLine.add(point);
    lines[lines.length - 1] = lastLine;
  }

  void clearCanvas() {
    lines.assignAll([[]]);
  }

  void undoLastStroke() {
    if (lines.length > 1) {
      lines.removeLast();
    } else if (lines.length == 1 && lines.first.isNotEmpty) {
      // If there is only one line, clear it.
      lines.assignAll([[]]);
    }
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
