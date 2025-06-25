import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:actividad4/models/usuario.dart';

class PantallaGestionarUsuarios extends StatefulWidget {
  final FirebaseDatabase database;

  const PantallaGestionarUsuarios({super.key, required this.database});

  @override
  State<PantallaGestionarUsuarios> createState() =>
      _GestionUsuariosScreenState();
}

class _GestionUsuariosScreenState extends State<PantallaGestionarUsuarios> {
  List<Usuario> _usuarios = [];
  String? _errorMessage;
  bool _showUserDialog = false;
  Usuario? _selectedUser;

  // Controladores para los campos del diálogo de edición
  final TextEditingController _usernameInputController =
      TextEditingController();
  final TextEditingController _nombreInputController = TextEditingController();
  final TextEditingController _emailInputController = TextEditingController();

  // Referencia a la base de datos
  late DatabaseReference _usersRef;
  late Stream<DatabaseEvent> _usersStream;

  @override
  void initState() {
    super.initState();
    _usersRef = widget.database.ref("actividad4/Usuario");
    _usersStream = _usersRef.onValue;
    _listenToUsers();
  }

  // Función para escuchar los cambios en la base de datos
  void _listenToUsers() {
    _usersStream.listen(
      (event) {
        final dataSnapshot = event.snapshot;
        if (dataSnapshot.exists && dataSnapshot.value != null) {
          final Map<dynamic, dynamic> usersMap =
              dataSnapshot.value as Map<dynamic, dynamic>;
          final List<Usuario> fetchedUsers = [];
          usersMap.forEach((key, value) {
            final user = Usuario.fromJson(value as Map<dynamic, dynamic>);
            user.id = key;
            fetchedUsers.add(user);
          });
          setState(() {
            _usuarios = fetchedUsers;
            _errorMessage = null;
          });
        } else {
          setState(() {
            _usuarios = [];
            _errorMessage = null;
          });
        }
      },
      onError: (error) {
        setState(() {
          _errorMessage = "Error al cargar usuarios: ${error.toString()}";
        });
        _showSnackBar(_errorMessage!);
        print('Error al cargar usuarios: $error'); // Para depuración
      },
    );
  }

  // Función para mostrar SnackBar (equivalente a Toast)
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // Función para limpiar el formulario del diálogo
  void _clearForm() {
    _selectedUser = null;
    _usernameInputController.clear();
    _nombreInputController.clear();
    _emailInputController.clear();
  }

  // --- Lógica de Edición de Usuario ---
  void _editUser(Usuario userToEdit) {
    setState(() {
      _selectedUser = userToEdit;
      _usernameInputController.text = userToEdit.username;
      _nombreInputController.text = userToEdit.nombre;
      _emailInputController.text = userToEdit.email;
      _showUserDialog = true;
    });
    _showEditUserDialog();
  }

  // --- Lógica de Eliminación de Usuario ---
  Future<void> _deleteUser(Usuario userToDelete) async {
    try {
      if (userToDelete.id.isNotEmpty) {
        await _usersRef.child(userToDelete.id).remove();
        _showSnackBar("Usuario eliminado exitosamente");
      } else {
        _showSnackBar("Error: ID de usuario no válido para eliminar.");
      }
    } catch (e) {
      _showSnackBar("Error al eliminar usuario: ${e.toString()}");
      print('Error al eliminar usuario: $e'); // Para depuración
    }
  }

  // --- Lógica para Guardar Cambios (Editar) ---
  Future<void> _saveUserChanges() async {
    if (_selectedUser == null) return;

    if (_usernameInputController.text.isEmpty ||
        _nombreInputController.text.isEmpty ||
        _emailInputController.text.isEmpty) {
      _showSnackBar("Por favor, complete todos los campos.");
      return;
    }

    final updatedUser = Usuario(
      id: _selectedUser!.id,
      username: _usernameInputController.text,
      nombre: _nombreInputController.text,
      email: _emailInputController.text,
      password: _selectedUser!.password,
    );

    try {
      await _usersRef.child(updatedUser.id).set(updatedUser.toJson());
      _showSnackBar("Usuario actualizado exitosamente");
      setState(() {
        _showUserDialog = false;
        _clearForm();
      });
    } catch (e) {
      _showSnackBar("Error al actualizar usuario: ${e.toString()}");
      print('Error al actualizar usuario: $e'); // Para depuración
    }
  }

  // --- Diálogo de Edición de Usuario ---
  void _showEditUserDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Editar Usuario"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _usernameInputController,
                  decoration: const InputDecoration(
                    labelText: "Nombre de Usuario",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8.0),
                TextField(
                  controller: _nombreInputController,
                  decoration: const InputDecoration(
                    labelText: "Nombre Completo",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8.0),
                TextField(
                  controller: _emailInputController,
                  decoration: const InputDecoration(
                    labelText: "Correo Electrónico",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _showUserDialog = false;
                  _clearForm();
                });
              },
            ),
            ElevatedButton(
              child: const Text("Guardar Cambios"),
              onPressed: () {
                _saveUserChanges();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ).then((_) {
      if (_showUserDialog) {
        setState(() {
          _showUserDialog = false;
          _clearForm();
        });
      }
    });
  }

  @override
  void dispose() {
    // Liberar los controladores de texto
    _usernameInputController.dispose();
    _nombreInputController.dispose();
    _emailInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestionar Usuarios"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Navega hacia atrás
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (_usuarios.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "No hay usuarios registrados.",
                  style: TextStyle(fontSize: 16),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _usuarios.length,
                  itemBuilder: (context, index) {
                    final usuario = _usuarios[index];
                    return UsuarioItem(
                      usuario: usuario,
                      onEdit: _editUser,
                      onDelete: _deleteUser,
                      showActions: true, // Mostrar acciones en esta pantalla
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const Divider(), // Separador entre elementos
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class UsuarioItem extends StatelessWidget {
  final Usuario usuario;
  final ValueChanged<Usuario> onEdit;
  final ValueChanged<Usuario> onDelete;
  final bool showActions;

  const UsuarioItem({
    super.key,
    required this.usuario,
    required this.onEdit,
    required this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Nombre: ${usuario.nombre}",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    "Usuario: ${usuario.username}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    "Email: ${usuario.email}",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (showActions)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => onEdit(usuario),
                    tooltip: "Editar Usuario",
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => onDelete(usuario),
                    tooltip: "Eliminar Usuario",
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
