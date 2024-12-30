// lib/services/map_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapService {
  static const String orsToken =
      '5b3ce3597851110001cf624855a2030980b346859dd95b3cc9eba073';

  /// Obtiene una ruta desde [start] hasta [end] usando la API de OpenRouteService
  static Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    final url =
        Uri.parse('https://api.openrouteservice.org/v2/directions/driving-car');
    final body = json.encode({
      "coordinates": [
        [
          start.longitude,
          start.latitude
        ], // IMPORTANTE: Ojo con el orden (lon, lat)
        [end.longitude, end.latitude],
      ]
    });

    final response = await http.post(
      url,
      headers: {
        'Authorization': orsToken,
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // La geometría (línea) viene codificada en polyline o en coordinates
      // En este caso, openrouteservice la da en "features[0].geometry.coordinates"
      final coords = data['features'][0]['geometry']['coordinates'] as List;
      // coords es una lista de [lon, lat]. Convertirla a List<LatLng>
      return coords
          .map((c) => LatLng(c[1], c[0])) // c[0]=lon, c[1]=lat
          .toList();
    } else {
      throw Exception('Error al obtener ruta: ${response.body}');
    }
  }
}
