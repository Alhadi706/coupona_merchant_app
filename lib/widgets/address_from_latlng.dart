import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class AddressFromLatLng extends StatefulWidget {
  final double latitude;
  final double longitude;

  const AddressFromLatLng({Key? key, required this.latitude, required this.longitude}) : super(key: key);

  @override
  _AddressFromLatLngState createState() => _AddressFromLatLngState();
}

class _AddressFromLatLngState extends State<AddressFromLatLng> {
  String? _address;

  @override
  void initState() {
    super.initState();
    _getAddress();
  }

  Future<void> _getAddress() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(widget.latitude, widget.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        setState(() {
          _address = "${p.street}, ${p.locality}, ${p.administrativeArea}";
        });
      }
    } catch (e) {
      setState(() {
        _address = "Could not get address";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(_address ?? 'Loading address...');
  }
}
