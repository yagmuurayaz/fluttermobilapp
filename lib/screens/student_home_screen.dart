import 'package:flutter/material.dart';
import 'announcements_screen.dart';  // Duyurular sayfası
import 'assignments_screen.dart';
import 'student_message_screen.dart';    // Ödevler sayfası
import 'exam_result_screen.dart';     // Sınav sonuçları sayfası

class StudentHomeScreen extends StatelessWidget {
  final String studentUsername;
  const StudentHomeScreen({required this.studentUsername});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Öğrenci Ana Ekran')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Duyurular butonu
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StudentAnnouncementsScreen()),
                );
              },
              child: Text('Duyurular'),
            ),
            SizedBox(height: 16),
            // Ödevler butonu
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StudentTasksScreen(username: studentUsername)),
                );
              },
              child: Text('Ödevler'),
            ),
            SizedBox(height: 16),
            // Mesajlar butonu
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StudentMessageScreen(studentUsername: studentUsername)),  // Öğrenci mesaj ekranına yönlendir
                );
              },
              child: Text('Mesajlar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExamResultsScreen(studentUsername: studentUsername),  // Sınav sonuçları ekranına yönlendir
                  ),
                );
              },
              child: Text('Sınav Sonuçları'),
            ),

          ],
        ),
      ),
    );
  }
}
