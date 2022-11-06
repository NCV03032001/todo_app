import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/model/aTodo.dart';

class DB {
  static var formatterDate = new DateFormat('yyyy-MM-dd');
  static var formatterTime = new DateFormat('HH:mm');

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

  static Future<List<aTodo>> getTodoList({String search = "", int status = 0, String type = ''}) async {
    final db = await DB.createData();
    List<Map<String, dynamic>> maps = [];

    if (type == '' || type == 'Today') {
      String today = formatterDate.format(DateTime.now());

      maps = await db.query(
        'todo', where: '(title LIKE ? OR description LIKE ?) AND status = ? AND date = ?',
        whereArgs: ['%' + search + '%', '%' + search + '%', status, today],
        orderBy: 'date, time',
      );
    }
    else if (type == 'Upcoming') {
      final now = DateTime.now();
      final upcoming = now.add(const Duration(hours: 1));

      final String dateNow = formatterDate.format(now);
      final String timeNow = formatterTime.format(now);

      final String dateUpcoming = formatterDate.format(upcoming);
      final String timeUpcoming = formatterTime.format(upcoming);

      maps = await db.query(
        'todo',
        where: dateUpcoming == dateNow
        ? '(title LIKE ? OR description LIKE ?) AND status = ? AND date = ? and time <= ?'
        : '(title LIKE ? OR description LIKE ?) AND status = ? AND ((date = ? and time >= ?) OR (date = ? and time >= ?))'
        ,
        whereArgs: dateUpcoming == dateNow
        ? ['%' + search + '%', '%' + search + '%', status, dateUpcoming, timeUpcoming]
        : ['%' + search + '%', '%' + search + '%', status, dateNow, timeNow, dateUpcoming, timeUpcoming],
        orderBy: 'date, time',
      );
    }
    else {
      maps = await db.query(
        'todo', where: '(title LIKE ? OR description LIKE ?) AND status = ?',
        whereArgs: ['%' + search + '%', '%' + search + '%', status],
        orderBy: 'date, time',
      );
    }

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

  static Future<void> updateTodo(aTodo val) async {
    final db = await DB.createData();

    await db.update(
      'todo',
      val.toMap(),
      where: 'id = ?',
      whereArgs: [val.id],
    );
  }

  static Future<void> deleteTodo(aTodo val) async {
    final db = await DB.createData();

    await db.delete(
      'todo',
      where: 'id = ?',
      whereArgs: [val.id],
    );
  }
}