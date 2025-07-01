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

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController ctrl) {
    controller = ctrl;
    controller!.scannedDataStream.listen((scanData) async {
      controller?.pauseCamera();
      try {
        final rewardId = scanData.code;
        if (rewardId == null) {
          setState(() {
            _success = false;
            _message = 'لم يتم العثور على الكود';
          });
          return;
        }

        // تحقق من صحة الجائزة في Supabase
        final List<dynamic> rewardData = await _supabase
            .from('redeemed_rewards')
            .select()
            .eq('id', rewardId);

        if (rewardData.isNotEmpty && rewardData.first['status'] != 'confirmed') {
          await _supabase.from('redeemed_rewards').update({
            'status': 'confirmed',
            'confirmedAt': DateTime.now().toIso8601String()
          }).eq('id', rewardId);

          setState(() {
            _success = true;
            _message = 'تم خصم الجائزة بنجاح';
          });
        } else {
          setState(() {
            _success = false;
            _message = 'الجائزة غير صالحة أو تم تأكيدها مسبقًا';
          });
        }
      } catch (e) {
        setState(() {
          _success = false;
          _message = 'حدث خطأ أثناء التأكيد: $e';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تأكيد الجائزة (QR)'),
        backgroundColor: Colors.deepPurple.shade700,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          if (_message != null)
            Container(
              color: _success ? Colors.green.shade100 : Colors.red.shade100,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(_success ? Icons.check_circle : Icons.error, color: _success ? Colors.green : Colors.red, size: 40),
                  const SizedBox(height: 10),
                  Text(_message!, style: TextStyle(fontSize: 18, color: _success ? Colors.green : Colors.red)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _message = null;
                        _success = false;
                      });
                      controller?.resumeCamera();
                    },
                    child: const Text('مسح كود آخر'),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
