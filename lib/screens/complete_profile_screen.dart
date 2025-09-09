import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:coupona_merchant/gen_l10n/app_localizations.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({Key? key}) : super(key: key);

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String _storeName = '';
  bool _loading = false;

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _loading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
  final loc = AppLocalizations.of(context);
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc?.mustLoginFirst ?? 'Login required')));
      setState(() => _loading = false);
      return;
    }
    try {
      await FirebaseFirestore.instance.collection('merchants').doc(user.uid).set({
        'store_name': _storeName,
        'email': user.email,
        'role': 'merchant',
        'created_at': DateTime.now().toIso8601String(),
      });
      if (mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc?.profileSavedSuccess ?? 'Profile saved')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc?.genericErrorWithMessage(e.toString()) ?? 'Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc?.completeProfileTitle ?? 'Complete Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: loc?.storeNameLabel ?? 'Store Name'),
                validator: (v) => v == null || v.isEmpty ? (loc?.requiredField ?? 'Required') : null,
                onSaved: (v) => _storeName = v ?? '',
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _saveProfile,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(loc?.save ?? 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
