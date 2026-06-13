import 'package:flutter/material.dart';
import 'package:devis/design_system/design_system.dart';

class SearchableList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(T item, int index) itemBuilder;
  final String Function(T item) searchKey;
  final String? hintText;
  final int pageSize;
  final Widget Function(List<T> filtered)? header;

  const SearchableList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.searchKey,
    this.hintText,
    this.pageSize = 20,
    this.header,
  });

  @override
  State<SearchableList<T>> createState() => _SearchableListState<T>();
}

class _SearchableListState<T> extends State<SearchableList<T>> {
  final _searchController = TextEditingController();
  String _query = '';
  final _scrollController = ScrollController();
  late int _visibleCount;

  @override
  void initState() {
    super.initState();
    _visibleCount = widget.pageSize;
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<T> get _filtered {
    if (_query.isEmpty) return widget.items;
    return widget.items
        .where(
            (i) => widget.searchKey(i).toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_visibleCount < _filtered.length) {
        setState(() {
          _visibleCount =
              (_visibleCount + widget.pageSize).clamp(0, _filtered.length);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final displayItems = filtered.take(_visibleCount).toList();
    final hasMore = _visibleCount < filtered.length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: PremiumTextField(
            hint: widget.hintText ?? 'Rechercher...',
            prefixIcon: Icons.search_rounded,
            controller: _searchController,
            onChanged: (v) => setState(() {
              _query = v;
              _visibleCount = widget.pageSize;
            }),
            suffixIcon: _query.isNotEmpty ? Icons.clear_rounded : null,
            onSuffixTap: () {
              _searchController.clear();
              setState(() {
                _query = '';
                _visibleCount = widget.pageSize;
              });
            },
          ),
        ),
        if (widget.header != null) widget.header!(filtered),
        Expanded(
          child: filtered.isEmpty
              ? EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'Aucun résultat',
                  subtitle: 'Essayez un autre terme de recherche',
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: displayItems.length + (hasMore ? 1 : 0),
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
        ),
      ],
    );
  }
}
