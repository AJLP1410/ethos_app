import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; //
import '../services/database_service.dart'; //
import '../models/habit_model.dart';
import '../widgets/habit_card.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // REEMPLAZAMOS LA LISTA LOCAL POR EL SERVICIO DE FIREBASE
  final DatabaseService _db = DatabaseService();
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    // Mantenemos tu animación de respiración original
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0.9,
      upperBound: 1.1,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // --- TUS WIDGETS DE INTERFAZ (DISEÑO INTACTO) ---

  Widget _buildAuraCoach(List<Habit> habits) {
    // Obtenemos tu nombre de Google (solo el primero para que se vea bien)
    String? fullUserName = FirebaseAuth.instance.currentUser?.displayName;
    String firstName =
        fullUserName != null ? fullUserName.split(' ')[0] : "Soldado";
    double progress = habits.isEmpty
        ? 0.0
        : habits.where((h) => h.isCompleted).length / habits.length;
    String message;
    if (habits.isEmpty) {
      message =
          "Aura: $firstName, No hay misiones. Define tu destino, soldado.";
    } else if (progress == 0) {
      message = "Aura: $firstName, La inacción es debilidad. ¡Inicia la forja!";
    } else if (progress < 1.0) {
      message =
          "Aura: $firstName, Bien hecho. El carácter se forja con cada acción.";
    } else {
      message =
          "Aura: $firstName, ¡MISIÓN CUMPLIDA! TU CARÁCTER SE HA FORJADO HOY.";
    }
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.cyan.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.2)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.cyanAccent,
          fontStyle: FontStyle.italic,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildProgressBar(List<Habit> habits) {
    double progress = habits.isEmpty
        ? 0.0
        : habits.where((h) => h.isCompleted).length / habits.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("PROGRESO DIARIO",
                  style: TextStyle(color: Colors.white38, fontSize: 12)),
              Text("${(progress * 100).toInt()}%",
                  style: const TextStyle(
                      color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white10,
              color: Colors.cyanAccent,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Habit>>(
        stream: _db.habits,
        builder: (context, snapshot) {
          final habits = snapshot.data ?? [];
          double progress = habits.isEmpty
              ? 0.0
              : habits.where((h) => h.isCompleted).length / habits.length;
          bool allDone = progress == 1.0 && habits.isNotEmpty;
          return Scaffold(
            backgroundColor: const Color(0xFF0A0E21),
            appBar: AppBar(
              title: Text("ETHOS",
                  style: TextStyle(
                      letterSpacing: 4,
                      fontWeight: FontWeight.bold,
                      color: allDone ? Colors.cyanAccent : Colors.white,
                      shadows: allDone
                          ? [Shadow(color: Colors.cyanAccent, blurRadius: 15)]
                          : null)),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(FirebaseAuth
                            .instance.currentUser?.photoURL ??
                        'https://ui-avatars.com/api/?name=${FirebaseAuth.instance.currentUser?.displayName}'),
                  ),
                ),
                IconButton(
                  icon:
                      const Icon(Icons.logout, size: 20, color: Colors.white38),
                  onPressed: () => FirebaseAuth.instance.signOut(),
                ),
              ],
            ),
            // CAMBIAMOS A STREAMBUILDER PARA CONECTAR CON TU BASE EN USA
            body: StreamBuilder<List<Habit>>(
              stream: _db.habits,
              builder: (context, snapshot) {
                final habits = snapshot.data ?? [];

                return Column(
                  children: [
                    _buildAuraCoach(habits),
                    _buildProgressBar(habits),
                    const SizedBox(height: 20),
                    Expanded(
                      child: habits.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              itemCount: habits.length,
                              itemBuilder: (context, index) {
                                return _buildHabitItem(habits[index]);
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.cyanAccent,
              elevation: 10,
              child: const Icon(Icons.add, color: Color(0xFF0A0E21), size: 30),
              onPressed: () => _showAddHabitDialog(context),
            ),
          );
        });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _pulseController,
            child: Image.asset(
              'assets/icon/logo.png', // Tu logo configurado
              height: 180,
              opacity: const AlwaysStoppedAnimation(0.3),
            ),
          ),
          const SizedBox(height: 25),
          const Text("SIN MISIONES ACTIVAS",
              style: TextStyle(
                  color: Colors.white24,
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text("Forja tu carácter añadiendo un hábito hoy.",
              style: TextStyle(color: Colors.white12)),
        ],
      ),
    );
  }

  Widget _buildHabitItem(Habit habit) {
    return Dismissible(
      key: Key(habit.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 25),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 30),
      ),
      // SE BORRA DIRECTO DE FIRESTORE
      onDismissed: (direction) => _db.deleteHabit(habit.id),
      child: HabitCard(
        title: habit.name,
        streak: habit.streak,
        isDone: habit.isCompleted,
        onTap: () {
          // 1. Agregamos la vibración aquí
          HapticFeedback.lightImpact();

          // 2. Tu lógica actual de base de datos
          _db.updateHabitStatus(habit.id, !habit.isCompleted, habit.streak);
        },
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F38),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("NUEVA MISIÓN",
            style: TextStyle(color: Colors.white, letterSpacing: 2)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Ej: Estudiar Flutter USC",
            hintStyle: TextStyle(color: Colors.white10),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.cyanAccent)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCELAR",
                  style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _db.addHabit(controller.text); // GUARDA EN LA NUBE
                Navigator.pop(context);
              }
            },
            child: const Text("FORJAR",
                style: TextStyle(
                    color: Color(0xFF0A0E21), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
