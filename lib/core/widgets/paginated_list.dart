import 'package:flutter/material.dart';
import 'package:devis/design_system/design_system.dart';

class PaginatedListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(T item, int index) itemBuilder;
  final int pageSize;
  final String? emptyMessage;
  final String? emptyIcon;
  final VoidCallback? onRefresh;

  const PaginatedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.pageSize = 20,
    this.emptyMessage,
    this.emptyIcon,
    this.onRefresh,
  });

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  late int _visibleCount;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _visibleCount = widget.pageSize;
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_visibleCount < widget.items.length) {
        setState(() {
          _visibleCount =
              (_visibleCount + widget.pageSize).clamp(0, widget.items.length);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.inbox_outlined,
          title: widget.emptyMessage ?? 'Aucun élément',
          subtitle: 'Les éléments apparaîtront ici',
        ),
      );
    }

    final displayItems = widget.items.take(_visibleCount).toList();

    return RefreshIndicator(
      onRefresh: () async => widget.onRefresh?.call(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: displayItems.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= displayItems.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return widget.itemBuilder(displayItems[index], index);
        },
      ),
    );
  }

  bool get _hasMore => _visibleCount < widget.items.length;
}
