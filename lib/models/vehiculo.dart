class Vehiculo {
  String id;
  String placa;
  String marca;
  String modelo;
  String version;
  String color;
  int numPuestos;
  int numPuertas;
  String combustible;
  double kilometros;
  double cilindraje;
  String categoria;

  // Constructor para crear instancias de Vehiculo
  Vehiculo({
    required this.id,
    required this.placa,
    required this.marca,
    required this.modelo,
    required this.version,
    required this.color,
    required this.numPuestos,
    required this.numPuertas,
    required this.combustible,
    required this.kilometros,
    required this.cilindraje,
    required this.categoria,
  });

  // Factory constructor para crear un objeto Vehiculo desde un Map (JSON de Firebase)
  factory Vehiculo.fromJson(Map<dynamic, dynamic> json) {
    return Vehiculo(
      id: json['id'] as String? ?? '',
      placa: json['placa'] as String? ?? '',
      marca: json['marca'] as String? ?? '',
      modelo: json['modelo'] as String? ?? '',
      version: json['version'] as String? ?? '',
      color: json['color'] as String? ?? '',
      numPuestos: (json['numPuestos'] as int?) ?? 0,
      numPuertas: (json['numPuertas'] as int?) ?? 0,
      combustible: json['combustible'] as String? ?? '',
      kilometros: (json['kilometros'] as num?)?.toDouble() ?? 0.0,
      cilindraje: (json['cilindraje'] as num?)?.toDouble() ?? 0.0,
      categoria: json['categoria'] as String? ?? '',
    );
  }

  // Método para convertir un objeto Vehiculo a un Map (para guardar en Firebase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'placa': placa,
      'marca': marca,
      'modelo': modelo,
      'version': version,
      'color': color,
      'numPuestos': numPuestos,
      'numPuertas': numPuertas,
      'combustible': combustible,
      'kilometros': kilometros,
      'cilindraje': cilindraje,
      'categoria': categoria,
    };
  }
}
