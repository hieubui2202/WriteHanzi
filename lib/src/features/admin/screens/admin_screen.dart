import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myapp/src/models/hanzi_character.dart';
import 'package:myapp/src/models/unit.dart';
import 'package:myapp/src/repositories/character_repository.dart';
import 'package:myapp/src/repositories/unit_repository.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _isLoading = false;
  final _tsvController = TextEditingController();

  @override
  void dispose() {
    _tsvController.dispose();
    super.dispose();
  }

  Future<void> _seedData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final unitRepo = UnitRepository();
      final charRepo = CharacterRepository();

      // Unit 1: Basic Strokes
      final unit1 = Unit(
        id: 'unit1',
        title: 'Cơ bản 1',
        description: 'Các nét cơ bản và các ký tự đơn giản.',
        order: 1,
        characters: ['一', '二', '三', '十', '人'],
        xpReward: 100,
      );
      await unitRepo.addUnit(unit1);

      final characters = <HanziCharacter>[
        HanziCharacter(
          hanzi: '一',
          pinyin: 'yī',
          meaning: 'một',
          unitId: 'unit1',
          strokeData: StrokeData(
            width: 1024,
            height: 1024,
            paths: [
              'M 54 511 c 102 0 799 1 915 1',
            ],
          ),
        ),
        HanziCharacter(
          hanzi: '二',
          pinyin: 'èr',
          meaning: 'hai',
          unitId: 'unit1',
          strokeData: StrokeData(
            width: 1024,
            height: 1024,
            paths: [
              'M 163 260 c 237 0 541 1 699 1',
              'M 103 540 c 260 0 653 1 818 1',
            ],
          ),
        ),
        HanziCharacter(
          hanzi: '三',
          pinyin: 'sān',
          meaning: 'ba',
          unitId: 'unit1',
          strokeData: StrokeData(
            width: 1024,
            height: 1024,
            paths: [
              'M 203 234 c 219 0 491 1 610 1',
              'M 163 440 c 245 0 554 1 700 1',
              'M 102 654 c 272 0 689 1 853 1',
            ],
          ),
        ),
        HanziCharacter(
          hanzi: '十',
          pinyin: 'shí',
          meaning: 'mười',
          unitId: 'unit1',
          strokeData: StrokeData(
            width: 1024,
            height: 1024,
            paths: [
              'M 152 491 c 252 0 598 1 744 1',
              'M 444 141 c 1 113 1 677 0 803',
            ],
          ),
        ),
        HanziCharacter(
          hanzi: '人',
          pinyin: 'rén',
          meaning: 'người',
          unitId: 'unit1',
          strokeData: StrokeData(
            width: 1024,
            height: 1024,
            paths: [
              'M 503 162 c -72 138 -225 352 -335 504',
              'M 515 163 c 101 133 283 392 371 529',
            ],
          ),
        ),
      ];

      for (final character in characters) {
        await charRepo.addCharacter(character);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data seeded successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error seeding data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _importTsvData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final charRepo = CharacterRepository();
      final unitRepo = UnitRepository();
      final tsvData = _tsvController.text.trim();
      if (tsvData.isEmpty) {
        return;
      }

      final unitCharacters = <String, Set<String>>{};
      final unitTitles = <String, String>{};
      final unitOrders = <String, int>{};

      final lines = tsvData.split('\n');
      for (final rawLine in lines) {
        final line = rawLine.trim();
        if (line.isEmpty) {
          continue;
        }

        final parts = line.split('\t');
        if (parts.length < 10) {
          debugPrint('Skipping malformed TSV row: ' + line);
          continue;
        }

        if (parts[0].trim().toLowerCase() == 'character') {
          // Skip header row.
          continue;
        }

        final hanzi = parts[0].trim();
        if (hanzi.isEmpty) {
          continue;
        }

        final rawSectionId = parts[1].trim();
        final sectionTitle = parts[2].trim();
        final meaning = parts[4].trim();
        final pinyin = parts[5].trim();
        final ttsUrl = parts.length > 6 ? parts[6].trim() : null;
        final strokeWidth = parts.length > 7 ? int.tryParse(parts[7].trim()) : null;
        final strokeHeight = parts.length > 8 ? int.tryParse(parts[8].trim()) : null;
        final strokePaths = parts[9]
            .split('|')
            .map((segment) => segment.trim())
            .where((segment) => segment.isNotEmpty)
            .toList();

        final unitId = _buildUnitId(rawSectionId, sectionTitle);

        final character = HanziCharacter(
          hanzi: hanzi,
          pinyin: pinyin.isNotEmpty ? pinyin : hanzi,
          meaning: meaning.isNotEmpty ? meaning : hanzi,
          unitId: unitId,
          ttsUrl: ttsUrl != null && ttsUrl.isNotEmpty ? ttsUrl : null,
          strokeData: StrokeData(
            width: strokeWidth ?? 109,
            height: strokeHeight ?? 109,
            paths: strokePaths,
          ),
        );
        await charRepo.addCharacter(character);

        final characterSet = unitCharacters.putIfAbsent(unitId, () => <String>{});
        characterSet.add(character.hanzi);

        if (sectionTitle.isNotEmpty) {
          unitTitles[unitId] = sectionTitle;
        }

        final numericOrder = int.tryParse(rawSectionId);
        if (numericOrder != null) {
          unitOrders[unitId] = numericOrder;
        }
      }

      for (final entry in unitCharacters.entries) {
        final unitId = entry.key;
        final characters = entry.value.toList()..sort();
        final title = unitTitles[unitId] ?? unitId;
        final order = unitOrders[unitId] ?? 0;
        final xpReward = (characters.length * 10).clamp(20, 200).toInt();

        final unit = Unit(
          id: unitId,
          title: title,
          description: '',
          order: order,
          characters: characters,
          xpReward: xpReward,
        );
        await unitRepo.addUnit(unit);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('TSV Data imported successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error importing TSV data: ' + e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _buildUnitId(String rawSectionId, String sectionTitle) {
    final cleanedSectionId = rawSectionId.trim();
    if (cleanedSectionId.isNotEmpty) {
      final normalized = cleanedSectionId
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9_-]+'), '_')
          .replaceAll(RegExp('_+'), '_')
          .replaceAll(RegExp(r'^_+|_+$'), '');
      if (normalized.isNotEmpty) {
        return normalized.startsWith('unit_') ? normalized : 'unit_' + normalized;
      }
    }

    final cleanedTitle = sectionTitle.trim();
    if (cleanedTitle.isNotEmpty) {
      final normalizedTitle = cleanedTitle
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
          .replaceAll(RegExp('_+'), '_')
          .replaceAll(RegExp(r'^_+|_+$'), '');
      if (normalizedTitle.isNotEmpty) {
        return 'unit_' + normalizedTitle;
      }
    }

    return 'unit_' + DateTime.now().millisecondsSinceEpoch.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _seedData,
                child: const Text('Seed Initial Data'),
              ),
            const SizedBox(height: 20),
            TextField(
              controller: _tsvController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Paste TSV Data Here',
                helperText:
                    'Columns: Character, SectionID, SectionTitle, Word, Translation, Transliteration, TTS URL, StrokeWidth, StrokeHeight, StrokePaths',
                alignLabelWithHint: true,
              ),
              maxLines: 10,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _importTsvData,
              child: const Text('Import TSV Data'),
            ),
          ],
        ),
      ),
    );
  }
}
