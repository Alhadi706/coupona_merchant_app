import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kDebugMode
import 'package:firebase_auth/firebase_auth.dart'; // قد نحذفه لاحقاً إذا توقفنا عن الاعتماد على Firebase هنا
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:coupona_merchant/widgets/home_button.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:coupona_merchant/gen_l10n/app_localizations.dart';
import '../models/points_scheme.dart';
import '../services/points_service.dart';
import '../services/product_search_service.dart';

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
  AppLocalizations? get loc => AppLocalizations.of(context);
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
  PointsScheme? _scheme; // مخطط النقاط الحالي (الوضع الوحيد per_product)
  bool _loadingScheme = false;
  bool get _isPerProduct => true; // النظام مبسط

  // بحث فوري / غامض
  final _searchController = TextEditingController();
  List<Map<String,dynamic>> _searchResults = [];
  bool _searching = false;
  String _lastSearchQuery = '';

  // وضع احتساب النقاط عند إضافة المنتج (اختياري جديد)
  final _ruleValueController = TextEditingController();
  final _rulePointsController = TextEditingController();
  String _selectedBasisMode = 'product'; // product | price | quantity | operation

  // قائمة إجراءات عبر BottomSheet (بديل عن FAB الموسع الذي تسبب في عدم الظهور)

  // تم نقل الصنف _ParsedProduct إلى الأعلى

  static const _nameHeaders = ['name','اسم','product','المنتج'];
  static const _pointsHeaders = ['points','النقاط','pts','required_points'];

  @override
  void initState() {
    super.initState();
    _ensureTable();
    _productsFuture = _fetchProducts();
    _loadScheme();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
  _ruleValueController.dispose();
  _rulePointsController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final q = _searchController.text.trim();
    if (q == _lastSearchQuery) return;
    _lastSearchQuery = q;
    if (q.isEmpty) {
      setState(() { _searchResults = []; });
      return;
    }
    _runFuzzySearch(q);
  }

  Future<void> _runFuzzySearch(String q) async {
    setState(() { _searching = true; });
    try {
      final res = await ProductSearchService.fuzzySearch(q, limit: 20);
      if (mounted) setState(() { _searchResults = res; });
    } catch (_) {
      // تجاهل الأخطاء (قد لا تكون الدالة منشأة بعد)
    } finally {
      if (mounted) setState(() { _searching = false; });
    }
  }

  Future<void> _loadScheme() async {
    setState(() { _loadingScheme = true; });
    try {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid != null) {
        _scheme = await PointsService.fetchOrCreateScheme(uid);
      }
    } catch (_) {
      // تجاهل الخطأ (ربما الجدول غير موجود بعد)
    } finally {
      if (mounted) setState(() { _loadingScheme = false; });
    }
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
    if (rows.isEmpty) throw (loc?.csvFileEmpty ?? 'Empty file');
      final first = rows.first.map((c) => c.toString().trim()).toList();
      final lower = first.map((c) => c.toLowerCase()).toList();
  final hasHeader = lower.any((h) => _nameHeaders.contains(h));
      final start = hasHeader ? 1 : 0;
      final header = hasHeader ? lower : null;
      final parsed = <_ParsedProduct>[];
      for (var i = start; i < rows.length; i++) {
        final r = rows[i];
        if (r.isEmpty) continue;
  String? name; String? pointsStr; String? error;
        if (header != null) {
          final nameIdx = header.indexWhere((h) => _nameHeaders.contains(h));
          if (nameIdx >= 0 && nameIdx < r.length) name = r[nameIdx]?.toString().trim();
          final ptsIdx = header.indexWhere((h) => _pointsHeaders.contains(h));
          if (ptsIdx >= 0 && ptsIdx < r.length) pointsStr = r[ptsIdx]?.toString().trim();
        } else {
          if (r.length >= 2) {
            name = r[0]?.toString().trim();
            pointsStr = r[1]?.toString().trim();
          } else if (r.isNotEmpty) {
            name = r[0]?.toString().trim();
          }
        }
        if (name == null || name.isEmpty) error = 'اسم مفقود';
        int? pts = int.tryParse(pointsStr ?? '');
        if (error == null && (pts == null || pts <= 0)) error = 'نقاط غير صالحة';
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
            subtitle: Text(p.valid
              ? 'النقاط: ${p.points}'
              : 'خطأ: ${p.error}', style: const TextStyle(fontSize: 11)),
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
  // أزلنا السعر
  _ruleValueController.clear();
  _rulePointsController.clear();
  _selectedBasisMode = 'product';
  // Debug trace
  // ignore: avoid_print
  print('[ADD_PRODUCT] open dialog');
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
  title: Text(loc?.addProductTitle ?? 'Add Product'),
        content: StatefulBuilder(builder: (c, setSt){
          Widget ruleSection(){
            switch(_selectedBasisMode){
              case 'price':
                return _buildRuleRow(labelValue: loc?.ruleValuePriceLabel ?? 'Price', labelPoints: loc?.rulePointsLabel ?? 'Points', helper: loc?.ruleExamplePrice);
              case 'quantity':
                return _buildRuleRow(labelValue: loc?.ruleValueQuantityLabel ?? 'Quantity', labelPoints: loc?.rulePointsLabel ?? 'Points', helper: loc?.ruleExampleQuantity);
              case 'operation':
                return _buildRuleRow(labelValue: loc?.ruleValueOperationLabel ?? 'Operations', labelPoints: loc?.rulePointsLabel ?? 'Points', helper: loc?.ruleExampleOperation);
              case 'product':
              default:
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _pointsController,
                      decoration: InputDecoration(labelText: loc?.productPointsLabel ?? 'Points'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                );
            }
          }
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: loc?.productNameLabel ?? 'Product name'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(loc?.basisSelectionLabel ?? 'Points based on:', style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedBasisMode,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        items: [
                          DropdownMenuItem(value: 'product', child: Text(loc?.basisProductDirect ?? 'Direct')),
                          DropdownMenuItem(value: 'price', child: Text(loc?.basisPrice ?? 'Price')),
                          DropdownMenuItem(value: 'quantity', child: Text(loc?.basisQuantity ?? 'Quantity')),
                          DropdownMenuItem(value: 'operation', child: Text(loc?.basisOperation ?? 'Operation')),
                        ],
                        onChanged: (v){
                          setSt((){ _selectedBasisMode = v ?? 'product'; });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ruleSection(),
              ],
            ),
          );
        }),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(loc?.cancel ?? 'Cancel')),
          ElevatedButton(
            onPressed: _inserting ? null : () async {
              final name = _nameController.text.trim();
              int directPoints = int.tryParse(_pointsController.text.trim()) ?? 0;
              double? basisValue;
              int? basisPoints;
              if (name.isEmpty) return;
              if (_selectedBasisMode == 'product') {
                if (directPoints <= 0) return; 
              } else {
                basisValue = double.tryParse(_ruleValueController.text.trim());
                basisPoints = int.tryParse(_rulePointsController.text.trim());
                if (basisValue == null || basisValue <= 0) return;
                if (basisPoints == null || basisPoints <= 0) return;
                // نعرضها كنقاط افتراضية حالياً = basisPoints (يمكن تغيير الحساب لاحقاً)
                directPoints = basisPoints;
              }
              setState(() { _inserting = true; });
              final supabase = Supabase.instance.client;
              final supaUid = supabase.auth.currentUser?.id;
              if (supaUid == null) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc?.supabaseSessionMissing ?? 'Session missing')));
                setState(() { _inserting = false; });
                return;
              }
              try {
                await supabase.from('merchant_products').insert({
                  'merchant_id': supaUid,
                  'name': name,
                  'points': directPoints,
                  'basis_mode': _selectedBasisMode,
                  'basis_value': basisValue,
                  'basis_points': basisPoints,
                  // لا يوجد سعر
                  'created_at': DateTime.now().toIso8601String(),
                });
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc?.productAdded ?? 'Added')));
                  _reloadProducts();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${loc?.productAddFailed ?? 'Add failed'}: $e')));
                }
              } finally {
                if (mounted) setState(() { _inserting = false; });
              }
            },
            child: _inserting ? const SizedBox(width:20,height:20,child: CircularProgressIndicator(strokeWidth:2,color: Colors.white)) : Text(loc?.addProduct ?? 'Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _editProductDialog(Map<String,dynamic> product) async {
  final isPerProduct = _isPerProduct;
    _nameController.text = product['name'] ?? '';
  _pointsController.text = (product['points'] ?? '').toString();
  // لا سعر
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
  title: Text(loc?.editProductTitle ?? 'Edit Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              enabled: false,
              decoration: InputDecoration(labelText: loc?.productNameImmutable ?? 'Product name (immutable)'),
            ),
            TextField(
              controller: _pointsController,
              decoration: InputDecoration(labelText: loc?.productPointsLabel ?? 'Points'),
              keyboardType: TextInputType.number,
            ),
            // لا حقل سعر
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(loc?.cancel ?? 'Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newPoints = int.tryParse(_pointsController.text.trim()) ?? 0;
              if (newPoints <= 0) return;
              try {
                final supaUid = Supabase.instance.client.auth.currentUser?.id;
                if (supaUid == null) return;
                await Supabase.instance.client
                    .from('merchant_products')
                    .update({'points': newPoints})
                    .eq('id', product['id'])
                    .eq('merchant_id', supaUid);
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc?.productUpdated ?? 'Updated')));
                  _reloadProducts();
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${loc?.productUpdateFailed ?? 'Update failed'}: $e')));
              }
            },
            child: const Text('حفظ'),
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
  final loc = AppLocalizations.of(context);
  return Scaffold(
      appBar: AppBar(
    title: Text(loc?.productsScreenTitle ?? 'Products'),
        backgroundColor: Colors.deepPurple.shade700,
        leading: const HomeButton(color: Colors.white),
      ),
      floatingActionButton: GestureDetector(
        onLongPress: _showFabMenu,
        child: FloatingActionButton.extended(
          onPressed: _addProductDialog,
          icon: const Icon(Icons.add),
          label: const Text('إضافة'),
          backgroundColor: Colors.deepPurple,
        ),
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
                    label: _bulkLoading ? const SizedBox(height:16,width:16,child: CircularProgressIndicator(strokeWidth:2,color: Colors.white)) : Text(loc?.importCsv ?? 'Import CSV'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple.shade400),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _bulkLoading ? null : _showTemplate,
                    icon: const Icon(Icons.description_outlined),
                    label: Text(loc?.csvTemplate ?? 'Template'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _exporting ? null : _exportCsv,
                    icon: const Icon(Icons.file_download),
                    label: _exporting ? const SizedBox(height:16,width:16,child: CircularProgressIndicator(strokeWidth:2,color: Colors.white)) : Text(loc?.exportCsv ?? 'Export CSV'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple.shade300),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: (_bulkLoading || _exporting) ? null : _reloadProducts,
                    icon: const Icon(Icons.refresh),
                    label: Text(loc?.refresh ?? 'Refresh'),
                  ),
                ),
              ],
            ),
          ),
          if (kDebugMode)
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 2),
              child: Text(loc?.debugProductsBanner ?? '[DEBUG] Products', style: const TextStyle(color: Colors.grey, fontSize: 11), textAlign: TextAlign.center),
            ),
          // شريط بحث
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: loc?.searchHintProducts ?? 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () { _searchController.clear(); },
                      ),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  if (_searching) const SizedBox(height:16,width:16,child: CircularProgressIndicator(strokeWidth:2)),
                  if (_searching) const SizedBox(width: 8),
                  Text(loc?.searchResultsCount(_searchResults.length) ?? 'Results: ${_searchResults.length}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  const Spacer(),
                  TextButton(
                    onPressed: _searchController.text.isEmpty ? null : () { _searchController.clear(); },
                    child: Text(loc?.clear ?? 'Clear'),
                  )
                ],
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
  canonical_name text generated always as (lower(regexp_replace(name,'[^a-zA-Z0-9\u0600-\u06FF]+',' ','g'))) stored,
  points int not null,
  created_at timestamptz default now(),
  constraint uq_product_name_per_merchant unique (merchant_id, name),
  constraint uq_product_canonical_per_merchant unique (merchant_id, canonical_name)
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
            child: _searchController.text.isNotEmpty
                ? _buildSearchResults()
                : FutureBuilder<List<Map<String, dynamic>>>(
                    future: _productsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('${loc?.unexpectedError ?? 'Error'}: ${snapshot.error}'));
                      }
                      final products = snapshot.data ?? [];
                      if (products.isEmpty) {
                        return Center(child: Text(loc?.noProductsYet ?? 'No products'));
                      }
                      return _buildProductsList(products);
                    },
                  ),
          ),
        ],
      ),
    );
  }
  Widget _buildProductsList(List<Map<String,dynamic>> products) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final mode = product['basis_mode'] ?? 'product';
        String subtitle;
        if (mode == 'price') {
      subtitle = (product['basis_value'] != null)
        ? (loc?.priceRuleFormat('${product['basis_value']}', product['basis_points'] ?? product['points']) ?? 'Price ${product['basis_value']} = ${product['basis_points'] ?? product['points']} pts')
        : (loc?.pointsRuleFormat(product['points'] ?? 0) ?? 'Points: ${product['points'] ?? 0}');
        } else if (mode == 'quantity') {
      subtitle = (product['basis_value'] != null)
        ? (loc?.quantityRuleFormat('${product['basis_value']}', product['basis_points'] ?? product['points']) ?? 'Qty ${product['basis_value']} = ${product['basis_points'] ?? product['points']} pts')
        : (loc?.pointsRuleFormat(product['points'] ?? 0) ?? 'Points: ${product['points'] ?? 0}');
        } else if (mode == 'operation') {
      subtitle = (product['basis_value'] != null)
        ? (loc?.operationRuleFormat('${product['basis_value']}', product['basis_points'] ?? product['points']) ?? 'Ops ${product['basis_value']} = ${product['basis_points'] ?? product['points']} pts')
        : (loc?.pointsRuleFormat(product['points'] ?? 0) ?? 'Points: ${product['points'] ?? 0}');
        } else {
          subtitle = loc?.pointsRuleFormat(product['points'] ?? 0) ?? 'Points: ${product['points'] ?? 0}';
        }
        return Card(
          child: ListTile(
            title: Text(product['name'] ?? ''),
            subtitle: Text(subtitle),
            trailing: IconButton(
              icon: const Icon(Icons.edit, size: 20),
              tooltip: loc?.editPointsTooltip ?? 'Edit points',
              onPressed: () => _editProductDialog(product),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    if (_searching && _searchResults.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_searchResults.isEmpty) {
      return const Center(child: Text('لا نتائج')); 
    }
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final p = _searchResults[index];
        final sim = p['similarity'];
        final simStr = sim is num ? (sim as num).toStringAsFixed(2) : '-';
        final mode = p['basis_mode'] ?? 'product';
        String subtitle;
        if (mode == 'price') {
          subtitle = (loc?.priceRuleFormat('${p['basis_value']}', p['basis_points'] ?? p['points']) ?? 'Price ${p['basis_value']} = ${p['basis_points'] ?? p['points']} pts') + ' | ' + (loc?.similarityFormat(simStr) ?? 'Similarity: $simStr');
        } else if (mode == 'quantity') {
          subtitle = (loc?.quantityRuleFormat('${p['basis_value']}', p['basis_points'] ?? p['points']) ?? 'Qty ${p['basis_value']} = ${p['basis_points'] ?? p['points']} pts') + ' | ' + (loc?.similarityFormat(simStr) ?? 'Similarity: $simStr');
        } else if (mode == 'operation') {
          subtitle = (loc?.operationRuleFormat('${p['basis_value']}', p['basis_points'] ?? p['points']) ?? 'Ops ${p['basis_value']} = ${p['basis_points'] ?? p['points']} pts') + ' | ' + (loc?.similarityFormat(simStr) ?? 'Similarity: $simStr');
        } else {
          subtitle = (loc?.pointsRuleFormat(p['points'] ?? 0) ?? 'Points: ${p['points'] ?? 0}') + ' | ' + (loc?.similarityFormat(simStr) ?? 'Similarity: $simStr');
        }
        return Card(
          color: Colors.indigo.shade50,
          child: ListTile(
            leading: const Icon(Icons.search),
            title: Text(p['name'] ?? ''),
            subtitle: Text(subtitle),
            trailing: IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _editProductDialog(p),
            ),
          ),
        );
      },
    );
  }

  void _showFabMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('إضافة منتج يدوي'),
              onTap: () { Navigator.pop(ctx); _addProductDialog(); },
            ),
            ListTile(
              leading: const Icon(Icons.file_upload),
              title: const Text('استيراد CSV'),
              onTap: () { Navigator.pop(ctx); _importCsv(); },
            ),
            ListTile(
              leading: const Icon(Icons.file_download),
              title: const Text('تصدير CSV'),
              onTap: () { Navigator.pop(ctx); _exportCsv(); },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('تحديث القائمة'),
              onTap: () { Navigator.pop(ctx); _reloadProducts(); },
            ),
          ],
        ),
      ),
    );
  }
}

// عنصر مساعد لبناء صف القاعدة = النقاط
extension on _MerchantProductsScreenState {
  Widget _buildRuleRow({required String labelValue, required String labelPoints, String? helper}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _ruleValueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: labelValue),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(' = ', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: TextField(
                controller: _rulePointsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: labelPoints),
              ),
            ),
          ],
        ),
        if (helper != null) Padding(
          padding: const EdgeInsets.only(top:6),
          child: Text(helper, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ),
      ],
    );
  }
}

