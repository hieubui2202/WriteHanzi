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

      await charRepo.addCharacter(HanziCharacter(
        hanzi: '一',
        pinyin: 'yī',
        meaning: 'một',
        unitId: 'unit1',
        strokeData: StrokeData(width: 1024, height: 1024, paths: ['M 54 511 c 102 0 799 1 915 1'])
      ));

       await charRepo.addCharacter(HanziCharacter(
        hanzi: '二',
        pinyin: 'èr',
        meaning: 'hai',
        unitId: 'unit1',
        strokeData: StrokeData(width: 1024, height: 1024, paths: ['M 163 260 c 237 0 541 1 699 1','M 103 540 c 260 0 653 1 818 1'])
      ));

       await charRepo.addCharacter(HanziCharacter(
        hanzi: '三',
        pinyin: 'sān',
        meaning: 'ba',
        unitId: 'unit1',
        strokeData: StrokeData(width: 1024, height: 1024, paths: ['M 203 234 c 219 0 491 1 610 1','M 163 440 c 245 0 554 1 700 1','M 102 654 c 272 0 689 1 853 1'])
      ));

      await charRepo.addCharacter(HanziCharacter(
        hanzi: '十',
        pinyin: 'shí',
        meaning: 'mười',
        unitId: 'unit1',
        strokeData: StrokeData(width: 1024, height: 1024, paths: ['M 152 491 c 252 0 598 1 744 1','M 444 141 c 1 113 1 677 0 803'])
      ));

      await charRepo.addCharacter(HanziCharacter(
        hanzi: '人',
        pinyin: 'rén',
        meaning: 'người',
        unitId: 'unit1',
        strokeData: StrokeData(width: 1024, height: 1024, paths: ['M 503 162 c -72 138 -225 352 -335 504','M 515 163 c 101 133 283 392 371 529'])
      ));

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _seedData,
                child: const Text('Seed Initial Data'),
              ),
      ),
    );
  }
}
