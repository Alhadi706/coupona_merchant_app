import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:coupona_merchant/widgets/home_button.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class MerchantStatsScreen extends StatefulWidget {
  const MerchantStatsScreen({super.key});

  @override
  State<MerchantStatsScreen> createState() => _MerchantStatsScreenState();
}

class _MerchantStatsScreenState extends State<MerchantStatsScreen> {
  bool _loading = true;
  String? _error;
  DateTimeRange? _range;
  String? _selectedBranchId; // للتصفية حسب الفرع مستقبلاً

  // نظرة عامة
  double _totalSales = 0;
  int _totalCustomers = 0;
  int _repeatCustomers = 0;

  // ديموغرافيا
  Map<String, int> genderDist = {}; // male / female / unknown
  Map<String, int> ageBuckets = {}; // 18-24 ...
  Map<String, int> geoDist = {}; // city counts

  // أداء المنتجات
  Map<String, int> productSalesCount = {}; // name -> qty
  Map<String, double> productRevenue = {}; // name -> revenue

  // مبيعات زمنية (يومياً)
  List<_DayPoint> salesTimeline = [];

  // توصيات
  List<String> recommendations = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _range = DateTimeRange(start: now.subtract(const Duration(days: 29)), end: now);
    _loadAll();
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year, now.month, now.day).add(const Duration(days: 1)),
      initialDateRange: _range,
      helpText: 'اختر نطاق التاريخ',
      locale: const Locale('ar'),
    );
    if (picked != null) {
      setState(() => _range = picked);
      _loadAll();
    }
  }

  bool _inRange(DateTime dt) => _range == null || (dt.isAfter(_range!.start.subtract(const Duration(seconds: 1))) && dt.isBefore(_range!.end.add(const Duration(seconds: 1))));

  Future<void> _loadAll() async {
    setState(() { _loading = true; _error = null; });
    try {
      await Future.wait([
        _loadOrdersAndProducts(),
        _loadCustomers(),
        _loadOffersForContext(),
      ]);
      _buildRecommendations();
      setState(() { _loading = false; });
    } catch (e) {
      setState(() { _error = 'خطأ: $e'; _loading = false; });
    }
  }

  Future<void> _loadOrdersAndProducts() async {
    final user = FirebaseAuth.instance.currentUser; if (user == null) return;
    final fs = FirebaseFirestore.instance;
    final ordersSnap = await fs.collection('orders').where('merchantId', isEqualTo: user.uid).get();
    _totalSales = 0; productSalesCount.clear(); productRevenue.clear(); salesTimeline.clear();
    final Map<String, double> dailySales = {};
    for (final doc in ordersSnap.docs) {
      final data = doc.data();
      DateTime? created;
      final raw = data['createdAt'] ?? data['created_at'];
      if (raw is Timestamp) created = raw.toDate();
      else if (raw is String) created = DateTime.tryParse(raw);
      created ??= DateTime.now();
      if (!_inRange(created)) continue;
      final total = (data['total'] is num) ? (data['total'] as num).toDouble() : 0.0;
      _totalSales += total;
      final dayKey = DateFormat('yyyy-MM-dd').format(created);
      dailySales[dayKey] = (dailySales[dayKey] ?? 0) + total;
      if (data['products'] is List) {
        for (final p in (data['products'] as List)) {
          if (p is Map) {
            final name = (p['name'] ?? 'غير معلوم').toString();
            final price = (p['price'] is num) ? (p['price'] as num).toDouble() : 0.0;
            productSalesCount[name] = (productSalesCount[name] ?? 0) + 1;
            productRevenue[name] = (productRevenue[name] ?? 0) + price;
          }
        }
      }
    }
    // بناء التايملاين
    final sortedKeys = dailySales.keys.toList()..sort();
    salesTimeline = [for (final k in sortedKeys) _DayPoint(DateTime.parse(k), dailySales[k]!)];
  }

  Future<void> _loadCustomers() async {
    final user = FirebaseAuth.instance.currentUser; if (user == null) return;
    final fs = FirebaseFirestore.instance;
    final customersSnap = await fs.collection('customers').where('merchantId', isEqualTo: user.uid).get();
    // فهرس حسب الهاتف لحساب التكرار (بديلاً عن customerId إن لم يوجد)
    final Set<String> uniqueCustomers = {}; final Set<String> repeated = {};
    genderDist.clear(); ageBuckets.clear(); geoDist.clear();
    for (final c in customersSnap.docs) {
      final data = c.data();
      final phone = (data['phone'] ?? c.id).toString();
      if (!uniqueCustomers.add(phone)) repeated.add(phone);
      final gender = (data['gender'] ?? 'غير محدد').toString();
      genderDist[gender] = (genderDist[gender] ?? 0) + 1;
      final age = data['age'];
      _bucketAge(age);
      final city = (data['city'] ?? (data['location']?['city']) ?? 'غير معروف').toString();
      geoDist[city] = (geoDist[city] ?? 0) + 1;
    }
    _totalCustomers = uniqueCustomers.length;
    _repeatCustomers = repeated.length;
  }

  void _bucketAge(dynamic ageVal) {
    if (ageVal == null) { ageBuckets['غير معروف'] = (ageBuckets['غير معروف'] ?? 0) + 1; return; }
    int? age;
    if (ageVal is int) age = ageVal; else if (ageVal is String) age = int.tryParse(ageVal);
    if (age == null) { ageBuckets['غير معروف'] = (ageBuckets['غير معروف'] ?? 0) + 1; return; }
    String bucket;
    if (age < 18) bucket = '<18'; else if (age <= 24) bucket = '18-24'; else if (age <= 34) bucket = '25-34'; else if (age <= 44) bucket = '35-44'; else if (age <= 54) bucket = '45-54'; else bucket = '55+';
    ageBuckets[bucket] = (ageBuckets[bucket] ?? 0) + 1;
  }

  Future<void> _loadOffersForContext() async { /* يمكن لاحقاً استخدام البيانات لتوليد توصيات توقيت */ }

  void _buildRecommendations() {
    recommendations.clear();
    if (productSalesCount.isNotEmpty) {
      // أقل منتج مبيعاً
      final low = productSalesCount.entries.reduce((a,b)=> a.value <= b.value ? a : b);
      final high = productSalesCount.entries.reduce((a,b)=> a.value >= b.value ? a : b);
      if (low.value < high.value * 0.3) {
        recommendations.add('المنتج "${low.key}" ضعيف الأداء – فكر في عرض ترويجي أو تحسين صورته.');
      }
    }
    final repeatRate = _totalCustomers == 0 ? 0 : (_repeatCustomers / _totalCustomers);
    if (repeatRate < 0.15) {
      recommendations.add('معدل التكرار منخفض (${(repeatRate*100).toStringAsFixed(1)}%). جرّب برنامج ولاء أو نقاط إضافية.');
    }
    if (_totalSales == 0) {
      recommendations.add('لا توجد مبيعات في النطاق المحدد – تأكد من اختيار تاريخ صحيح أو أضف منتجات.');
    }
    if (recommendations.isEmpty) recommendations.add('الأداء مستقر – استمر في التحسين التدريجي.');
  }

  double get repeatRate => _totalCustomers == 0 ? 0 : _repeatCustomers / _totalCustomers;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return Scaffold(
      appBar: AppBar(
        title: const Text('التحليلات والإحصائيات'),
        leading: const HomeButton(),
        actions: [
          IconButton(onPressed: _pickRange, tooltip: 'تحديد تاريخ', icon: const Icon(Icons.date_range)),
          IconButton(onPressed: _loadAll, tooltip: 'تحديث', icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _loadAll,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOverviewCards(isWide),
                        const SizedBox(height: 16),
                        _sectionTitle('التركيبة الديموغرافية'),
                        _wrapResponsive([
                          _chartCard('توزيع الجنس', _buildGenderPie()),
                          _chartCard('الفئات العمرية', _buildAgeBar()),
                          _chartCard('التوزيع الجغرافي (أعلى المدن)', _buildGeoList()),
                        ], isWide),
                        const SizedBox(height: 16),
                        _sectionTitle('أداء المنتجات'),
                        _chartCard('أفضل وأسوأ المنتجات', _buildProductsPerformance()),
                        const SizedBox(height: 16),
                        _sectionTitle('المبيعات عبر الزمن'),
                        _chartCard('المخطط الزمني', _buildSalesLine()),
                        const SizedBox(height: 16),
                        _sectionTitle('التوصيات الذكية'),
                        _buildRecommendationsList(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildOverviewCards(bool wide) {
    final items = [
      _MetricTile(label: 'إجمالي المبيعات', value: NumberFormat.compactCurrency(symbol: 'د.ل', decimalDigits: 1).format(_totalSales)),
      _MetricTile(label: 'عدد الزبائن', value: _totalCustomers.toString()),
      _MetricTile(label: 'معدل التكرار', value: '${(repeatRate*100).toStringAsFixed(1)}%'),
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((w)=> SizedBox(width: wide? (MediaQuery.of(context).size.width-64)/3 : MediaQuery.of(context).size.width/1 - 32, child: w)).toList(),
    );
  }

  Widget _chartCard(String title, Widget child) => Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(height: 220, child: child),
            ],
          ),
        ),
      );

  Widget _buildGenderPie() {
    if (genderDist.isEmpty) return const Center(child: Text('لا بيانات'));
    final total = genderDist.values.fold<int>(0, (a,b)=>a+b);
    int index = 0;
    final colors = [Colors.blue, Colors.pink, Colors.grey];
    return PieChart(PieChartData(
      sections: genderDist.entries.map((e){
        final color = colors[index++ % colors.length];
        final pct = total==0?0:(e.value/total*100);
        return PieChartSectionData(
          value: e.value.toDouble(),
          title: '${pct.toStringAsFixed(1)}%',
          color: color,
          radius: 60,
        );
      }).toList(),
      sectionsSpace: 2,
      centerSpaceRadius: 30,
    )) ;
  }

  Widget _buildAgeBar() {
    if (ageBuckets.isEmpty) return const Center(child: Text('لا بيانات'));
    final keys = ageBuckets.keys.toList()..sort();
    final maxVal = ageBuckets.values.isEmpty?1:ageBuckets.values.reduce((a,b)=> a>b?a:b);
    return BarChart(BarChartData(
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m){
          final idx = v.toInt(); if (idx<0 || idx>=keys.length) return const SizedBox.shrink();
          return Transform.rotate(angle: -0.8, child: Text(keys[idx], style: const TextStyle(fontSize: 10)));
        })),
      ),
      barGroups: [for (int i=0;i<keys.length;i++) BarChartGroupData(x: i, barRods: [BarChartRodData(toY: ageBuckets[keys[i]]!.toDouble(), gradient: LinearGradient(colors:[Colors.deepPurple, Colors.purpleAccent]))])],
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      maxY: maxVal.toDouble()*1.2,
    ));
  }

  Widget _buildSalesLine() {
    if (salesTimeline.isEmpty) return const Center(child: Text('لا توجد مبيعات في النطاق'));
    final spots = <FlSpot>[];
    for (int i=0;i<salesTimeline.length;i++) {
      spots.add(FlSpot(i.toDouble(), salesTimeline[i].value));
    }
    return LineChart(LineChartData(
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta){
          final idx = v.toInt();
          if (idx<0 || idx>=salesTimeline.length) return const SizedBox.shrink();
          final d = salesTimeline[idx].date;
          return Text(DateFormat('MM/dd').format(d), style: const TextStyle(fontSize: 10));
        })),
      ),
      gridData: const FlGridData(show: true),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.deepPurple,
          barWidth: 3,
          belowBarData: BarAreaData(show: true, color: Colors.deepPurple.withOpacity(0.15)),
          dotData: const FlDotData(show: false),
        )
      ],
    ));
  }

  Widget _buildProductsPerformance() {
    if (productSalesCount.isEmpty) return const Center(child: Text('لا بيانات منتجات')); 
    final sorted = productSalesCount.entries.toList()
      ..sort((a,b)=> b.value.compareTo(a.value));
    final top = sorted.take(5);
    final worst = sorted.reversed.take(3);
    return Column(
      children: [
        Expanded(child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            const Text('الأكثر مبيعاً', style: TextStyle(fontWeight: FontWeight.bold)),
            ...top.map((e)=> ListTile(dense:true,title: Text(e.key), trailing: Text('${e.value}'))),
            const SizedBox(height:8),
            const Text('الأقل مبيعاً', style: TextStyle(fontWeight: FontWeight.bold)),
            ...worst.map((e)=> ListTile(dense:true,title: Text(e.key), trailing: Text('${e.value}'))),
          ],
        )),
      ],
    );
  }

  Widget _buildGeoList() {
    if (geoDist.isEmpty) return const Center(child: Text('لا بيانات مواقع'));
    final sorted = geoDist.entries.toList()..sort((a,b)=> b.value.compareTo(a.value));
    return ListView.builder(
      itemCount: sorted.length>5?5:sorted.length,
      itemBuilder: (c,i){
        final e = sorted[i];
        return ListTile(dense:true,title: Text(e.key), trailing: Text('${e.value}'));},
    );
  }

  Widget _buildRecommendationsList() => Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...recommendations.map((r)=> Padding(
            padding: const EdgeInsets.symmetric(vertical:4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb, color: Colors.amber),
                const SizedBox(width:8),
                Expanded(child: Text(r)),
              ],
            ),
          )),
        ],
      ),
    ),
  );

  Widget _sectionTitle(String t) => Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));

  Widget _wrapResponsive(List<Widget> children, bool wide) {
    if (!wide) return Column(children: children.map((c)=> Padding(padding: const EdgeInsets.only(bottom:12), child: c)).toList());
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.map((c)=> Expanded(child: Padding(padding: const EdgeInsets.only(left:6,right:6), child: c))).toList(),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label; final String value;
  const _MetricTile({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _DayPoint {
  final DateTime date; final double value;
  _DayPoint(this.date, this.value);
}
