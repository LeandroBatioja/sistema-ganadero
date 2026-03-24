import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'screens/listado_screen.dart';
import 'screens/registro_screen.dart';
import 'screens/historial_screen.dart'; // ✅ NUEVO

void main() {

  // Inicializar SQLite para Linux / Windows / Mac
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(AgroScanApp());
}

class AgroScanApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgroScan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),

      // ✅ CAMBIO → nuevo menú
      home: MenuPrincipal(),
    );
  }
}


// =======================================
// NUEVO MENU CON 3 PESTAÑAS
// =======================================

class MenuPrincipal extends StatefulWidget {
  @override
  State<MenuPrincipal> createState() => _MenuPrincipalState();
}

class _MenuPrincipalState extends State<MenuPrincipal> {

  int _actual = 0;

  // ✅ 3 pantallas
  final List<Widget> _paginas = [

    ListadoScreen(),    // pendientes / sync

    HistorialScreen(),  // nube

    RegistroScreen(),   // nuevo animal

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: _paginas[_actual],

      bottomNavigationBar: BottomNavigationBar(

        currentIndex: _actual,

        type: BottomNavigationBarType.fixed, // necesario para 3

        onTap: (i) {
          setState(() {
            _actual = i;
          });
        },

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.sync),
            label: "Pendientes",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.cloud_done),
            label: "Historial",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: "Nuevo",
          ),

        ],
      ),
    );
  }
}