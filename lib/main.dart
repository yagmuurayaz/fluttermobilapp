import 'package:flutter/material.dart';
import '../database/database_helper.dart';  // DatabaseHelper'ı dahil edin
import 'screens/home_screen.dart';
import 'screens/user_type_printer.dart';

void main() async {
  // Flutter'ın başlangıç bağlamını başlatın
  WidgetsFlutterBinding.ensureInitialized();

  // Uygulama başladığında veritabanını sıfırlama
  //await DatabaseHelper.instance.resetDatabase();
  // UserTypePrinter çağır ve kullanıcı türlerini konsola yazdır
  //final printer = UserTypePrinter();
 // await printer.printUserTypesCount();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kayıt ve Giriş Sistemi',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),  // Ana ekran
    );
  }
}
