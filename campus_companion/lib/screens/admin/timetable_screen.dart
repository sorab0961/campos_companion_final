import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/database_service.dart';
import '../../models/timetable_model.dart';
import '../../widgets/loading_indicator.dart';
import '../../utils/theme.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  final _subjectCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DatabaseService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Timetable')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _subjectCtrl,
                  decoration: const InputDecoration(labelText: 'Subject'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _timeCtrl,
                  decoration: const InputDecoration(labelText: 'Time'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                  ),
                  onPressed: () async {
                    if (_subjectCtrl.text.isNotEmpty &&
                        _timeCtrl.text.isNotEmpty) {
                      await dbService.addTimetable(
                        _subjectCtrl.text,
                        _timeCtrl.text,
                      );
                      _subjectCtrl.clear();
                      _timeCtrl.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Timetable added')),
                      );
                    }
                  },
                  child: const Text(
                    'Add',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<TimetableModel>>(
              stream: dbService.getTimetables(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const LoadingIndicator();
                if (snapshot.hasError)
                  return Center(child: Text('Error: ${snapshot.error}'));
                final timetables = snapshot.data ?? [];
                return ListView.builder(
                  itemCount: timetables.length,
                  itemBuilder: (context, index) {
                    final item = timetables[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(item.subject),
                        subtitle: Text(item.time),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await dbService.deleteTimetable(item.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Deleted')),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
