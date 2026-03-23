import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/animal_models.dart';
import 'detalle_animal_screen.dart';

class HistorialScreen extends StatefulWidget {
  @override
  _HistorialScreenState createState() =>
      _HistorialScreenState();
}

class _HistorialScreenState
    extends State<HistorialScreen> {

  final _dbHelper = DBHelper();

  List<Animal> _animalesSincronizados = [];


  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }


  // ============================================
  // CARGAR SOLO SINCRONIZADOS
  // ============================================

  void _cargarHistorial() async {

    final listaSincronizada =
        await _dbHelper
            .obtenerSincronizados();

    setState(() {

      _animalesSincronizados =
          listaSincronizada;

    });
  }


  // ============================================
  // REFRESCAR AL VOLVER A LA PESTAÑA
  // ============================================

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cargarHistorial();
  }


  // ============================================
  // UI
  // ============================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title:
            Text("Historial en la Nube"),
        backgroundColor:
            Colors.blueGrey,
      ),

      body:
          _animalesSincronizados
                  .isEmpty
              ? Center(
                  child: Text(
                    "No hay vacas sincronizadas",
                  ),
                )
              : ListView.builder(

                  itemCount:
                      _animalesSincronizados
                          .length,

                  itemBuilder:
                      (context, index) {

                    final animal =
                        _animalesSincronizados[
                            index];

                    return ListTile(

                      onTap: () {

                        Navigator.push(

                          context,

                          MaterialPageRoute(

                            builder:
                                (context) =>
                                    DetalleAnimalScreen(
                              animal:
                                  animal,
                            ),
                          ),
                        );
                      },

                      leading: Icon(
                        Icons.cloud_done,
                        color:
                            Colors.green,
                      ),

                      title: Text(
                        "Arete: ${animal.codigoQR}",
                      ),

                      subtitle: Text(
                        "${animal.raza} - Registro Permanente",
                      ),

                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 15,
                      ),
                    );
                  },
                ),
    );
  }
}