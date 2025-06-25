import 'package:flutter/material.dart';
import 'package:actividad4/models/usuario.dart';
import 'package:actividad4/services/usuario_service.dart';
import 'dart:async';

class PantallaGestionarUsuarios extends StatefulWidget {
  final UsuarioService usuarioService;

  const PantallaGestionarUsuarios({
    super.key,
    required this.usuarioService,
    required database,
  });

  @override
  State<PantallaGestionarUsuarios> createState() =>
      _GestionUsuariosScreenState();
}

class _GestionUsuariosScreenState extends State<PantallaGestionarUsuarios> {
  List<Usuario> _usuarios = [];
  String? _errorMessage;
  bool _isLoading = false;
  Usuario? _selectedUser;

  final TextEditingController _usernameInputController =
      TextEditingController();
  final TextEditingController _nombreInputController = TextEditingController();
  final TextEditingController _emailInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final fetchedUsers = await widget.usuarioService.getUsers();
      if (!mounted) return;
      setState(() {
        _usuarios = fetchedUsers;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Error al cargar usuarios: ${e.toString()}";
      });
      _showSnackBar(_errorMessage!);
      print('Error al cargar usuarios: $e');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _clearForm() {
    _selectedUser = null;
    _usernameInputController.clear();
    _nombreInputController.clear();
    _emailInputController.clear();
  }

  // --- Lógica de Edición de Usuario ---
  void _editUser(Usuario userToEdit) {
    _selectedUser = userToEdit;
    _usernameInputController.text = userToEdit.username;
    _nombreInputController.text = userToEdit.nombre;
    _emailInputController.text = userToEdit.email;
    _showEditUserDialog();
  }

  // --- Lógica de Eliminación de Usuario ---
  Future<void> _deleteUser(Usuario userToDelete) async {
    try {
      if (userToDelete.id.isNotEmpty) {
        await widget.usuarioService.deleteUser(userToDelete.id);
        _showSnackBar("Usuario eliminado exitosamente");
        await _loadUsers();
      } else {
        _showSnackBar("Error: ID de usuario no válido para eliminar.");
      }
    } catch (e) {
      _showSnackBar("Error al eliminar usuario: ${e.toString()}");
      print('Error al eliminar usuario: $e'); // Para depuración
    }
  }

  // --- Lógica para Guardar Cambios (Editar) ---
  Future<void> _saveUserChanges(BuildContext dialogContext) async {
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
      await widget.usuarioService.updateUser(updatedUser);
      _showSnackBar("Usuario actualizado exitosamente");
      if (mounted) {
        Navigator.of(dialogContext).pop();
      }
      _clearForm();
      await _loadUsers();
    } catch (e) {
      _showSnackBar("Error al actualizar usuario: ${e.toString()}");
      print('Error al actualizar usuario: $e'); // Para depuración
    }
  }

  // --- Diálogo de Edición de Usuario ---
  void _showEditUserDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (didPop) return;
            _clearForm();
            Navigator.of(dialogContext).pop();
          },
          child: AlertDialog(
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
                  _clearForm();
                  Navigator.of(dialogContext).pop();
                },
              ),
              ElevatedButton(
                onPressed: () => _saveUserChanges(dialogContext),
                child: const Text("Guardar Cambios"),
              ),
            ],
          ),
        );
      },
    );
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
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              )
            else if (_usuarios.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    "No hay usuarios registrados.",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
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
                      showActions: true,
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(),
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
