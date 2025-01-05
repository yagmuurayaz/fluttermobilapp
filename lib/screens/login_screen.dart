import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'student_home_screen.dart';  // Öğrenci Ana Ekranı
import 'teacher_home_screen.dart';  // Öğretmen Ana Ekranı

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _userType;
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Giriş Yap')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Kullanıcı Adı',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Şifre',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _userType,
              items: [
                DropdownMenuItem(value: 'Öğrenci', child: Text('Öğrenci')),
                DropdownMenuItem(value: 'Öğretmen', child: Text('Öğretmen')),
              ],
              onChanged: (value) {
                setState(() {
                  _userType = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Kullanıcı Türü',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final username = _usernameController.text.trim();
                final password = _passwordController.text.trim();

                // Kullanıcı adı, şifre ve kullanıcı türü boş olmamalı
                if (username.isEmpty || password.isEmpty || _userType == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tüm alanları doldurun')),
                  );
                  return;
                }

                // Kullanıcıyı veritabanından kontrol et
                final user = await DatabaseHelper.instance.getUser(username, password, _userType!);

                if (user != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Giriş başarılı!')),
                  );

                  // Kullanıcı türüne göre yönlendirme
                  if (_userType == 'Öğrenci') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) =>  StudentHomeScreen(studentUsername: username)),
                    );
                  } else if (_userType == 'Öğretmen') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => TeacherHomeScreen(teacherUsername: username)),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Geçersiz bilgiler')),
                  );
                }
              },
              child: Text('Giriş Yap'),
            ),
          ],
        ),
      ),
    );
  }
}
