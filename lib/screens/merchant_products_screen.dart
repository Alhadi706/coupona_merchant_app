import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kDebugMode
import 'package:firebase_auth/firebase_auth.dart'; // قد نحذفه لاحقاً إذا توقفنا عن الاعتماد على Firebase هنا
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:coupona_merchant/widgets/home_button.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:csv/csv.dart';

// نموذج صف محمّل من CSV (مستوى علوي بدلاً من داخل الـ State لتفادي خطأ التعشيش)
class _ParsedProduct {
  final String? name;
  final int? points;
  final String? error;
  _ParsedProduct({this.name, this.points, this.error});
  bool get valid => error == null && name != null && points != null && points! > 0;
}

class MerchantProductsScreen extends StatefulWidget {
  const MerchantProductsScreen({Key? key}) : super(key: key);

  @override
  State<MerchantProductsScreen> createState() => _MerchantProductsScreenState();
}

class _MerchantProductsScreenState extends State<MerchantProductsScreen> {
  final _nameController = TextEditingController();
  final _pointsController = TextEditingController();
  bool _initializing = false;
  String? _initError;
  bool _inserting = false;
  Future<List<Map<String, dynamic>>>? _productsFuture;
  bool _bulkLoading = false;
  bool _exporting = false;
  // للمعاينة المتقدمة
  bool _importingPreview = false;

  // تم نقل الصنف _ParsedProduct إلى الأعلى

  static const _nameHeaders = ['name','اسم','product','المنتج'];
  static const _pointsHeaders = ['points','النقاط','pts','required_points'];

  @override
  void initState() {
    super.initState();
    _ensureTable();
  _productsFuture = _fetchProducts();
  }

  Future<void> _ensureTable() async {
    setState(() { _initializing = true; _initError = null; });
    final supabase = Supabase.instance.client;
    try {
      // محاولة قراءة صف واحد لمعرفة إن كان الجدول موجوداً
      await supabase.from('merchant_products').select('id').limit(1);
    } catch (e) {
      final msg = e.toString();
      // كود Postgres 42P01 = الجدول غير موجود
      if (msg.contains('42P01') || msg.contains('does not exist')) {
        // سننشئ الجدول عبر استدعاء RPC بسيط (يتطلب صلاحية) أو نطلب من المستخدم تنفيذ SQL يدوياً.
        // هنا نعرض تعليمات فقط بدلاً من تنفيذ مباشر لأن تنفيذ SQL raw غير متاح من عميل Flutter بدون وظيفة
        _initError = 'جدول merchant_products غير موجود. الرجاء إنشاءه في Supabase SQL.';
      } else {
        _initError = 'خطأ أثناء الفحص: $e';
      }
    } finally {
      if (mounted) setState(() { _initializing = false; });
    }
  }

  void _reloadProducts() {
    setState(() { _productsFuture = _fetchProducts(); });
  }

  Future<void> _importCsv() async {
    try {
      setState(() { _bulkLoading = true; });
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv']);
      if (result == null || result.files.isEmpty) { setState(() { _bulkLoading = false; }); return; }
      final file = result.files.first;
      final bytes = file.bytes ?? await file.readStream!.fold<List<int>>([], (p, e) { p.addAll(e); return p; });
      final content = utf8.decode(bytes);
      final rows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false).convert(content);
      if (rows.isEmpty) throw 'ملف فارغ';
      final first = rows.first.map((c) => c.toString().trim()).toList();
      final lower = first.map((c) => c.toLowerCase()).toList();
      final hasHeader = lower.any((h) => _nameHeaders.contains(h)) || lower.any((h) => _pointsHeaders.contains(h));
      final start = hasHeader ? 1 : 0;
      final header = hasHeader ? lower : null;
      final parsed = <_ParsedProduct>[];
      for (var i = start; i < rows.length; i++) {
        final r = rows[i];
        if (r.isEmpty) continue;
        String? name; String? pointsStr; String? error;
        if (header != null) {
          final nameIdx = header.indexWhere((h) => _nameHeaders.contains(h));
          final ptsIdx = header.indexWhere((h) => _pointsHeaders.contains(h));
          if (nameIdx >= 0 && nameIdx < r.length) name = r[nameIdx]?.toString().trim();
          if (ptsIdx >= 0 && ptsIdx < r.length) pointsStr = r[ptsIdx]?.toString().trim();
        } else if (r.length >= 2) {
          name = r[0]?.toString().trim();
          pointsStr = r[1]?.toString().trim();
        }
        if (name == null || name.isEmpty) {
          error = 'اسم مفقود';
        }
        final pts = int.tryParse(pointsStr ?? '');
        if (error == null && (pts == null || pts <= 0)) {
          error = 'نقاط غير صالحة';
        }
        parsed.add(_ParsedProduct(name: name, points: pts, error: error));
      }
      if (parsed.isEmpty) throw 'لا صفوف قابلة للمعالجة';
      if (!mounted) return;
      await _showPreviewDialog(parsed);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل التحليل: $e')));
    } finally {
      if (mounted) setState(() { _bulkLoading = false; });
    }
  }

  Future<void> _showPreviewDialog(List<_ParsedProduct> parsed) async {
    final valid = parsed.where((p) => p.valid).toList();
    final invalid = parsed.where((p) => !p.valid).toList();
    bool skipDuplicates = true;
    bool importing = false;
    int inserted = 0;
    await showDialog(context: context, barrierDismissible: !importing, builder: (ctx) {
      return StatefulBuilder(builder: (ctx, setSt) {
        Future<void> doImport() async {
          if (importing) return; setSt(() { importing = true; });
          try {
            final supaUid = Supabase.instance.client.auth.currentUser?.id;
            if (supaUid == null) throw 'جلسة مفقودة';
            // جلب الأسماء الحالية عند تفعيل تخطي المكررات
            final existingNames = <String>{};
            if (skipDuplicates) {
              final existing = await Supabase.instance.client
                  .from('merchant_products')
                  .select('name').eq('merchant_id', supaUid);
              for (final e in existing as List) {
                final n = (e['name'] ?? '').toString().trim().toLowerCase();
                if (n.isNotEmpty) existingNames.add(n);
              }
            }
            final toInsert = <Map<String,dynamic>>[];
            for (final p in valid) {
              final key = p.name!.trim().toLowerCase();
              if (skipDuplicates && existingNames.contains(key)) continue;
              existingNames.add(key);
              toInsert.add({
                'merchant_id': supaUid,
                'name': p.name,
                'points': p.points,
                'created_at': DateTime.now().toIso8601String(),
              });
            }
            if (toInsert.isEmpty) throw 'لا عناصر جديدة بعد تطبيق المكررات';
            const batchSize = 75;
            for (var i = 0; i < toInsert.length; i += batchSize) {
              final slice = toInsert.sublist(i, (i + batchSize).clamp(0, toInsert.length));
              await Supabase.instance.client.from('merchant_products').insert(slice);
              inserted += slice.length;
              setSt(() {});
            }
            if (mounted) {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم إدراج $inserted منتجاً (مرفوض ${invalid.length})')));
              _reloadProducts();
            }
          } catch (e) {
            setSt(() { importing = false; });
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الاستيراد: $e')));
          }
        }
        return AlertDialog(
          title: const Text('مراجعة الاستيراد'),
          content: SizedBox(
            width: 520,
            height: 440,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('صالحة: ${valid.length} | أخطاء: ${invalid.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Row(children: [
                  Checkbox(
                    value: skipDuplicates,
                    onChanged: importing ? null : (v) => setSt(() { skipDuplicates = v ?? true; }),
                  ),
                  const Flexible(child: Text('تخطي المنتجات ذات الاسم المكرر', style: TextStyle(fontSize: 12)))
                ]),
                const SizedBox(height: 4),
                Expanded(
                  child: ListView.builder(
                    itemCount: parsed.length,
                    itemBuilder: (c,i){
                      final p = parsed[i];
                      final color = p.valid ? Colors.green : Colors.red;
                      return ListTile(
                        dense: true,
                        leading: Icon(p.valid ? Icons.check_circle : Icons.error, color: color, size: 18),
                        title: Text(p.name ?? '-', style: TextStyle(color: color, fontSize: 13)),
                        subtitle: Text(p.valid ? 'النقاط: ${p.points}' : 'خطأ: ${p.error}', style: const TextStyle(fontSize: 11)),
                      );
                    },
                  ),
                ),
                if (importing) ...[
                  const SizedBox(height: 6),
                  LinearProgressIndicator(value: valid.isEmpty ? 0 : inserted / valid.length),
                ]
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: importing ? null : () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton.icon(
              onPressed: importing || valid.isEmpty ? null : doImport,
              icon: const Icon(Icons.cloud_upload),
              label: Text(importing ? 'جارٍ الإدراج...' : 'استيراد ${valid.length}')
            ),
          ],
        );
      });
    });
  }

  Future<void> _showTemplate() async {
    const sample = 'name,points\nLatte,12\nEspresso,8\nMuffin,6';
    await showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('نموذج CSV'),
      content: SizedBox(width: 420, child: SelectableText(sample, style: const TextStyle(fontSize: 12))),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق'))],
    ));
  }

  Future<void> _exportCsv() async {
    try {
      setState(() { _exporting = true; });
      final supabase = Supabase.instance.client;
      final supaUid = supabase.auth.currentUser?.id;
      if (supaUid == null) throw 'جلسة Supabase غير متوفرة';
      final data = await supabase.from('merchant_products').select().eq('merchant_id', supaUid).order('created_at', ascending: false);
      final list = List<Map<String,dynamic>>.from(data as List);
      final rows = <List<dynamic>>[];
      rows.add(['name','points']);
      for (final p in list) {
        rows.add([p['name'] ?? '', p['points'] ?? '']);
      }
      final csvStr = const ListToCsvConverter().convert(rows);
      if (!mounted) return;
      // عرض في حوار قابل للنسخ (حل متعدد المنصات بسيط)
      await showDialog(context: context, builder: (ctx) => AlertDialog(
        title: const Text('تصدير CSV'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: SelectableText(csvStr, style: const TextStyle(fontSize: 12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق')),
        ],
      ));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إنشاء CSV - انسخ النص')));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل التصدير: $e')));
      }
    } finally {
      if (mounted) setState(() { _exporting = false; });
    }
  }

  Future<void> _addProductDialog() async {
    _nameController.clear();
    _pointsController.clear();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة منتج جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'اسم المنتج'),
            ),
            TextField(
              controller: _pointsController,
              decoration: const InputDecoration(labelText: 'النقاط المطلوبة'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: _inserting ? null : () async {
              final name = _nameController.text.trim();
              final points = int.tryParse(_pointsController.text.trim()) ?? 0;
              if (name.isEmpty || points <= 0) return;
              setState(() { _inserting = true; });
              final supabase = Supabase.instance.client;
              final supaUid = supabase.auth.currentUser?.id;
              if (supaUid == null) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جلسة Supabase غير متوفرة، أعد تسجيل الدخول')));
                setState(() { _inserting = false; });
                return;
              }
              try {
                await supabase.from('merchant_products').insert({
                  'merchant_id': supaUid,
                  'name': name,
                  'points': points,
                  'created_at': DateTime.now().toIso8601String(),
                });
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت إضافة المنتج')));
                  _reloadProducts();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الإضافة: $e')));
                }
              } finally {
                if (mounted) setState(() { _inserting = false; });
              }
            },
            child: _inserting ? const SizedBox(width:20,height:20,child: CircularProgressIndicator(strokeWidth:2,color: Colors.white)) : const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    final supabase = Supabase.instance.client;
    final supaUid = supabase.auth.currentUser?.id;
    if (supaUid == null) {
      return [];
    }
    try {
      final response = await supabase
          .from('merchant_products')
          .select()
          .eq('merchant_id', supaUid)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      if (e.toString().contains('42P01')) {
        return [];
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
  final supaUid = Supabase.instance.client.auth.currentUser?.id; // للعرض فقط إن احتجنا
    return Scaffold(
      appBar: AppBar(
        title: const Text('منتجات المحل'),
        backgroundColor: Colors.deepPurple.shade700,
        leading: const HomeButton(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addProductDialog,
        icon: const Icon(Icons.add),
        label: const Text('إضافة منتج يدويًا'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _bulkLoading ? null : _importCsv,
                    icon: const Icon(Icons.file_upload),
                    label: _bulkLoading ? const SizedBox(height:16,width:16,child: CircularProgressIndicator(strokeWidth:2,color: Colors.white)) : const Text('استيراد CSV'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple.shade400),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _bulkLoading ? null : _showTemplate,
                    icon: const Icon(Icons.description_outlined),
                    label: const Text('نموذج'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _exporting ? null : _exportCsv,
                    icon: const Icon(Icons.file_download),
                    label: _exporting ? const SizedBox(height:16,width:16,child: CircularProgressIndicator(strokeWidth:2,color: Colors.white)) : const Text('تصدير CSV'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple.shade300),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: (_bulkLoading || _exporting) ? null : _reloadProducts,
                    icon: const Icon(Icons.refresh),
                    label: const Text('تحديث'),
                  ),
                ),
              ],
            ),
          ),
          if (kDebugMode)
            const Padding(
              padding: EdgeInsets.only(top: 6, bottom: 2),
              child: Text(
                '[DEBUG] شاشة المنتجات (يظهر فقط في التطوير)',
                style: TextStyle(color: Colors.grey, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ),
          if (_initializing)
            const LinearProgressIndicator(minHeight: 2),
          if (_initError != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Card(
                color: Colors.amber.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('تنبيه: الجدول غير موجود', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('قم بإنشاء جدول merchant_products في Supabase ثم أعد فتح الصفحة.'),
                      const SizedBox(height: 8),
                      const Text('SQL المقترح:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      SelectableText('''-- ملاحظة: تم استخدام merchant_id كـ text لأن جدول merchants يحتوي معرّفات قديمة (Firebase UID) وأخرى UUID.
-- بعد توحيد المعرفات يمكن تعديل النوع إلى uuid وإضافة مفتاح أجنبي.
create table if not exists merchant_products (
  id uuid primary key default gen_random_uuid(),
  merchant_id text not null,
  name text not null,
  points int not null,
  created_at timestamptz default now()
);
create index if not exists idx_merchant_products_merchant_id on merchant_products(merchant_id);
alter table merchant_products enable row level security;
create policy mp_select on merchant_products for select using (merchant_id = auth.uid()::text);
create policy mp_insert on merchant_products for insert with check (merchant_id = auth.uid()::text);
create policy mp_update on merchant_products for update using (merchant_id = auth.uid()::text);
create policy mp_delete on merchant_products for delete using (merchant_id = auth.uid()::text);''',
                        style: const TextStyle(fontSize: 11),),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _ensureTable,
                          icon: const Icon(Icons.refresh),
                          label: const Text('إعادة الفحص'),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('حدث خطأ: ${snapshot.error}'));
                }
                final products = snapshot.data ?? [];
                if (products.isEmpty) {
                  return const Center(child: Text('لا توجد منتجات بعد'));
                }
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      child: ListTile(
                        title: Text(product['name'] ?? ''),
                        subtitle: Text('النقاط: ${product['points'] ?? 0}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
