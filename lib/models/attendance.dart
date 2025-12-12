import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'attendance.g.dart';

@HiveType(typeId: 1)
class Attendance extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String employeeId;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  DateTime? checkInTime;

  @HiveField(4)
  DateTime? checkOutTime;

  Attendance({
    String? id,
    required this.employeeId,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
  }) : id = id ?? const Uuid().v4();
}
