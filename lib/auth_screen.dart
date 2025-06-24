import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:actividad4/models/usuario.dart';

class AuthScreen extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseDatabase database;
  final VoidCallback onAuthSuccess;

  const AuthScreen({
    Key? key,
    required this.auth,
    required this.database,
    required this.onAuthSuccess,
  }) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Controladores para los campos de texto
  final TextEditingController _usernameOrEmailController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameRegController = TextEditingController();
  final TextEditingController _emailRegController = TextEditingController();
  final TextEditingController _nombreRegController = TextEditingController();

  // Estado para alternar entre Login y Registro
  bool _isLogin = true;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // --- Lógica de Inicio de Sesión ---
  Future<void> _signIn() async {
    final usernameOrEmail = _usernameOrEmailController.text.trim();
    final password = _passwordController.text.trim();

    if (usernameOrEmail.isEmpty || password.isEmpty) {
      _showSnackBar("Por favor, ingresa nombre de usuario y contraseña.");
      return;
    }

    try {
      // Buscar el email asociado al nombre de usuario en la Realtime Database
      final usersRef = widget.database.ref("actividad3/Usuario");
      final snapshot = await usersRef
          .orderByChild("username")
          .equalTo(usernameOrEmail)
          .get();

      if (snapshot.exists && snapshot.value != null) {
        String? emailToAuth;
        final userData = snapshot.value as Map<dynamic, dynamic>;

        // Firebase puede devolver un mapa si hay múltiples resultados o un solo resultado.
        if (userData.keys.length == 1 &&
            userData.values.first is Map<dynamic, dynamic>) {
          emailToAuth =
              (userData.values.first as Map<dynamic, dynamic>)['email']
                  as String?;
        } else if (userData.isNotEmpty) {
          for (var entry in userData.entries) {
            final userMap = entry.value as Map<dynamic, dynamic>;
            if (userMap['username'] == usernameOrEmail) {
              emailToAuth = userMap['email'] as String?;
              break;
            }
          }
        }

        if (emailToAuth != null) {
          // Usar el email encontrado para autenticar con Firebase Auth
          await widget.auth.signInWithEmailAndPassword(
            email: emailToAuth,
            password: password,
          );
          _showSnackBar("Inicio de sesión exitoso.");
          widget.onAuthSuccess();
        } else {
          _showSnackBar(
            "Nombre de usuario no encontrado o email no disponible.",
          );
        }
      } else {
        _showSnackBar("Nombre de usuario no encontrado.");
      }
    } on FirebaseAuthException catch (e) {
      String message = "Error de inicio de sesión.";
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        message = "Credenciales incorrectas.";
      } else if (e.code == 'invalid-email') {
        message = "El formato del correo electrónico es inválido.";
      } else {
        message = "Error: ${e.message}";
      }
      _showSnackBar(message);
    } catch (e) {
      _showSnackBar("Ocurrió un error inesperado: $e");
    }
  }

  // --- Lógica de Registro ---
  Future<void> _signUp() async {
    final email = _emailRegController.text.trim();
    final password = _passwordController.text.trim();
    final username = _usernameRegController.text.trim();
    final nombre = _nombreRegController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        username.isEmpty ||
        nombre.isEmpty) {
      _showSnackBar("Por favor, complete todos los campos para el registro.");
      return;
    }

    try {
      UserCredential userCredential = await widget.auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        final userId = firebaseUser.uid;
        final newUser = Usuario(
          id: userId,
          username: username,
          password: "", // La contraseña no se guarda en Realtime DB
          nombre: nombre,
          email: email,
        );

        // Guarda la información adicional del usuario en Firebase Realtime Database
        await widget.database
            .ref("actividad3/Usuario")
            .child(userId)
            .set(newUser.toJson());
        _showSnackBar("Registro exitoso y datos de usuario guardados.");
        widget.onAuthSuccess(); // Llama al callback de éxito
      }
    } on FirebaseAuthException catch (e) {
      String message = "Error de registro.";
      if (e.code == 'weak-password') {
        message = 'La contraseña es demasiado débil.';
      } else if (e.code == 'email-already-in-use') {
        message = 'El correo electrónico ya está en uso.';
      } else if (e.code == 'invalid-email') {
        message = 'El formato del correo electrónico es inválido.';
      } else {
        message = "Error: ${e.message}";
      }
      _showSnackBar(message);
    } catch (e) {
      _showSnackBar("Ocurrió un error inesperado: $e");
    }
  }

  // --- Lógica de Restablecimiento de Contraseña ---
  Future<void> _resetPassword() async {
    final inputEmailForReset = _usernameOrEmailController.text
        .trim(); // Se asume que el usuario ingresó el email en el campo de login
    if (inputEmailForReset.isEmpty || !inputEmailForReset.contains('@')) {
      _showSnackBar(
        "Por favor, ingresa un correo electrónico válido para restablecer la contraseña.",
      );
      return;
    }

    try {
      await widget.auth.sendPasswordResetEmail(email: inputEmailForReset);
      _showSnackBar("Correo de restablecimiento enviado a $inputEmailForReset");
    } on FirebaseAuthException catch (e) {
      _showSnackBar("Error al enviar correo de restablecimiento: ${e.message}");
    } catch (e) {
      _showSnackBar("Ocurrió un error inesperado: $e");
    }
  }

  @override
  void dispose() {
    // libera los controladores de texto cuando el widget ya no es necesario
    _usernameOrEmailController.dispose();
    _passwordController.dispose();
    _usernameRegController.dispose();
    _emailRegController.dispose();
    _nombreRegController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? "Iniciar Sesión" : "Registrarse"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          // Permite scroll si el teclado cubre los campos
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _isLogin ? "Iniciar Sesión" : "Registrarse",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 32.0),

              // Campo para Nombre de Usuario (Login) o Correo Electrónico (Registro)
              TextField(
                controller: _isLogin
                    ? _usernameOrEmailController
                    : _emailRegController,
                decoration: InputDecoration(
                  labelText: _isLogin
                      ? "Nombre de Usuario"
                      : "Correo Electrónico",
                  border: const OutlineInputBorder(),
                ),
                keyboardType: _isLogin
                    ? TextInputType.text
                    : TextInputType.emailAddress,
              ),
              const SizedBox(height: 8.0),

              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: "Contraseña",
                  border: OutlineInputBorder(),
                ),
                obscureText: true, // Para ocultar la contraseña
                keyboardType: TextInputType.visiblePassword,
              ),
              const SizedBox(height: 16.0),

              if (!_isLogin) ...[
                // Campos adicionales para el registro
                TextField(
                  controller: _usernameRegController,
                  decoration: const InputDecoration(
                    labelText: "Nombre de Usuario (Registro)",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 8.0),

                TextField(
                  controller: _nombreRegController,
                  decoration: const InputDecoration(
                    labelText: "Nombre Completo (Registro)",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16.0),
              ],

              ElevatedButton(
                onPressed: _isLogin ? _signIn : _signUp,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: Text(_isLogin ? "Iniciar Sesión" : "Registrarse"),
              ),
              const SizedBox(height: 8.0),

              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                    // Limpiar campos al cambiar entre login y registro
                    _usernameOrEmailController.clear();
                    _passwordController.clear();
                    _usernameRegController.clear();
                    _emailRegController.clear();
                    _nombreRegController.clear();
                  });
                },
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: Text(
                  _isLogin
                      ? "¿No tienes cuenta? Regístrate"
                      : "¿Ya tienes cuenta? Inicia Sesión",
                ),
              ),

              if (_isLogin) ...[
                const SizedBox(height: 16.0),
                TextButton(
                  onPressed: _resetPassword,
                  style: TextButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text("¿Olvidaste tu contraseña?"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
