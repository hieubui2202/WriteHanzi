# WriteHanzi

A Duolingo-inspired Flutter app focused on handwriting Chinese characters. The project is configured for Firebase (Auth, Firestore, Storage) and includes admin tooling to seed units and character stroke data.

## Prerequisites
- Flutter 3.7.x
- Firebase project configured via the provided `firebase_options.dart`
- Dart SDK that matches the Flutter version (3.7.x)

## Running the app
```
flutter pub get
flutter run
```

If you launch the web build use:
```
flutter run -d chrome
```

## Importing character data from TSV
The admin panel can ingest tab-separated rows that follow the schema below:

```
Character	SectionID	SectionTitle	Word	Translation	Transliteration	TTS URL	StrokeWidth	StrokeHeight	StrokePaths
```

- `Character`: the Hanzi itself (also used as the Firestore document id).
- `SectionID`: numeric or textual identifier for the unit/section the character belongs to. The importer creates a slugged unit id such as `unit_0` or `unit_section_1`.
- `SectionTitle`: human readable unit title.
- `Word`: optional duplicate of the character column (kept for compatibility).
- `Translation`: localized meaning displayed in lessons.
- `Transliteration`: pinyin (or pronunciation) text.
- `TTS URL`: optional audio file already uploaded to Firebase Storage or CDN.
- `StrokeWidth` / `StrokeHeight`: canvas dimensions used by the stroke paths (e.g. `109`).
- `StrokePaths`: pipe-delimited SVG path commands describing each stroke.

### Steps
1. Run the app and sign in with an account that should manage content.
2. Navigate to `/admin` (e.g. `Navigator.of(context).pushNamed('/admin')` or via deep link) to open the admin panel.
3. Paste the TSV rows into the text area and press **Import TSV Data**.
4. The importer will:
   - Create/update characters in the `characters` collection with pinyin, translation, TTS URL, and stroke data.
   - Group characters by `SectionID`/`SectionTitle`, creating corresponding entries in the `units` collection with ordered character lists and XP rewards.
5. Check the console/logcat for any skipped rows; malformed lines are reported and ignored safely.

Example row:
```
水	0	Section 1, Unit 1	水	water	shuǐ	https://d1vq87e9lcf771.cloudfront.net/xiuying/fd2cb29ebd4da887ea3908c8b324cc1d	109	109	M 52.77,15.08 C 53.85,16.16,54.44,17.57,54.53,20.60 C 54.93,35.15,54.27,82.76,54.27,87.72 C 54.27,97.50,46.75,87.75,45.25,86.50|M 17.50,45.75 C 19.25,46.37,21.23,46.18,22.75,45.75 C 25.88,44.88,36.09,41.00,38.59,40.00 C 41.09,39.00,43.06,41.24,42.34,43.50 C 39.00,54.00,28.25,69.00,19.00,74.75|M 81.22,27.50 C 81.00,28.75,80.50,29.75,79.70,30.47 C 74.06,35.57,67.25,40.25,57.25,44.25|M 57.00,46.00 C 65.82,56.73,76.23,67.46,85.42,73.42 C 87.58,74.82,89.94,76.42,92.50,77.00
```

After importing, reload the home screen to see the newly created units and characters.
