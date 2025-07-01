import 'package:flutter/material.dart';

class ConfirmRewardScreen extends StatelessWidget {
  const ConfirmRewardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تأكيد الجائزة')),
      body: const Center(
        child: Text('ميزة تأكيد الجوائز غير مدعومة على الويب.'),
      ),
    );
  }
}
