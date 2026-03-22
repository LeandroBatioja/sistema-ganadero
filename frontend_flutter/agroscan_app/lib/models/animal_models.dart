class Animal {
  final String codigoQR;
  final String raza;
  final double peso;
  final int edad;
  final String estadoSalud; // Para la Historia 4
   int sincronizado;   // 0 = No, 1 = Sí (Para la Historia 5)

  Animal({
    required this.codigoQR,
    required this.raza,
    required this.peso,
    required this.edad,
    this.estadoSalud = "Excelente",
    this.sincronizado = 0,
  });

  // Convierte un objeto Animal a un "Mapa" para guardarlo en SQLite o enviar a Python
  Map<String, dynamic> toMap() {
    return {
      'codigoQR': codigoQR,
      'raza': raza,
      'peso': peso,
      'edad': edad,
      'estadoSalud': estadoSalud,
      'sincronizado': sincronizado,
    };
  }

  // Crea un objeto Animal a partir de lo que devuelve la base de datos
  factory Animal.fromMap(Map<String, dynamic> map) {
    return Animal(
      codigoQR: map['codigoQR'],
      raza: map['raza'],
      peso: map['peso'],
      edad: map['edad'],
      estadoSalud: map['estadoSalud'] ?? "Excelente",
      sincronizado: map['sincronizado'] ?? 0,
    );
  }
}