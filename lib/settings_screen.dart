import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'l10n/locale_notifier.dart';
import 'gen_l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
  final ln = context.watch<LocaleNotifier>();
  final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
  title: Text(loc?.settings ?? 'Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc?.language ?? 'Language', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ln.supported.map((loc) {
                final active = ln.locale?.languageCode == loc.languageCode || (ln.locale == null && loc.languageCode == 'ar');
                return ChoiceChip(
                  label: Text(loc.languageCode.toUpperCase()),
                  selected: active,
                  onSelected: (_) => ln.setLocale(loc),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(loc?.settings ?? 'Settings'),
          ],
        ),
      ),
    );
  }
}
