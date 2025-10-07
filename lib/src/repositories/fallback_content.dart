import 'package:myapp/src/models/hanzi_character.dart';
import 'package:myapp/src/models/unit.dart';

/// Static fallback content that can be shown when Firestore access is blocked,
/// for example when the user is browsing in guest/anonymous mode and security
/// rules forbid reads. This keeps the app usable offline or without database
/// permissions.
class FallbackContent {
  static final List<Unit> units = [
    Unit(
      id: 'intro-basics',
      title: 'Bài học khởi động',
      description: 'Làm quen với một vài chữ Hán căn bản.',
      order: 0,
      characters: const ['shui', 'ren', 'hao'],
      xpReward: 40,
    ),
    Unit(
      id: 'daily-life',
      title: 'Cuộc sống hằng ngày',
      description: 'Từ vựng dùng hằng ngày cho người mới bắt đầu.',
      order: 1,
      characters: const ['chi', 'he', 'kan'],
      xpReward: 60,
    ),
  ];

  static final List<HanziCharacter> characters = [
    HanziCharacter(
      id: 'shui',
      hanzi: '水',
      pinyin: 'shuǐ',
      meaning: 'nước',
      unitId: 'intro-basics',
      ttsUrl:
          'https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&q=水&tl=zh-CN',
      strokeData: StrokeData(
        width: 1024,
        height: 1024,
        paths: const [
          'M512 128 L512 896',
          'M256 512 L768 512',
        ],
      ),
    ),
    HanziCharacter(
      id: 'ren',
      hanzi: '人',
      pinyin: 'rén',
      meaning: 'người',
      unitId: 'intro-basics',
      ttsUrl:
          'https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&q=人&tl=zh-CN',
      strokeData: StrokeData(
        width: 1024,
        height: 1024,
        paths: const [
          'M448 192 L352 832',
          'M576 192 L672 832',
        ],
      ),
    ),
    HanziCharacter(
      id: 'hao',
      hanzi: '好',
      pinyin: 'hǎo',
      meaning: 'tốt',
      unitId: 'intro-basics',
      ttsUrl:
          'https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&q=好&tl=zh-CN',
      strokeData: StrokeData(
        width: 1024,
        height: 1024,
        paths: const [
          'M256 256 L448 832',
          'M448 256 L640 640',
          'M640 256 L768 832',
        ],
      ),
    ),
    HanziCharacter(
      id: 'chi',
      hanzi: '吃',
      pinyin: 'chī',
      meaning: 'ăn',
      unitId: 'daily-life',
      ttsUrl:
          'https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&q=吃&tl=zh-CN',
      strokeData: StrokeData(
        width: 1024,
        height: 1024,
        paths: const [
          'M256 192 L448 832',
          'M640 192 L704 832',
          'M512 384 L704 512',
        ],
      ),
    ),
    HanziCharacter(
      id: 'he',
      hanzi: '喝',
      pinyin: 'hē',
      meaning: 'uống',
      unitId: 'daily-life',
      ttsUrl:
          'https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&q=喝&tl=zh-CN',
      strokeData: StrokeData(
        width: 1024,
        height: 1024,
        paths: const [
          'M288 192 L480 832',
          'M640 256 L736 832',
          'M512 448 L736 512',
        ],
      ),
    ),
    HanziCharacter(
      id: 'kan',
      hanzi: '看',
      pinyin: 'kàn',
      meaning: 'nhìn/xem',
      unitId: 'daily-life',
      ttsUrl:
          'https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&q=看&tl=zh-CN',
      strokeData: StrokeData(
        width: 1024,
        height: 1024,
        paths: const [
          'M256 192 L256 832',
          'M768 256 L512 512',
          'M512 512 L768 832',
        ],
      ),
    ),
  ];

  static List<HanziCharacter> charactersForUnit(String unitId) =>
      characters.where((character) => character.unitId == unitId).toList();
}
