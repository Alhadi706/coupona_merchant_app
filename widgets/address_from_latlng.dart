import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';

class AddressFromLatLng extends StatelessWidget {
  final LatLng latLng;
  final TextStyle? style;
  const AddressFromLatLng({required this.latLng, this.style, Key? key}) : super(key: key);

  Future<String> _getAddress(String langCode) async {
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${latLng.latitude}&lon=${latLng.longitude}&zoom=18&addressdetails=1&accept-language=$langCode');
      final response = await http.get(url, headers: {
        'User-Agent': 'coupona_merchant_app',
      });
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'] ?? {};
        String street = address['road'] ?? address['neighbourhood'] ?? '';
        String city = address['city'] ?? address['town'] ?? address['village'] ?? address['state'] ?? '';
        String result = street.isNotEmpty ? '$street, $city' : city;
        return result.isNotEmpty ? result : 'عنوان غير متوفر';
      }
      return 'عنوان غير متوفر';
    } catch (e) {
      return 'عنوان غير متوفر';
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return FutureBuilder<String>(
      future: _getAddress(languageCode),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('...جاري جلب العنوان');
        }
        if (snapshot.hasError) {
          return const Text('عنوان غير متوفر');
        }
        return Text(snapshot.data ?? 'عنوان غير متوفر', style: style);
      },
    );
  }
}
