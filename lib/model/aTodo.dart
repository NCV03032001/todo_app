import 'package:flutter/material.dart';

class aTodo {
  final int? id;
  final String title;
  final String? description;
  final String date;
  final String time;
  final int status;

  const aTodo({
    this.id,
    required this.title,
    this.description,
    required this.date,
    required this.time,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "description": description ?? '',
      "date": date.toString(),
      "time": time.toString(),
      "status": status.toString(),
    };
  }

  @override
  String toString() {
    return "Note{id:$id, name:$title, description:$description, date:$date, time:$time, status:$status}";
  }
}