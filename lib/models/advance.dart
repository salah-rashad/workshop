import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'advance.g.dart';

@HiveType(typeId: 2)
class Advance extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String employeeId;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  double amount;

  @HiveField(4)
  String note;

  Advance({
    String? id,
    required this.employeeId,
    required this.date,
    required this.amount,
    this.note = '',
  }) : id = id ?? const Uuid().v4();
}
