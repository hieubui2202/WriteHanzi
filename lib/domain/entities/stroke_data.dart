import 'package:equatable/equatable.dart';

class StrokeData extends Equatable {
  const StrokeData({
    required this.width,
    required this.height,
    required this.paths,
  });

  final int width;
  final int height;
  final List<String> paths;

  @override
  List<Object?> get props => [width, height, paths];
}
