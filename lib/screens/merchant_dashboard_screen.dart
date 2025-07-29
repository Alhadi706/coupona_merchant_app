import 'package:coupona_merchant/screens/merchant_analytics_screen.dart';
import 'package:coupona_merchant/screens/merchant_customers_screen.dart';
import 'package:coupona_merchant/screens/merchant_offers_screen.dart';
import 'package:coupona_merchant/screens/merchant_products_screen.dart';
import 'package:coupona_merchant/screens/merchant_receipts_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';

class MerchantDashboardScreen extends StatefulWidget {
  const MerchantDashboardScreen({Key? key}) : super(key: key);

  @override
  State<MerchantDashboardScreen> createState() => _MerchantDashboardScreenState();
}

class _MerchantDashboardScreenState extends State<MerchantDashboardScreen> {
  int _selectedIndex = 0;
  String _storeName = 'لوحة التحكم';
  String? _merchantCode;
  bool _loadingCode = true;

  final List<Widget> _screens = [
    const MerchantAnalyticsScreen(),
    const MerchantOffersScreen(),
    const MerchantCustomersScreen(),
    const MerchantProductsScreen(),
    const MerchantReceiptsScreen(),
  ];

  final List<String> _screenTitles = [
    'الرئيسية',
    'العروض',
    'الزبائن',
    'المنتجات',
    'الإيصالات',
  ];

  @override
  void initState() {
    super.initState();
    _fetchMerchantData();
    _fetchMerchantCode();
  }

  Future<void> _fetchMerchantData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('merchants').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          setState(() {
            _storeName = doc.data()!['store_name'] ?? 'لوحة التحكم';
          });
        }
      } catch (e) {
        // Handle error if needed
        print("Failed to fetch merchant data: $e");
      }
    }
  }

  Future<void> _fetchMerchantCode() async {
    final supabase = Supabase.instance.client;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _merchantCode = null;
        _loadingCode = false;
      });
      return;
    }
    final res = await supabase
        .from('merchants')
        .select('merchant_code')
        .eq('user_id', user.uid)
        .maybeSingle();
    setState(() {
      _merchantCode = res != null ? res['merchant_code'] as String? : null;
      _loadingCode = false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    // The auth listener in main.dart will handle navigation
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final merchantId = user?.uid ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? _storeName : _screenTitles[_selectedIndex]),
        actions: [
          _loadingCode
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                )
              : (_merchantCode != null && _merchantCode!.isNotEmpty)
                  ? IconButton(
                      icon: const Icon(Icons.vpn_key),
                      tooltip: 'رمز التاجر',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('رمز التاجر'),
                            content: Row(
                              children: [
                                Expanded(
                                  child: SelectableText(
                                    _merchantCode!,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy),
                                  tooltip: 'نسخ الرمز',
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: _merchantCode!));
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ رمز التاجر')));
                                  },
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('إغلاق'),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('لا يوجد رمز تاجر', style: TextStyle(color: Colors.white)),
                    ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.go('/dashboard/settings');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // To show all labels
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: 'العروض',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'الزبائن',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'المنتجات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'الإيصالات',
          ),
        ],
      ),
    );
  }
}