import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'employee.g.dart';

@HiveType(typeId: 0)
class Employee extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String role;

  @HiveField(3)
  double dailyRate;

  @HiveField(4)
  DateTime createdAt;

  Employee({
    String? id,
    required this.name,
    required this.role,
    this.dailyRate = 0.0,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();
}
