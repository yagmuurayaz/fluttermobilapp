import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class ExamResultsScreen extends StatefulWidget {
  final String studentUsername;

  const ExamResultsScreen({Key? key, required this.studentUsername}) : super(key: key);

  @override
  State<ExamResultsScreen> createState() => _ExamResultsScreenState();
}

class _ExamResultsScreenState extends State<ExamResultsScreen> {
  List<Map<String, dynamic>> _grades = [];

  @override
  void initState() {
    super.initState();
    _fetchGrades();
  }

  Future<void> _fetchGrades() async {
    try {
      final grades = await DatabaseHelper.instance.getGradesForStudent(widget.studentUsername);
      setState(() {
        _grades = grades;
      });
    } catch (e) {
      _showError("Notları getirirken hata oluştu: $e");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sınav Sonuçları'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _grades.isEmpty
            ? Center(child: Text('Hiç sınav sonucu yok.'))
            : ListView.builder(
          itemCount: _grades.length,
          itemBuilder: (context, index) {
            final grade = _grades[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text('Ders: ${grade['courseName']}'),
                subtitle: Text(
                  'Vize: ${grade['midterm']}, Final: ${grade['finalExam']}, Ortalama: ${grade['average']}',
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
