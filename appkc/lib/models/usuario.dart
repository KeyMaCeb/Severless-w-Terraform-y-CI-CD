class Usuario {
  final int? id;
  final String nombre;
  final String email;
  final String? fotoUrl;

  Usuario({this.id, required this.nombre, required this.email, this.fotoUrl});

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nombre: json['nombre'],
      email: json['email'],
      fotoUrl: json['fotoUrl'],
    );
  }

  Map<String, dynamic> toJson({String? password}) {
    return {
      'nombre': nombre,
      'email': email,
      if (password != null && password.isNotEmpty) 'password': password,
    };
  }
}