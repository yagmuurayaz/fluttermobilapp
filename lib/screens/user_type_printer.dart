import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class UserTypePrinter {
  // Kullanıcı türlerini ve sayılarını konsola yazdırır
  Future<void> printUserTypesCount() async {
    final db = await DatabaseHelper.instance.database;

    try {
      // Kullanıcı türlerini ve her türün sayısını gruplandırarak al
      final result = await db.rawQuery('''
        SELECT userType, COUNT(*) as count 
        FROM users 
        GROUP BY userType
      ''');

      if (result.isEmpty) {
        print('Veritabanında hiç kullanıcı bulunamadı.');
      } else {
        print('Kullanıcı Türleri ve Sayıları:');
        for (var row in result) {
          final userType = row['userType'] as String;
          final count = row['count'] as int;
          print('Tür: $userType - Sayı: $count');
        }
      }
    } catch (e) {
      print('Hata oluştu: $e');
    }
  }
}
