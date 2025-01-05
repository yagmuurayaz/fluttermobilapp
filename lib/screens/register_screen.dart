import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _userType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kayıt Ol'),
      ),
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
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Şifreyi Onayla',
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
                final confirmPassword = _confirmPasswordController.text.trim();

                // Boş alan kontrolü
                if (username.isEmpty || password.isEmpty || confirmPassword.isEmpty || _userType == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tüm alanları doldurun')),
                  );
                  return;
                }

                // Şifre eşleşme kontrolü
                if (password != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Şifreler eşleşmiyor')),
                  );
                  return;
                }

                try {
                  // Veritabanına kullanıcıyı ekleyelim
                  await DatabaseHelper.instance.insertUser(username, password, _userType!);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Kayıt başarılı! Giriş yapabilirsiniz')),
                  );

                  // Kullanıcıyı ana ekrana yönlendir
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                        (route) => false, // Önceki sayfaları temizler
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Bir hata oluştu: $e')),
                  );
                  print('Database error: $e'); // Hata mesajını console'a yazdırma
                }
              },
              child: Text('Kayıt Ol'),
            ),
          ],
        ),
      ),
    );
  }
}
