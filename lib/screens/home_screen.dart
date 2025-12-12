import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:workshop/models/employee.dart';
import 'package:workshop/providers/workshop_provider.dart';
import 'package:workshop/screens/employee_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workshop Attendance')),
      body: Consumer<WorkshopProvider>(
        builder: (context, provider, child) {
          final employees = provider.employees;
          if (employees.isEmpty) {
            return const Center(child: Text('No employees added yet.'));
          }
          return ListView.builder(
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final employee = employees[index];
              final attendance = provider.getTodayAttendance(employee.id);
              final isPresent =
                  attendance?.checkInTime != null &&
                  attendance?.checkOutTime == null;
              final isCheckedOut = attendance?.checkOutTime != null;

              return ListTile(
                title: Text(employee.name),
                subtitle: Text(employee.role),
                leading: CircleAvatar(child: Text(employee.name[0])),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isCheckedOut)
                      ElevatedButton(
                        onPressed: isPresent
                            ? () => provider.checkOut(employee.id)
                            : () => provider.checkIn(employee.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPresent
                              ? Colors.orange
                              : Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(isPresent ? 'Check Out' : 'Check In'),
                      )
                    else
                      const Icon(Icons.check_circle, color: Colors.green),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EmployeeDetailScreen(employee: employee),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEmployeeDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddEmployeeDialog(BuildContext context) {
    final nameController = TextEditingController();
    final roleController = TextEditingController();
    final rateController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Employee'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: roleController,
              decoration: const InputDecoration(labelText: 'Role'),
            ),
            TextField(
              controller: rateController,
              decoration: const InputDecoration(labelText: 'Daily Rate'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  roleController.text.isNotEmpty) {
                final employee = Employee(
                  name: nameController.text,
                  role: roleController.text,
                  dailyRate: double.tryParse(rateController.text) ?? 0.0,
                );
                Provider.of<WorkshopProvider>(
                  context,
                  listen: false,
                ).addEmployee(employee);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
