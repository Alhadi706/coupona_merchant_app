import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class RewardManagementScreen extends StatefulWidget {
  const RewardManagementScreen({Key? key}) : super(key: key);

  @override
  _RewardManagementScreenState createState() => _RewardManagementScreenState();
}

class _RewardManagementScreenState extends State<RewardManagementScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<QueryDocumentSnapshot> _rewards = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRewards();
  }

  Future<void> _loadRewards() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'يجب تسجيل الدخول أولاً';
          _isLoading = false;
        });
        return;
      }

      // استعلام مركب: merchant_id + active + created_at
      try {
        final querySnapshot = await _firestore
            .collection('rewards')
            .where('merchant_id', isEqualTo: user.uid)
            .where('active', isEqualTo: true)
            .orderBy('created_at', descending: true)
            .get();
        setState(() {
          _rewards = querySnapshot.docs;
          _isLoading = false;
        });
      } catch (e) {
        // إذا فشل الاستعلام المركب (غالباً بسبب الفهرس)، جلب كل الجوائز ثم فلترة النتائج وترتيبها
        print('Composite query with sorting failed, fallback to simple query: $e');
        final fallbackSnapshot = await _firestore
            .collection('rewards')
            .where('merchant_id', isEqualTo: user.uid)
            .get();
        
        final filtered = fallbackSnapshot.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          // التأكد من وجود حقل 'active' قبل الفلترة
          return data.containsKey('active') && data['active'] == true;
        }).toList();

        // الترتيب يدوياً في الكود
        filtered.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aTimestamp = aData['created_at'];
          final bTimestamp = bData['created_at'];
          if (aTimestamp is String && bTimestamp is String) {
            return bTimestamp.compareTo(aTimestamp); // الأحدث أولاً
          }
          return 0;
        });

        setState(() {
          _rewards = filtered;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ في جلب البيانات: [31m${e.toString()}[0m';
        _isLoading = false;
      });
      print('Error loading rewards: $e');
    }
  }

  Future<void> _deleteReward(String rewardId) async {
    try {
      await _firestore.collection('rewards').doc(rewardId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الجائزة بنجاح')),
      );
      _loadRewards();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء الحذف: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الجوائز'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRewards,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _rewards.isEmpty
                  ? const Center(child: Text('لا توجد جوائز مفعلة حالياً'))
                  : ListView.builder(
                      itemCount: _rewards.length,
                      itemBuilder: (context, index) {
                        final reward = _rewards[index].data() as Map<String, dynamic>;
                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(reward['title'] ?? 'بدون عنوان'),
                            subtitle: Text(reward['description'] ?? 'بدون وصف'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddEditRewardScreen(
                                        reward: reward,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteReward(_rewards[index].id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddEditRewardScreen(),
          ),
        ),
      ),
    );
  }
}

class AddEditRewardScreen extends StatefulWidget {
  final Map<String, dynamic>? reward;

  const AddEditRewardScreen({Key? key, this.reward}) : super(key: key);

  @override
  _AddEditRewardScreenState createState() => _AddEditRewardScreenState();
}

class _AddEditRewardScreenState extends State<AddEditRewardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = Uuid();

  String _title = '';
  String _description = '';
  int _pointsCost = 0;
  String _rewardType = 'direct';
  int? _conditionPointsRequired;
  DateTime? _drawDate;
  int? _numberOfWinners;
  bool _isActive = true; // إضافة متغير الحالة

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.reward != null) {
      _title = widget.reward!['title'] ?? '';
      _description = widget.reward!['description'] ?? '';
      _pointsCost = widget.reward!['points_cost'] ?? 0;
      _rewardType = widget.reward!['type'] ?? 'direct';
      _conditionPointsRequired = widget.reward!['condition_points_required'];
      _drawDate = widget.reward!['draw_date'] != null
          ? DateTime.parse(widget.reward!['draw_date'])
          : null;
      _numberOfWinners = widget.reward!['number_of_winners'];
      _isActive = widget.reward!['active'] ?? true; // تحميل الحالة عند التعديل
    }
  }

  Future<void> _saveReward() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يجب تسجيل الدخول أولاً')),
        );
        setState(() => _isLoading = false);
        return;
      }

      final rewardId = widget.reward?['id'] ?? _uuid.v4();
      final qrCode = widget.reward?['qrCode'] ?? 'reward_${_uuid.v4()}';

      final rewardData = {
        'title': _title,
        'description': _description,
        'pointsCost': _pointsCost,
        'rewardType': _rewardType,
        'conditionPointsRequired': _conditionPointsRequired,
        'drawDate': _drawDate,
        'numberOfWinners': _numberOfWinners,
        'qrCode': qrCode,
        'merchant_id': user.uid, // <-- توحيد اسم الحقل
        'created_at': widget.reward != null
            ? (widget.reward!['created_at']) // المحافظة على التاريخ القديم عند التعديل
            : FieldValue.serverTimestamp(), // تاريخ جديد عند الإنشاء
        'active': _isActive,
      };

      try {
        await FirebaseFirestore.instance
            .collection('rewards')
            .doc(rewardId)
            .set(rewardData, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.reward == null
                  ? 'تمت إضافة الجائزة بنجاح'
                  : 'تم تحديث الجائزة بنجاح')),
        );
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('حدث خطأ أثناء الحفظ: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reward == null ? 'إضافة جائزة جديدة' : 'تعديل الجائزة'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  TextFormField(
                    initialValue: _title,
                    decoration: const InputDecoration(labelText: 'عنوان الجائزة'),
                    validator: (value) => value!.isEmpty ? 'الحقل مطلوب' : null,
                    onSaved: (value) => _title = value!,
                  ),
                  TextFormField(
                    initialValue: _description,
                    decoration: const InputDecoration(labelText: 'وصف الجائزة'),
                    onSaved: (value) => _description = value ?? '',
                  ),
                  TextFormField(
                    initialValue: _pointsCost.toString(),
                    decoration: const InputDecoration(labelText: 'تكلفة النقاط'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'الحقل مطلوب' : null,
                    onSaved: (value) => _pointsCost = int.tryParse(value!) ?? 0,
                  ),
                  DropdownButtonFormField<String>(
                    value: _rewardType,
                    decoration: const InputDecoration(labelText: 'نوع الجائزة'),
                    items: const [
                      DropdownMenuItem(value: 'direct', child: Text('مباشرة')),
                      DropdownMenuItem(value: 'conditional', child: Text('مشروطة')),
                      DropdownMenuItem(value: 'draw', child: Text('سحب')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _rewardType = value!;
                      });
                    },
                  ),
                  if (_rewardType == 'conditional')
                    TextFormField(
                      initialValue: _conditionPointsRequired?.toString(),
                      decoration: const InputDecoration(
                          labelText: 'النقاط المطلوبة للشرط'),
                      keyboardType: TextInputType.number,
                      onSaved: (value) => _conditionPointsRequired =
                          int.tryParse(value ?? ''),
                    ),
                  if (_rewardType == 'draw') ...[
                    TextFormField(
                      initialValue: _numberOfWinners?.toString(),
                      decoration:
                          const InputDecoration(labelText: 'عدد الفائزين'),
                      keyboardType: TextInputType.number,
                      onSaved: (value) =>
                          _numberOfWinners = int.tryParse(value ?? ''),
                    ),
                    ListTile(
                      title: Text(_drawDate == null
                          ? 'اختر تاريخ السحب'
                          : 'تاريخ السحب: ${_drawDate!.toLocal()}'.split(' ')[0]),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _drawDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _drawDate = pickedDate;
                          });
                        }
                      },
                    ),
                  ],
                  SwitchListTile(
                    title: const Text('الجائزة مفعلة'),
                    value: _isActive,
                    onChanged: (bool value) {
                      setState(() {
                        _isActive = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveReward,
                    child: const Text('حفظ'),
                  ),
                ],
              ),
            ),
    );
  }
}