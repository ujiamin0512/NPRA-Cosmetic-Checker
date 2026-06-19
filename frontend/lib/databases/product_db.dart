import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/products.dart';
import '../services/api_service.dart';

class ProductDatabase {
  ProductDatabase._();

  static final ProductDatabase instance = ProductDatabase._();

  Future<List<Product>> searchProducts(String query) async {
    final String trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return <Product>[];

    final url = Uri.parse('${await ApiService.getBaseUrl()}/api/products/search');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': trimmedQuery}),
      );

      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        if (resData['status'] == 'success' && resData['products'] != null) {
          final List<dynamic> productsList = resData['products'];
          return productsList
              .map((data) => Product.fromMap(data as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      print('Error searching products: $e');
    }
    return <Product>[];
  }

  Future<List<Product>> fetchByStatusPaged(
    String status, {
    int limit = 50,
    int offset = 0,
  }) async {
    final url = Uri.parse('${await ApiService.getBaseUrl()}/api/products/fetch');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'status': status,
          'limit': limit,
          'offset': offset,
        }),
      );

      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        if (resData['status'] == 'success' && resData['products'] != null) {
          final List<dynamic> productsList = resData['products'];
          return productsList
              .map((data) => Product.fromMap(data as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      print('Error fetching products by status: $e');
    }
    return <Product>[];
  }
}