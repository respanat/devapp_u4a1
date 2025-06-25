import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:actividad4/pantalla_gestionar_usuarios.dart';
import 'package:actividad4/pantalla_informe_usuarios.dart';
import 'package:actividad4/pantalla_gestionar_vehiculos.dart';
import 'package:actividad4/pantalla_informe_vehiculos.dart';
import 'package:actividad4/pantalla_tablero_principal.dart';

class MainNavigation extends StatelessWidget {
  final FirebaseAuth auth;
  final FirebaseDatabase database;
  final VoidCallback onLogout;

  const MainNavigation({
    super.key,
    required this.auth,
    required this.database,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Actividad 4 - Flutter',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blueAccent),
      initialRoute: '/', // La ruta inicial de la navegación
      routes: {
        '/': (context) => MainDashboardScreen(
          auth: auth,
          database: database,
          onLogout: onLogout,
        ),
        '/manage_vehicles': (context) => PantallaGestionarVehiculos(
          database: database,
          onBack: () => Navigator.of(context).pop(),
        ),
        '/manage_users': (context) =>
            PantallaGestionarUsuarios(database: database),
        '/user_report': (context) =>
            PantallaInformeUsuarios(database: database),
        '/vehicle_report': (context) =>
            PantallaInformeVehiculos(database: database),
      },
    );
  }
}
