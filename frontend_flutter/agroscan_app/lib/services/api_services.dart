import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/animal_models.dart';

class ApiService {

  // ✅ IP de tu backend FastAPI
  static const String baseUrl = "http://192.168.100.17:8000/ganado";


  // =========================================================
  // 1. SINCRONIZAR ANIMALES (Historia 5)
  // =========================================================
  Future<bool> sincronizarConBackend(List<Animal> pendientes) async {
    try {

      // Convertir lista a JSON
      List<Map<String, dynamic>> data =
          pendientes.map((a) => a.toMap()).toList();

      final response = await http.post(
        Uri.parse("$baseUrl/sync"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print(">>> Sincronización exitosa <<<");
        return true;
      } else {
        print("Error servidor: ${response.body}");
        return false;
      }

    } catch (e) {
      print("Error red: $e");
      return false;
    }
  }


  // =========================================================
  // 2. OBTENER HISTORIAL
  // =========================================================
  Future<Map<String, dynamic>?> obtenerHistorial(String qr) async {
    try {

      final response =
          await http.get(Uri.parse("$baseUrl/$qr/historial"));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;

    } catch (e) {
      print("Error historial: $e");
      return null;
    }
  }


  // =========================================================
  // 3. REGISTRAR VACUNA
  // =========================================================
  Future<bool> registrarVacuna(
      String qr,
      String nombre,
      String dosis,
  ) async {

    try {

      final response = await http.post(
        Uri.parse("$baseUrl/$qr/vacuna"),

        headers: {
          "Content-Type": "application/json"
        },

        // ✅ IMPORTANTE
        // Debe coincidir con Pydantic en FastAPI
        body: jsonEncode({
          "tipo": nombre,
          "dosis": dosis,
        }),
      );

      if (response.statusCode == 200) {
        print("Vacuna guardada");
        return true;
      } else {
        print("Error vacuna: ${response.body}");
        return false;
      }

    } catch (e) {
      print("Error red vacuna: $e");
      return false;
    }
  }


  // =========================================================
  // 4. REGISTRAR REVISION
  // =========================================================
  Future<bool> registrarRevision(
      String qr,
      String obs,
      String estado,
  ) async {

    try {

      final response = await http.post(
        Uri.parse("$baseUrl/$qr/revision"),

        headers: {
          "Content-Type": "application/json"
        },

        // ✅ IMPORTANTE
        // Debe coincidir con FastAPI
        body: jsonEncode({
          "observaciones": obs,
          "estado_salud": estado,
        }),
      );

      if (response.statusCode == 200) {
        print("Revision guardada");
        return true;
      } else {
        print("Error revision: ${response.body}");
        return false;
      }

    } catch (e) {
      print("Error red revision: $e");
      return false;
    }
  }

}