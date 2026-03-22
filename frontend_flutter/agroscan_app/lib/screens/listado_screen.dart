import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/animal_models.dart';
import '../services/api_services.dart';
import 'detalle_animal_screen.dart';

class ListadoScreen extends StatefulWidget {
  @override
  _ListadoScreenState createState() => _ListadoScreenState();
}

class _ListadoScreenState extends State<ListadoScreen> {

  final _dbHelper = DBHelper();

  // ✅ Servicio API
  final _apiService = ApiService();

  List<Animal> _animales = [];

  @override
  void initState() {
    super.initState();
    _cargarAnimales();
  }


  // ============================================
  // ✅ SOLO PENDIENTES (CAMBIO AQUÍ)
  // ============================================
  void _cargarAnimales() async {

    final datos = await _dbHelper.obtenerPendientes();

    setState(() {
      _animales = datos;
    });
  }


  // ============================================
  // ✅ SINCRONIZAR CON BACKEND
  // ============================================
  void _sincronizarTodo() async {

    List<Animal> pendientes =
        await _dbHelper.obtenerPendientes();

    if (pendientes.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("✅ Todo está al día en la nube"),
        ),
      );

      return;
    }

    bool exito =
        await _apiService.sincronizarConBackend(
            pendientes);

    if (exito) {

      for (var animal in pendientes) {
        await _dbHelper
            .marcarSincronizado(animal.codigoQR);
      }

      _cargarAnimales();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "🚀 Sincronización exitosa con Atlas"),
        ),
      );

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "❌ Error de conexión con el servidor"),
        ),
      );
    }
  }


  // ============================================
  // UI
  // ============================================
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Inventario Local (Offline)"),

        actions: [

          IconButton(
            icon: Icon(
              Icons.cloud_upload,
              color: Colors.blue,
            ),
            onPressed: _sincronizarTodo,
          ),

          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _cargarAnimales,
          ),

        ],
      ),


      body: _animales.isEmpty
          ? Center(
              child: Text(
                "No hay animales pendientes.",
              ),
            )

          : ListView.builder(

              itemCount: _animales.length,

              itemBuilder: (context, index) {

                final animal = _animales[index];

                return ListTile(

                  onTap: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetalleAnimalScreen(
                          animal: animal,
                        ),
                      ),
                    );
                  },

                  leading: Icon(
                    Icons.pest_control_rodent,
                    color: Colors.brown,
                  ),

                  title: Text(
                    "Arete: ${animal.codigoQR}",
                  ),

                  subtitle: Text(
                    "Raza: ${animal.raza} - Peso: ${animal.peso}kg",
                  ),

                  trailing: Icon(

                    animal.sincronizado == 1
                        ? Icons.cloud_done
                        : Icons.cloud_off,

                    color:
                        animal.sincronizado == 1
                            ? Colors.green
                            : Colors.orange,
                  ),
                );
              },
            ),
    );
  }
}