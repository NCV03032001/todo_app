import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/model/aTodo.dart';

class DB {
  static Future<Database> createData() async{
    WidgetsFlutterBinding.ensureInitialized();
    return  openDatabase(
      join(await getDatabasesPath(), 'todoDB.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE todo(id INTEGER PRIMARY KEY, title TEXT, description TEXT, date TEXT, time TEXT, status INTEGER)',
        );
      },
      version: 1,
    );
  }

  static Future<List<aTodo>> getAllTodoList({String search = "", int status = 0}) async {
    final db = await DB.createData();

    final List<Map<String, dynamic>> maps = await db.query(
      'todo', where: '(title LIKE ? OR description LIKE ?) AND status = ?',
      whereArgs: ['%' + search + '%', '%' + search + '%', status],
      orderBy: 'date, time',
    );

    return List.generate(maps.length, (i) {
      return aTodo(
        id: maps[i]['id'],
        title: maps[i]['title'],
        description: maps[i]['description'],
        date: maps[i]['date'],
        time: maps[i]['time'],
        status: maps[i]['status'],
      );
    });
  }

  static Future<void> insertTodo(aTodo val) async {
    // Get a reference to the database.
    final db = await DB.createData();
    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'todo',
      val.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}