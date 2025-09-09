import 'package:flutter/material.dart';
import 'reward_qr_scanner_screen.dart';

class ConfirmRewardScreen extends StatefulWidget {
  const ConfirmRewardScreen({Key? key}) : super(key: key);

  @override
  State<ConfirmRewardScreen> createState() => _ConfirmRewardScreenState();
}

class _ConfirmRewardScreenState extends State<ConfirmRewardScreen> {
  @override
  Widget build(BuildContext context) {
    // Delegate to unified scanner implementation
    return const RewardQrScannerScreen();
  }
}