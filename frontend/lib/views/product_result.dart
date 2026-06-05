import 'package:flutter/material.dart';

import '../databases/product_db.dart';
import '../models/products.dart';
import '../views/product_detail.dart';

class ProductResultsPage extends StatefulWidget {
  const ProductResultsPage({super.key, required this.query, this.isGuest = false});

  final String query;
  final bool isGuest;

  @override
  State<ProductResultsPage> createState() => _ProductResultsPageState();
}

class _ProductResultsPageState extends State<ProductResultsPage> {
  late Future<List<Product>> _future;

  @override
  void initState() {
    super.initState();
    _future = ProductDatabase.instance.searchProducts(widget.query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D0CC2),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Results for "${widget.query}"',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<Product>>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final List<Product> products = snapshot.data ?? <Product>[];
          if (products.isEmpty) {
            return const Center(
              child: Text('No products found'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (BuildContext context, int index) {
              final Product product = products[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(product.product),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ProductDetailPage(product: product, isGuest: widget.isGuest),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
