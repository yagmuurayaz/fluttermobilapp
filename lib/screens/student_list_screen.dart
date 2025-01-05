import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({Key? key}) : super(key: key);

  @override
  _StudentListScreenState createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  List<String> studentUsernames = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    try {
      // Veritabanından "student" türündeki kullanıcıları getir
      final students = await DatabaseHelper.instance.getUsersByType('Öğrenci');
      setState(() {
        studentUsernames = students.map((e) => e['username'] as String).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching student data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Öğrenci Listesi'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Toplam Öğrenci Sayısı: ${studentUsernames.length}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: studentUsernames.isEmpty
                  ? Center(
                child: Text(
                  'Kayıtlı öğrenci bulunamadı.',
                  style: TextStyle(fontSize: 16),
                ),
              )
                  : ListView.builder(
                itemCount: studentUsernames.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(studentUsernames[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
