import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:coupona_merchant/widgets/home_button.dart';
// import 'package:go_router/go_router.dart'; // لم يعد مستخدماً هنا
import 'package:supabase_flutter/supabase_flutter.dart';

class MerchantCommunityScreen extends StatefulWidget {
  const MerchantCommunityScreen({Key? key}) : super(key: key);

  @override
  State<MerchantCommunityScreen> createState() => _MerchantCommunityScreenState();
}

class _MerchantCommunityScreenState extends State<MerchantCommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? userId;
  bool isLoading = false;
  String? storeGroupId;
  String? storeName;
  String? activityType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMerchantData();
  }

  Future<void> _loadMerchantData() async {
    setState(() => isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;

      final merchantDoc = await FirebaseFirestore.instance
          .collection('merchants')
          .doc(user.uid)
          .get();

      if (merchantDoc.exists) {
        setState(() {
          final data = merchantDoc.data() as Map<String, dynamic>?;
          storeName = data != null && data.containsKey('store_name') ? data['store_name'] : null;
          activityType = data != null && data.containsKey('activity_type') ? data['activity_type'] : null;
          storeGroupId = data != null && data.containsKey('store_group_id') ? data['store_group_id'] : null;
        });
      }
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('مجتمع التاجر'),
          leading: const HomeButton(),
        ),
        body: const Center(child: Text('يجب تسجيل الدخول لعرض المجتمع')),
      );
    }

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('مجتمع التاجر'),
        leading: const HomeButton(),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'مجتمع التجار'),
            Tab(text: 'قروب المحل'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PostsFeed(
            groupCollection: 'merchant_posts',
            groupQueryTable: 'merchant_posts',
            canPost: true,
            userId: userId!,
            groupName: 'مجتمع التجار',
            isAdmin: false,
            storeGroupId: null,
            activityType: activityType,
          ),
          _PostsFeed(
            groupCollection: 'store_group_posts',
            groupQueryTable: 'store_group_posts',
            canPost: storeGroupId != null,
            userId: userId!,
            groupName: storeName ?? '',
            isAdmin: true,
            storeGroupId: storeGroupId,
            activityType: null,
          )
        ],
      ),
    );
  }
}

class _PostsFeed extends StatefulWidget {
  final String groupCollection;
  final String groupQueryTable;
  final bool canPost;
  final String userId;
  final String groupName;
  final bool isAdmin;
  final String? storeGroupId;
  final String? activityType;

  const _PostsFeed({
    required this.groupCollection,
    required this.groupQueryTable,
    required this.canPost,
    required this.userId,
    required this.groupName,
    required this.isAdmin,
    this.storeGroupId,
    this.activityType,
    Key? key,
  }) : super(key: key);

  @override
  State<_PostsFeed> createState() => _PostsFeedState();
}

class _PostsFeedState extends State<_PostsFeed> {
  Future<List<Map<String, dynamic>>>? _postsFuture;

  @override
  void initState() {
    super.initState();
    _refreshPosts();
  }

  void _refreshPosts() {
    setState(() {
      _postsFuture = _fetchPosts();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchPosts() async {
    final supabase = Supabase.instance.client;
    // ترحيل تلقائي: إصلاح user_id القديم (Firebase UID أو يساوي id) ليطابق معرف Supabase الحالي
    try {
      final currentUid = supabase.auth.currentUser?.id;
      if (currentUid != null && widget.groupQueryTable == 'merchant_posts') {
        // تحديث الصفوف التي user_id = id (خطيئة إدراج قديمة) أو user_id قصير (< 30) إلى المعرف الحالي
        // ملاحظة: .or تستخدم صيغة فلترة OR في PostgREST
        await supabase
            .from(widget.groupQueryTable)
            .update({'user_id': currentUid})
            .or('user_id.eq.id,user_id.lt.30');
      }
    } catch (_) {
      // تجاهل أي أخطاء أثناء الترحيل الصامت
    }
    final query = supabase.from(widget.groupQueryTable).select();

    if (widget.storeGroupId != null) {
      query.eq('store_group_id', widget.storeGroupId!);
    }

    if (widget.activityType != null) {
      query.eq('activity_type', widget.activityType!);
    }

    query.order('created_at', ascending: false); // الترتيب تنازلي

    final response = await query;
    final posts = List<Map<String, dynamic>>.from(response);

    DateTime? _parse(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      // أنماط محتملة: 2025-08-17T12:30:00.123Z أو 2025-08-17 12:30:00+00 أو تاريخ فقط
      DateTime? dt = DateTime.tryParse(s);
      if (dt != null) return dt;
      // لو تاريخ فقط
      final dateOnlyReg = RegExp(r'^\\d{4}-\\d{2}-\\d{2}$');
      if (dateOnlyReg.hasMatch(s)) {
        try { return DateTime.parse('${s}T00:00:00Z'); } catch (_) {}
      }
      return null;
    }

    posts.sort((a, b) {
      final da = _parse(a['created_at']);
      final db = _parse(b['created_at']);
      if (da == null && db == null) return 0;
      if (da == null) return 1; // nulls للأسفل
      if (db == null) return -1;
      return db.compareTo(da); // تنازلي
    });

  // ملاحظة: أزلنا الانعكاس الاحتياطي لأنّه كان يقلب الترتيب الصحيح في بعض الحالات.
  // لو احتجت تحقق يمكنك طباعة أول وآخر تاريخ للتأكد:
  // final first = _parse(posts.first['created_at']);
  // final last = _parse(posts.last['created_at']);
  // print('DEBUG order first=$first last=$last (يجب أن يكون first >= last)');

    return posts;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.canPost)
          _AddPostWidget(
            groupCollection: widget.groupCollection,
            groupQueryTable: widget.groupQueryTable,
            userId: widget.userId,
            groupName: widget.groupName,
            storeGroupId: widget.storeGroupId,
            activityType: widget.activityType,
            onPostAdded: _refreshPosts,
          ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _postsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('حدث خطأ: ${snapshot.error}'));
              }
              final docs = snapshot.data ?? [];
              if (docs.isEmpty) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('لا توجد منشورات بعد. كن أول من ينشر!'),
                    if (widget.canPost)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text('يمكنك إضافة منشور جديد من الأعلى',
                            style: TextStyle(color: Colors.deepPurple)),
                      ),
                  ],
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final data = docs[index];
                  final postId = data['id'].toString();
                  final supaUserId = Supabase.instance.client.auth.currentUser?.id;
                  final isOwner = data['user_id'] == supaUserId || data['user_id'] == widget.userId;
                  return _PostCard(
                    postId: postId,
                    data: data,
                    groupCollection: widget.groupCollection,
                    groupQueryTable: widget.groupQueryTable,
                    isOwner: isOwner,
                    isAdmin: widget.isAdmin,
                    userId: widget.userId,
                    onPostDeleted: _refreshPosts,
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

// (تم حذف النسخة القديمة لـ _AddPostWidget واستبدالها بنسخة Stateful في الأسفل)

class _PostCard extends StatelessWidget {
  final String postId;
  final Map<String, dynamic> data;
  final String groupCollection;
  final String groupQueryTable;
  final bool isOwner;
  final bool isAdmin;
  final String userId;
  final VoidCallback onPostDeleted;

  const _PostCard({
    required this.postId,
    required this.data,
    required this.groupCollection,
    required this.groupQueryTable,
    required this.isOwner,
    required this.isAdmin,
    required this.userId,
    required this.onPostDeleted,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(
          (data['title'] ?? data['content'] ?? 'منشور') as String,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Builder(
          builder: (context) {
            final createdAt = data['created_at'];
            String ts = '';
            if (createdAt is String) ts = createdAt.split('T').first;
            return Text([
              if (data['content'] != null && data['title'] != data['content']) data['content'],
              if (ts.isNotEmpty) '📅 $ts'
            ].whereType<String>().join('\n'));
          },
        ),
        trailing: (isOwner || isAdmin)
            ? IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final supabase = Supabase.instance.client;
                  try {
                    if (!isOwner && !isAdmin) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('لا تملك صلاحية الحذف (ليست منشورك)')),
                        );
                      }
                      return;
                    }
                    final idValue = data['id'];
                    final existing = await supabase
                        .from(groupQueryTable)
                        .select('id,user_id')
                        .eq('id', idValue)
                        .maybeSingle();
                    if (existing == null) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('المنشور غير موجود (ربما حُذف)')),
                        );
                      }
                      onPostDeleted();
                      return;
                    }
                    final deleted = await supabase
                        .from(groupQueryTable)
                        .delete()
                        .eq('id', idValue)
                        // أزلنا تقييد user_id لتسهيل الحذف بعد تعديل السياسة (مؤقتاً)
                        .select();
                    if (deleted is List && deleted.isNotEmpty) {
                      onPostDeleted();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم حذف المنشور')),
                        );
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تعذر الحذف: تحقق من سياسات RLS')),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('فشل حذف المنشور: $e')),
                      );
                    }
                  }
                },
              )
            : null,
      ),
    );
  }
}

class _AddPostWidget extends StatefulWidget {
  final String groupCollection;
  final String groupQueryTable;
  final String userId;
  final String groupName;
  final String? storeGroupId;
  final String? activityType; // لتمرير نوع النشاط حتى يتم إدراجه في الصف
  final VoidCallback? onPostAdded;

  const _AddPostWidget({
    required this.groupCollection,
    required this.groupQueryTable,
    required this.userId,
    required this.groupName,
    this.storeGroupId,
  this.activityType,
    this.onPostAdded,
    Key? key,
  }) : super(key: key);

  @override
  State<_AddPostWidget> createState() => _AddPostWidgetState();
}

class _AddPostWidgetState extends State<_AddPostWidget> {
  final _controller = TextEditingController();
  bool _submitting = false;

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء كتابة محتوى المنشور')),
      );
      return;
    }
    final supaUserId = Supabase.instance.client.auth.currentUser?.id;
    if (supaUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب تسجيل الدخول (Supabase) قبل النشر.')),
      );
      return;
    }
    setState(() => _submitting = true);
    final supabase = Supabase.instance.client;
    final Map<String, dynamic> row = {
      'content': text,
      'user_id': supaUserId, // مطلوب لمطابقة RLS
      // created_at يتم توليده من قاعدة البيانات
    };
    if (widget.storeGroupId != null) {
      row['store_group_id'] = widget.storeGroupId;
    }
    if (widget.activityType != null) {
      row['activity_type'] = widget.activityType; // لضمان ظهور المنشور في الفلتر
    }
    // For merchant public community we might need activity_type filter to match query
    if (widget.groupQueryTable == 'merchant_posts') {
      // try to fetch merchant activity_type from Firestore (optional) – skipped for performance
    }
  try {
    final inserted = await supabase
      .from(widget.groupQueryTable)
      .insert(row)
      .select()
      .maybeSingle();
    // debug: inserted id $inserted?['id']
    await Future.delayed(const Duration(milliseconds: 80));
      _controller.clear();
      widget.onPostAdded?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم نشر المنشور بنجاح')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل نشر المنشور: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'اكتب شيئاً لمجتمعك...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
            _submitting
                ? const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : ElevatedButton(
                    onPressed: _submit,
                    child: const Text('نشر'),
                  ),
        ],
      ),
    );
  }
}