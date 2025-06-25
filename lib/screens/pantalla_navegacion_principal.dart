import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:actividad4/services/usuario_service.dart';
import 'package:actividad4/services/vehiculo_service.dart';
import 'package:actividad4/screens/pantalla_gestionar_usuarios.dart';
import 'package:actividad4/screens/pantalla_informe_usuarios.dart';
import 'package:actividad4/screens/pantalla_gestionar_vehiculos.dart';
import 'package:actividad4/screens/pantalla_informe_vehiculos.dart';
import 'package:actividad4/screens/pantalla_tablero_principal.dart';

class MainNavigation extends StatelessWidget {
  final FirebaseAuth auth;
  final VoidCallback onLogout;
  final UsuarioService usuarioService;
  final VehiculoService vehiculoService;

  const MainNavigation({
    super.key,
    required this.auth,
    required this.onLogout,
    required this.usuarioService,
    required this.vehiculoService,
    required database,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Actividad 4 - DevApp2025',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blueAccent),
      initialRoute: '/',
      routes: {
        '/': (context) => MainDashboardScreen(
          auth: auth,
          usuarioService: usuarioService,
          vehiculoService: vehiculoService,
          onLogout: onLogout,
          database: null,
        ),
        '/gestion_vehiculos': (context) => PantallaGestionarVehiculos(
          vehiculoService: vehiculoService,
          onBack: () => Navigator.of(context).pop(),
          database: null,
        ),
        '/gestion_usuarios': (context) => PantallaGestionarUsuarios(
          usuarioService: usuarioService,
          database: null,
        ),
        '/reporte_usuarios': (context) => PantallaInformeUsuarios(
          usuarioService: usuarioService,
          database: null,
        ),
        '/reporte_vehiculos': (context) => PantallaInformeVehiculos(
          vehiculoService: vehiculoService,
          database: null,
        ),
      },
    );
  }
}
