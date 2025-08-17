import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:coupona_merchant/widgets/home_button.dart';

class MerchantProductsScreen extends StatefulWidget {
  const MerchantProductsScreen({Key? key}) : super(key: key);

  @override
  State<MerchantProductsScreen> createState() => _MerchantProductsScreenState();
}

class _MerchantProductsScreenState extends State<MerchantProductsScreen> {
  final _nameController = TextEditingController();
  final _pointsController = TextEditingController();

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
            onPressed: () async {
              final name = _nameController.text.trim();
              final points = int.tryParse(_pointsController.text.trim()) ?? 0;
              if (name.isNotEmpty && points > 0) {
                final supabase = Supabase.instance.client;
                await supabase.from('merchant_products').insert({
                  'merchantId': FirebaseAuth.instance.currentUser?.uid,
                  'name': name,
                  'points': points,
                  'created_at': DateTime.now().toIso8601String(),
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    final supabase = Supabase.instance.client;
    final merchantId = FirebaseAuth.instance.currentUser?.uid ?? 'demo_merchant_uid';
    final response = await supabase
        .from('merchant_products')
        .select()
        .eq('merchantId', merchantId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    final merchantId = FirebaseAuth.instance.currentUser?.uid ?? 'demo_merchant_uid';
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
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('[DEBUG][Widget] MerchantProductsScreen loaded!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchProducts(),
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
