// lib/pages/map_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import '../services/map_service.dart';

class MapPage extends StatefulWidget {
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // Controlador del mapa
  final MapController _mapController = MapController();

  // Lista de puntos seguros (refugios)
  List<QueryDocumentSnapshot> safePoints = [];

  // Polylines para mostrar la ruta
  List<Polyline> polylines = [];

  // Posición actual del usuario
  LatLng? userPosition;

  @override
  void initState() {
    super.initState();
    _initLocation();
    _loadSafePointsFromFirestore();
  }

  /// Solicita permisos y obtiene la ubicación actual del usuario
  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // El usuario tiene el GPS desactivado
      // Maneja este caso, por ejemplo, mostrando un mensaje o solicitando que lo active
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // El usuario negó los permisos
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // El usuario negó los permisos permanentemente
      return;
    }

    // Obtener posición actual
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      userPosition = LatLng(pos.latitude, pos.longitude);
    });
  }

  /// Carga los puntos seguros (refugios) de Firestore
  Future<void> _loadSafePointsFromFirestore() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('safe_points').get();
    setState(() {
      safePoints = snapshot.docs;
    });
  }

  /// Genera la ruta desde la posición del usuario hasta el refugio seleccionado
  Future<void> _drawRouteToRefuge(LatLng refugeLatLng) async {
    if (userPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('No se puede trazar ruta: ubicación del usuario desconocida'),
      ));
      return;
    }

    try {
      final routeCoords =
          await MapService.getRoute(userPosition!, refugeLatLng);
      setState(() {
        polylines = [
          Polyline(
            points: routeCoords,
            color: Colors.blue,
            strokeWidth: 4.0,
          ),
        ];
      });
      // Opcional: mover la cámara para que muestre la ruta
      if (routeCoords.isNotEmpty) {
        _mapController.move(routeCoords[0], 14);
      }
    } catch (e) {
      print('Error al trazar ruta: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Marcador de la ubicación del usuario
    final userMarker = userPosition == null
        ? <Marker>[] // si no hay ubicación, no dibujamos nada
        : [
            Marker(
              width: 60,
              height: 60,
              point: userPosition!,
              builder: (ctx) =>
                  Icon(Icons.person_pin_circle, color: Colors.red, size: 50),
            )
          ];

    // Marcadores de refugios
    final refugeMarkers = safePoints.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final name = data['name'] ?? 'Refugio';
      final lat = data['latitude'] as double;
      final lon = data['longitude'] as double;
      return Marker(
        width: 60,
        height: 60,
        point: LatLng(lat, lon),
        builder: (ctx) => GestureDetector(
          onTap: () {
            // Cuando el usuario toque el marcador, le preguntamos si quiere trazar la ruta
            _showRefugeDialog(name, LatLng(lat, lon));
          },
          child: Icon(Icons.home, color: Colors.green, size: 40),
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa de Refugios'),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: userPosition ??
              LatLng(14.0, -87.0), // Coord por defecto si no hay ubicación
          zoom: 13.0,
          maxZoom: 18,
          minZoom: 3,
        ),
        children: [
          // Capa del mapa base
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
          ),
          // Capa de líneas (polylines)
          PolylineLayer(
            polylines: polylines,
          ),
          // Capa de marcadores
          MarkerLayer(
            markers: [
              ...userMarker,
              ...refugeMarkers,
            ],
          ),
        ],
      ),
    );
  }

  void _showRefugeDialog(String refugeName, LatLng latLng) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Refugio: $refugeName'),
          content: Text('¿Quieres trazar la ruta hacia este refugio?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _drawRouteToRefuge(latLng);
              },
              child: Text('Sí'),
            )
          ],
        );
      },
    );
  }
}
