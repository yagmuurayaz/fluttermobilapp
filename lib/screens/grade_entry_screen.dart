import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class GradeEntryScreen extends StatefulWidget {
  const GradeEntryScreen({Key? key}) : super(key: key);

  @override
  State<GradeEntryScreen> createState() => _GradeEntryScreenState();
}

class _GradeEntryScreenState extends State<GradeEntryScreen> {
  final TextEditingController _studentUsernameController =
  TextEditingController();
  final TextEditingController _midtermController = TextEditingController();
  final TextEditingController _finalController = TextEditingController();
  final TextEditingController _courseNameController = TextEditingController();

  double? _average;

  Future<void> _saveGrade() async {
    final studentUsername = _studentUsernameController.text.trim();
    final midterm = double.tryParse(_midtermController.text) ?? 0.0;
    final finalExam = double.tryParse(_finalController.text) ?? 0.0;
    final courseName = _courseNameController.text.trim();

    if (studentUsername.isEmpty) {
      _showError("Lütfen öğrenci kullanıcı adını girin.");
      return;
    }
    if (courseName.isEmpty) {
      _showError("Lütfen ders adını girin.");
      return;
    }

    final doesExist = await DatabaseHelper.instance.doesUserExist(studentUsername);

    if (!doesExist) {
      _showError("Girilen kullanıcı adı bir öğrenciye ait değil.");
      return;
    }

    final average = (midterm * 0.4) + (finalExam * 0.6);

    try {
      await DatabaseHelper.instance.insertGrade(
        studentUsername: studentUsername,
        midterm: midterm,
        finalExam: finalExam,
        average: average,
        courseName: courseName,
      );

      setState(() {
        _average = average;
      });

      _showSuccess(
        "Not kaydedildi: $studentUsername\nDers: $courseName\nOrtalama: ${average.toStringAsFixed(2)}",
      );
      // Öğretmenin ana ekranına dön
      Navigator.pop(context);
    } catch (e) {
      _showError("Not kaydedilirken hata oluştu: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Not Girişi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _studentUsernameController,
              decoration: InputDecoration(
                labelText: 'Öğrenci Kullanıcı Adı',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _midtermController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Vize Notu',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _finalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Final Notu',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _courseNameController,
              decoration: InputDecoration(
                labelText: 'Ders Adı',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveGrade,
              child: Text('Kaydet ve Ortalama Hesapla'),
            ),
            if (_average != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  'Ortalama: ${_average!.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
