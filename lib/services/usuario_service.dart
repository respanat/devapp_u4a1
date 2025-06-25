import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:actividad4/models/usuario.dart';

class UsuarioService {
  final String _baseUrl =
      'https://vehiculosapp-37a3f-default-rtdb.firebaseio.com/actividad4/Usuario';
  final FirebaseAuth _auth;

  UsuarioService({required FirebaseAuth auth}) : _auth = auth;

  Future<String?> _getIdToken() async {
    return await _auth.currentUser?.getIdToken();
  }

  /// Recupera una lista de usuarios de la base de datos.
  /// Puede requerir autenticación si 'requireAuth' es true.
  Future<List<Usuario>> getUsers({bool requireAuth = false}) async {
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
          'Formato de datos inesperado para Usuarios en Firebase.',
        );
      }

      final Map<String, dynamic> data = decodedData;

      List<Usuario> users = [];
      data.forEach((key, value) {
        if (value is Map<dynamic, dynamic>) {
          try {
            final user = Usuario.fromJson(value);
            user.id = key;
            users.add(user);
          } catch (e) {
            // Manejo de errores de parseo individual, no se muestra al usuario.
          }
        }
      });
      return users;
    } else {
      throw Exception(
        'Fallo al intentar cargar Usuarios: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Crea un nuevo usuario en la base de datos. Requiere autenticación.
  Future<Usuario> createUser(Usuario user) async {
    final token = await _getIdToken();
    if (token == null) {
      throw Exception('No hay token de autenticación disponible.');
    }
    final response = await http.put(
      Uri.parse('$_baseUrl/${user.id}.json?auth=$token'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(user.toJson()),
    );

    if (response.statusCode == 200) {
      return Usuario.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Fallo al intentar crear usuario: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Actualiza un usuario existente en la base de datos. Requiere autenticación.
  Future<Usuario> updateUser(Usuario user) async {
    final token = await _getIdToken();
    if (token == null) {
      throw Exception('No hay token de autenticación disponible.');
    }
    final response = await http.put(
      Uri.parse('$_baseUrl/${user.id}.json?auth=$token'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(user.toJson()),
    );

    if (response.statusCode == 200) {
      return Usuario.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Fallo al intentar actualizar usuario: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Elimina un usuario de la base de datos. Requiere autenticación.
  Future<void> deleteUser(String userId) async {
    final token = await _getIdToken();
    if (token == null) {
      throw Exception('No hay token de autenticación disponible.');
    }
    final response = await http.delete(
      Uri.parse('$_baseUrl/$userId.json?auth=$token'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Fallo al intentar borrar usuario: ${response.statusCode} ${response.body}',
      );
    }
  }
}
