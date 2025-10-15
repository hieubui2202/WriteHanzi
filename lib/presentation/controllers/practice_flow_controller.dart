import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import 'package:myapp/app/data/models/hanzi_character.dart';
import 'package:myapp/app/data/services/practice_progress_service.dart';
import 'package:myapp/core/audio_service.dart';

enum PracticeStep {
  selectPronunciation,
  selectMeaning,
  traceFull,
  finishPartialA,
  traceSegment,
  finishPartialB,
  writeFromScratch1,
  writeFromScratch2,
  buildFromParts1,
  buildFromParts2,
  result,
}

class BuildPartGame {
  const BuildPartGame({
    required this.layout,
    required this.slots,
    required this.choices,
  });

  final String layout;
  final List<CharacterPart> slots;
  final List<CharacterPart> choices;
}

class PracticeFlowController extends GetxController {
  PracticeFlowController({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    PracticeProgressService? progressService,
    AudioService? audioService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _progressService =
            progressService ?? PracticeProgressService(firestore: firestore, auth: auth),
        _audioService = audioService ?? AudioService();

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final PracticeProgressService _progressService;
  final AudioService _audioService;

  final RxBool isLoading = true.obs;
  final Rxn<HanziCharacter> character = Rxn<HanziCharacter>();
  final RxList<PracticeStep> steps = <PracticeStep>[].obs;
  final RxInt currentIndex = 0.obs;
  final RxInt mistakes = 0.obs;
  final Map<PracticeStep, bool> stepResults = {};

  final Stopwatch _stopwatch = Stopwatch();
  List<BuildPartGame> _partGames = const [];
  List<String> _pronunciationChoices = const [];
  List<String> _meaningChoices = const [];

  PracticeStep get currentStep => steps[currentIndex.value];

  double get progress => steps.isEmpty
      ? 0
      : (currentIndex.value / math.max(steps.length - 1, 1)).clamp(0, 1).toDouble();

  List<String> get pronunciationChoices => _pronunciationChoices;
  List<String> get meaningChoices => _meaningChoices;
  List<BuildPartGame> get partGames => _partGames;
  int get xpEarned => mistakes.value == 0
      ? 10
      : mistakes.value == 1
          ? 5
          : 2;
  int get totalInteractiveSteps =>
      steps.where((step) => step != PracticeStep.result).length;
  int get passedInteractiveSteps => stepResults.entries
      .where((entry) => entry.key != PracticeStep.result && entry.value)
      .length;
  int get score => totalInteractiveSteps == 0
      ? 0
      : ((passedInteractiveSteps / totalInteractiveSteps) * 100).round();

  Future<void> load(String charId) async {
    isLoading.value = true;
    stepResults.clear();
    mistakes.value = 0;
    currentIndex.value = 0;
    final doc = await _firestore.collection('characters').doc(charId).get();
    if (!doc.exists) {
      isLoading.value = false;
      return;
    }
    character.value = HanziCharacter.fromFirestore(doc);
    _buildSteps();
    _buildChoices();
    _stopwatch
      ..reset()
      ..start();
    isLoading.value = false;
  }

  Future<void> playAudio() async {
    final url = character.value?.ttsUrl ?? '';
    if (url.isEmpty) {
      return;
    }
    await _audioService.playUrl(url);
  }

  void markStepCompleted(PracticeStep step, {bool passed = true}) {
    final previous = stepResults[step];
    if (!passed) {
      if (previous != false) {
        mistakes.value++;
      }
      stepResults[step] = false;
    } else {
      stepResults[step] = true;
    }
  }

  void goToNext() {
    if (currentIndex.value < steps.length - 1) {
      currentIndex.value++;
    }
  }

  void goToPrevious() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
    }
  }

  BuildPartGame gameForIndex(int index) {
    if (_partGames.isEmpty) {
      return const BuildPartGame(layout: 'left-right', slots: [], choices: []);
    }
    return _partGames[index.clamp(0, _partGames.length - 1)];
  }

  Map<String, bool> get completionFlags {
    final available = steps.toSet();
    final traceSteps = <PracticeStep>{
      PracticeStep.traceFull,
      PracticeStep.traceSegment,
      PracticeStep.finishPartialA,
      PracticeStep.finishPartialB,
      PracticeStep.writeFromScratch1,
      PracticeStep.writeFromScratch2,
    };
    final missingSteps = <PracticeStep>{
      PracticeStep.finishPartialA,
      PracticeStep.finishPartialB,
    };
    final buildSteps = <PracticeStep>{
      PracticeStep.buildFromParts1,
      PracticeStep.buildFromParts2,
    };
    bool _allPassed(Set<PracticeStep> target) {
      final relevant = target.where((step) => available.contains(step)).toList();
      if (relevant.isEmpty) {
        return true;
      }
      return relevant.every((step) => stepResults[step] ?? false);
    }

    return {
      'trace': _allPassed(traceSteps),
      'missing': _allPassed(missingSteps),
      'build': _allPassed(buildSteps),
    };
  }

  Future<void> persistResult() async {
    _stopwatch.stop();
    final char = character.value;
    if (char == null) {
      return;
    }
    await _progressService.submitProgress(
      character: char,
      xp: xpEarned,
      score: score,
      mistakes: mistakes.value,
      completedSteps: completionFlags,
      duration: _stopwatch.elapsed,
    );
  }

  void _buildSteps() {
    final strokes = character.value?.svgList.length ?? 0;
    steps.assignAll([
      PracticeStep.selectPronunciation,
      PracticeStep.selectMeaning,
      PracticeStep.traceFull,
      PracticeStep.finishPartialA,
      PracticeStep.traceSegment,
      PracticeStep.finishPartialB,
      PracticeStep.writeFromScratch1,
      PracticeStep.writeFromScratch2,
      PracticeStep.buildFromParts1,
      PracticeStep.buildFromParts2,
      PracticeStep.result,
    ]);
    if (strokes <= 2) {
      steps.remove(PracticeStep.writeFromScratch2);
      steps.remove(PracticeStep.finishPartialB);
    }
    if (strokes <= 1) {
      steps.remove(PracticeStep.traceSegment);
    }
  }

  void _buildChoices() {
    final char = character.value;
    if (char == null) {
      _pronunciationChoices = const [];
      _meaningChoices = const [];
      return;
    }
    final random = math.Random(char.id.hashCode);
    _pronunciationChoices = _generatePronunciationChoices(char.pinyin, random);
    _meaningChoices = _generateMeaningChoices(char.meaning, random);
    _partGames = _preparePartGames(char, random);
  }

  List<String> _generatePronunciationChoices(String correct, math.Random random) {
    if (correct.isEmpty) {
      return const ['ma', 'sha', 'la'];
    }
    final set = <String>{correct};
    while (set.length < 3) {
      set.add(_mutatePinyin(correct, random));
    }
    final options = set.toList();
    options.shuffle(random);
    return options;
  }

  List<String> _generateMeaningChoices(String correct, math.Random random) {
    const pool = [
      'tea',
      'lantern',
      'river',
      'mountain',
      'window',
      'snow',
      'forest',
      'moonlight',
      'firework',
      'bamboo',
      'lantern',
      'horizon',
    ];
    final set = <String>{correct};
    while (set.length < 3) {
      final candidate = pool[random.nextInt(pool.length)];
      set.add(candidate);
    }
    final options = set.toList();
    options.shuffle(random);
    return options;
  }

  List<BuildPartGame> _preparePartGames(HanziCharacter char, math.Random random) {
    final parts = char.parts.isNotEmpty ? char.parts : _fallbackParts(char.svgList);
    if (parts.isEmpty) {
      return const [];
    }
    final games = <BuildPartGame>[];
    final slots = parts.take(4).toList();
    final layout = char.layout ?? (slots.length <= 2 ? 'left-right' : 'top-bottom');
    games.add(
      BuildPartGame(
        layout: layout,
        slots: slots,
        choices: _withNoise(slots, random),
      ),
    );

    final shuffled = List<CharacterPart>.from(parts)..shuffle(random);
    games.add(
      BuildPartGame(
        layout: layout,
        slots: shuffled.take(math.min(3, shuffled.length)).toList(),
        choices: _withNoise(shuffled, random),
      ),
    );
    return games;
  }

  List<CharacterPart> _fallbackParts(List<String> svgList) {
    if (svgList.isEmpty) {
      return const [];
    }
    final chunk = math.max(1, (svgList.length / 3).floor());
    final parts = <CharacterPart>[];
    for (int i = 0; i < svgList.length; i += chunk) {
      final id = 'part_${i ~/ chunk}';
      final label = ['Bộ nét', 'Thành phần', 'Góc chữ', 'Nét nhấn'][parts.length % 4];
      parts.add(CharacterPart(id: id, label: label, svgList: svgList.sublist(i, math.min(i + chunk, svgList.length))));
    }
    return parts;
  }

  List<CharacterPart> _withNoise(List<CharacterPart> parts, math.Random random) {
    final choices = List<CharacterPart>.from(parts);
    const decoys = [
      CharacterPart(id: 'noise_1', label: '木'),
      CharacterPart(id: 'noise_2', label: '艹'),
      CharacterPart(id: 'noise_3', label: '氵'),
      CharacterPart(id: 'noise_4', label: '心'),
    ];
    for (final decoy in decoys) {
      if (choices.length >= 6) break;
      choices.add(decoy);
    }
    choices.shuffle(random);
    return choices;
  }

  String _mutatePinyin(String value, math.Random random) {
    final syllables = value.split(' ');
    final buffer = <String>[];
    for (final syllable in syllables) {
      if (syllable.isEmpty) {
        continue;
      }
      final initial = _initialOf(syllable);
      final finals = syllable.substring(initial.length);
      final alternatives = ['b', 'p', 'm', 'f', 'd', 't', 'n', 'l', 'g', 'k', 'h', 'j', 'q', 'x', 'zh', 'ch', 'sh', 'r', 'z', 'c', 's'];
      String candidate = initial;
      while (candidate == initial) {
        candidate = alternatives[random.nextInt(alternatives.length)];
      }
      buffer.add('$candidate$finals');
    }
    return buffer.join(' ');
  }

  String _initialOf(String syllable) {
    const digraphs = ['zh', 'ch', 'sh'];
    for (final digraph in digraphs) {
      if (syllable.startsWith(digraph)) {
        return digraph;
      }
    }
    if (syllable.length >= 2 && syllable[1] == 'h') {
      return syllable.substring(0, 2);
    }
    return syllable.substring(0, 1);
  }

  @override
  void onClose() {
    _audioService.dispose();
    super.onClose();
  }
}
