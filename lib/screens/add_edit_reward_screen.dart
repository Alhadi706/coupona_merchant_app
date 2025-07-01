import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class AddEditRewardScreen extends StatefulWidget {
  final Map<String, dynamic>? reward;

  const AddEditRewardScreen({Key? key, this.reward}) : super(key: key);

  @override
  _AddEditRewardScreenState createState() => _AddEditRewardScreenState();
}

class _AddEditRewardScreenState extends State<AddEditRewardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = Uuid();

  // Provide initial values to avoid LateInitializationError
  String _title = '';
  String _description = '';
  int _pointsCost = 0;
  String _rewardType = 'direct'; // Default type
  int? _conditionPointsRequired;
  DateTime? _drawDate;
  int? _numberOfWinners;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // If editing, populate fields from the passed reward data
    if (widget.reward != null) {
      _title = widget.reward!['title'] ?? '';
      _description = widget.reward!['description'] ?? '';
      _pointsCost = widget.reward!['points_cost'] ?? 0;
      _rewardType = widget.reward!['type'] ?? 'direct';
      _conditionPointsRequired = widget.reward!['condition_points_required'];
      _drawDate = widget.reward!['draw_date'] != null
          ? DateTime.parse(widget.reward!['draw_date']!)
          : null;
      _numberOfWinners = widget.reward!['number_of_winners'];
    }
  }

  Future<void> _saveReward() async {
    print("--- _saveReward called ---"); // For debugging
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      final rewardId = widget.reward?['id'] ?? _uuid.v4();
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يجب تسجيل الدخول أولاً')),
        );
        setState(() => _isLoading = false);
        return;
      }
      final data = {
        'id': rewardId,
        'title': _title,
        'description': _description,
        'points_cost': _pointsCost,
        'type': _rewardType,
        'condition_points_required': _conditionPointsRequired,
        'draw_date': _drawDate?.toIso8601String(),
        'number_of_winners': _numberOfWinners,
        'qr_code': 'reward_$rewardId',
        'created_at': DateTime.now().toIso8601String(),
        'merchant_id': user.uid,
      };
      print('--- Saving Reward Data ---');
      print(data);
      try {
        final rewardsCollection = FirebaseFirestore.instance.collection('rewards');
        if (widget.reward == null) {
          // Create new reward
          await rewardsCollection.doc(rewardId).set(data);
        } else {
          // Update existing reward
          await rewardsCollection.doc(rewardId).update(data);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حفظ الجائزة بنجاح!')),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } catch (e) {
        // For debugging
        print('--- Error Saving Reward ---');
        print(e);
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

  // New wrapper function for debugging
  void _handleSave() {
    print("--- Button Pressed: _handleSave initiated ---");
    try {
      // Check form state explicitly before calling the async function
      if (_formKey.currentState!.validate()) {
        print("--- Form is valid ---");
        _formKey.currentState!.save();
        print("--- Form saved ---");
        _saveReward();
      } else {
        print("--- Form is NOT valid ---");
        setState(() => _isLoading = false); // Ensure loading indicator is off
      }
    } catch (e, s) {
      print("--- SYNCHRONOUS ERROR in _handleSave ---");
      print(e);
      print(s);
      if (mounted) {
        setState(() => _isLoading = false);
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
                    // Simple Date Picker for now
                    ListTile(
                      title: Text(_drawDate == null
                          ? 'اختر تاريخ السحب'
                          : 'تاريخ السحب: \${_drawDate!.toLocal()}'.split(' ')[0]),
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
                  const SizedBox(height: 20),
                  ElevatedButton(
                    // Disable button when loading to prevent multiple clicks
                    onPressed: _isLoading ? null : _handleSave,
                    child: const Text('حفظ'),
                  ),
                ],
              ),
            ),
    );
  }
}
