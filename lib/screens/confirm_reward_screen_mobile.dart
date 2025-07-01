import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ConfirmRewardScreen extends StatefulWidget {
  const ConfirmRewardScreen({Key? key}) : super(key: key);

  @override
  State<ConfirmRewardScreen> createState() => _ConfirmRewardScreenState();
}

class _ConfirmRewardScreenState extends State<ConfirmRewardScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _success = false;
  String? _message;
  String? _scannedCode;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController ctrl) {
    controller = ctrl;
    controller!.scannedDataStream.listen((scanData) {
      controller?.pauseCamera();
      setState(() {
        _scannedCode = scanData.code;
        // محاكاة التحقق من الجائزة بدون اتصال بقاعدة بيانات
        _success = _scannedCode != null && _scannedCode!.startsWith('REWARD_');
        _message = _success 
            ? 'تم تأكيد الجائزة بنجاح!\nكود الجائزة: $_scannedCode'
            : 'كود غير صالح - يجب أن يبدأ الكود بـ "REWARD_"';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تأكيد الجائزة (QR)'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.deepPurple,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),
          if (_message != null)
            Container(
              color: _success ? Colors.green.shade50 : Colors.red.shade50,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    _success ? Icons.check_circle : Icons.error,
                    color: _success ? Colors.green : Colors.red,
                    size: 50,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _message!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _success ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    onPressed: () {
                      setState(() {
                        _message = null;
                        _success = false;
                        _scannedCode = null;
                      });
                      controller?.resumeCamera();
                    },
                    child: const Text(
                      'مسح كود آخر',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          if (_message == null)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'امسح كود الجائزة لتأكيد الخصم',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '(يجب أن يبدأ الكود بـ "REWARD_")',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}