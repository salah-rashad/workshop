import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';
import 'package:workshop/models/employee.dart';
import 'package:workshop/models/advance.dart';
import 'package:workshop/providers/workshop_provider.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final Employee employee;

  const EmployeeDetailScreen({super.key, required this.employee});

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.employee.name),
              GestureDetector(
                onTap: () => _showMonthPicker(context),
                child: Row(
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(_selectedMonth),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, size: 16),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditEmployeeDialog(context);
                } else if (value == 'delete') {
                  _showDeleteConfirmationDialog(context);
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Attendance'),
              Tab(text: 'Advances'),
              Tab(text: 'Charts'),
            ],
          ),
        ),
        body: Consumer<WorkshopProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                _buildSummaryCard(provider),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildAttendanceList(provider),
                      _buildAdvancesList(context, provider),
                      _buildChartsTab(context, provider),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _showMonthPicker(BuildContext context) async {
    final picked = await showMonthPicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = picked;
      });
    }
  }

  Widget _buildSummaryCard(WorkshopProvider provider) {
    final daysWorked = provider.getDaysWorked(
      widget.employee.id,
      month: _selectedMonth,
    );
    final totalAdvances = provider.getTotalAdvances(
      widget.employee.id,
      month: _selectedMonth,
    );
    final netPayable = provider.getNetPayable(
      widget.employee.id,
      widget.employee.dailyRate,
      month: _selectedMonth,
    );

    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem('Days Worked', '$daysWorked'),
                _buildStatItem('Daily Rate', '${widget.employee.dailyRate}'),
                _buildStatItem(
                  'Advances',
                  '${totalAdvances.toStringAsFixed(1)}',
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Net Payable',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  '${netPayable.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: netPayable >= 0
                        ? Colors.green[800]
                        : Colors.red[800],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildAttendanceList(WorkshopProvider provider) {
    final attendance = provider.getAttendanceForEmployee(
      widget.employee.id,
      month: _selectedMonth,
    );
    // Sort by date descending
    attendance.sort((a, b) => b.date.compareTo(a.date));

    if (attendance.isEmpty) {
      return const Center(child: Text('No attendance records for this month.'));
    }

    return ListView.builder(
      itemCount: attendance.length,
      itemBuilder: (context, index) {
        final record = attendance[index];
        final dateFormat = DateFormat('EEE, MMM d, yyyy');
        final timeFormat = DateFormat('h:mm a');

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: const Icon(Icons.calendar_today, color: Colors.blue),
            title: Text(
              dateFormat.format(record.date),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Row(
              children: [
                Icon(Icons.login, size: 16, color: Colors.green[700]),
                const SizedBox(width: 4),
                Text(
                  record.checkInTime != null
                      ? timeFormat.format(record.checkInTime!)
                      : '-',
                ),
                const SizedBox(width: 16),
                Icon(Icons.logout, size: 16, color: Colors.orange[700]),
                const SizedBox(width: 4),
                Text(
                  record.checkOutTime != null
                      ? timeFormat.format(record.checkOutTime!)
                      : '-',
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditAttendanceDialog(context, record);
                } else if (value == 'delete') {
                  _showDeleteAttendanceConfirmation(context, record);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit Time'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdvancesList(BuildContext context, WorkshopProvider provider) {
    final advances = provider.getAdvancesForEmployee(
      widget.employee.id,
      month: _selectedMonth,
    );
    // Sort by date descending
    advances.sort((a, b) => b.date.compareTo(a.date));

    return Column(
      children: [
        Expanded(
          child: advances.isEmpty
              ? const Center(
                  child: Text('No advances recorded for this month.'),
                )
              : ListView.builder(
                  itemCount: advances.length,
                  itemBuilder: (context, index) {
                    final advance = advances[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.money_off, color: Colors.red),
                        title: Text(
                          '${advance.amount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(advance.note),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              DateFormat('MMM d, yyyy').format(advance.date),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showEditAdvanceDialog(context, advance);
                                } else if (value == 'delete') {
                                  _showDeleteAdvanceConfirmation(
                                    context,
                                    advance,
                                  );
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 20),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Delete'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddAdvanceDialog(context),
              label: const Text('Add Advance'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartsTab(BuildContext context, WorkshopProvider provider) {
    final attendance = provider.getAttendanceForEmployee(
      widget.employee.id,
    ); // Get ALL attendance for trends

    // Group by month
    // Map<MonthInt, Count>
    final Map<int, int> monthlyCounts = {};
    for (var i = 0; i < 6; i++) {
      final now = DateTime.now();
      final month = DateTime(now.year, now.month - i);
      monthlyCounts[month.month] = 0; // Initialize last 6 months
    }

    for (final record in attendance) {
      if (record.checkInTime != null) {
        final month = record.date.month;
        if (monthlyCounts.containsKey(month)) {
          monthlyCounts[month] = (monthlyCounts[month] ?? 0) + 1;
        }
      }
    }

    // Fix: x=0 should be 5 months ago, x=5 should be current month
    final List<BarChartGroupData> orderedGroups = [];
    final now = DateTime.now();
    for (int x = 0; x < 6; x++) {
      final monthsAgo = 5 - x;
      final d = DateTime(now.year, now.month - monthsAgo);
      final count = monthlyCounts[d.month] ?? 0;

      orderedGroups.add(
        BarChartGroupData(
          x: x,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: Colors.blue,
              width: 16,
              borderRadius: BorderRadius.circular(4),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 31, // Max days in month
                color: Colors.grey[200],
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Attendance (Last 6 Months)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Charts show last 6 months trend regardless of filter',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 31,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.toInt()} Days',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i > 5) return const SizedBox();
                          final d = DateTime(now.year, now.month - (5 - i));
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('MMM').format(d),
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: orderedGroups,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAdvanceDialog(BuildContext context) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Advance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Note'),
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
              if (amountController.text.isNotEmpty) {
                final advance = Advance(
                  employeeId: widget.employee.id,
                  date: DateTime.now(),
                  amount: double.tryParse(amountController.text) ?? 0.0,
                  note: noteController.text,
                );
                Provider.of<WorkshopProvider>(
                  context,
                  listen: false,
                ).addAdvance(advance);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditEmployeeDialog(BuildContext context) {
    final nameController = TextEditingController(text: widget.employee.name);
    final roleController = TextEditingController(text: widget.employee.role);
    final rateController = TextEditingController(
      text: widget.employee.dailyRate.toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Employee'),
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
                widget.employee.name = nameController.text;
                widget.employee.role = roleController.text;
                widget.employee.dailyRate =
                    double.tryParse(rateController.text) ?? 0.0;

                // Save changes
                widget.employee.save();
                // Or use provider if logic is there:
                Provider.of<WorkshopProvider>(
                  context,
                  listen: false,
                ).updateEmployee(widget.employee);

                setState(() {}); // Refresh title
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text(
          'Are you sure you want to delete ${widget.employee.name}? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<WorkshopProvider>(
                context,
                listen: false,
              ).deleteEmployee(widget.employee.id);
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Go back to Home
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEditAttendanceDialog(BuildContext context, dynamic record) {
    // record is Attendance
    TimeOfDay? checkIn = record.checkInTime != null
        ? TimeOfDay.fromDateTime(record.checkInTime!)
        : null;
    TimeOfDay? checkOut = record.checkOutTime != null
        ? TimeOfDay.fromDateTime(record.checkOutTime!)
        : null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Edit Attendance Time'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Check In Time'),
                  trailing: Text(checkIn?.format(context) ?? 'Not set'),
                  onTap: () async {
                    final t = await showTimePicker(
                      context: context,
                      initialTime: checkIn ?? TimeOfDay.now(),
                    );
                    if (t != null) setDialogState(() => checkIn = t);
                  },
                ),
                ListTile(
                  title: const Text('Check Out Time'),
                  trailing: Text(checkOut?.format(context) ?? 'Not set'),
                  onTap: () async {
                    final t = await showTimePicker(
                      context: context,
                      initialTime: checkOut ?? TimeOfDay.now(),
                    );
                    if (t != null) setDialogState(() => checkOut = t);
                  },
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
                  final date = record.date;
                  if (checkIn != null) {
                    record.checkInTime = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      checkIn!.hour,
                      checkIn!.minute,
                    );
                  }
                  if (checkOut != null) {
                    record.checkOutTime = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      checkOut!.hour,
                      checkOut!.minute,
                    );
                  }
                  Provider.of<WorkshopProvider>(
                    context,
                    listen: false,
                  ).updateAttendance(record);
                  Navigator.pop(ctx);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteAttendanceConfirmation(BuildContext context, dynamic record) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Attendance'),
        content: const Text(
          'Are you sure you want to delete this attendance record?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<WorkshopProvider>(
                context,
                listen: false,
              ).deleteAttendance(record);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEditAdvanceDialog(BuildContext context, Advance advance) {
    final amountController = TextEditingController(
      text: advance.amount.toString(),
    );
    final noteController = TextEditingController(text: advance.note);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Advance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Note'),
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
              if (amountController.text.isNotEmpty) {
                advance.amount = double.tryParse(amountController.text) ?? 0.0;
                advance.note = noteController.text;
                Provider.of<WorkshopProvider>(
                  context,
                  listen: false,
                ).updateAdvance(advance);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAdvanceConfirmation(BuildContext context, dynamic advance) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Advance'),
        content: const Text(
          'Are you sure you want to delete this advance record?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<WorkshopProvider>(
                context,
                listen: false,
              ).deleteAdvance(advance);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
