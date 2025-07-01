import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:coupona_merchant/widgets/cached_firestore_list.dart';

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
                await FirebaseFirestore.instance.collection('merchant_products').add({
                  'merchantId': FirebaseAuth.instance.currentUser?.uid,
                  'name': name,
                  'points': points,
                  'createdAt': DateTime.now(),
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

  @override
  Widget build(BuildContext context) {
    final merchantId = FirebaseAuth.instance.currentUser?.uid ?? 'demo_merchant_uid';
    return Scaffold(
      appBar: AppBar(
        title: const Text('منتجات المحل'),
        backgroundColor: Colors.deepPurple.shade700,
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
            child: CachedFirestoreList<Map<String, dynamic>>(
              query: FirebaseFirestore.instance
                  .collection('merchant_products')
                  .where('merchantId', isEqualTo: merchantId)
                  .orderBy('createdAt', descending: true),
              itemBuilder: (context, product) {
                return Card(
                  child: ListTile(
                    title: Text(product['name'] ?? ''),
                    subtitle: Text('النقاط: ${product['points'] ?? 0}'),
                  ),
                );
              },
              emptyWidget: const Center(child: Text('لا توجد منتجات بعد')),
            ),
          ),
        ],
      ),
    );
  }
}
