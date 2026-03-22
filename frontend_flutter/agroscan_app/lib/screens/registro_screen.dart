import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/animal_models.dart';
import '../services/api_services.dart'; // ✅ NUEVO

class RegistroScreen extends StatefulWidget {
  @override
  _RegistroScreenState createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {

  final _formKey = GlobalKey<FormState>();

  final _dbHelper = DBHelper();

  final _apiService = ApiService(); // ✅ NUEVO


  final _qrController = TextEditingController();
  final _razaController = TextEditingController();
  final _pesoController = TextEditingController();
  final _edadController = TextEditingController();



  // ============================================
  // NUEVO GUARDADO AUTOMÁTICO ONLINE / OFFLINE
  // ============================================

  void _guardarLocalmente() async {

    if (!_formKey.currentState!.validate()) return;

    final nuevoAnimal = Animal(
      codigoQR: _qrController.text,
      raza: _razaController.text,
      peso: double.parse(_pesoController.text),
      edad: int.parse(_edadController.text),
      estadoSalud: "Excelente",
      sincronizado: 0,
    );

    try {

      // ✅ intentar enviar al backend
      bool exitoSincro =
          await _apiService
              .sincronizarConBackend(
                  [nuevoAnimal]);

      if (exitoSincro) {

        // guardamos como sincronizado
        nuevoAnimal.sincronizado = 1;

        await _dbHelper.insertarAnimal(
            nuevoAnimal);

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
                "🚀 Registrada y subida a la nube automáticamente"),
          ),
        );

      } else {

        // guardar offline
        await _dbHelper.insertarAnimal(
            nuevoAnimal);

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
                "💾 Guardado en local (Sin conexión al servidor)"),
          ),
        );
      }

    } catch (e) {

      // sin internet
      await _dbHelper.insertarAnimal(
          nuevoAnimal);

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
              "⚠️ Offline: Guardado en el teléfono"),
        ),
      );
    }


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

        padding: EdgeInsets.all(16.0),

        child: Form(

          key: _formKey,

          child: ListView(

            children: [

              TextFormField(
                controller: _qrController,
                decoration: InputDecoration(
                    labelText:
                        "Código QR / Arete"),
                validator: (value) =>
                    value!.isEmpty
                        ? "Ingrese el código"
                        : null,
              ),

              TextFormField(
                controller: _razaController,
                decoration: InputDecoration(
                    labelText: "Raza"),
                validator: (value) =>
                    value!.isEmpty
                        ? "Ingrese la raza"
                        : null,
              ),

              TextFormField(
                controller: _pesoController,
                decoration: InputDecoration(
                    labelText: "Peso (kg)"),
                keyboardType:
                    TextInputType.number,
                validator: (value) =>
                    value!.isEmpty
                        ? "Ingrese el peso"
                        : null,
              ),

              TextFormField(
                controller: _edadController,
                decoration: InputDecoration(
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
                child: Text(
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