import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/habit_model.dart';

class DatabaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference habitsCollection =
      FirebaseFirestore.instance.collection('habits');

  // OBTENER HÁBITOS EN TIEMPO REAL (Para tu StreamBuilder)
  Stream<List<Habit>> get habits {
    return habitsCollection
        .where('userId', isEqualTo: _auth.currentUser?.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Habit.fromFirestore(doc)).toList();
    });
  }

  // AGREGAR HÁBITO
  Future<void> addHabit(String title) {
    return habitsCollection.add({
      'title': title,
      'isCompleted': false,
      'streak': 0,
      'createdAt': Timestamp.now(),
      'userId': _auth.currentUser?.uid,
    });
  }

  // ACTUALIZAR ESTADO (Check/Uncheck)
  Future<void> updateHabitStatus(
      String id, bool isCompleted, int currentStreak) {
    int newStreak = isCompleted
        ? currentStreak + 1
        : (currentStreak > 0 ? currentStreak - 1 : 0);
    return habitsCollection.doc(id).update({
      'isCompleted': isCompleted,
      'streak': newStreak,
    });
  }

  // BORRAR HÁBITO (Para tu función de deslizar)
  Future<void> deleteHabit(String id) {
    return habitsCollection.doc(id).delete();
  }
}
