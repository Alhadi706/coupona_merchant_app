import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// زر موحد للانتقال إلى لوحة التحكم الرئيسية
class HomeButton extends StatelessWidget {
  final Color? color;
  const HomeButton({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'الرئيسية',
      icon: Icon(Icons.home, color: color),
      onPressed: () => context.go('/dashboard'),
    );
  }
}
