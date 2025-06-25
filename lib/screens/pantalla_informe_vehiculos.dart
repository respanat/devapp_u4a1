import 'package:flutter/material.dart';
import 'package:actividad4/models/vehiculo.dart';
import 'dart:async';
import 'package:actividad4/services/vehiculo_service.dart';

class PantallaInformeVehiculos extends StatefulWidget {
  final VehiculoService vehiculoService;

  const PantallaInformeVehiculos({
    super.key,
    required this.vehiculoService,
    required database,
  });

  @override
  State<PantallaInformeVehiculos> createState() => _VehicleReportScreenState();
}

class _VehicleReportScreenState extends State<PantallaInformeVehiculos> {
  final TextEditingController _searchController = TextEditingController();
  List<Vehiculo> _allVehiclesLoaded = [];
  List<Vehiculo> _filteredVehicles = [];
  String _reportMessage = "Ingresa un parámetro y genera el informe.";
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final fetchedVehicles = await widget.vehiculoService.getVehiculos();
      if (!mounted) return;
      setState(() {
        _allVehiclesLoaded = fetchedVehicles;
        _isLoading = false;
        if (_searchController.text.isNotEmpty) {
          _generateReport();
        } else {
          _filteredVehicles = List.from(_allVehiclesLoaded);
          _reportMessage = "Total de vehículos: ${_allVehiclesLoaded.length}.";
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Error al cargar vehículos: ${e.toString()}";
      });
      _showSnackBar(_errorMessage!);
      print('Error al cargar vehículos: $e'); // Para depuración
    }
  }

  void _generateReport() {
    final parameter = _searchController.text.trim();
    if (parameter.isNotEmpty) {
      final filterLower = parameter.toLowerCase();
      final results = _allVehiclesLoaded.where((vehiculo) {
        return vehiculo.placa.toLowerCase().contains(filterLower) ||
            vehiculo.marca.toLowerCase().contains(filterLower) ||
            vehiculo.modelo.toLowerCase().contains(filterLower) ||
            vehiculo.version.toLowerCase().contains(filterLower) ||
            vehiculo.color.toLowerCase().contains(filterLower) ||
            vehiculo.combustible.toLowerCase().contains(filterLower) ||
            vehiculo.categoria.toLowerCase().contains(filterLower) ||
            vehiculo.numPuestos.toString().toLowerCase().contains(
              filterLower,
            ) ||
            vehiculo.numPuertas.toString().toLowerCase().contains(
              filterLower,
            ) ||
            vehiculo.kilometros.toString().toLowerCase().contains(
              filterLower,
            ) ||
            vehiculo.cilindraje.toString().toLowerCase().contains(filterLower);
      }).toList();

      if (!mounted) return;
      setState(() {
        _filteredVehicles = results;
        _reportMessage =
            "Resultados para: '$parameter'. ${_filteredVehicles.length} coincidencias.";
      });
    } else {
      if (!mounted) return;
      setState(() {
        _filteredVehicles = List.from(_allVehiclesLoaded);
        _reportMessage = "Total de vehículos: ${_allVehiclesLoaded.length}.";
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
        title: const Text("Informe de Vehículos"),
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
                labelText:
                    "Parámetro de Búsqueda (Placa, Marca, Modelo, Color, Categoría, etc.)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (_) => _generateReport(),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _generateReport,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text("Generar Informe / Mostrar Todos"),
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
                "Total de vehículos registrados: ${_allVehiclesLoaded.length}",
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

              if (_filteredVehicles.isNotEmpty)
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
                      columnSpacing: 12,
                      dataRowMinHeight: 40,
                      dataRowMaxHeight: 60,
                      columns: const <DataColumn>[
                        DataColumn(
                          label: Expanded(
                            child: Text(
                              'Placa',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Text(
                              'Marca',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Text(
                              'Modelo',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Text(
                              'Color',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Text(
                              'Puestos',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Text(
                              'Puertas',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Text(
                              'Combustible',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Text(
                              'Km',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Text(
                              'Cilindraje',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Text(
                              'Categoría',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                      rows: _filteredVehicles.map((vehiculo) {
                        return DataRow(
                          cells: <DataCell>[
                            DataCell(Text(vehiculo.placa)),
                            DataCell(Text(vehiculo.marca)),
                            DataCell(Text(vehiculo.modelo)),
                            DataCell(Text(vehiculo.color)),
                            DataCell(Text(vehiculo.numPuestos.toString())),
                            DataCell(Text(vehiculo.numPuertas.toString())),
                            DataCell(Text(vehiculo.combustible)),
                            DataCell(
                              Text(vehiculo.kilometros.toStringAsFixed(0)),
                            ),
                            DataCell(
                              Text(vehiculo.cilindraje.toStringAsFixed(1)),
                            ),
                            DataCell(Text(vehiculo.categoria)),
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
                    "No se encontraron vehículos que coincidan con el parámetro de búsqueda.",
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
