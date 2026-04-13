import 'package:flutter/material.dart';

class HabitCard extends StatelessWidget {
  final String title;
  final int streak;
  final bool isDone;
  final VoidCallback onTap;

  const HabitCard({
    super.key,
    required this.title,
    required this.streak,
    required this.isDone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // Si está completado, brilla en cian; si no, es oscuro sutil
          color: isDone
              ? Colors.cyan.withOpacity(0.15)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDone ? Colors.cyanAccent : Colors.white10,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Racha: $streak días",
                  style: const TextStyle(color: Colors.white60),
                ),
              ],
            ),
            Icon(
              isDone ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isDone ? Colors.cyanAccent : Colors.white30,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}
