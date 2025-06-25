import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:actividad4/screens/pantalla_autorizacion.dart';
import 'package:actividad4/screens/pantalla_navegacion_principal.dart';
import 'package:actividad4/services/usuario_service.dart';
import 'package:actividad4/services/vehiculo_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UsuarioService _usuarioService = UsuarioService(
    auth: FirebaseAuth.instance,
  );
  final VehiculoService _vehiculoService = VehiculoService(
    auth: FirebaseAuth.instance,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Actividad 4 Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StreamBuilder<User?>(
        stream: _auth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            return MainNavigation(
              auth: _auth,
              usuarioService: _usuarioService,
              vehiculoService: _vehiculoService,
              onLogout: () async {
                try {
                  await _auth.signOut();
                  print("Sesión cerrada exitosamente.");
                } catch (e) {
                  print("Error al cerrar sesión: $e");
                }
              },
              database: null,
            );
          } else {
            return AuthScreen(
              auth: _auth,
              usuarioService: _usuarioService,
              vehiculoService: _vehiculoService,
              onAuthSuccess: () {},
              database: null,
            );
          }
        },
      ),
    );
  }
}
