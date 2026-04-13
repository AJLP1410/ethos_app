import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
      lowerBound: 0.85,
      upperBound: 1.0,
    )..repeat(reverse: true);
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      // Configuración específica para Web/Desktop
      final GoogleSignIn googleSignIn = GoogleSignIn(
          clientId:
              '222242968460-p0mqnqtpa4svttra3nm4pmf4hnrrhm5g.apps.googleusercontent.com');

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print("ERROR EN LA FORJA: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al conectar: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF1A1F38), Color(0xFF0A0E21)],
            radius: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            ScaleTransition(
              scale: _pulseController,
              child: Image.asset('assets/icon/logo.png', height: 220),
            ),
            const SizedBox(height: 30),
            const Text(
              "ETHOS",
              style: TextStyle(
                fontSize: 40,
                letterSpacing: 10,
                fontWeight: FontWeight.bold,
                color: Colors.cyanAccent,
                shadows: [Shadow(color: Colors.cyanAccent, blurRadius: 20)],
              ),
            ),
            const Text(
              "FORJA TU DESTINO",
              style: TextStyle(color: Colors.white24, letterSpacing: 3),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.cyanAccent)
                  : OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.cyanAccent,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _signInWithGoogle,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.login, color: Colors.cyanAccent),
                          SizedBox(width: 15),
                          Text(
                            "INGRESAR CON GOOGLE",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
