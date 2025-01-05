import 'package:flutter/material.dart';
import 'announcement_creation_screen.dart'; // Duyuru yapma ekranı
import 'assignments_creation_screen.dart';

import 'grade_entry_screen.dart';
import 'message_screen.dart';
import 'student_list_screen.dart'; // Mesaj gönderme ekranı

class TeacherHomeScreen extends StatelessWidget {
  final String teacherUsername;
  const TeacherHomeScreen({required this.teacherUsername});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Öğretmen Ana Ekran'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AnnouncementCreationScreen()),
                );
              },
              child: Text('Duyuru Yap'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AssignmentCreationScreen()),
                );
              },
              child: Text('Ödev Ver'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MessageScreen(teacherUsername: teacherUsername)),
                );
              },
              child: Text('Mesajlar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StudentListScreen(),
                  ),
                );
              },
              child: Text('Öğrenci Listesi'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GradeEntryScreen(),
                  ),
                );
              },
              child: Text('Not Girişi'),
            )

          ],
        ),
      ),
    );
  }
}
