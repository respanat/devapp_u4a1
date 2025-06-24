import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseAuth auth;
  final FirebaseDatabase database;

  final VoidCallback? onLogout;

  const HomeScreen({
    Key? key,
    required this.auth,
    required this.database,
    this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bienvenido (HomeScreen)')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('¡Has iniciado sesión!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onLogout,
              child: const Text('Cerrar Sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
