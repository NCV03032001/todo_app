class aTodo {
  final int id;
  final String title;
  final String description;
  final String date;
  final String time;
  final int status;

  const aTodo({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "date": date,
      "time": time,
      "status": status,
    };
  }

  @override
  String toString() {
    return "Note{id: $id, name: $title, description: $description, date: $date, time: $time, status: $status}";
  }
}