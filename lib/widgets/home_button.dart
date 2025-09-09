import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:coupona_merchant/gen_l10n/app_localizations.dart';

/// زر موحد للانتقال إلى لوحة التحكم الرئيسية
class HomeButton extends StatelessWidget {
  final Color? color;
  const HomeButton({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return IconButton(
      tooltip: loc?.home ?? 'Home',
      icon: Icon(Icons.home, color: color),
      onPressed: () => context.go('/dashboard'),
    );
  }
}
