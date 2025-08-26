import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/points_service.dart';
import '../models/points_scheme.dart';
import '../widgets/home_button.dart';

class PointsSettingsScreen extends StatefulWidget {
  const PointsSettingsScreen({super.key});

  @override
  State<PointsSettingsScreen> createState() => _PointsSettingsScreenState();
}

class _PointsSettingsScreenState extends State<PointsSettingsScreen> {
  PointsScheme? _scheme;
  bool _loading = true;
  String? _error;
  final _amountCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _perInvoiceCtrl = TextEditingController();
  String _mode = 'per_product';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(()=>_loading=true);
    try {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid == null) { _error = 'جلسة مفقودة'; return; }
      final scheme = await PointsService.fetchOrCreateScheme(uid);
      _scheme = scheme; _mode = scheme.mode;
      _amountCtrl.text = scheme.amountPerPoint?.toString() ?? '';
      _qtyCtrl.text = scheme.quantityPerPoint?.toString() ?? '';
      _perInvoiceCtrl.text = scheme.pointsPerInvoice?.toString() ?? '';
    } catch (e) { _error = e.toString(); }
    finally { if(mounted) setState(()=>_loading=false); }
  }

  Future<void> _save() async {
    final uid = Supabase.instance.client.auth.currentUser?.id; if (uid == null || _scheme==null) return;
    setState(()=>_loading=true);
    try {
      final newScheme = PointsScheme(
        id: _scheme!.id,
        merchantId: uid,
        mode: _mode,
        amountPerPoint: _mode=='per_amount'? double.tryParse(_amountCtrl.text.trim()): null,
        quantityPerPoint: _mode=='per_quantity'? int.tryParse(_qtyCtrl.text.trim()): null,
        pointsPerInvoice: _mode=='per_invoice'? int.tryParse(_perInvoiceCtrl.text.trim()): null,
        createdAt: _scheme!.createdAt,
        updatedAt: DateTime.now(),
      );
      _scheme = await PointsService.updateScheme(uid, newScheme);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحفظ')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الحفظ: $e')));
    } finally { if(mounted) setState(()=>_loading=false); }
  }

  Widget _modeHelp() {
    switch (_mode) {
      case 'per_amount': return const Text('مثال: كل 10 دينار = 1 نقطة. أدخل قيمة الدينار لكل نقطة.');
      case 'per_quantity': return const Text('مثال: كل 20 قطعة = 1 نقطة. أدخل عدد القطع لكل نقطة.');
      case 'per_invoice': return const Text('نقاط ثابتة لكل فاتورة/زيارة.');
      case 'per_product': return const Text('النقاط تأتي من حقل points في كل منتج.');
      default: return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إعداد نظام النقاط'), leading: const HomeButton(color: Colors.white), backgroundColor: Colors.deepPurple.shade700,),
      body: _loading ? const LinearProgressIndicator() : _error!=null? Center(child: Text(_error!)) : Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text('آلية احتساب النقاط', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height:8),
            DropdownButtonFormField<String>(
              value: _mode,
              items: const [
                DropdownMenuItem(value: 'per_product', child: Text('حسب كل منتج (الحقل points)')),
                DropdownMenuItem(value: 'per_amount', child: Text('حسب القيمة المالية (دينار لكل نقطة)')),
                DropdownMenuItem(value: 'per_quantity', child: Text('حسب الكمية الإجمالية (قطع لكل نقطة)')),
                DropdownMenuItem(value: 'per_invoice', child: Text('نقاط ثابتة لكل فاتورة')),
              ],
              onChanged: (v){ if(v!=null) setState(()=>_mode=v); },
            ),
            const SizedBox(height:12),
            _modeHelp(),
            const SizedBox(height:16),
            if(_mode=='per_amount') TextField(controller:_amountCtrl, decoration: const InputDecoration(labelText: 'القيمة (دينار) لكل نقطة', border: OutlineInputBorder()), keyboardType: TextInputType.number,),
            if(_mode=='per_quantity') TextField(controller:_qtyCtrl, decoration: const InputDecoration(labelText: 'عدد القطع لكل نقطة', border: OutlineInputBorder()), keyboardType: TextInputType.number,),
            if(_mode=='per_invoice') TextField(controller:_perInvoiceCtrl, decoration: const InputDecoration(labelText: 'النقاط لكل فاتورة', border: OutlineInputBorder()), keyboardType: TextInputType.number,),
            const SizedBox(height:24),
            ElevatedButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text('حفظ')),
            const SizedBox(height:32),
            const Text('ملاحظات', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height:8),
            const Text('يمكن لاحقاً إضافة مزج بين أكثر من وضع (مثلاً حد أدنى للفاتورة + نقاط المنتج).'),
          ],
        ),
      ),
    );
  }
}
