import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PickLocationScreen extends StatefulWidget {
  final LatLng? initialLocation;
  const PickLocationScreen({this.initialLocation, Key? key}) : super(key: key);

  @override
  State<PickLocationScreen> createState() => _PickLocationScreenState();
}

class _PickLocationScreenState extends State<PickLocationScreen> {
  LatLng? pickedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حدد موقع المحل على الخريطة')),
      body: FlutterMap(
        options: MapOptions(
          center: widget.initialLocation ?? LatLng(32.8872, 13.1913),
          zoom: 13,
          onTap: (tapPosition, latLng) {
            setState(() {
              pickedLocation = latLng;
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          if (pickedLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: pickedLocation!,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.check),
        onPressed: pickedLocation == null
            ? null
            : () {
                Navigator.pop(context, pickedLocation);
              },
      ),
    );
  }
}
