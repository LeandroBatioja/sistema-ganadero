import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/animal_models.dart';
import '../services/api_services.dart';

class RegistroScreen extends StatefulWidget {
  @override
  _RegistroScreenState createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {

  final _formKey = GlobalKey<FormState>();

  final _dbHelper = DBHelper();
  final _apiService = ApiService();

  final _qrController = TextEditingController();
  final _razaController = TextEditingController();
  final _pesoController = TextEditingController();
  final _edadController = TextEditingController();


  // ============================================
  // GUARDAR ANIMAL (CORREGIDO)
  // ============================================

  void _guardarLocalmente() async {

    if (!_formKey.currentState!.validate()) return;

    // ✅ SIEMPRE empieza en 0
    final nuevoAnimal = Animal(
      codigoQR: _qrController.text,
      raza: _razaController.text,
      peso: double.parse(_pesoController.text),
      edad: int.parse(_edadController.text),
      estadoSalud: "Excelente",
      sincronizado: 0,
    );

    try {

      // Intentar enviar al backend
      bool exito =
          await _apiService
              .sincronizarConBackend(
                  [nuevoAnimal]);

      // ✅ SOLO si responde OK pasa a 1
      if (exito) {

        nuevoAnimal.sincronizado = 1;

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              "🚀 Registrada y subida a la nube",
            ),
          ),
        );

      } else {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              "💾 Guardado offline",
            ),
          ),
        );
      }

    } catch (e) {

      print("Modo offline");

      // se queda en 0

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "⚠️ Sin conexión, guardado local",
          ),
        ),
      );
    }


    // ✅ Guardar UNA sola vez
    await _dbHelper.insertarAnimal(
        nuevoAnimal);


    // limpiar
    _qrController.clear();
    _razaController.clear();
    _pesoController.clear();
    _edadController.clear();
  }



  // ============================================
  // UI
  // ============================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Registrar Nuevo Animal"),
      ),

      body: Padding(

        padding: EdgeInsets.all(16),

        child: Form(

          key: _formKey,

          child: ListView(

            children: [

              TextFormField(
                controller: _qrController,
                decoration:
                    InputDecoration(
                        labelText:
                            "Código QR / Arete"),
                validator: (value) =>
                    value!.isEmpty
                        ? "Ingrese el código"
                        : null,
              ),

              TextFormField(
                controller: _razaController,
                decoration:
                    InputDecoration(
                        labelText: "Raza"),
                validator: (value) =>
                    value!.isEmpty
                        ? "Ingrese la raza"
                        : null,
              ),

              TextFormField(
                controller: _pesoController,
                decoration:
                    InputDecoration(
                        labelText:
                            "Peso (kg)"),
                keyboardType:
                    TextInputType.number,
                validator: (value) =>
                    value!.isEmpty
                        ? "Ingrese el peso"
                        : null,
              ),

              TextFormField(
                controller: _edadController,
                decoration:
                    InputDecoration(
                        labelText:
                            "Edad (meses)"),
                keyboardType:
                    TextInputType.number,
                validator: (value) =>
                    value!.isEmpty
                        ? "Ingrese la edad"
                        : null,
              ),

              SizedBox(height: 20),

              ElevatedButton(

                onPressed:
                    _guardarLocalmente,

                child:
                    Text(
                        "Guardar en el Teléfono"),

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}