import 'package:flutter/material.dart';

const Color practiceBackground = Color(0xFF0E1116);
const Color practiceText = Color(0xFFE8EEF4);
const Color practicePrimary = Color(0xFF18E06F);

const EdgeInsets practicePadding = EdgeInsets.symmetric(horizontal: 24, vertical: 16);

TextStyle titleStyle(BuildContext context) => Theme.of(context).textTheme.headlineMedium?.copyWith(
      color: practiceText,
      fontFamily: 'NotoSansSC',
      fontWeight: FontWeight.w700,
    ) ??
    const TextStyle(
      color: practiceText,
      fontSize: 28,
      fontFamily: 'NotoSansSC',
      fontWeight: FontWeight.w700,
    );

TextStyle bodyStyle({double fontSize = 16, FontWeight fontWeight = FontWeight.w500}) => TextStyle(
      color: practiceText.withOpacity(0.85),
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontFamily: 'Arial',
    );

TextStyle helperStyle({double fontSize = 14}) => bodyStyle(fontSize: fontSize).copyWith(
      color: Colors.white60,
      fontWeight: FontWeight.w500,
    );

Widget hintCaption({String text = 'Tap once for a hint. Double-tap the canvas for a walkthrough.'}) =>
    Text(
      text,
      textAlign: TextAlign.center,
      style: helperStyle(fontSize: 14),
    );

final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: practicePrimary,
  foregroundColor: Colors.black,
  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, fontFamily: 'Arial'),
  minimumSize: const Size(double.infinity, 56),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
);
