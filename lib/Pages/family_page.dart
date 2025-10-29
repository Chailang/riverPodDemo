// widgets/product_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductListPage extends ConsumerWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = [
      {'id': '1', 'name': '无线蓝牙耳机', 'price': '¥299'},
      {'id': '2', 'name': '智能手机', 'price': '¥3999'},
      {'id': '3', 'name': '智能手表', 'price': '¥1299'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('商品列表'),
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.shopping_bag, size: 40),
              title: Text(product['name']!),
              subtitle: Text(product['price']!),
              trailing: const Icon(Icons.arrow_forward_ios),
              // onTap: () {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) => ProductDetailPage(
              //         productId: product['id']!,
              //       ),
              //     ),
              //   );
              // },
            ),
          );
        },
      ),
    );
  }
}