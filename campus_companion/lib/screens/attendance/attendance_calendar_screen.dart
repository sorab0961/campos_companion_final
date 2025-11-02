import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../../services/database_service.dart';

class AttendanceCalendarScreen extends StatefulWidget {
  final String studentId;
  const AttendanceCalendarScreen({super.key, required this.studentId});

  @override
  State<AttendanceCalendarScreen> createState() =>
      _AttendanceCalendarScreenState();
}

class _AttendanceCalendarScreenState extends State<AttendanceCalendarScreen> {
  Map<DateTime, bool> _attendanceData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
  }

  Future<void> _fetchAttendance() async {
    final dbService = Provider.of<DatabaseService>(context, listen: false);
    try {
      final response = await dbService.getUserAttendance(widget.studentId);

      Map<DateTime, bool> data = {};
      for (var record in response) {
        final date = DateTime.parse(record['date']).toLocal();
        data[DateTime(date.year, date.month, date.day)] = record['present'];
      }

      setState(() {
        _attendanceData = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching attendance: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Attendance Calendar")),
      body: TableCalendar(
        focusedDay: DateTime.now(),
        firstDay: DateTime.utc(2024, 1, 1),
        lastDay: DateTime.utc(2026, 12, 31),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            final present =
                _attendanceData[DateTime(day.year, day.month, day.day)];
            Color color;
            if (present == true) {
              color = Colors.green.shade400;
            } else if (present == false) {
              color = Colors.red.shade400;
            } else {
              color = Colors.grey.shade300;
            }
            return Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text('${day.day}'),
            );
          },
        ),
      ),
    );
  }
}
