import 'package:equatable/equatable.dart';

class UnitModel extends Equatable {
  const UnitModel({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    required this.characters,
    required this.xpReward,
  });

  final String id;
  final String title;
  final String description;
  final int order;
  final List<String> characters;
  final int xpReward;

  @override
  List<Object?> get props => [id, title, description, order, characters, xpReward];
}
