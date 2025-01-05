import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'teacher_home_screen.dart';

class MessageScreen extends StatefulWidget {
  final String teacherUsername;
  const MessageScreen({Key? key, required this.teacherUsername}) : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  late Future<List<Map<String, dynamic>>> _messages;
  final TextEditingController _receiverController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _receiverController.dispose();
    _messageController.dispose();
    super.dispose();
  }
  // Öğretmen için gelen mesajları yükleme
  Future<void> _loadMessages() async {
    _messages = DatabaseHelper.instance.getMessagesForTeacher(widget.teacherUsername);
  }

  // Mesaj gönderme fonksiyonu
  Future<void> _sendMessage() async {
    final senderUsername = widget.teacherUsername; // Öğretmenin kullanıcı adı
    final receiverUsername = _receiverController.text;
    final message = _messageController.text;

    if (receiverUsername.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Alıcı ve mesaj boş olamaz!")),
      );
      return;
    }

    try {
      // Veritabanında alıcıyı kontrol et
      final receiverExists = await DatabaseHelper.instance.doesUserExist(receiverUsername);
      if (!receiverExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Alıcı bulunamadı!")),
        );
        return;
      }

      await DatabaseHelper.instance.sendMessageFromTeacher(
        senderUsername,
        receiverUsername,
        message,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mesaj gönderildi!")),
      );
      _receiverController.clear();
      _messageController.clear();
      _fetchMessages();
      _loadMessages(); // Yeni mesajı göstermek için

      // Mesaj gönderildikten sonra TeacherHomeScreen'e dön
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  TeacherHomeScreen(teacherUsername: widget.teacherUsername)), // TeacherHomeScreen'e geçiş
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: ${e.toString()}")),
      );
    }
  }

  // Mesajları veritabanından al
  Future<void> _fetchMessages() async {
    setState(() {
      _messages = DatabaseHelper.instance.getMessagesForTeacher(widget.teacherUsername);
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mesajlaşma Ekranı"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _receiverController,
              decoration: const InputDecoration(
                labelText: "Alıcı Kullanıcı Adı",
              ),
            ),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: "Mesajınız",
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _sendMessage,
              child: const Text("Mesaj Gönder"),
            ),
            const SizedBox(height: 16.0),
            const Text(
              "Gelen Mesajlar",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Mesajları yüklemek için FutureBuilder
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _messages,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Hata: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Henüz mesajınız yok.'));
                  }

                  final messages = snapshot.data!;

                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return ListTile(
                        title: Text(message['message']),
                        subtitle: Text("Gönderen: ${message['senderUsername']}"),

                      );
                    },
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
