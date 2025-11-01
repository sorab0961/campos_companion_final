import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/database_service.dart';
import '../../widgets/loading_indicator.dart';
import '../../utils/theme.dart';

class MaterialsScreen extends StatefulWidget {
  const MaterialsScreen({super.key});

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DatabaseService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Materials')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _subjectCtrl,
                  decoration: const InputDecoration(labelText: 'Subject'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _linkCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Link (optional)',
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                  ),
                  onPressed: () async {
                    if (_titleCtrl.text.isNotEmpty) {
                      await dbService.addMaterial(
                        _titleCtrl.text,
                        _descCtrl.text,
                        _subjectCtrl.text,
                        _linkCtrl.text,
                      );
                      _titleCtrl.clear();
                      _descCtrl.clear();
                      _subjectCtrl.clear();
                      _linkCtrl.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Material added')),
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
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: dbService.getMaterials(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const LoadingIndicator();
                if (snapshot.hasError)
                  return Center(child: Text('Error: ${snapshot.error}'));
                final materials = snapshot.data ?? [];
                return ListView.builder(
                  itemCount: materials.length,
                  itemBuilder: (context, index) {
                    final item = materials[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(item['title']),
                        subtitle: Text(item['description'] ?? ''),
                        trailing: item['link'] != null
                            ? IconButton(
                                icon: const Icon(Icons.link),
                                onPressed: () =>
                                    launchUrl(Uri.parse(item['link'])),
                              )
                            : IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  await dbService.deleteMaterial(item['id']);
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
