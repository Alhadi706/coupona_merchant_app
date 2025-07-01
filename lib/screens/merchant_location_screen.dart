import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:hive/hive.dart';

class MerchantLocationScreen extends StatefulWidget {
  final List<LatLng>? initialLocations;
  const MerchantLocationScreen({super.key, this.initialLocations});

  @override
  State<MerchantLocationScreen> createState() => _MerchantLocationScreenState();
}

class _MerchantLocationScreenState extends State<MerchantLocationScreen> {
  List<LatLng> _locations = [];

  @override
  void initState() {
    super.initState();
    _locations = widget.initialLocations ?? [];
  }

  void _onMapTap(TapPosition tapPosition, LatLng latLng) {
    setState(() {
      _locations.add(latLng);
    });
  }

  void _removeLocation(int index) {
    setState(() {
      _locations.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تحديد مواقع الفروع')),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                center: _locations.isNotEmpty ? _locations.first : LatLng(32.8872, 13.1913),
                zoom: 12,
                onTap: _onMapTap,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: _locations
                      .asMap()
                      .entries
                      .map((e) => Marker(
                            point: e.value,
                            width: 40,
                            height: 40,
                            rotate: false,
                            child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // إضافة الموقعي الحالي غير مدعوم في flutter_map
                  },
                  icon: const Icon(Icons.my_location),
                  label: const Text('إضافة موقعي الحالي'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context, _locations);
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('حفظ المواقع', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
          if (_locations.isNotEmpty)
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _locations.length,
                itemBuilder: (context, i) => Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('فرع ${i + 1}\n${_locations[i].latitude.toStringAsFixed(4)}, ${_locations[i].longitude.toStringAsFixed(4)}', textAlign: TextAlign.center),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeLocation(i),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
