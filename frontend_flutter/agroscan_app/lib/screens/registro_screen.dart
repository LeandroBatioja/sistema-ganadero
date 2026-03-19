import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/animal_models.dart';

class RegistroScreen extends StatefulWidget {
  @override
  _RegistroScreenState createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dbHelper = DBHelper();

  // Controladores para capturar lo que el usuario escribe
  final _qrController = TextEditingController();
  final _razaController = TextEditingController();
  final _pesoController = TextEditingController();
  final _edadController = TextEditingController();

  void _guardarLocalmente() async {
    if (_formKey.currentState!.validate()) {
      // Creamos el objeto Animal con los datos del formulario
      final nuevaVaca = Animal(
        codigoQR: _qrController.text,
        raza: _razaController.text,
        peso: double.parse(_pesoController.text),
        edad: int.parse(_edadController.text),
        sincronizado: 0, // Importante: Se guarda como NO sincronizado
      );

      // Guardamos en SQLite (Offline-First)
      await _dbHelper.insertarAnimal(nuevaVaca);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🐄 Guardado localmente (Modo Offline)")),
      );

      // Limpiamos los campos
      _qrController.clear();
      _razaController.clear();
      _pesoController.clear();
      _edadController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registrar Nuevo Animal")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _qrController,
                decoration: InputDecoration(labelText: "Código QR / Arete"),
                validator: (value) => value!.isEmpty ? "Ingrese el código" : null,
              ),
              TextFormField(
                controller: _razaController,
                decoration: InputDecoration(labelText: "Raza"),
                validator: (value) => value!.isEmpty ? "Ingrese la raza" : null,
              ),
              TextFormField(
                controller: _pesoController,
                decoration: InputDecoration(labelText: "Peso (kg)"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Ingrese el peso" : null,
              ),
              TextFormField(
                controller: _edadController,
                decoration: InputDecoration(labelText: "Edad (meses)"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Ingrese la edad" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarLocalmente,
                child: Text("Guardar en el Teléfono"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }
}