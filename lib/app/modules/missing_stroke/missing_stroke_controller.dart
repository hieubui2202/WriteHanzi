import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:path_drawing/path_drawing.dart';

import 'package:myapp/app/data/models/hanzi_character.dart';
import 'package:myapp/app/routes/app_pages.dart';

import '../writing_practice/practice_session_controller.dart';
import '../writing_practice/widgets/hanzi_canvas.dart';

class MissingStrokeController extends GetxController {
  late final HanziCharacter character;
  late final PracticeSessionController session;

  final RxInt matchedCount = 0.obs;
  final RxBool canContinue = false.obs;

  late final List<Path> referencePaths;
  late final Rect referenceBounds;
  late final List<Path> expectedPaths;
  late final int preRenderedCount;

  final GlobalKey<HanziCanvasState> canvasKey = GlobalKey<HanziCanvasState>();

  @override
  void onInit() {
    super.onInit();
    session = Get.find<PracticeSessionController>();

    final args = Get.arguments;
    if (args is Map && args['character'] is HanziCharacter) {
      character = args['character'] as HanziCharacter;
      session.initialize(character);
      final missing = args['missingCount'] is int
          ? (args['missingCount'] as int)
          : character.missingCount;
      _prepareReferencePaths(missing);
    } else {
      Get.back();
      Get.snackbar('Lỗi', 'Thiếu dữ liệu ký tự cho bài tập hoàn thiện nét.');
    }
  }

  void _prepareReferencePaths(int missingCount) {
    final parsed = <Path>[];
    for (final raw in character.svgList) {
      final data = raw.trim();
      if (data.isEmpty) continue;
      try {
        parsed.add(parseSvgPathData(data));
      } catch (e) {
        debugPrint('Không thể phân tích SVG cho ${character.id}: $e');
      }
    }
    referencePaths = parsed;
    referenceBounds = _calculateBounds(parsed);

    final total = parsed.length;
    final missing = missingCount.clamp(1, max(1, total)).toInt();
    preRenderedCount = max(0, total - missing).toInt();
    expectedPaths = total == 0
        ? const []
        : parsed.sublist(preRenderedCount, parsed.length);
    if (expectedPaths.isEmpty) {
      canContinue.value = true;
    }
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

  void onStrokeMatched(int count) {
    matchedCount.value = count;
    if (count >= expectedPaths.length) {
      canContinue.value = true;
    }
  }

  void onStrokeRejected() {
    session.recordMistake();
  }

  void showHint() {
    canvasKey.currentState?.replayHint();
  }

  void clearCanvas() {
    matchedCount.value = 0;
    canContinue.value = false;
    canvasKey.currentState?.clearUserStrokes();
  }

  void continueFlow() {
    if (!canContinue.value) {
      return;
    }
    session.markStepCompleted('missing');
    Get.toNamed(
      Routes.buildHanzi,
      arguments: {
        'character': character,
      },
    );
  }
}
