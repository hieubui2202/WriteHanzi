import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  // Initialize Firebase
  await Firebase.initializeApp();

  final db = FirebaseFirestore.instance;

  // 1. Seed 'characters' collection
  final charDoc = db.collection('characters').doc('tê');
  await charDoc.set({
    'id': 'tê',
    'character': '茶',
    'pinyin': 'chá',
    'meaning': 'trà, chè',
    'ttsUrl': 'https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&q=茶&tl=zh-CN',
    'strokeCount': 9,
    'components': ['艹', '人', '木'],
    'structure': '上下',
    'creationDate': Timestamp.fromDate(DateTime.parse('2024-07-29T10:00:00Z')),
    'lastModified': Timestamp.fromDate(DateTime.parse('2024-07-29T10:00:00Z')),
    'examples': [
      {'word': '茶杯', 'pinyin': 'chábēi', 'meaning': 'tách trà'},
      {'word': '绿茶', 'pinyin': 'lǜchá', 'meaning': 'trà xanh'}
    ],
    'strokeGifUrl': 'https://raw.githubusercontent.com/skishore/makemeahanzi/master/graphics/茶.gif',
    'mp4Url': 'https://videos.strokeorder.com/99f35bb37d38313a5b6786c8d76d332d.mp4'
  });
  print('Seeded character: 茶');

  // 2. Seed 'units' collection
  final unitDoc = db.collection('units').doc('section1_unit1');
  await unitDoc.set({
    'id': 'section1_unit1',
    'title': 'Chào hỏi',
    'description': 'Học các cách chào hỏi cơ bản.',
    'characterIds': ['ch-ni-hao', 'ch-xie-xie', 'ch-zai-jian'],
    'creationDate': Timestamp.fromDate(DateTime.parse('2024-07-29T10:00:00Z')),
    'lastModified': Timestamp.fromDate(DateTime.parse('2024-07-29T10:00:00Z'))
  });
  print('Seeded unit: Chào hỏi');

  // 3. Seed 'users' collection
  final userDoc = db.collection('users').doc('demo-uid');
  await userDoc.set({
    'uid': 'demo-uid',
    'email': 'demo@example.com',
    'displayName': 'Demo User',
    'avatarUrl': 'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y',
    'creationDate': Timestamp.fromDate(DateTime.parse('2024-07-29T10:00:00Z')),
    'lastLogin': Timestamp.fromDate(DateTime.parse('2024-07-29T10:00:00Z')),
    'unlockedCharacters': ['tê']
  });
  print('Seeded user: Demo User');

  print('\nDatabase seeding complete!');
}
