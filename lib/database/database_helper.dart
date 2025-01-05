import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper instance = DatabaseHelper._init();

  // Veritabanı nesnesi
  static Database? _database;

  // Private constructor for singleton
  DatabaseHelper._init();

  // Veritabanına bağlantı sağlayan getter
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
  }

  // Veritabanı dosyasını oluşturma ve açma
  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        // Versiyon değişirse, veritabanı silinip yeniden oluşturulacak
        await db.execute("DROP TABLE IF EXISTS tasks");
        await db.execute("DROP TABLE IF EXISTS announcements");
        await db.execute("DROP TABLE IF EXISTS users");
        await db.execute("DROP TABLE IF EXISTS messages");
        await _createDB(db, newVersion);
      },
    );
  }

  // Veritabanını sıfırlama ve yeniden başlatma
  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');

    // Veritabanı dosyasını sil
    try {
      await deleteDatabase(path);  // Veritabanı dosyasını tamamen siler
      print("Veritabanı dosyası silindi.");
    } catch (e) {
      print("Veritabanı dosyası silinirken hata oluştu: $e");
    }

    // Veritabanını yeniden oluştur
    _database = await _initDB('app_database.db');
    print('Veritabanı sıfırlandı ve yeniden oluşturuldu.');
  }

  // Veritabanı tablosunu oluşturma
  Future _createDB(Database db, int version) async {
    // Kullanıcılar tablosu
    const userTable = '''
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      password TEXT NOT NULL,
      userType TEXT NOT NULL
    );
    ''';
    const messageTable= '''
    CREATE TABLE IF NOT EXISTS messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        senderUsername TEXT NOT NULL,
        receiverUsername TEXT NOT NULL,
        message TEXT NOT NULL
        
    );
    ''';
    const gradeTable = '''
  CREATE TABLE IF NOT EXISTS grades (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    studentUsername TEXT NOT NULL,
    midterm REAL NOT NULL,
    finalExam REAL NOT NULL,
    average REAL NOT NULL,
    courseName TEXT NOT NULL
  );
  ''';

    // Duyurular tablosu
    const announcementTable = '''
    CREATE TABLE IF NOT EXISTS announcements (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      announcement TEXT NOT NULL
    );
    ''';

    // Ödevler tablosu
    const taskTable = '''
    CREATE TABLE IF NOT EXISTS tasks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      description TEXT,
      dueDate TEXT NOT NULL
    );
    ''';

    // Tabloyu veritabanına oluştur
    await db.execute(userTable);
    await db.execute(announcementTable);
    await db.execute(taskTable);
    await db.execute(messageTable);
    await db.execute(gradeTable);
    print('ALL table created.');
  }

  // Kullanıcıyı veritabanına ekleme
  Future<int> insertUser(String username, String password, String userType) async {
    final db = await instance.database;
    return await db.insert(
      'users',
      {
        'username': username,
        'password': password,
        'userType': userType
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  Future<void> insertGrade({
    required String studentUsername,
    required double midterm,
    required double finalExam,
    required double average,
    required String courseName,
  }) async {
    final db = await database;
    await db.insert(
      'grades',
      {
        'studentUsername': studentUsername,
        'midterm': midterm,
        'finalExam': finalExam,
        'average': average,
        'courseName': courseName,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  Future<List<Map<String, dynamic>>> getUsersByType(String userType) async {
    final db = await DatabaseHelper.instance.database;
    return await db.query(
      'users',
      where: 'userType = ?',
      whereArgs: [userType],
    );
  }
// Öğrenciden öğretmene mesaj gönderme
  Future<void> sendMessageFromStudent(String senderUsername, String teacherUsername, String message) async {
    final db = await database;

    // Öğretmenin varlığını kontrol et
    final result = await db.query(
      'users',
      where: 'LOWER(username) = ?',
      whereArgs: [teacherUsername.toLowerCase()],
    );

    // Eğer öğretmen bulunamadıysa hata fırlat
    if (result.isEmpty) {
      throw Exception("Öğretmen bulunamadı!");
    }

    // Veritabanına mesajı ekle
    await db.insert('messages', {
      'senderUsername': senderUsername,
      'receiverUsername': teacherUsername,
      'message': message,
    });
  }

// Öğretmenden öğrenciye mesaj gönderme
  Future<void> sendMessageFromTeacher(String senderUsername, String receiverUsername, String message) async {
    final db = await database;

    // Öğrencinin varlığını kontrol et
    final result = await db.query(
      'users',
      where: 'LOWER(username) = ?',
      whereArgs: [receiverUsername.toLowerCase()],
    );

    // Eğer öğrenci bulunamadıysa hata fırlat
    if (result.isEmpty) {
      throw Exception("Öğrenci bulunamadı!");
    }

    // Veritabanına mesajı ekle
    await db.insert('messages', {
      'senderUsername': senderUsername,
      'receiverUsername': receiverUsername,
      'message': message,
    });
  }
  Future<List<Map<String, dynamic>>> getGradesForStudent(String studentUsername) async {
    final db = await database;
    return await db.query(
      'grades',
      where: 'studentUsername = ?',
      whereArgs: [studentUsername],
    );
  }



  Future<List<Map<String, dynamic>>> getMessagesForTeacher(String teacherUsername) async {
    final db = await instance.database;

    return await db.query(
      'messages',
      columns: ['message', 'senderUsername'],
      where: 'receiverUsername = ?',
      whereArgs: [teacherUsername],
    );
  }


  // Kullanıcı var mı kontrolü
  Future<bool> _userExists(String username) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty;
  }
  // Öğrencinin mesajlarını getirme
  Future<List<Map<String, dynamic>>> getMessagesForStudent(String studentUsername) async {
    final db = await database;
    return await db.query(
      'messages',
      where: 'receiverUsername = ?',
      whereArgs: [studentUsername],
    );
  }
  // Öğrencinin notlarını almak için yöntem
  Future<List<Map<String, dynamic>>> getGradesByStudent(String studentUsername) async {
    final db = await database;
    return await db.query(
      'grades',
      where: 'studentUsername = ?',
      whereArgs: [studentUsername],
    );
  }




  Future<bool> doesUserExist(String username) async {
    final db = await database;

    // Burada alıcıyı küçük/büyük harf duyarsız olarak arıyoruz
    final result = await db.query(
      'users',
      where: 'LOWER(username) = ?',
      whereArgs: [username.toLowerCase()],
    );

    // Eğer sonuç boş değilse alıcıyı bulduk
    return result.isNotEmpty;
  }





  // Kullanıcıyı sorgulama
  Future<Map<String, dynamic>?> getUser(String username, String password, String userType) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ? AND userType = ?',
      whereArgs: [username, password, userType],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Duyuru ekleme
  Future<void> insertAnnouncement(String announcement) async {
    final db = await instance.database;
    await db.insert(
      'announcements',
      {'announcement': announcement},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Duyuruları alma
  Future<List<String>> getAnnouncements() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('announcements');

    // Eğer hiç duyuru yoksa, boş liste döneriz
    if (maps.isEmpty) {
      return [];
    }

    // Her duyuru metnini bir listeye ekleriz
    return List.generate(maps.length, (i) {
      return maps[i]['announcement'] as String;
    });
  }

  // Duyuruları listeleme
  Future<List<Map<String, dynamic>>> getAllAnnouncements() async {
    final db = await instance.database;
    return await db.query('announcements');
  }

  // Ödev ekleme
  Future<void> insertTask({
    required String title,
    required String description,
    required String dueDate,
  }) async {
    final db = await instance.database;

    try {
      await db.insert(
        'tasks',
        {
          'title': title,
          'description': description,
          'dueDate': dueDate,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Task inserted successfully');
    } catch (e) {
      print('Error inserting task: $e');
    }
  }

  // Ödevleri listeleme
  Future<List<Map<String, dynamic>>> getAllTasks() async {
    final db = await instance.database;
    return await db.query('tasks');
  }

  // Tüm ödevleri temizleme
  Future<int> clearAllTasks() async {
    final db = await instance.database;
    return await db.delete('tasks');
  }

}
