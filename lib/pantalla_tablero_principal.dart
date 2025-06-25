import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'dart:async';

class MainDashboardScreen extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseDatabase database;
  final VoidCallback onLogout;

  const MainDashboardScreen({
    super.key,
    required this.auth,
    required this.database,
    required this.onLogout,
  });

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  // --- Lógica del Sensor de Proximidad ---
  bool _isProximityDetected = false;
  StreamSubscription<int>? _proximitySubscription;

  // --- Lógica del Sensor de Acelerómetro ---
  bool _showAccelerometerMessage = false;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  final double _shakeThresholdGravity =
      12.0; // Fuerza de gravedad mínima para una "sacudida"
  final int _shakeSlopTimeMs =
      500; // Tiempo máximo entre dos sacudidas consecutivas
  final int _shakeCountNeeded = 2; // Número de sacudidas necesarias

  int _mShakeCount = 0;
  int _mShakeTimestamp = 0;

  // --- Lógica del Sensor de Campo Magnético (Magnetómetro) ---
  bool _showMagnetometerMessage = false;
  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;
  double _initialMagneticFieldStrength = 0.0;
  final double _magneticFieldThreshold =
      80.0; // Umbral de cambio para detectar un "evento"

  @override
  void initState() {
    super.initState();
    _initProximitySensor();
    _initAccelerometerSensor();
    _initMagnetometerSensor(); // Inicializa el nuevo sensor
  }

  void _initProximitySensor() {
    _proximitySubscription = ProximitySensor.events.listen((int event) {
      setState(() {
        _isProximityDetected = event > 0;
      });
    });
  }

  void _initAccelerometerSensor() {
    _accelerometerSubscription = SensorsPlatform.instance.accelerometerEvents
        .listen((AccelerometerEvent event) {
          final double x = event.x;
          final double y = event.y;
          final double z = event.z;

          final double gForce = (x * x + y * y + z * z); // Magnitud cuadrada

          if (gForce > _shakeThresholdGravity * _shakeThresholdGravity) {
            final int now = DateTime.now().millisecondsSinceEpoch;

            if (_mShakeTimestamp + _shakeSlopTimeMs > now) {
              return;
            }

            if (_mShakeTimestamp + (2 * _shakeSlopTimeMs) < now) {
              _mShakeCount = 0;
            }

            _mShakeTimestamp = now;
            _mShakeCount++;

            if (_mShakeCount >= _shakeCountNeeded) {
              setState(() {
                _showAccelerometerMessage = true;
              });
              _mShakeCount = 0;
              Future.delayed(const Duration(seconds: 3), () {
                if (mounted) {
                  setState(() {
                    _showAccelerometerMessage = false;
                  });
                }
              });
            }
          }
        });
  }

  void _initMagnetometerSensor() {
    _magnetometerSubscription = SensorsPlatform.instance.magnetometerEvents
        .take(1)
        .listen((MagnetometerEvent event) {
          _initialMagneticFieldStrength = _calculateMagneticFieldStrength(
            event.x,
            event.y,
            event.z,
          );
          print(
            'Initial magnetic field: $_initialMagneticFieldStrength µT',
          ); // Para depuración

          _magnetometerSubscription?.cancel(); // Cancela la suscripción inicial
          _magnetometerSubscription = SensorsPlatform
              .instance
              .magnetometerEvents
              .listen((MagnetometerEvent event) {
                final double currentStrength = _calculateMagneticFieldStrength(
                  event.x,
                  event.y,
                  event.z,
                );

                if ((currentStrength - _initialMagneticFieldStrength).abs() >
                    _magneticFieldThreshold) {
                  setState(() {
                    _showMagnetometerMessage = true;
                  });
                  // Después de 3 segundos, oculta el mensaje y restablece el valor inicial
                  Future.delayed(const Duration(seconds: 3), () {
                    if (mounted) {
                      setState(() {
                        _showMagnetometerMessage = false;
                        _initialMagneticFieldStrength =
                            currentStrength; // Actualiza el valor base
                      });
                    }
                  });
                }
              });
        });
  }

  double _calculateMagneticFieldStrength(double x, double y, double z) {
    return (x * x + y * y + z * z); // Magnitud cuadrada para comparación
    // return Math.sqrt(x * x + y * y + z * z); // Magnitud real si se necesita
  }

  @override
  void dispose() {
    _proximitySubscription?.cancel();
    _accelerometerSubscription?.cancel();
    _magnetometerSubscription
        ?.cancel(); // Cancela la suscripción del magnetómetro
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.auth.currentUser;
    final String userEmail = user?.email ?? "Desconocido";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Menú Principal"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                if (_isProximityDetected)
                  Text(
                    "Sensor de proximidad activado",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                if (_isProximityDetected) const SizedBox(height: 8.0),

                if (_showAccelerometerMessage)
                  Text(
                    "Sensor activado, reduzca el movimiento",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                if (_showAccelerometerMessage) const SizedBox(height: 8.0),

                if (_showMagnetometerMessage)
                  Text(
                    "Campo magnético alterado",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                if (_showMagnetometerMessage) const SizedBox(height: 8.0),

                Text(
                  "¡Hola, Bienvenido a la actividad 4 de Desarrollo de Apps!",
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0),
                Text(
                  "Verificado: $userEmail",
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24.0),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/manage_vehicles'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: const Text("Gestionar Vehículos"),
                  ),
                ),
                const SizedBox(height: 16.0),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/manage_users'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: const Text("Gestionar Usuarios"),
                  ),
                ),
                const SizedBox(height: 16.0),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/user_report'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: const Text("Generar Informe Usuarios"),
                  ),
                ),
                const SizedBox(height: 16.0),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/vehicle_report'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: const Text("Generar Informe Vehículos"),
                  ),
                ),
                const SizedBox(height: 32.0),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: widget.onLogout,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                    child: const Text("Cerrar Sesión"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
