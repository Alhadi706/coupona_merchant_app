import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class StoresMapScreen extends StatelessWidget {
  const StoresMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('خريطة المحلات'),
        backgroundColor: Colors.deepPurple.shade700,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('branches').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('لا توجد فروع على الخريطة بعد'));
          }
          final branches = snapshot.data!.docs;
          final List<Marker> markers = [];
          for (final doc in branches) {
            final data = doc.data() as Map<String, dynamic>;
            final loc = data['location'];
            if (loc != null && loc['lat'] != null && loc['lng'] != null) {
              markers.add(
                Marker(
                  width: 40,
                  height: 40,
                  point: LatLng(loc['lat'], loc['lng']),
                  builder: (ctx) => Icon(Icons.location_on, color: Colors.deepPurple, size: 36),
                ),
              );
            }
          }
          return FlutterMap(
            options: MapOptions(
              center: LatLng(32.8872, 13.1913),
              zoom: 11,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.couponaMerchant',
              ),
              MarkerLayer(markers: markers),
            ],
          );
        },
      ),
    );
  }
}
