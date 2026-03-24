import 'package:flutter/material.dart';
import '../models/animal_models.dart';
import '../services/api_services.dart';

class DetalleAnimalScreen extends StatefulWidget {
  final Animal animal;

  DetalleAnimalScreen({required this.animal});

  @override
  _DetalleAnimalScreenState createState() =>
      _DetalleAnimalScreenState();
}

class _DetalleAnimalScreenState
    extends State<DetalleAnimalScreen> {
  final _apiService = ApiService();

  Map<String, dynamic>? _historial;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosMedicos();
  }

  // ================================
  // Cargar historial desde backend
  // ================================
  void _cargarDatosMedicos() async {
    final datos =
        await _apiService.obtenerHistorial(
            widget.animal.codigoQR);

    setState(() {
      _historial = datos;
      _cargando = false;
    });
  }

  // ================================
  // Obtener estado dinámico
  // ================================
  String _obtenerEstadoActual() {
    var clinico =
        _historial?['clinico'] as List? ?? [];

    if (clinico.isNotEmpty) {
      return clinico.first['estado_salud'] ??
          widget.animal.estadoSalud;
    }

    return widget.animal.estadoSalud;
  }

  // ================================
  // FORMULARIO
  // ================================
  void _mostrarFormularioAccion() {
    String tipoAccion = "Vacuna";

    final _controller1 =
        TextEditingController();
    final _controller2 =
        TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            StateSetter setModalState,
          ) {
            return Padding(
              padding: EdgeInsets.only(
                bottom:
                    MediaQuery.of(context)
                        .viewInsets
                        .bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Text(
                    "Registrar Actividad Médica",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  DropdownButton<String>(
                    value: tipoAccion,
                    isExpanded: true,
                    items: [
                      "Vacuna",
                      "Revisión"
                    ].map((value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged:
                        (nuevoValor) {
                      setModalState(() {
                        tipoAccion =
                            nuevoValor!;
                      });
                    },
                  ),

                  TextField(
                    controller:
                        _controller1,
                    decoration:
                        InputDecoration(
                      labelText:
                          tipoAccion ==
                                  "Vacuna"
                              ? "Nombre de la Vacuna"
                              : "Observaciones Médicas",
                    ),
                  ),

                  TextField(
                    controller:
                        _controller2,
                    decoration:
                        InputDecoration(
                      labelText:
                          tipoAccion ==
                                  "Vacuna"
                              ? "Dosis (ej: 5ml)"
                              : "Estado",
                    ),
                  ),

                  SizedBox(height: 20),

                  ElevatedButton(
                    child: Text(
                        "Guardar en Historial"),
                    onPressed:
                        () async {
                      bool exito =
                          false;

                      if (tipoAccion ==
                          "Vacuna") {
                        exito =
                            await _apiService
                                .registrarVacuna(
                          widget.animal
                              .codigoQR,
                          _controller1
                              .text,
                          _controller2
                              .text,
                        );
                      } else {
                        exito =
                            await _apiService
                                .registrarRevision(
                          widget.animal
                              .codigoQR,
                          _controller1
                              .text,
                          _controller2
                              .text,
                        );
                      }

                      if (exito) {
                        Navigator.pop(
                            context);

                        _cargarDatosMedicos();

                        ScaffoldMessenger.of(
                                context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                                "✅ Registro médico actualizado"),
                          ),
                        );
                      }
                    },
                  ),

                  SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ================================
  // UI
  // ================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Ficha: ${widget.animal.codigoQR}"),
      ),

      body: _cargando
          ? Center(
              child:
                  CircularProgressIndicator(),
            )
          : ListView(
              padding:
                  EdgeInsets.all(16),
              children: [
                _buildInfoCard(),

                SizedBox(height: 20),

                Text(
                  "💉 Historial de Vacunas",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                _buildListaVacunas(),

                SizedBox(height: 20),

                Text(
                  "📋 Evolución de Salud",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                _buildListaClinica(),
              ],
            ),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed:
            _mostrarFormularioAccion,
        label:
            Text("Registrar Acción"),
        icon: Icon(
            Icons.medical_services),
        backgroundColor:
            Colors.redAccent,
      ),
    );
  }

  // ================================
  // CARD INFO
  // ================================
  Widget _buildInfoCard() {
    String estado =
        _obtenerEstadoActual();

    return Card(
      elevation: 4,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
                12),
      ),
      child: ListTile(
        title: Text(
          "Raza: ${widget.animal.raza}",
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Padding(
          padding:
              EdgeInsets.only(
                  top: 8),
          child: Text(
            "Peso actual: ${widget.animal.peso} kg\n"
            "Estado Actual: $estado",
          ),
        ),
        trailing: Icon(
          Icons.analytics,
          size: 40,
          color:
              estado == "Crítico"
                  ? Colors.red
                  : Colors.green,
        ),
      ),
    );
  }

  // ================================
  // VACUNAS
  // ================================
  Widget _buildListaVacunas() {
    var vacunas =
        _historial?['vacunas']
                as List? ??
            [];

    if (vacunas.isEmpty)
      return Text(
          "No hay vacunas registradas.");

    return Column(
      children: vacunas.map(
        (v) {
          return ListTile(
            leading: Icon(
              Icons.check_circle,
              color: Colors.blue,
            ),
            title: Text(v['tipo']),
            subtitle: Text(
              "Dosis: ${v['dosis']} - Fecha: ${v['fecha_aplicacion'].toString().split('T')[0]}",
            ),
          );
        },
      ).toList(),
    );
  }

  // ================================
  // CLINICO
  // ================================
  Widget _buildListaClinica() {
    var clinico =
        _historial?['clinico']
                as List? ??
            [];

    if (clinico.isEmpty)
      return Text(
          "Sin observaciones médicas.");

    return Column(
      children: clinico.map(
        (c) {
          return Card(
            color:
                Colors.grey[100],
            child: ListTile(
              title: Text(
                  "Estado: ${c['estado_salud']}"),
              subtitle: Text(
                  "${c['observaciones']}\nPor: ${c['veterinario']}"),
              isThreeLine: true,
            ),
          );
        },
      ).toList(),
    );
  }
}