import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:actividad4/models/vehiculo.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class PantallaGestionarVehiculos extends StatefulWidget {
  final FirebaseDatabase database;
  final VoidCallback onBack;

  const PantallaGestionarVehiculos({
    super.key,
    required this.database,
    required this.onBack,
  });

  @override
  State<PantallaGestionarVehiculos> createState() =>
      _ManageVehiclesScreenState();
}

class _ManageVehiclesScreenState extends State<PantallaGestionarVehiculos> {
  final List<Vehiculo> _vehicles = [];
  Vehiculo? _selectedVehicle;

  final TextEditingController _placaController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();
  final TextEditingController _versionController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _numPuestosController = TextEditingController();
  final TextEditingController _numPuertasController = TextEditingController();
  final TextEditingController _combustibleController = TextEditingController();
  final TextEditingController _kilometrosController = TextEditingController();
  final TextEditingController _cilindrajeController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();

  final Uuid _uuid = const Uuid();

  late DatabaseReference _vehiclesRef;
  StreamSubscription<DatabaseEvent>? _vehiclesSubscription;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _vehiclesRef = widget.database.ref("actividad4/Vehiculos");
    _listenToVehicles();
  }

  void _listenToVehicles() {
    _vehiclesSubscription = _vehiclesRef.onValue.listen(
      (event) {
        if (!mounted) {
          return;
        }

        final dataSnapshot = event.snapshot;
        if (dataSnapshot.exists && dataSnapshot.value != null) {
          final Map<dynamic, dynamic> vehiclesMap =
              dataSnapshot.value as Map<dynamic, dynamic>;
          _vehicles.clear();
          vehiclesMap.forEach((key, value) {
            final vehicle = Vehiculo.fromJson(value as Map<dynamic, dynamic>);
            vehicle.id = key;
            _vehicles.add(vehicle);
          });
          setState(() {});
        } else {
          setState(() {
            _vehicles.clear();
          });
        }
      },
      onError: (error) {
        if (!mounted) return;
        _showSnackBar("Error al cargar vehículos: ${error.toString()}");
        print('Error al cargar vehículos: $error');
      },
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _clearForm() {
    _selectedVehicle = null;
    _placaController.clear();
    _marcaController.clear();
    _modeloController.clear();
    _versionController.clear();
    _colorController.clear();
    _numPuestosController.clear();
    _numPuertasController.clear();
    _combustibleController.clear();
    _kilometrosController.clear();
    _cilindrajeController.clear();
    _categoriaController.clear();
    // Reset validation state
    _formKey.currentState?.reset();
  }

  void _editVehicle(Vehiculo vehicleToEdit) {
    _selectedVehicle = vehicleToEdit;
    _placaController.text = vehicleToEdit.placa;
    _marcaController.text = vehicleToEdit.marca;
    _modeloController.text = vehicleToEdit.modelo;
    _versionController.text = vehicleToEdit.version;
    _colorController.text = vehicleToEdit.color;
    _numPuestosController.text = vehicleToEdit.numPuestos.toString();
    _numPuertasController.text = vehicleToEdit.numPuertas.toString();
    _combustibleController.text = vehicleToEdit.combustible;
    _kilometrosController.text = vehicleToEdit.kilometros.toString();
    _cilindrajeController.text = vehicleToEdit.cilindraje.toString();
    _categoriaController.text = vehicleToEdit.categoria;
    _showVehicleFormDialog();
  }

  Future<void> _deleteVehicle(Vehiculo vehicleToDelete) async {
    try {
      if (vehicleToDelete.id.isNotEmpty) {
        await _vehiclesRef.child(vehicleToDelete.id).remove();
        _showSnackBar("Vehículo eliminado exitosamente");
      } else {
        _showSnackBar("Error: ID de vehículo no válido para eliminar.");
      }
    } catch (e) {
      _showSnackBar("Error al eliminar vehículo: ${e.toString()}");
      print('Error al eliminar vehículo: $e');
    }
  }

  Future<void> _saveVehicle(BuildContext dialogContext) async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar("Por favor, complete todos los campos obligatorios.");
      return;
    }

    final int? numPuestos = int.tryParse(_numPuestosController.text);
    final int? numPuertas = int.tryParse(_numPuertasController.text);
    final double? kilometros = double.tryParse(_kilometrosController.text);
    final double? cilindraje = double.tryParse(_cilindrajeController.text);

    if (numPuestos == null ||
        numPuertas == null ||
        kilometros == null ||
        cilindraje == null) {
      _showSnackBar("Los campos numéricos deben ser válidos.");
      return;
    }

    final newVehicle = Vehiculo(
      id: _selectedVehicle?.id ?? _uuid.v4(),
      placa: _placaController.text,
      marca: _marcaController.text,
      modelo: _modeloController.text,
      version: _versionController.text,
      color: _colorController.text,
      numPuestos: numPuestos,
      numPuertas: numPuertas,
      combustible: _combustibleController.text,
      kilometros: kilometros,
      cilindraje: cilindraje,
      categoria: _categoriaController.text,
    );

    try {
      await _vehiclesRef.child(newVehicle.id).set(newVehicle.toJson());
      _showSnackBar(
        _selectedVehicle == null
            ? "Vehículo añadido exitosamente"
            : "Vehículo actualizado exitosamente",
      );
      _clearForm();
      if (mounted) {
        Navigator.of(dialogContext).pop();
      }
    } catch (e) {
      _showSnackBar("Error al guardar vehículo: ${e.toString()}");
      print('Error al guardar vehículo: $e');
    }
  }

  void _showVehicleFormDialog() {
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
            title: Text(
              _selectedVehicle == null
                  ? "Añadir Nuevo Vehículo"
                  : "Editar Vehículo",
            ),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      controller: _placaController,
                      decoration: const InputDecoration(
                        labelText: "Placa",
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La placa es obligatoria';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _marcaController,
                      decoration: const InputDecoration(
                        labelText: "Marca",
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La marca es obligatoria';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _modeloController,
                      decoration: const InputDecoration(
                        labelText: "Modelo",
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El modelo es obligatorio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: _versionController,
                      decoration: const InputDecoration(
                        labelText: "Versión",
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: _colorController,
                      decoration: const InputDecoration(
                        labelText: "Color",
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _numPuestosController,
                      decoration: const InputDecoration(
                        labelText: "Num. Puestos",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null) {
                          return 'Debe ser un número entero';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _numPuertasController,
                      decoration: const InputDecoration(
                        labelText: "Num. Puertas",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null) {
                          return 'Debe ser un número entero';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: _combustibleController,
                      decoration: const InputDecoration(
                        labelText: "Combustible",
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _kilometrosController,
                      decoration: const InputDecoration(
                        labelText: "Kilómetros",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            double.tryParse(value) == null) {
                          return 'Debe ser un número válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _cilindrajeController,
                      decoration: const InputDecoration(
                        labelText: "Cilindraje",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            double.tryParse(value) == null) {
                          return 'Debe ser un número válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: _categoriaController,
                      decoration: const InputDecoration(
                        labelText: "Categoría",
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.done,
                    ),
                  ],
                ),
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
                onPressed: () => _saveVehicle(dialogContext),
                child: Text(
                  _selectedVehicle == null ? "Añadir" : "Guardar Cambios",
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _vehiclesSubscription?.cancel();
    _placaController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _versionController.dispose();
    _colorController.dispose();
    _numPuestosController.dispose();
    _numPuertasController.dispose();
    _combustibleController.dispose();
    _kilometrosController.dispose();
    _cilindrajeController.dispose();
    _categoriaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestión de Vehículos"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            if (_vehicles.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    "No hay vehículos registrados.",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _vehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = _vehicles[index];
                    return VehicleItem(
                      vehicle: vehicle,
                      onEdit: _editVehicle,
                      onDelete: _deleteVehicle,
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _clearForm();
          _showVehicleFormDialog();
        },
        tooltip: "Añadir Vehículo",
        child: const Icon(Icons.add),
      ),
    );
  }
}

class VehicleItem extends StatelessWidget {
  final Vehiculo vehicle;
  final ValueChanged<Vehiculo> onEdit;
  final ValueChanged<Vehiculo> onDelete;
  final bool showActions;

  const VehicleItem({
    super.key,
    required this.vehicle,
    required this.onEdit,
    required this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      elevation: 2.0,
      child: InkWell(
        onTap: () => onEdit(vehicle),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "${vehicle.marca} ${vehicle.modelo} (${vehicle.version})",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      "Placa: ${vehicle.placa}",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      "Color: ${vehicle.color}, Puestos: ${vehicle.numPuestos}, Puertas: ${vehicle.numPuertas}",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      "Combustible: ${vehicle.combustible}, Kilómetros: ${vehicle.kilometros}",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      "Cilindraje: ${vehicle.cilindraje}, Categoría: ${vehicle.categoria}",
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
                      onPressed: () => onEdit(vehicle),
                      tooltip: "Editar Vehículo",
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => onDelete(vehicle),
                      tooltip: "Eliminar Vehículo",
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
