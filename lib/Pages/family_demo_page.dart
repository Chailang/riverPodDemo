// widgets/family_demo_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/product.dart' as product;
import '../provieder/product_provider.dart';

class FamilyDemoPage extends ConsumerStatefulWidget {
  const FamilyDemoPage({super.key});

  @override
  ConsumerState<FamilyDemoPage> createState() => _FamilyDemoPageState();
}

class _FamilyDemoPageState extends ConsumerState<FamilyDemoPage> {
  String _selectedProductId = '1';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Family Modifier Demo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 产品选择器
            _buildProductSelector(),
            const SizedBox(height: 24),

            // 1. 基础产品信息展示
            _buildProductInfoSection(),
            const SizedBox(height: 24),

            // 2. 产品详情展示
            _buildProductDetailSection(),
            const SizedBox(height: 24),

            // 3. 价格历史
            _buildPriceHistorySection(),
            const SizedBox(height: 24),

            // 4. 推荐商品
            _buildRecommendationsSection(),
            const SizedBox(height: 24),

            // 5. 搜索功能
            _buildSearchSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '选择产品',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: mockProducts.values.map((prod) {
                return ChoiceChip(
                  label: Text(prod.name),
                  selected: _selectedProductId == prod.id,
                  onSelected: (selected) {
                    setState(() {
                      _selectedProductId = prod.id;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfoSection() {
    final productAsync = ref.watch(productProvider(_selectedProductId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '1. 基础产品信息 (单参数 family)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            productAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('错误: $error'),
              data: (product) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '名称: ${product.name}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    '价格: \$${product.price}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    '分类: ${product.category}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    '评分: ${product.rating}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetailSection() {
    final productDetailAsync = ref.watch(
      productDetailProvider(_selectedProductId),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '2. 产品详情 (单参数 family)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            productDetailAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('错误: $error'),
              data: (detail) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('描述: ${detail.description}'),
                  const SizedBox(height: 8),
                  const Text('规格:'),
                  ...detail.specifications.entries.map(
                    (entry) => Text('  • ${entry.key}: ${entry.value}'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceHistorySection() {
    final now = DateTime.now();
    final params = product.PriceHistoryParams(
      productId: _selectedProductId,
      dateRange: product.DateTimeRange(
        start: now.subtract(const Duration(days: 60)),
        end: now,
      ),
    );

    final priceHistoryAsync = ref.watch(priceHistoryProvider(params));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '3. 价格历史 (复杂参数 family)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            priceHistoryAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('错误: $error'),
              data: (history) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('产品ID: ${history.productId}'),
                  const SizedBox(height: 8),
                  const Text('价格变化:'),
                  ...history.history.map(
                    (point) => Text(
                      '  • ${point.date.day}/${point.date.month}: \$${point.price}',
                    ),
                  ),
                  if (history.history.isEmpty) const Text('  暂无价格历史数据'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    final params = product.RecommendationParams(
      currentProductId: _selectedProductId,
      limit: 3,
      excludeCategories: const ['shoes'], // 排除鞋子分类
    );

    final recommendationsAsync = ref.watch(recommendationsProvider(params));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '4. 推荐商品 (复杂参数 family)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            recommendationsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('错误: $error'),
              data: (recommendations) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('为您推荐 (排除分类: shoes):'),
                  const SizedBox(height: 8),
                  ...recommendations.map(
                    (product) => ListTile(
                      leading: CircleAvatar(child: Text(product.id)),
                      title: Text(product.name),
                      subtitle: Text('\$${product.price}'),
                      trailing: Text('⭐ ${product.rating}'),
                    ),
                  ),
                  if (recommendations.isEmpty) const Text('暂无推荐商品'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '5. 商品搜索 (复杂参数 family)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // 搜索框
            TextField(
              decoration: const InputDecoration(
                labelText: '搜索商品',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // 搜索结果
            _buildSearchResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchQuery.isEmpty) {
      return const Text('请输入搜索关键词');
    }

    final params = product.SearchParams(
      query: _searchQuery,
      sortBy: product.SortBy.rating,
    );

    final searchResultsAsync = ref.watch(searchResultsProvider(params));

    return searchResultsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('搜索错误: $error'),
      data: (results) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('找到 ${results.length} 个结果:'),
          const SizedBox(height: 8),
          ...results.map(
            (product) => ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: Text(product.id),
              ),
              title: Text(product.name),
              subtitle: Text('${product.category} • ⭐ ${product.rating}'),
              trailing: Text('\$${product.price}'),
            ),
          ),
          if (results.isEmpty) const Text('没有找到匹配的商品'),
        ],
      ),
    );
  }
}
