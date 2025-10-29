// providers/product_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/product.dart';


// 模拟数据
final mockProducts = {
  '1': Product(
    id: '1',
    name: 'iPhone 15 Pro',
    price: 999.0,
    category: 'electronics',
    rating: 4.8,
  ),
  '2': Product(
    id: '2',
    name: 'MacBook Air',
    price: 1299.0,
    category: 'electronics',
    rating: 4.7,
  ),
  '3': Product(
    id: '3',
    name: 'AirPods Pro',
    price: 249.0,
    category: 'electronics',
    rating: 4.6,
  ),
  '4': Product(
    id: '4',
    name: 'Nike Air Max',
    price: 120.0,
    category: 'shoes',
    rating: 4.4,
  ),
  '5': Product(
    id: '5',
    name: 'Adidas Ultraboost',
    price: 180.0,
    category: 'shoes',
    rating: 4.5,
  ),
};

// 1. 基础商品信息 - 使用单个参数的 family
final productProvider = FutureProvider.family<Product, String>((ref, productId) async {
  await Future.delayed(const Duration(milliseconds: 300)); // 模拟网络延迟

  if (mockProducts.containsKey(productId)) {
    return mockProducts[productId]!;
  } else {
    throw Exception('Product not found');
  }
});

// 2. 商品详情 - 同样使用单个参数的 family
final productDetailProvider = FutureProvider.family<ProductDetail, String>((ref, productId) async {
  await Future.delayed(const Duration(milliseconds: 500));

  // 模拟商品详情数据
  return ProductDetail(
    id: productId,
    description: 'This is a detailed description for product $productId',
    imageUrls: [
      'https://picsum.photos/400/300?random=$productId&1',
      'https://picsum.photos/400/300?random=$productId&2',
    ],
    specifications: {
      'Color': 'Black',
      'Weight': '200g',
      'Warranty': '2 years',
    },
  );
});

// 3. 价格历史 - 使用复杂参数的 family
final priceHistoryProvider = FutureProvider.family<PriceHistory, PriceHistoryParams>(
      (ref, params) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟价格历史数据
    final now = DateTime.now();
    final history = [
      PricePoint(date: now.subtract(const Duration(days: 30)), price: 1099.0),
      PricePoint(date: now.subtract(const Duration(days: 15)), price: 1049.0),
      PricePoint(date: now.subtract(const Duration(days: 7)), price: 999.0),
      PricePoint(date: now, price: 899.0),
    ].where((point) =>
    point.date.isAfter(params.dateRange.start) &&
        point.date.isBefore(params.dateRange.end)
    ).toList();

    return PriceHistory(
      productId: params.productId,
      history: history,
    );
  },
);

// 4. 商品推荐 - 使用复杂参数的 family
final recommendationsProvider = FutureProvider.family<List<Product>, RecommendationParams>(
      (ref, params) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // 过滤掉当前商品和排除的分类
    final filteredProducts = mockProducts.values.where((product) {
      return product.id != params.currentProductId &&
          !params.excludeCategories.contains(product.category);
    }).toList();

    // 限制返回数量
    return filteredProducts.take(params.limit).toList();
  },
);

// 5. 商品搜索 - 使用复杂参数的 family
final searchResultsProvider = FutureProvider.family<List<Product>, SearchParams>(
      (ref, params) async {
    await Future.delayed(const Duration(milliseconds: 400));

    var results = mockProducts.values.where((product) {
      // 匹配搜索词
      final matchesQuery = product.name.toLowerCase().contains(params.query.toLowerCase());

      // 匹配分类
      final matchesCategory = params.category == null || product.category == params.category;

      // 匹配价格范围
      final matchesMinPrice = params.minPrice == null || product.price >= params.minPrice!;
      final matchesMaxPrice = params.maxPrice == null || product.price <= params.maxPrice!;

      return matchesQuery && matchesCategory && matchesMinPrice && matchesMaxPrice;
    }).toList();

    // 排序
    switch (params.sortBy) {
      case SortBy.priceLowToHigh:
        results.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortBy.priceHighToLow:
        results.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortBy.rating:
        results.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortBy.relevance:
      // 保持原顺序
        break;
    }

    return results;
  },
);