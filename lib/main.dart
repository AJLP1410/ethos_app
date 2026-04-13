import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización de Firebase con tus credenciales
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const EthosApp());
}

class EthosApp extends StatelessWidget {
  const EthosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ethos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.cyanAccent,
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
      ),
      // --- SISTEMA DE SESIÓN INTELIGENTE ---
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Si ya hay una sesión activa, saltamos el login
          if (snapshot.hasData) {
            return HomeScreen();
          }
          // Si no, mostramos la pantalla de inicio
          return const LoginScreen();
        },
      ),
    );
  }
}
