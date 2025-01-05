import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class StudentAnnouncementsScreen extends StatefulWidget {
  @override
  _StudentAnnouncementsScreenState createState() => _StudentAnnouncementsScreenState();
}

class _StudentAnnouncementsScreenState extends State<StudentAnnouncementsScreen> {
  late Future<List<String>> _announcements;

  @override
  void initState() {
    super.initState();
    _announcements = DatabaseHelper.instance.getAnnouncements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Duyurular')),
      body: FutureBuilder<List<String>>(
        future: _announcements,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          }

          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(child: Text('Henüz duyuru yok.'));
          }

          final announcements = snapshot.data!;

          return ListView.builder(
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(announcements[index]),
              );
            },
          );
        },
      ),
    );
  }
}
