class Usuario {
  String id;
  String username;
  String password;
  String nombre;
  String email;

  // Constructor para crear instancias de Usuario
  Usuario({
    required this.id,
    required this.username,
    required this.password, // Aunque no se guarda en DB, se mantiene para consistencia si viene de un formulario
    required this.nombre,
    required this.email,
  });

  factory Usuario.fromJson(Map<dynamic, dynamic> json) {
    return Usuario(
      id: json['id'] as String,
      username: json['username'] as String,
      password: json['password'] as String? ?? '',
      nombre: json['nombre'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'nombre': nombre,
      'email': email,
    };
  }
}
