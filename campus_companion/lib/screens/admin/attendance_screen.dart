import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/database_service.dart';
import '../../widgets/loading_indicator.dart';
import '../../utils/theme.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<Map<String, dynamic>> _unmarked = [];
  List<Map<String, dynamic>> _present = [];
  List<Map<String, dynamic>> _absent = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final dbService = Provider.of<DatabaseService>(context, listen: false);
    try {
      final students = await dbService.getAllStudents();
      setState(() {
        _unmarked = students;
        _present.clear();
        _absent.clear();
        _error = null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _markAttendance(Map<String, dynamic> student, bool isPresent) async {
    try {
      final dbService = Provider.of<DatabaseService>(context, listen: false);
      await dbService.markAttendance(student['id'], DateTime.now(), isPresent);

      setState(() {
        _unmarked.remove(student);
        if (isPresent) {
          _present.add(student);
        } else {
          _absent.add(student);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${student['email']} marked as ${isPresent ? "Present" : "Absent"}',
          ),
        ),
      );
    } catch (e) {
      print('Error marking attendance: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error marking attendance: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildStudentList(
    String title,
    List<Map<String, dynamic>> students, {
    bool isActionable = false,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        initiallyExpanded: title == "Unmarked Students",
        title: Text(
          '$title (${students.length})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: students.isEmpty
            ? [
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text('No students in this list'),
                ),
              ]
            : students.map((student) {
                return ListTile(
                  title: Text(student['email']),
                  trailing: isActionable
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.check,
                                color: Colors.green,
                              ),
                              onPressed: () => _markAttendance(student, true),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _markAttendance(student, false),
                            ),
                          ],
                        )
                      : null,
                );
              }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mark Attendance')),
      body: _isLoading
          ? const LoadingIndicator()
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: $_error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                    ),
                    onPressed: _loadStudents,
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadStudents,
              child: ListView(
                children: [
                  const SizedBox(height: 8),
                  _buildStudentList(
                    'Unmarked Students',
                    _unmarked,
                    isActionable: true,
                  ),
                  _buildStudentList('Present Students', _present),
                  _buildStudentList('Absent Students', _absent),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}
