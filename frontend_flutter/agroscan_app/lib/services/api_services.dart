import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/animal_models.dart';

class ApiService {

  // ✅ IP de tu backend FastAPI
  static const String baseUrl =
      "http://192.168.100.17:8000/ganado";


  // =========================================================
  // 1. OBTENER TODO EL GANADO DESDE MONGODB (GET /ganado)
  // =========================================================

  Future<List<Animal>> obtenerTodoElGanado() async {

    try {

      final response =
          await http.get(
        Uri.parse(baseUrl),
      );

      if (response.statusCode == 200) {

        List<dynamic> body =
            jsonDecode(response.body);

        return body
            .map((item) =>
                Animal.fromMap(item))
            .toList();
      }

      return [];

    } catch (e) {

      print(
          "Error al conectar con el servidor: $e");

      return [];
    }
  }


  // =========================================================
  // 2. SINCRONIZAR ANIMALES (POST /ganado/sync)
  // =========================================================

  Future<bool> sincronizarConBackend(
      List<Animal> pendientes) async {

    try {

      List<Map<String, dynamic>> data =
          pendientes
              .map((a) => a.toMap())
              .toList();

      final response = await http.post(

        Uri.parse("$baseUrl/sync"),

        headers: {
          "Content-Type":
              "application/json"
        },

        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {

        print(
            ">>> Sincronización exitosa <<<");

        return true;

      } else {

        print(
            "Error servidor: ${response.body}");

        return false;
      }

    } catch (e) {

      print("Error red: $e");

      return false;
    }
  }


  // =========================================================
  // 3. OBTENER HISTORIAL (GET /ganado/{qr}/historial)
  // =========================================================

  Future<Map<String, dynamic>?>
      obtenerHistorial(String qr) async {

    try {

      final response =
          await http.get(

        Uri.parse(
          "$baseUrl/$qr/historial",
        ),
      );

      if (response.statusCode == 200) {

        return jsonDecode(
            response.body);
      }

      return null;

    } catch (e) {

      print(
          "Error historial: $e");

      return null;
    }
  }


  // =========================================================
  // 4. REGISTRAR VACUNA (POST /ganado/{qr}/vacuna)
  // =========================================================

  Future<bool> registrarVacuna(

    String qr,
    String nombre,
    String dosis,

  ) async {

    try {

      final response =
          await http.post(

        Uri.parse(
            "$baseUrl/$qr/vacuna"),

        headers: {
          "Content-Type":
              "application/json"
        },

        body: jsonEncode({

          "tipo": nombre,
          "dosis": dosis,

        }),
      );

      if (response.statusCode == 200) {

        print("Vacuna guardada");

        return true;

      } else {

        print(
            "Error vacuna: ${response.body}");

        return false;
      }

    } catch (e) {

      print(
          "Error red vacuna: $e");

      return false;
    }
  }


  // =========================================================
  // 5. REGISTRAR REVISION (POST /ganado/{qr}/revision)
  // =========================================================

  Future<bool> registrarRevision(

    String qr,
    String obs,
    String estado,

  ) async {

    try {

      final response =
          await http.post(

        Uri.parse(
            "$baseUrl/$qr/revision"),

        headers: {
          "Content-Type":
              "application/json"
        },

        body: jsonEncode({

          "observaciones": obs,
          "estado_salud": estado,

        }),
      );

      if (response.statusCode == 200) {

        print(
            "Revision guardada");

        return true;

      } else {

        print(
            "Error revision: ${response.body}");

        return false;
      }

    } catch (e) {

      print(
          "Error red revision: $e");

      return false;
    }
  }

}