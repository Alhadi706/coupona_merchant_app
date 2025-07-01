import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class CachedFirestoreList<T> extends StatefulWidget {
  final String boxName;
  final Future<List<T>> Function() fetcher;
  final Widget Function(BuildContext, List<T>, bool) builder;
  const CachedFirestoreList({required this.boxName, required this.fetcher, required this.builder, super.key});

  @override
  State<CachedFirestoreList<T>> createState() => _CachedFirestoreListState<T>();
}

class _CachedFirestoreListState<T> extends State<CachedFirestoreList<T>> {
  List<T> _data = [];
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    print('[DEBUG][CachedFirestoreList] initState for box: \\${widget.boxName}');
    _loadCache();
    _fetchAndCache();
  }
  Future<void> _loadCache() async {
    print('[DEBUG][CachedFirestoreList] _loadCache for box: \\${widget.boxName}');
    final box = await Hive.openBox(widget.boxName);
    if (!mounted) return;
    setState(() {
      _data = box.values.cast<T>().toList();
      _loading = false;
    });
  }
  Future<void> _fetchAndCache() async {
    print('[DEBUG][CachedFirestoreList] _fetchAndCache for box: \\${widget.boxName}');
    final fresh = await widget.fetcher();
    final box = await Hive.openBox(widget.boxName);
    await box.clear();
    await box.addAll(fresh);
    if (!mounted) return;
    setState(() {
      _data = fresh;
    });
  }
  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _data, _loading);
  }
}
