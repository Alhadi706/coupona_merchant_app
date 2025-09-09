import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/points_service.dart';
import '../models/points_scheme.dart';
import '../widgets/home_button.dart';
import 'package:coupona_merchant/gen_l10n/app_localizations.dart';


class PointsSettingsScreen extends StatefulWidget {
  const PointsSettingsScreen({super.key});

  @override
  State<PointsSettingsScreen> createState() => _PointsSettingsScreenState();
}

class _PointsSettingsScreenState extends State<PointsSettingsScreen> {
  PointsScheme? _scheme;
  bool _loading = true;
  String? _error;

  AppLocalizations? get loc => AppLocalizations.of(context);

  @override
  void initState() { super.initState(); _init(); }

  Future<void> _init() async {
    setState(()=>_loading=true);
    try {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid == null) { _error = 'جلسة مفقودة'; return; }
      // نضمن وجود صف بالمود per_product فقط
      _scheme = await PointsService.fetchOrCreateScheme(uid);
    } catch (e) { _error = e.toString(); }
    finally { if(mounted) setState(()=>_loading=false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(loc?.pointsSystemTitle ?? 'Points System'), leading: const HomeButton(color: Colors.white), backgroundColor: Colors.deepPurple.shade700),
      body: _loading ? const LinearProgressIndicator() : _error!=null? Center(child: Text(_error!)) : Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(loc?.pointsMechanismTitle ?? 'Calculation Mechanism', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height:8),
            Text(loc?.pointsSimplifiedDescription ?? ''),
            const SizedBox(height:24),
            Text(loc?.pointsSimplificationBenefitsTitle ?? 'Benefits', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height:4),
            Text(loc?.pointsSimplificationBenefitsBullet ?? ''),
          ],
        ),
      ),
    );
  }
}
