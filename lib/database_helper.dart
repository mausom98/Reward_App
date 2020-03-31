import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import './HistoryList.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database;

  String historyTable = 'history_table';
  String colId = 'id';
  String colCode = 'code';
  String colReward = 'reward';
  String colDate = 'date';

  DatabaseHelper._createInstance();
  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }

    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'history.db';
    var historyDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return historyDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $historyTable($colId INTEGER PRIMARY KEY AUTOINCREMENT,$colCode TEXT,$colReward TEXT,$colDate TEXT)');
  }

  Future<List<Map<String, dynamic>>> getHistoryMapList() async {
    Database db = await this.database;
    var result = await db.rawQuery('SELECT * FROM $historyTable');
    return result;
  }

  Future<int> insertHistory(HistoryList historyList) async {
    Database db = await this.database;
    var result = await db.insert(historyTable, historyList.toMap());
    return result;
  }

  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) FROM $historyTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<HistoryList>> getHistoryList() async {
    var historyMapList = await getHistoryMapList();
    int count = historyMapList.length;
    List<HistoryList> historyList = List<HistoryList>();
    for (int i = 0; i < count; i++) {
      historyList.add(HistoryList.fromMapObject(historyMapList[i]));
    }
    return historyList;
  }
}
