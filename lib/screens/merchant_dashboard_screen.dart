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
import 'package:provider/provider.dart';
import 'package:coupona_merchant/l10n/locale_notifier.dart';
import 'package:coupona_merchant/gen_l10n/app_localizations.dart';

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

  // Titles are resolved via _localizedTitle to follow current locale
  final List<String> _screenTitles = const ['', '', '', '', ''];

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
    try {
      final supaUserId = supabase.auth.currentUser?.id; // UUID الخاص بـ Supabase إن وجد
      Map<String,dynamic>? row;
      // المحاولة 1: user_id = Supabase UUID (الأكثر دقة بعد الجسر)
      if (supaUserId != null) {
        row = await supabase.from('merchants').select('merchant_code').eq('user_id', supaUserId).maybeSingle();
      }
      // المحاولة 2: user_id = Firebase UID (لحسابات أقدم)
      if (row == null) {
        row = await supabase.from('merchants').select('merchant_code').eq('user_id', user.uid).maybeSingle();
      }
      // المحاولة 3: id = Supabase UUID
      if (row == null && supaUserId != null) {
        row = await supabase.from('merchants').select('merchant_code').eq('id', supaUserId).maybeSingle();
      }
      // المحاولة 4: id = Firebase UID
      if (row == null) {
        row = await supabase.from('merchants').select('merchant_code').eq('id', user.uid).maybeSingle();
      }
      // المحاولة 5: email = user.email (كحل أخير) مع حراسة null
      if (row == null) {
        final email = user.email; // قد تكون null
        if (email != null && email.isNotEmpty) {
          row = await supabase
              .from('merchants')
              .select('merchant_code')
              .eq('email', email)
              .maybeSingle();
        }
      }
      setState(() {
        _merchantCode = row != null ? row['merchant_code'] as String? : null;
        _loadingCode = false;
      });
      // ignore: avoid_print
      print('[merchant_dashboard] fetch code supaUser=$supaUserId firebase=${user.uid} code=${_merchantCode ?? 'NULL'}');
    } catch (e) {
      // ignore: avoid_print
      print('[merchant_dashboard] fetch merchant code error: $e');
      setState(() { _loadingCode = false; });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final merchantId = user?.uid ?? '';
    return Scaffold(
      appBar: AppBar(
        title: _selectedIndex == 0
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      _storeName,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_loadingCode)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  else if (_merchantCode != null && _merchantCode!.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: _merchantCode!));
                        final loc = AppLocalizations.of(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(loc?.copiedMerchantCode ?? 'Merchant code copied')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.25),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.vpn_key, size: 16, color: Theme.of(context).colorScheme.onSecondaryContainer),
                            const SizedBox(width: 4),
                            Text(
                              _merchantCode!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSecondaryContainer,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () {
                        setState(() { _loadingCode = true; });
                        _fetchMerchantCode();
                      },
                      child: Text(
                        AppLocalizations.of(context)?.noMerchantCode ?? 'No code',
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ),
                ],
              )
            : Text(_localizedTitle(context, _selectedIndex)),
        actions: [
          // اختيار اللغة السريع
          Builder(builder: (ctx) {
            return IconButton(
              tooltip: AppLocalizations.of(ctx)?.language ?? 'Language',
              icon: const Icon(Icons.language),
              onPressed: () {
                final ln = ctx.read<LocaleNotifier>();
                showModalBottomSheet(
                  context: ctx,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (_) {
                    final loc = AppLocalizations.of(ctx);
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text((loc?.language ?? 'Language'), style: Theme.of(ctx).textTheme.titleMedium),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: ln.supported.map((l) {
                              final selected = ln.locale?.languageCode == l.languageCode || (ln.locale == null && l.languageCode == 'ar');
                              return ChoiceChip(
                                label: Text(l.languageCode.toUpperCase()),
                                selected: selected,
                                onSelected: (_) {
                                  ln.setLocale(l);
                                  Navigator.pop(ctx);
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(loc?.close ?? 'Close'),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            );
          }),
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
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.analytics),
            label: AppLocalizations.of(context)?.home ?? 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.local_offer),
            label: AppLocalizations.of(context)?.offers ?? 'Offers',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people),
            label: AppLocalizations.of(context)?.customers ?? 'Customers',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_bag),
            label: AppLocalizations.of(context)?.products ?? 'Products',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt),
            label: AppLocalizations.of(context)?.receipts ?? 'Receipts',
          ),
        ],
      ),
    );
  }

  String _localizedTitle(BuildContext context, int index) {
    final loc = AppLocalizations.of(context);
    switch (index) {
      case 0: return loc?.home ?? 'Home';
      case 1: return loc?.offers ?? 'Offers';
      case 2: return loc?.customers ?? 'Customers';
      case 3: return loc?.products ?? 'Products';
      case 4: return loc?.receipts ?? 'Receipts';
      default: return '';
    }
  }
}