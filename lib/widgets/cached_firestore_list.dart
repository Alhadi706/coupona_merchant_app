import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CachedFirestoreList<T> extends StatefulWidget {
  final Query query;
  final Widget Function(BuildContext, T) itemBuilder;
  final Widget? emptyWidget;

  const CachedFirestoreList({
    Key? key,
    required this.query,
    required this.itemBuilder,
    this.emptyWidget,
  }) : super(key: key);

  @override
  _CachedFirestoreListState<T> createState() => _CachedFirestoreListState<T>();
}

class _CachedFirestoreListState<T> extends State<CachedFirestoreList<T>> {
  List<T>? _cachedData;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: widget.query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting && _cachedData == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          _cachedData = snapshot.data!.docs
              .map((doc) => doc.data() as T)
              .toList();
        }

        if (_cachedData == null || _cachedData!.isEmpty) {
          return widget.emptyWidget ?? const Center(child: Text('No data found.'));
        }

        return ListView.builder(
          itemCount: _cachedData!.length,
          itemBuilder: (context, index) => widget.itemBuilder(context, _cachedData![index]),
        );
      },
    );
  }
}
