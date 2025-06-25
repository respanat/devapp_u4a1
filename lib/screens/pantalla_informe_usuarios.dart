import 'package:flutter/material.dart';
import 'package:actividad4/models/usuario.dart';
import 'dart:async';
import 'package:actividad4/services/usuario_service.dart';

class PantallaInformeUsuarios extends StatefulWidget {
  final UsuarioService usuarioService;

  const PantallaInformeUsuarios({
    super.key,
    required this.usuarioService,
    required database,
  });

  @override
  State<PantallaInformeUsuarios> createState() => _UserReportScreenState();
}

class _UserReportScreenState extends State<PantallaInformeUsuarios> {
  final TextEditingController _searchController = TextEditingController();
  List<Usuario> _allUsersLoaded = [];
  List<Usuario> _filteredUsers = [];
  String _reportMessage = "Ingresa un parámetro y genera el informe.";
  bool _isLoading = false;
  String? _errorMessage;

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
        _allUsersLoaded = fetchedUsers;
        _isLoading = false;
        if (_searchController.text.isNotEmpty) {
          _generateReport();
        } else {
          _filteredUsers = List.from(_allUsersLoaded);
          _reportMessage = "Total de usuarios: ${_allUsersLoaded.length}.";
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Error al cargar usuarios: ${e.toString()}";
      });
      _showSnackBar(_errorMessage!);
      print('Error al cargar usuarios: $e'); // Para depuración
    }
  }

  void _generateReport() {
    final parameter = _searchController.text.trim();
    if (parameter.isNotEmpty) {
      final results = _allUsersLoaded.where((user) {
        return user.nombre.toLowerCase().contains(parameter.toLowerCase()) ||
            user.username.toLowerCase().contains(parameter.toLowerCase()) ||
            user.email.toLowerCase().contains(parameter.toLowerCase());
      }).toList();

      if (!mounted) return;
      setState(() {
        _filteredUsers = results;
        _reportMessage =
            "Informe de usuarios para: '$parameter'. ${_filteredUsers.length} resultados.";
      });
    } else {
      if (!mounted) return;
      setState(() {
        _filteredUsers = List.from(_allUsersLoaded);
        _reportMessage = "Total de usuarios: ${_allUsersLoaded.length}.";
      });
    }
  }

  // Función para mostrar SnackBar
  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Informe de Usuarios"),
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
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: "Parámetro de Búsqueda (Nombre, Email, Usuario)",
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _generateReport(),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _generateReport,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text("Generar Informe"),
            ),
            const SizedBox(height: 24.0),

            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),

            if (_isLoading)
              const CircularProgressIndicator()
            else ...[
              Text(
                "Total de usuarios registrados: ${_allUsersLoaded.length}",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              Text(
                _reportMessage,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
              if (_filteredUsers.isNotEmpty)
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.resolveWith<Color?>((
                        Set<WidgetState> states,
                      ) {
                        return Theme.of(context).primaryColor.withOpacity(0.1);
                      }),
                      border: TableBorder.all(color: Colors.grey.shade300),
                      columnSpacing: 20,
                      columns: const <DataColumn>[
                        DataColumn(
                          label: Expanded(
                            child: Text(
                              'Nombre',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Text(
                              'Usuario',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Text(
                              'Correo',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                      rows: _filteredUsers.map((usuario) {
                        return DataRow(
                          cells: <DataCell>[
                            DataCell(Text(usuario.nombre)),
                            DataCell(Text(usuario.username)),
                            DataCell(Text(usuario.email)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                )
              else if (_searchController.text.isNotEmpty && !_isLoading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "No se encontraron usuarios que coincidan con el parámetro de búsqueda.",
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
