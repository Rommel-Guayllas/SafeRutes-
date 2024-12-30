import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddSafePointPage extends StatefulWidget {
  @override
  _AddSafePointPageState createState() => _AddSafePointPageState();
}

class _AddSafePointPageState extends State<AddSafePointPage> {
  // Controladores para los campos de texto
  final nameCtrl = TextEditingController();
  final latCtrl = TextEditingController();
  final lonCtrl = TextEditingController();

  /// Función para guardar el punto seguro en Firestore
  Future<void> _saveSafePoint() async {
    final name = nameCtrl.text.trim();
    final lat = double.tryParse(latCtrl.text);
    final lon = double.tryParse(lonCtrl.text);

    // Validar que los campos tengan datos correctos
    if (name.isEmpty || lat == null || lon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor ingresa valores válidos')),
      );
      return;
    }

    try {
      // Guardar en la colección "safe_points"
      await FirebaseFirestore.instance.collection('safe_points').add({
        'name': name,
        'latitude': lat,
        'longitude': lon,
      });

      // Mostrar éxito y regresar a la pantalla anterior
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Punto seguro guardado con éxito')),
      );
      Navigator.pop(context);
    } catch (e) {
      // Si hay un error (por ejemplo, sin conexión a Firestore), mostrar mensaje
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Punto Seguro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(labelText: 'Nombre del Refugio'),
            ),
            TextField(
              controller: latCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Latitud'),
            ),
            TextField(
              controller: lonCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Longitud'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveSafePoint,
              child: Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
