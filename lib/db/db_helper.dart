
import 'dart:io';

import 'package:Donsale/db/fav_item.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBProvider {

  DBProvider._();

  static final DBProvider db = DBProvider._();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "Favs.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute("CREATE TABLE MyDraft("
              "id INTEGER PRIMARY KEY,"
              "id_ads TEXT"
              ")"
          );
        });
  }
  Future<List<FavItem>?> getAll() async {
    final db = await database;
    var res = await db?.query("MyDraft");
    return List<FavItem>.from(res!.map((e) => FavItem.fromJson(e)).toList());
  }

  void insert(FavItem note) async {
    final db = await database;
    db?.insert("MyDraft", note.toJson());
  }
  Future<int?> removeFromFavs(String id) async {
    final db  = await database;
    return await db?.delete("MyDraft", where: "id_ads = ?", whereArgs: [id]);
  }
}