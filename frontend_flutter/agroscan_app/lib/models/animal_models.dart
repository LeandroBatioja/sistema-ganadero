class Vacuna {

  final String tipo;
  final String dosis;

  Vacuna({
    required this.tipo,
    required this.dosis,
  });

  factory Vacuna.fromMap(
      Map<String, dynamic> map) {

    return Vacuna(
      tipo: map['tipo'] ?? '',
      dosis: map['dosis'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tipo': tipo,
      'dosis': dosis,
    };
  }
}



class RevisionMedica {

  final String observaciones;
  final String estadoSalud;

  RevisionMedica({
    required this.observaciones,
    required this.estadoSalud,
  });

  factory RevisionMedica.fromMap(
      Map<String, dynamic> map) {

    return RevisionMedica(
      observaciones:
          map['observaciones'] ?? '',
      estadoSalud:
          map['estado_salud'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'observaciones': observaciones,
      'estado_salud': estadoSalud,
    };
  }
}



class Animal {

  final String codigoQR;
  final String raza;
  final double peso;
  final int edad;
  final String estadoSalud;

  int sincronizado;

  List<Vacuna> historialVacunas;
  List<RevisionMedica> historialClinico;



  Animal({

    required this.codigoQR,
    required this.raza,
    required this.peso,
    required this.edad,

    this.estadoSalud = "Excelente",

    this.sincronizado = 0,

    this.historialVacunas = const [],
    this.historialClinico = const [],
  });



  // ============================================
  // PARA SQLITE / API
  // ============================================

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



  // ============================================
  // DESDE SQLITE / MONGODB / API
  // ============================================

  factory Animal.fromMap(
      Map<String, dynamic> map) {

    return Animal(

      codigoQR:
          map['codigoQR'] ?? 'S/N',

      raza:
          map['raza'] ?? 'Mestiza',

      peso:
          (map['peso'] ?? 0.0)
              .toDouble(),

      edad:
          map['edad'] ?? 0,

      estadoSalud:
          map['estadoSalud']
              ?? 'Excelente',

      // si viene de la nube → sincronizado
      sincronizado:
          map['sincronizado'] ?? 1,


      // ✅ PROTECCIÓN MONGODB
      historialVacunas:
          (map['historial_vacunas']
                  as List?)
              ?.map((v) =>
                  Vacuna.fromMap(v))
              .toList()
          ?? [],


      historialClinico:
          (map['historial_clinico']
                  as List?)
              ?.map((r) =>
                  RevisionMedica
                      .fromMap(r))
              .toList()
          ?? [],
    );
  }
}