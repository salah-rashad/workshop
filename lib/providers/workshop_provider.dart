import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:workshop/models/employee.dart';
import 'package:workshop/models/attendance.dart';
import 'package:workshop/models/advance.dart';

class WorkshopProvider extends ChangeNotifier {
  late Box<Employee> _employeeBox;
  late Box<Attendance> _attendanceBox;
  late Box<Advance> _advanceBox;

  List<Employee> get employees => _employeeBox.values.toList();
  List<Attendance> get attendanceRecords => _attendanceBox.values.toList();
  List<Advance> get advances => _advanceBox.values.toList();

  WorkshopProvider() {
    _employeeBox = Hive.box<Employee>('employees');
    _attendanceBox = Hive.box<Attendance>('attendance');
    _advanceBox = Hive.box<Advance>('advances');
  }

  // Employee Methods
  Future<void> addEmployee(Employee employee) async {
    await _employeeBox.put(employee.id, employee);
    notifyListeners();
  }

  Future<void> deleteEmployee(String id) async {
    await _employeeBox.delete(id);
    notifyListeners();
  }

  Future<void> updateEmployee(Employee employee) async {
    await _employeeBox.put(employee.id, employee);
    notifyListeners();
  }

  // Attendance Methods
  Future<void> updateAttendance(Attendance attendance) async {
    await attendance.save();
    notifyListeners();
  }

  Future<void> deleteAttendance(Attendance attendance) async {
    await attendance.delete();
    notifyListeners();
  }

  Future<void> checkIn(String employeeId) async {
    final now = DateTime.now();
    // Check if already checked in today
    final today = DateTime(now.year, now.month, now.day);

    final existing = _attendanceBox.values.firstWhere(
      (a) =>
          a.employeeId == employeeId &&
          DateTime(a.date.year, a.date.month, a.date.day) == today,
      orElse: () => Attendance(employeeId: employeeId, date: now),
    );

    if (existing.checkInTime == null) {
      existing.checkInTime = now;
      if (existing.isInBox) {
        await existing.save();
      } else {
        await _attendanceBox.put(existing.id, existing);
      }
      notifyListeners();
    }
  }

  Future<void> checkOut(String employeeId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    try {
      final existing = _attendanceBox.values.firstWhere(
        (a) =>
            a.employeeId == employeeId &&
            DateTime(a.date.year, a.date.month, a.date.day) == today,
      );

      if (existing.checkOutTime == null) {
        existing.checkOutTime = now;
        await existing.save();
        notifyListeners();
      }
    } catch (e) {
      // No attendance record found for today to check out
      debugPrint('Cannot check out: No attendance record found for today.');
    }
  }

  Attendance? getTodayAttendance(String employeeId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    try {
      return _attendanceBox.values.firstWhere(
        (a) =>
            a.employeeId == employeeId &&
            DateTime(a.date.year, a.date.month, a.date.day) == today,
      );
    } catch (e) {
      return null;
    }
  }

  List<Attendance> getAttendanceForEmployee(
    String employeeId, {
    DateTime? month,
  }) {
    var query = _attendanceBox.values.where((a) => a.employeeId == employeeId);

    if (month != null) {
      query = query.where(
        (a) => a.date.year == month.year && a.date.month == month.month,
      );
    }

    return query.toList();
  }

  // Advance Methods
  Future<void> addAdvance(Advance advance) async {
    await _advanceBox.put(advance.id, advance);
    notifyListeners();
  }

  Future<void> updateAdvance(Advance advance) async {
    await advance.save();
    notifyListeners();
  }

  Future<void> deleteAdvance(Advance advance) async {
    await advance.delete();
    notifyListeners();
  }

  List<Advance> getAdvancesForEmployee(String employeeId, {DateTime? month}) {
    var query = _advanceBox.values.where((a) => a.employeeId == employeeId);

    if (month != null) {
      query = query.where(
        (a) => a.date.year == month.year && a.date.month == month.month,
      );
    }

    return query.toList();
  }

  // Stats
  int getDaysWorked(String employeeId, {DateTime? month}) {
    var query = _attendanceBox.values.where(
      (a) => a.employeeId == employeeId && a.checkInTime != null,
    );

    if (month != null) {
      query = query.where(
        (a) => a.date.year == month.year && a.date.month == month.month,
      );
    }

    return query.length;
  }

  double getTotalAdvances(String employeeId, {DateTime? month}) {
    var query = _advanceBox.values.where((a) => a.employeeId == employeeId);

    if (month != null) {
      query = query.where(
        (a) => a.date.year == month.year && a.date.month == month.month,
      );
    }

    return query.fold(0.0, (sum, item) => sum + item.amount);
  }

  double getNetPayable(String employeeId, double dailyRate, {DateTime? month}) {
    final days = getDaysWorked(employeeId, month: month);
    final advances = getTotalAdvances(employeeId, month: month);
    return (days * dailyRate) - advances;
  }
}
