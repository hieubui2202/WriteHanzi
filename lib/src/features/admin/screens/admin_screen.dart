import 'package:flutter/material.dart';

import '../../../models/hanzi_character.dart';
import '../../../models/unit.dart';
import '../../../repositories/character_repository.dart';
import '../../../repositories/unit_repository.dart';

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

      final unit1 = Unit(
        id: 'section_1_unit_1',
        section: 'Phần 1',
        sectionIndex: 1,
        unitNumber: 1,
        characters: const ['一', '二', '三', '十', '人'],
        words: const ['一', '二', '三', '十', '人'],
        wordCount: 5,
      );
      await unitRepo.addUnit(unit1);

      final characters = <HanziCharacter>[
        HanziCharacter(
          id: '一',
          hanzi: '一',
          pinyin: 'yī',
          meaning: 'một',
          section: 'Phần 1',
          strokeCount: 1,
          strokePaths: const ['M 54 511 c 102 0 799 1 915 1'],
        ),
        HanziCharacter(
          id: '二',
          hanzi: '二',
          pinyin: 'èr',
          meaning: 'hai',
          section: 'Phần 1',
          strokeCount: 2,
          strokePaths: const [
            'M 163 260 c 237 0 541 1 699 1',
            'M 103 540 c 260 0 653 1 818 1',
          ],
        ),
        HanziCharacter(
          id: '三',
          hanzi: '三',
          pinyin: 'sān',
          meaning: 'ba',
          section: 'Phần 1',
          strokeCount: 3,
          strokePaths: const [
            'M 203 234 c 219 0 491 1 610 1',
            'M 163 440 c 245 0 554 1 700 1',
            'M 102 654 c 272 0 689 1 853 1',
          ],
        ),
        HanziCharacter(
          id: '十',
          hanzi: '十',
          pinyin: 'shí',
          meaning: 'mười',
          section: 'Phần 1',
          strokeCount: 2,
          strokePaths: const [
            'M 152 491 c 252 0 598 1 744 1',
            'M 444 141 c 1 113 1 677 0 803',
          ],
        ),
        HanziCharacter(
          id: '人',
          hanzi: '人',
          pinyin: 'rén',
          meaning: 'người',
          section: 'Phần 1',
          strokeCount: 2,
          strokePaths: const [
            'M 503 162 c -72 138 -225 352 -335 504',
            'M 515 163 c 101 133 283 392 371 529',
          ],
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
      final tsvData = _tsvController.text;
      final lines = tsvData.split('\n');

      for (final line in lines) {
        if (line.trim().isEmpty) continue;

        final parts = line.split('\t');
        if (parts.length < 6) {
          continue;
        }

        final character = HanziCharacter(
          id: parts[0],
          hanzi: parts[0],
          pinyin: parts[5],
          meaning: parts[4],
          section: parts[1],
          strokePaths: parts.length > 9
              ? parts[9]
                  .split('|')
                  .map((e) => e.trim())
                  .where((element) => element.isNotEmpty)
                  .toList()
              : const [],
        );
        await charRepo.addCharacter(character);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('TSV Data imported successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error importing TSV data: $e')),
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
