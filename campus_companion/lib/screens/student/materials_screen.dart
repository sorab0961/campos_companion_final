import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/database_service.dart';
import '../../widgets/loading_indicator.dart';

class StudentMaterialsScreen extends StatelessWidget {
  const StudentMaterialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DatabaseService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Study Materials')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
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
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(item['title']),
                  subtitle: Text(item['description'] ?? ''),
                  trailing: item['link'] != null
                      ? IconButton(
                          icon: const Icon(Icons.link),
                          onPressed: () => launchUrl(Uri.parse(item['link'])),
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
