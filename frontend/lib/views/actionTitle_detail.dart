import 'package:flutter/material.dart';

import '../databases/product_db.dart';
import '../models/action_title.dart';
import '../models/products.dart';

class ActionTileDetails extends StatefulWidget {
  const ActionTileDetails({super.key, required this.tile});

  final ActionTile tile;

  @override
  State<ActionTileDetails> createState() => _ActionTileDetailsState();
}

class _ActionTileDetailsState extends State<ActionTileDetails> {
  static const int _pageSize = 50;

  final List<Product> _products = <Product>[];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;

  String? get _statusFilter {
    switch (widget.tile.title) {
      case 'Notified Cosmetic List':
        return 'Notified';
      case 'Canceled Cosmetic Notification List':
        return 'Cancelled';
      default:
        return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  Future<void> _loadMore() async {
    final String? status = _statusFilter;
    if (status == null || _isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final List<Product> nextBatch = await ProductDatabase.instance
          .fetchByStatusPaged(status, limit: _pageSize, offset: _offset);

      if (!mounted) return;

      setState(() {
        _products.addAll(nextBatch);
        _offset += nextBatch.length;
        _hasMore = nextBatch.length == _pageSize;
        _isLoading = false;
      });
    } catch (e, stacktrace) {
      print('Error fetching products: $e');
      print(stacktrace);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasMore = false;
      });
    }
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification.metrics.extentAfter < 200) {
      _loadMore();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final String? status = _statusFilter;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D0CC2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.tile.title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: status == null
            ? const Text(
                'No data is available for this action.',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              )
            : NotificationListener<ScrollNotification>(
                onNotification: _onScrollNotification,
                child: _products.isEmpty && _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF1D0CC2),
                          ),
                        ),
                      )
                    : _products.isEmpty
                        ? const Center(
                            child: Text(
                              'No products found for this category.',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Showing ${_products.length}${_hasMore ? '+' : ''} product(s)',
                                style: const TextStyle(
                                  color: Color(0xFF333752),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: ListView.builder(
                                  itemCount:
                                      _products.length + (_hasMore ? 1 : 0),
                                  itemBuilder: (BuildContext context, int index) {
                                    if (index >= _products.length) {
                                      return const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 12),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Color(0xFF1D0CC2),
                                            ),
                                          ),
                                        ),
                                      );
                                    }

                                    final Product product = _products[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Material(
                                        color: const Color(0xFFF7F8FC),
                                        borderRadius: BorderRadius.circular(12),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      'Notification: ${product.notifNo}',
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.w700,
                                                        color: Color(0xFF333752),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      product.product,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Color(0xFF1D0CC2),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      product.company,
                                                      style: const TextStyle(
                                                        color: Color(0xFF555B73),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
              ),
      ),
    );
  }
}