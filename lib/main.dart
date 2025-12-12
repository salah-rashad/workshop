import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workshop/models/advance.dart';
import 'package:workshop/models/attendance.dart';
import 'package:workshop/models/employee.dart';
import 'package:workshop/providers/workshop_provider.dart';
import 'package:workshop/screens/home_screen.dart';

void main() async {
  await Hive.initFlutter();

  Hive.registerAdapter(EmployeeAdapter());
  Hive.registerAdapter(AttendanceAdapter());
  Hive.registerAdapter(AdvanceAdapter());

  await Hive.openBox<Employee>('employees');
  await Hive.openBox<Attendance>('attendance');
  await Hive.openBox<Advance>('advances');

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WorkshopProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Workshop Attendance',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        darkTheme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
        home: const HomeScreen(),
        themeMode: ThemeMode.dark,
      ),
    );
  }
}
