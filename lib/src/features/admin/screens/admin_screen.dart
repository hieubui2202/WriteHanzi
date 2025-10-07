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
        id: 'unit1',
        title: 'Cơ bản 1',
        description: 'Các nét cơ bản và các ký tự đơn giản.',
        order: 1,
        characters: const ['一', '二', '三', '十', '人'],
        xpReward: 100,
      );
      await unitRepo.addUnit(unit1);

      Future<void> createCharacter({
        required String hanzi,
        required String pinyin,
        required String meaning,
        required List<String> paths,
      }) async {
        await charRepo.addCharacter(
          HanziCharacter(
            hanzi: hanzi,
            pinyin: pinyin,
            meaning: meaning,
            unitId: unit1.id,
            strokeData: StrokeData(
              width: 1024,
              height: 1024,
              paths: paths,
            ),
          ),
        );
      }

      await createCharacter(
        hanzi: '一',
        pinyin: 'yī',
        meaning: 'một',
        paths: const ['M 54 511 c 102 0 799 1 915 1'],
      );

      await createCharacter(
        hanzi: '二',
        pinyin: 'èr',
        meaning: 'hai',
        paths: const [
          'M 163 260 c 237 0 541 1 699 1',
          'M 103 540 c 260 0 653 1 818 1',
        ],
      );

      await createCharacter(
        hanzi: '三',
        pinyin: 'sān',
        meaning: 'ba',
        paths: const [
          'M 203 234 c 219 0 491 1 610 1',
          'M 163 440 c 245 0 554 1 700 1',
          'M 102 654 c 272 0 689 1 853 1',
        ],
      );

      await createCharacter(
        hanzi: '十',
        pinyin: 'shí',
        meaning: 'mười',
        paths: const [
          'M 152 491 c 252 0 598 1 744 1',
          'M 444 141 c 1 113 1 677 0 803',
        ],
      );

      await createCharacter(
        hanzi: '人',
        pinyin: 'rén',
        meaning: 'người',
        paths: const [
          'M 503 162 c -72 138 -225 352 -335 504',
          'M 515 163 c 101 133 283 392 371 529',
        ],
      );

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
      final lines = _tsvController.text.split('\n');

      for (final rawLine in lines) {
        final line = rawLine.trim();
        if (line.isEmpty) continue;

        final parts = line.split('\t');
        if (parts.length < 10) {
          continue;
        }

        final strokePaths = parts[9]
            .split('|')
            .map((path) => path.trim())
            .where((path) => path.isNotEmpty)
            .toList();

        final character = HanziCharacter(
          hanzi: parts[0],
          unitId: parts[1],
          meaning: parts[4],
          pinyin: parts[5],
          strokeData: StrokeData(
            width: int.parse(parts[7]),
            height: int.parse(parts[8]),
            paths: strokePaths,
          ),
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
