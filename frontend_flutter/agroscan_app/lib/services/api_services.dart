import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/animal_models.dart';

class ApiService {
  // REEMPLAZA ESTA IP por la de tu computadora (puedes verla con 'ifconfig' o 'ipconfig')
  // El puerto es el 8000 que usa Uvicorn por defecto.
  static const String baseUrl = "http://192.168.100.17:8000/ganado";

  // 1. Enviar una lista de animales (Sincronización Masiva - Historia 5)
  Future<bool> sincronizarConBackend(List<Animal> pendientes) async {
    try {
      // Convertimos la lista de objetos Animal a una lista de Mapas (JSON)
      List<Map<String, dynamic>> data = pendientes.map((a) => a.toMap()).toList();

      final response = await http.post(
        Uri.parse("$baseUrl/sync"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print(">>> Sincronización exitosa con el Backend <<<");
        return true;
      } else {
        print("XXX Error en el servidor: ${response.body} XXX");
        return false;
      }
    } catch (e) {
      print("XXX Error de red: No se pudo contactar al servidor ($e) XXX");
      return false;
    }
  }

  // 2. Obtener historial médico desde la nube (Historias 3 y 4)
  Future<Map<String, dynamic>?> obtenerHistorial(String qr) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/$qr/historial"));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}