import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class AssignmentCreationScreen extends StatefulWidget {
  @override
  _AssignmentCreationScreenState createState() => _AssignmentCreationScreenState();
}

class _AssignmentCreationScreenState extends State<AssignmentCreationScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController(); // Teslim tarihi için


  @override
  void dispose() {
    // Bellek sızıntılarını önlemek için controller'ları dispose ediyoruz
    _titleController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ödev Ekle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Ödev Başlığı',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Ödev Açıklaması (Opsiyonel)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _dueDateController,
              decoration: InputDecoration(
                labelText: 'Teslim Tarihi (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final title = _titleController.text.trim();
                final description = _descriptionController.text.trim();
                final dueDate = _dueDateController.text.trim();


                // Gerekli alanlar boşsa uyarı göster
                if (title.isEmpty || dueDate.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lütfen gerekli alanları doldurun')),
                  );
                  return;
                }

                // Veritabanına ödevi ekle
                try {

                  await DatabaseHelper.instance.insertTask(

                  title: title,

                  description: description,

                  dueDate: dueDate,

                );


    // Ödev başarıyla eklendikten sonra SnackBar göster
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ödev başarıyla eklendi')),
                );
                // Formu temizle ve önceki ekrana dön
                _titleController.clear();
                _descriptionController.clear();
                _dueDateController.clear();


                // Ana ekran olan TeacherHomeScreen'a dön
                Navigator.pop(context);
              } catch (e) {
                  // Hata durumunda SnackBar göster
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Ödev eklenirken bir hata oluştu: $e')),
                  );
                }

              },
              child: Text('Ödev Gönder'),
            ),
          ],
        ),
      ),
    );
  }
}
