import 'package:cloud_firestore/cloud_firestore.dart';

class Habit {
  final String id;
  final String name; // Tu diseño usa .name
  final bool isCompleted;
  final int streak;

  Habit({
    required this.id,
    required this.name,
    this.isCompleted = false,
    this.streak = 0,
  });

  factory Habit.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Habit(
      id: doc.id,
      name:
          data['title'] ?? '', // Mapeamos 'title' de Firebase a 'name' de tu UI
      isCompleted: data['isCompleted'] ?? false,
      streak: data['streak'] ?? 0,
    );
  }
}
