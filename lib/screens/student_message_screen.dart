import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class StudentMessageScreen extends StatefulWidget {
  final String studentUsername; // Öğrencinin kullanıcı adı

  StudentMessageScreen({required this.studentUsername});

  @override
  _StudentMessageScreenState createState() => _StudentMessageScreenState();
}

class _StudentMessageScreenState extends State<StudentMessageScreen> {
  late Future<List<Map<String, dynamic>>> _messages;
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _teacherUsernameController = TextEditingController(); // Öğretmen kullanıcı adı

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  // Öğrencinin mesajlarını veritabanından al
  void _loadMessages() {
    setState(() {
      _messages = DatabaseHelper.instance.getMessagesForStudent(widget.studentUsername);
    });
  }

  // Öğrenci mesajını öğretmene gönderme fonksiyonu
  void _sendMessage() async {
    final message = _messageController.text;
    final teacherUsername = _teacherUsernameController.text;

    if (message.isNotEmpty && teacherUsername.isNotEmpty) {
      try {
        // Mesajı veritabanına gönderme
        await DatabaseHelper.instance.sendMessageFromStudent(widget.studentUsername, teacherUsername, message);
        _messageController.clear(); // Mesaj kutusunu temizle
        _teacherUsernameController.clear(); // Öğretmen kullanıcı adı kutusunu temizle
        _loadMessages(); // Yeni mesaj gönderildikten sonra mesajları güncelle

        // Başarı mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Mesaj başarıyla gönderildi!'),
          backgroundColor: Colors.green,
        ));

        // Ana ekrana dön
        Navigator.pop(context);

      } catch (e) {
        print("Mesaj gönderme hatası: $e");

        // Hata mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Mesaj gönderilirken bir hata oluştu.'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mesajlar'),
      ),
      body: Column(
        children: [
          // Mesaj Listesi (Öğrencinin aldığı mesajlar)
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _messages,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Henüz mesajınız yok.'));
                }

                final messages = snapshot.data!;
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return ListTile(
                      title: Text("Gönderen Ögretmen : ${message['senderUsername']}"),
                      subtitle: Text(message['message']),
                    );
                  },
                );
              },
            ),
          ),
          // Mesaj gönderme alanı
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Öğretmen kullanıcı adını girme alanı
                TextField(
                  controller: _teacherUsernameController,
                  decoration: InputDecoration(
                    labelText: 'Öğretmen Kullanıcı Adı',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 8.0),
                // Öğrencinin mesajını yazma alanı
                TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    labelText: 'Mesajınızı yazın...',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 8.0),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage, // Mesaj gönderme fonksiyonu
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
