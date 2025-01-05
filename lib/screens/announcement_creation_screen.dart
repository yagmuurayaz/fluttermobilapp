import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class AnnouncementCreationScreen extends StatefulWidget {
  @override
  _AnnouncementCreationScreenState createState() => _AnnouncementCreationScreenState();
}

class _AnnouncementCreationScreenState extends State<AnnouncementCreationScreen> {
  final _announcementController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Duyuru Yap')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _announcementController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Duyuru Yazın',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final announcementText = _announcementController.text.trim();

                // Eğer duyuru metni boşsa, uyarı göster
                if (announcementText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Duyuru metni boş olamaz')),
                  );
                  return;
                }

                // Veritabanına duyuruyu ekle
                await DatabaseHelper.instance.insertAnnouncement(announcementText);

                // Duyuru başarıyla eklendikten sonra SnackBar göster
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Duyuru başarıyla eklendi')),
                );

                // Ana ekran olan TeacherHomeScreen'a dön
                Navigator.pop(context); // Burada `await` kullanıyoruz
              },
              child: Text('Duyuru Gönder'),
            ),
          ],
        ),
      ),
    );
  }
}
