import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:myapp/app/data/models/hanzi_character.dart';
import 'package:myapp/app/routes/app_pages.dart';

import '../writing_practice/practice_session_controller.dart';
import 'widgets/radical_board.dart';

class BuildHanziController extends GetxController {
  late final HanziCharacter character;
  late final PracticeSessionController session;

  final RxBool canContinue = false.obs;

  late final List<CharacterPart> slots;
  late final List<CharacterPart> choices;
  late final String layout;

  @override
  void onInit() {
    super.onInit();
    session = Get.find<PracticeSessionController>();

    final args = Get.arguments;
    if (args is Map && args['character'] is HanziCharacter) {
      character = args['character'] as HanziCharacter;
      session.initialize(character);
      _prepareParts();
    } else {
      Get.back();
      Get.snackbar('Lỗi', 'Thiếu dữ liệu ký tự cho trò chơi ghép chữ.');
    }
  }

  void _prepareParts() {
    if (character.parts.isNotEmpty) {
      slots = character.parts;
      layout = character.layout ?? _layoutForCount(character.parts.length);
    } else {
      _buildFallbackParts();
    }

    choices = _buildChoices(slots);
  }

  void _buildFallbackParts() {
    final strokes = character.svgList;
    if (strokes.isEmpty) {
      slots = [
        CharacterPart(id: '${character.id}_core', label: 'Toàn bộ chữ'),
      ];
      layout = character.layout ?? 'stack-3';
      return;
    }

    final total = strokes.length;
    final desiredGroups = total >= 8
        ? 4
        : total >= 5
            ? 3
            : 2;
    final groupCount = desiredGroups.clamp(1, total);
    final chunkSize = (total / groupCount).ceil();
    final groups = <CharacterPart>[];
    for (var i = 0; i < groupCount; i++) {
      final start = i * chunkSize;
      if (start >= total) break;
      final end = min(total, start + chunkSize);
      final subset = strokes.sublist(start, end);
      groups.add(
        CharacterPart(
          id: '${character.id}_grp_$i',
          label: 'Nhóm nét ${i + 1}',
          svgList: subset,
        ),
      );
    }
    slots = groups;
    layout = character.layout ?? _layoutForCount(groups.length);
  }

  List<CharacterPart> _buildChoices(List<CharacterPart> base) {
    final random = Random(character.id.hashCode);
    final result = List<CharacterPart>.from(base);
    final target = base.length >= 3
        ? (base.length + 2).clamp(4, 6).toInt()
        : 4;
    var index = 0;
    while (result.length < target) {
      final ref = base.isEmpty ? null : base[random.nextInt(base.length)];
      result.add(
        CharacterPart(
          id: '${character.id}_decoy_$index',
          label: 'Nhiễu ${index + 1}',
          svgList: ref?.svgList,
          imgUrl: ref?.imgUrl,
        ),
      );
      index++;
    }
    result.shuffle(random);
    return result;
  }

  String _layoutForCount(int count) {
    if (count <= 1) return 'stack-3';
    if (count == 2) return 'left-right';
    if (count == 3) return 'stack-3';
    return 'enclose';
  }

  void onBoardStateChanged(bool isComplete) {
    canContinue.value = isComplete;
  }

  void onBoardMistake() {
    session.recordMistake();
  }

  void continueFlow() {
    if (!canContinue.value) {
      return;
    }
    session.markStepCompleted('build');
    Get.toNamed(Routes.practiceResult);
  }
}
