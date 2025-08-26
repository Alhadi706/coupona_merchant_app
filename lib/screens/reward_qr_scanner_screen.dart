import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/reward_service.dart';

class RewardQrScannerScreen extends StatefulWidget {
  const RewardQrScannerScreen({Key? key}) : super(key: key);

  @override
  State<RewardQrScannerScreen> createState() => _RewardQrScannerScreenState();
}

class _RewardQrScannerScreenState extends State<RewardQrScannerScreen> {
  final _tokenController = TextEditingController();
  bool _loading = false;
  String? _status;
  bool _scannedOnce = false;

  bool get _canUseCamera => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<void> _redeemToken(String token) async {
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل الرمز')));
      return;
    }
    setState(() { _loading = true; _status = 'جارٍ التحقق...'; });
    final result = await RewardService.redeemByToken(token.trim());
    if (!mounted) return;
    setState(() { _loading = false; _status = result.message; });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(result.message),
      backgroundColor: result.success ? Colors.green : Colors.red,
    ));
  }

  Future<void> _redeemManual() => _redeemToken(_tokenController.text.trim());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('استرداد جائزة')),
      body: Column(
        children: [
          if (_canUseCamera)
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  MobileScanner(
                    onDetect: (capture) {
                      if (_scannedOnce) return; // منع التكرار السريع
                      final barcodes = capture.barcodes;
                      if (barcodes.isEmpty) return;
                      final raw = barcodes.first.rawValue ?? '';
                      if (raw.isEmpty) return;
                      _scannedOnce = true;
                      _redeemToken(raw).then((_) => Future.delayed(const Duration(seconds: 2), (){ _scannedOnce = false; }));
                    },
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                      child: const Text('وجّه الكاميرا نحو QR', style: TextStyle(color: Colors.white)),
                    ),
                  )
                ],
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('المتصفح لا يدعم الكاميرا هنا، استخدم الإدخال اليدوي للرمز.'),
            ),
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('أدخل الرمز (في حال عدم نجاح المسح):'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _tokenController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'qr_token',
                      prefixIcon: Icon(Icons.qr_code),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _redeemManual,
                      icon: _loading ? const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2,color:Colors.white)) : const Icon(Icons.verified),
                      label: const Text('تحقق وتسليم'),
                    ),
                  ),
                  if (_status != null) ...[
                    const SizedBox(height: 16),
                    Text(_status!, style: TextStyle(color: _status!.contains('نجاح') ? Colors.green : Colors.red)),
                  ],
                  const Divider(height: 32),
                  Text(_canUseCamera
                      ? 'تم تفعيل الكاميرا على الجهاز. في الويب يظهر فقط الإدخال اليدوي.'
                      : 'الوضع الحالي: إدخال يدوي فقط (ويب أو منصة غير مدعومة).'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
