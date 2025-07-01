import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MerchantCommunityScreen extends StatefulWidget {
  const MerchantCommunityScreen({Key? key}) : super(key: key);

  @override
  State<MerchantCommunityScreen> createState() => _MerchantCommunityScreenState();
}

class _MerchantCommunityScreenState extends State<MerchantCommunityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? merchantId;
  String? storeGroupId;
  String? storeName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    merchantId = FirebaseAuth.instance.currentUser?.uid;
    _fetchStoreGroup();
  }

  Future<void> _fetchStoreGroup() async {
    if (merchantId == null) return;
    // جلب معرف القروب (إن وجد)
    final snapshot = await FirebaseFirestore.instance
        .collection('store_groups')
        .where('adminId', isEqualTo: merchantId)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      storeGroupId = snapshot.docs.first.id;
    } else {
      // إذا لم يوجد قروب، أنشئ واحد تلقائياً
      // جلب اسم المتجر من merchants
      String? autoStoreName;
      final merchantDoc = await FirebaseFirestore.instance
          .collection('merchants')
          .doc(merchantId)
          .get();
      if (merchantDoc.exists && merchantDoc.data() != null) {
        autoStoreName = merchantDoc.data()!['store_name'] ?? 'قروب المحل';
      } else {
        autoStoreName = 'قروب المحل';
      }
      final newGroup = await FirebaseFirestore.instance.collection('store_groups').add({
        'adminId': merchantId,
        'storeName': autoStoreName,
        'createdAt': FieldValue.serverTimestamp(),
      });
      storeGroupId = newGroup.id;
    }
    // جلب اسم المتجر من merchants
    final merchantDoc = await FirebaseFirestore.instance
        .collection('merchants')
        .doc(merchantId)
        .get();
    if (merchantDoc.exists && merchantDoc.data() != null) {
      storeName = merchantDoc.data()!['store_name'] ?? 'قروب المحل';
    } else {
      storeName = 'قروب المحل';
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (merchantId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('مجتمع التاجر')),
        body: const Center(child: Text('يجب تسجيل الدخول لعرض المجتمع')),
      );
    }
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('مجتمع التاجر'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(icon: Icon(Icons.public), text: 'مجتمع التجار'),
            Tab(icon: const Icon(Icons.store), text: storeName ?? 'قروب المحل'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // قروب التجار العام
          _PostsFeed(
            groupCollection: 'merchant_global_group',
            groupQuery: FirebaseFirestore.instance
                .collection('merchant_global_group')
                .orderBy('createdAt', descending: true),
            canPost: true,
            merchantId: merchantId!,
            groupName: 'مجتمع التجار',
            isAdmin: false,
          ),
          // قروب المحل الخاص (يظهر فقط إذا كان التاجر أدمن لمحل)
          Builder(
            builder: (context) {
              if (storeGroupId == null) {
                return const Center(child: Text('لا يوجد قروب محل خاص بك كأدمن. تواصل مع الدعم لإنشاء قروب لمتجرك.'));
              }
              // تأكد من ظهور واجهة النشر والتعليق دائماً
              return _PostsFeed(
                groupCollection: 'store_groups/$storeGroupId/messages',
                groupQuery: FirebaseFirestore.instance
                    .collection('store_groups')
                    .doc(storeGroupId)
                    .collection('messages')
                    .orderBy('createdAt', descending: true),
                canPost: true, // دائماً true للتاجر الأدمن
                merchantId: merchantId!,
                groupName: storeName ?? 'قروب المحل',
                isAdmin: true,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PostsFeed extends StatelessWidget {
  final String groupCollection;
  final Query groupQuery;
  final bool canPost;
  final String merchantId;
  final String groupName;
  final bool isAdmin;
  const _PostsFeed({
    required this.groupCollection,
    required this.groupQuery,
    required this.canPost,
    required this.merchantId,
    required this.groupName,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (canPost)
          _AddPostWidget(
            groupCollection: groupCollection,
            merchantId: merchantId,
            groupName: groupName,
          ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: groupQuery.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('حدث خطأ: [38;5;9m${snapshot.error}[0m'));
              }
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                // إظهار واجهة النشر دائماً مع رسالة واضحة
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('لا توجد منشورات بعد. كن أول من ينشر!'),
                    if (canPost)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text('يمكنك إضافة منشور جديد من الأعلى', style: TextStyle(color: Colors.deepPurple)),
                      ),
                  ],
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final postId = docs[index].id;
                  final isOwner = data['merchantId'] == merchantId;
                  return _PostCard(
                    postId: postId,
                    data: data,
                    groupCollection: groupCollection,
                    isOwner: isOwner,
                    isAdmin: isAdmin,
                    merchantId: merchantId,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PostCard extends StatelessWidget {
  final String postId;
  final Map<String, dynamic> data;
  final String groupCollection;
  final bool isOwner;
  final bool isAdmin;
  final String merchantId;
  const _PostCard({
    required this.postId,
    required this.data,
    required this.groupCollection,
    required this.isOwner,
    required this.isAdmin,
    required this.merchantId,
  });

  @override
  Widget build(BuildContext context) {
    final likes = (data['likes'] as List?) ?? [];
    final commentsCount = (data['commentsCount'] ?? 0) as int;
    final createdAt = data['createdAt'] is Timestamp
        ? (data['createdAt'] as Timestamp).toDate()
        : DateTime.now();
    final merchantName = data['merchantName']?.toString() ?? 'تاجر';
    final avatarUrl = data['merchantAvatar'] as String?;
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.deepPurple.shade100,
                  backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl) : null,
                  child: (avatarUrl == null || avatarUrl.isEmpty) ? Text(merchantName.isNotEmpty ? merchantName.characters.first : 'ت', style: const TextStyle(color: Colors.deepPurple)) : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    merchantName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Text(
                  '${createdAt.year}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.day.toString().padLeft(2, '0')}'
                  '\n${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  textAlign: TextAlign.right,
                ),
                (isOwner || isAdmin)
                  ? IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'حذف المنشور',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('تأكيد الحذف'),
                            content: const Text('هل أنت متأكد من حذف هذا المنشور؟'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('إلغاء'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('حذف'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await FirebaseFirestore.instance
                              .collection(groupCollection)
                              .doc(postId)
                              .delete();
                        }
                      },
                    )
                  : SizedBox.shrink(),
              ],
            ),
            const SizedBox(height: 8),
            if ((data['title'] ?? '').toString().isNotEmpty)
              Text(
                data['title'] ?? '',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            if ((data['content'] ?? '').toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(data['content'] ?? '', style: const TextStyle(fontSize: 15)),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    likes.contains(merchantId)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: likes.contains(merchantId)
                        ? Colors.red
                        : Colors.grey,
                  ),
                  tooltip: 'إعجاب',
                  onPressed: () async {
                    final ref = FirebaseFirestore.instance
                        .collection(groupCollection)
                        .doc(postId);
                    if (likes.contains(merchantId)) {
                      await ref.update({
                        'likes': FieldValue.arrayRemove([merchantId])
                      });
                    } else {
                      await ref.update({
                        'likes': FieldValue.arrayUnion([merchantId])
                      });
                    }
                  },
                ),
                Text('${likes.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 18),
                TextButton.icon(
                  icon: const Icon(Icons.comment, color: Colors.deepPurple),
                  label: Text('$commentsCount تعليق', style: const TextStyle(color: Colors.deepPurple)),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                      ),
                      builder: (context) => Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: _CommentsSheet(
                          groupCollection: groupCollection,
                          postId: postId,
                          merchantId: merchantId,
                          isAdmin: isAdmin,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPostWidget extends StatefulWidget {
  final String groupCollection;
  final String merchantId;
  final String groupName;

  const _AddPostWidget({
    required this.groupCollection,
    required this.merchantId,
    required this.groupName,
  });

  @override
  State<_AddPostWidget> createState() => _AddPostWidgetState();
}

class _AddPostWidgetState extends State<_AddPostWidget> {
  final contentController = TextEditingController();
  bool isLoading = false;

  Future<void> _addPost() async {
    if (contentController.text.trim().isEmpty) {
      return;
    }
    setState(() {
      isLoading = true;
    });

    final merchant = FirebaseAuth.instance.currentUser;
    String merchantName = merchant?.displayName ?? '';
    // إذا لم يوجد displayName، جلب اسم المحل من merchants
    if (merchantName.isEmpty && merchant != null) {
      final merchantDoc = await FirebaseFirestore.instance
          .collection('merchants')
          .doc(merchant.uid)
          .get();
      if (merchantDoc.exists && merchantDoc.data() != null) {
        merchantName = merchantDoc.data()!['store_name'] ?? '';
      }
    }
    if (merchantName.isEmpty) merchantName = 'تاجر';
    try {
      await FirebaseFirestore.instance.collection(widget.groupCollection).add({
        'merchantId': widget.merchantId,
        'merchantName': merchantName,
        'merchantAvatar': merchant?.photoURL,
        'title': '',
        'content': contentController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'likes': [],
        'commentsCount': 0,
      });

      contentController.clear();
      FocusScope.of(context).unfocus();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('تم نشر منشورك بنجاح!'),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('حدث خطأ أثناء النشر: $e'),
            backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final merchantName = currentUser?.displayName?.split(' ').first ?? 'التاجر';

    final String initial;
    final String? photoURL = currentUser?.photoURL;
    final String? displayName = currentUser?.displayName;

    if (displayName != null && displayName.isNotEmpty) {
      initial = displayName.characters.first;
    } else {
      initial = 'ت';
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.deepPurple.shade100,
                  backgroundImage: (photoURL != null && photoURL.isNotEmpty) ? NetworkImage(photoURL) : null,
                  child: (photoURL == null || photoURL.isEmpty)
                      ? Text(initial, style: const TextStyle(color: Colors.deepPurple))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: contentController,
                    decoration: InputDecoration.collapsed(
                      hintText: 'بماذا تفكر يا $merchantName؟',
                    ),
                    maxLines: 5,
                    minLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: isLoading ? null : _addPost,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('نشر'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _CommentsSheet extends StatefulWidget {
  final String groupCollection;
  final String postId;
  final String merchantId;
  final bool isAdmin;
  const _CommentsSheet({
    required this.groupCollection,
    required this.postId,
    required this.merchantId,
    required this.isAdmin,
  });

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final commentController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final commentsRef = FirebaseFirestore.instance
        .collection(widget.groupCollection)
        .doc(widget.postId)
        .collection('comments')
        .orderBy('createdAt', descending: false);
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.65,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          const Text('التعليقات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: commentsRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('لا توجد تعليقات بعد. يمكنك أن تبدأ النقاش!'));
                }
                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final isOwner = data['merchantId'] == widget.merchantId;
                    final merchantName = data['merchantName']?.toString() ?? 'تاجر';
                    final avatarUrl = data['merchantAvatar'] as String?;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple.shade100,
                        backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl) : null,
                        child: (avatarUrl == null || avatarUrl.isEmpty) ? Text(merchantName.isNotEmpty ? merchantName.characters.first : 'ت', style: const TextStyle(color: Colors.deepPurple)) : null,
                      ),
                      title: Text(merchantName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(data['content'] ?? ''),
                      trailing: (isOwner || widget.isAdmin)
                          ? IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'حذف التعليق',
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('تأكيد الحذف'),
                                    content: const Text('هل أنت متأكد من حذف هذا التعليق؟'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('إلغاء'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('حذف'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await FirebaseFirestore.instance
                                      .collection(widget.groupCollection)
                                      .doc(widget.postId)
                                      .collection('comments')
                                      .doc(docs[index].id)
                                      .delete();
                                }
                              },
                            )
                          : null,
                    );
                  },
                );
              },
            ),
          ),
          // واجهة إضافة التعليق دائماً في الأسفل
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: const InputDecoration(hintText: 'أضف تعليق...', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                isLoading
                    ? const SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 2))
                    : IconButton(
                        icon: const Icon(Icons.send, color: Colors.deepPurple),
                        onPressed: () async {
                          if (commentController.text.trim().isEmpty) return;
                          setState(() => isLoading = true);
                          final merchant = FirebaseAuth.instance.currentUser;
                          String merchantName = '';
                          // جلب اسم التاجر من displayName أو من merchants
                          if (merchant != null) {
                            merchantName = merchant.displayName ?? '';
                            if (merchantName.isEmpty) {
                              final merchantDoc = await FirebaseFirestore.instance
                                  .collection('merchants')
                                  .doc(merchant.uid)
                                  .get();
                              if (merchantDoc.exists && merchantDoc.data() != null) {
                                merchantName = merchantDoc.data()!['store_name'] ?? '';
                              }
                            }
                          }
                          if (merchantName.isEmpty) merchantName = 'تاجر';
                          await FirebaseFirestore.instance
                              .collection(widget.groupCollection)
                              .doc(widget.postId)
                              .collection('comments')
                              .add({
                            'merchantId': widget.merchantId,
                            'merchantName': merchantName,
                            'merchantAvatar': merchant?.photoURL,
                            'content': commentController.text.trim(),
                            'createdAt': FieldValue.serverTimestamp(),
                          });
                          // تحديث عدد التعليقات
                          final postRef = FirebaseFirestore.instance
                              .collection(widget.groupCollection)
                              .doc(widget.postId);
                          await postRef.update({
                            'commentsCount': FieldValue.increment(1),
                          });
                          commentController.clear();
                          setState(() => isLoading = false);
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<String> generateStoreCode(String storeName, String area) async {
  String code = '$storeName-$area'.replaceAll(' ', '-');
  // تحقق من عدم وجود الكود في قاعدة البيانات
  final exists = await FirebaseFirestore.instance
      .collection('merchants')
      .where('store_code', isEqualTo: code)
      .get();
  if (exists.docs.isNotEmpty) {
    // أضف رقم أو تمييز إضافي
    code = '$code-${exists.docs.length + 1}';
  }
  return code;
}

Future<void> registerMerchantWithCode({
  required String merchantId,
  required String storeName,
  required String area,
  required String phone,
  // أضف أي بيانات أخرى تحتاجها
}) async {
  final storeCode = await generateStoreCode(storeName, area);
  await FirebaseFirestore.instance.collection('merchants').doc(merchantId).set({
    'store_name': storeName,
    'area': area,
    'store_code': storeCode,
    'phone': phone,
    'createdAt': FieldValue.serverTimestamp(),
    // أضف أي بيانات أخرى
  }, SetOptions(merge: true));
}