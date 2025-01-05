import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class StudentTasksScreen extends StatefulWidget {
  final String username; // Öğrencinin kullanıcı adı
  const StudentTasksScreen({required this.username});

  @override
  _StudentTasksScreenState createState() => _StudentTasksScreenState();
}

class _StudentTasksScreenState extends State<StudentTasksScreen> {
  late Future<List<Map<String, dynamic>>> _tasks;

  @override
  void initState() {
    super.initState();
    // Veritabanından öğrenciye atanmış ödevleri al
    _tasks = DatabaseHelper.instance.getAllTasks() ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ödevlerim')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _tasks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          }

          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(child: Text('Henüz atanmış bir ödev yok.'));
          }

          final tasks = snapshot.data!;

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(task['title']),
                  subtitle: Text('Son Tarih: ${task['dueDate']}\nAçıklama: ${task['description']}'),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
