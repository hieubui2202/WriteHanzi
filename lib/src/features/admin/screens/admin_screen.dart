import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../models/hanzi_character.dart';
import '../../../repositories/character_repository.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _isLoading = false;
  final _tsvController = TextEditingController();

  Future<void> _seedData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Seeding is disabled trong phiên bản này. Vui lòng nhập dữ liệu trực tiếp qua Firebase.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error preparing seed data: $e')),
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
      final lines = LineSplitter.split(tsvData.trim())
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();

      for (final line in lines) {
        final parts = line.split('\t');
        if (parts.length < 10) {
          debugPrint('Skipping malformed TSV row: $line');
          continue;
        }

        final paths = parts[9]
            .split('|')
            .map((path) => path.trim())
            .where((path) => path.isNotEmpty)
            .toList();

        final character = HanziCharacter(
          id: parts[0], // Use hanzi as ID
          hanzi: parts[0],
          unitId: parts[1],
          pinyin: parts[5],
          meaning: parts[4],
          ttsUrl: parts[6],
          strokeData: StrokeData(
            width: int.tryParse(parts[7]) ?? 109,
            height: int.tryParse(parts[8]) ?? 109,
            paths: paths,
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
