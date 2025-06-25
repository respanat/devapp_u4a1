import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:actividad4/models/vehiculo.dart';

class VehiculoService {
  final String _baseUrl =
      'https://vehiculosapp-37a3f-default-rtdb.firebaseio.com/actividad4/Vehiculos';
  final FirebaseAuth _auth;

  VehiculoService({required FirebaseAuth auth}) : _auth = auth;

  Future<String?> _getIdToken() async {
    return await _auth.currentUser?.getIdToken();
  }

  /// Recupera una lista de vehículos de la base de datos.
  /// Método HTTP: GET
  /// Puede requerir autenticación si 'requireAuth' es true.
  Future<List<Vehiculo>> getVehiculos({bool requireAuth = false}) async {
    String? token = null;

    if (requireAuth) {
      token = await _getIdToken();
      if (token == null) {
        throw Exception('No hay token de autenticación disponible.');
      }
    }

    final url = Uri.parse(
      '$_baseUrl.json${token != null ? '?auth=$token' : ''}',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final dynamic decodedData = json.decode(response.body);

      if (decodedData == null) {
        return [];
      }

      if (decodedData is! Map<String, dynamic>) {
        throw Exception(
          'Formato de datos inesperado para Vehiculos en Firebase.',
        );
      }

      final Map<String, dynamic> data = decodedData;

      List<Vehiculo> vehicles = [];
      data.forEach((key, value) {
        if (value is Map<dynamic, dynamic>) {
          try {
            final vehicle = Vehiculo.fromJson(value);
            vehicle.id = key;
            vehicles.add(vehicle);
          } catch (e) {
            // Manejo de errores de parseo individual, no se muestra al usuario.
          }
        }
      });
      return vehicles;
    } else {
      throw Exception(
        'Fallo al intentar cargar vehiculos: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Crea un nuevo vehículo en la base de datos o reemplaza uno existente si el ID coincide.
  /// Método HTTP: PUT
  /// Requiere autenticación.
  Future<Vehiculo> createVehicle(Vehiculo vehicle) async {
    final token = await _getIdToken();
    if (token == null) {
      throw Exception('No hay token de autenticación disponible.');
    }
    final response = await http.put(
      Uri.parse('$_baseUrl/${vehicle.id}.json?auth=$token'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(vehicle.toJson()),
    );

    if (response.statusCode == 200) {
      return Vehiculo.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Falla al crear vehiculo: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Actualiza un vehículo existente en la base de datos.
  /// Método HTTP: PUT
  /// Requiere autenticación.
  Future<Vehiculo> updateVehicle(Vehiculo vehicle) async {
    final token = await _getIdToken();
    if (token == null) {
      throw Exception('No hay token de actualización disponible.');
    }
    final response = await http.put(
      Uri.parse('$_baseUrl/${vehicle.id}.json?auth=$token'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(vehicle.toJson()),
    );

    if (response.statusCode == 200) {
      return Vehiculo.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Fallo al intentar actualizar vehículo: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Elimina un vehículo de la base de datos.
  /// Método HTTP: DELETE
  /// Requiere autenticación.
  Future<void> deleteVehicle(String vehicleId) async {
    final token = await _getIdToken();
    if (token == null) {
      throw Exception('No hay token de autenticación disponible.');
    }
    final response = await http.delete(
      Uri.parse('$_baseUrl/$vehicleId.json?auth=$token'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Fallo al intentar borrar vehículo: ${response.statusCode} ${response.body}',
      );
    }
  }
}
