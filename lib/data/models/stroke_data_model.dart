import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/stroke_data.dart';

class StrokeDataModel extends StrokeData {
  const StrokeDataModel({
    required super.width,
    required super.height,
    required super.paths,
  });

  factory StrokeDataModel.fromJson(Map<String, dynamic> json) {
    return StrokeDataModel(
      width: (json['width'] as num?)?.toInt() ?? 100,
      height: (json['height'] as num?)?.toInt() ?? 100,
      paths: (json['paths'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'width': width,
        'height': height,
        'paths': paths,
      };

  static StrokeDataModel fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return StrokeDataModel.fromJson(data['strokeData'] as Map<String, dynamic>? ?? {});
  }
}
