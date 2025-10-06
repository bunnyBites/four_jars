import 'package:hive/hive.dart';

part 'goal.g.dart';

@HiveType(typeId: 4)
class Goal {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double targetAmount;

  @HiveField(3)
  double savedAmount;

  @HiveField(4)
  final DateTime creationDate;

  Goal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.savedAmount = 0.0,
    required this.creationDate,
  });
}
