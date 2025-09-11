import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'package:coupona_merchant/gen_l10n/app_localizations.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _msgController = TextEditingController();
  final _typeController = TextEditingController();
  bool _sending = false;

  String? _merchantCode;
  bool _loadingCode = true;

  List<Map<String, String>> _faqLocalized(AppLocalizations loc) => [
        {'q': loc.faqAddOfferQuestion, 'a': loc.faqAddOfferAnswer},
        {'q': loc.faqChangePasswordQuestion, 'a': loc.faqChangePasswordAnswer},
        {'q': loc.faqTrackPointsQuestion, 'a': loc.faqTrackPointsAnswer},
        {'q': loc.faqContactSupportQuestion, 'a': loc.faqContactSupportAnswer},
      ];

  @override
  void initState() {
    super.initState();
    _fetchMerchantCode();
  }

  Future<void> _fetchMerchantCode() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    print('Firebase user.id: \\${user?.id}'); // طباعة uid في debug console
    if (user == null) {
      setState(() {
        _merchantCode = null;
        _loadingCode = false;
      });
      return;
    }
    final res = await supabase
        .from('merchants')
        .select('merchant_code, user_id')
        .eq('user_id', user.id)
        .maybeSingle();
    print('Supabase merchant row: \\${res?.toString()}'); // طباعة نتيجة الاستعلام
    setState(() {
      _merchantCode = res != null ? res['merchant_code'] as String? : null;
      _loadingCode = false;
    });
  }

  Future<void> _sendSupportMessage() async {
    if (_msgController.text.trim().isEmpty) return;
    setState(() => _sending = true);
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    await supabase.from('support_requests').insert({
      'user_id': user?.id,
      'message': _msgController.text.trim(),
      'type': _typeController.text.trim(),
      'created_at': DateTime.now().toIso8601String(),
    });
    setState(() => _sending = false);
    _msgController.clear();
    _typeController.clear();
    final loc = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc?.supportMessageSent ?? 'Sent')),
    );
  }

  void _contactSupport() {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc?.supportContactDialogTitle ?? ''),
        content: Text(loc?.supportContactInfo('support@coupona.com', '0555555555') ?? ''),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(loc?.close ?? 'Close'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc?.supportHelpTitle ?? ''),
        backgroundColor: Colors.deepPurple.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.key),
            tooltip: loc?.showMerchantCodeTooltip,
            onPressed: _loadingCode || _merchantCode == null || _merchantCode!.isEmpty
                ? null
                : () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(loc?.merchantShortCodeTitle ?? ''),
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
                              tooltip: loc?.copyCodeTooltip,
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: _merchantCode!));
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc?.copiedMerchantCode ?? 'Copied')));
                              },
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(loc?.close ?? 'Close'),
                          ),
                        ],
                      ),
                    );
                  },
          ),
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
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Text(
                            loc?.merchantCodePrefix ?? '',
                            style: const TextStyle(fontSize: 14, color: Colors.white),
                          ),
                          SelectableText(
                            _merchantCode!,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, color: Colors.white, size: 20),
                            tooltip: loc?.copyCodeTooltip,
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _merchantCode!));
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc?.copiedMerchantCode ?? 'Copied')));
                            },
                          ),
                        ],
                      ),
                    )
                  : const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('—', style: TextStyle(color: Colors.white)),
                    ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(loc?.supportFaqTitle ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 12),
          ..._faqLocalized(loc!).map((item) => ExpansionTile(
                title: Text(item['q']!),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(item['a']!),
                  ),
                ],
              )),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _contactSupport,
            icon: const Icon(Icons.support_agent),
            label: Text(loc?.contactSupportButton ?? ''),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
          ),
          const SizedBox(height: 32),
          Text(loc?.sendIssueSuggestionTitle ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),
          TextField(
            controller: _typeController,
            decoration: InputDecoration(labelText: loc?.messageTypeLabel),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _msgController,
            decoration: InputDecoration(labelText: loc?.messageInputLabel),
            minLines: 2,
            maxLines: 5,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _sending ? null : _sendSupportMessage,
            child: _sending ? const CircularProgressIndicator() : Text(loc?.sendButton ?? '', style: const TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }
}
