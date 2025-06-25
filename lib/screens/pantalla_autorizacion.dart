import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:actividad4/models/usuario.dart';
import 'package:actividad4/services/usuario_service.dart';
import 'package:actividad4/services/vehiculo_service.dart';

class AuthScreen extends StatefulWidget {
  final FirebaseAuth auth;
  final VoidCallback onAuthSuccess;
  final UsuarioService usuarioService;
  final VehiculoService vehiculoService;

  const AuthScreen({
    super.key,
    required this.auth,
    required this.onAuthSuccess,
    required this.usuarioService,
    required this.vehiculoService,
    database,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _usernameOrEmailController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameRegController = TextEditingController();
  final TextEditingController _emailRegController = TextEditingController();
  final TextEditingController _nombreRegController = TextEditingController();

  bool _isLogin = true;

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _signIn() async {
    final usernameOrEmail = _usernameOrEmailController.text.trim();
    final password = _passwordController.text.trim();

    if (usernameOrEmail.isEmpty || password.isEmpty) {
      _showSnackBar("Por favor, ingresa nombre de usuario y contraseña.");
      return;
    }

    try {
      final List<Usuario> allUsers = await widget.usuarioService.getUsers(
        requireAuth: false,
      );
      String? emailToAuth;

      for (var user in allUsers) {
        if (user.username.toLowerCase() == usernameOrEmail.toLowerCase()) {
          emailToAuth = user.email;
          break;
        }
      }

      if (emailToAuth != null) {
        UserCredential userCredential = await widget.auth
            .signInWithEmailAndPassword(email: emailToAuth, password: password);

        User? user = userCredential.user;
        if (user != null) {
          _showSnackBar("Inicio de sesión exitoso.");
          widget.onAuthSuccess();
        } else {
          _showSnackBar("Error interno al iniciar sesión.");
        }
      } else {
        _showSnackBar("Nombre de usuario no encontrado.");
      }
    } on FirebaseAuthException catch (e) {
      String message = "Error de inicio de sesión.";
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
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
      final List<Usuario> existingUsers = await widget.usuarioService.getUsers(
        requireAuth: false,
      );
      if (existingUsers.any(
        (user) => user.username.toLowerCase() == username.toLowerCase(),
      )) {
        _showSnackBar(
          "El nombre de usuario ya está en uso. Por favor, elige otro.",
        );
        return;
      }

      UserCredential userCredential = await widget.auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        final userId = firebaseUser.uid;
        final newUser = Usuario(
          id: userId,
          username: username,
          password: "",
          nombre: nombre,
          email: email,
        );

        await widget.usuarioService.createUser(newUser);

        _showSnackBar("Registro exitoso y datos de usuario guardados.");
        widget.onAuthSuccess();
      } else {
        _showSnackBar("Error interno al registrar usuario.");
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

  Future<void> _resetPassword() async {
    final inputEmailForReset = _usernameOrEmailController.text.trim();
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _isLogin ? "Iniciar Sesión" : "Registrarse",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 32.0),

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
                  border: const OutlineInputBorder(),
                ),
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
              ),
              const SizedBox(height: 16.0),

              if (!_isLogin) ...[
                TextField(
                  controller: _usernameRegController,
                  decoration: const InputDecoration(
                    labelText: "Nombre de Usuario (Registro)",
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 8.0),

                TextField(
                  controller: _nombreRegController,
                  decoration: const InputDecoration(
                    labelText: "Nombre Completo (Registro)",
                    border: const OutlineInputBorder(),
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
