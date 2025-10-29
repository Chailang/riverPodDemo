import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'family_demo_page.dart';
import 'jocker_page.dart';
import 'todo_home_page.dart';
import 'user_page.dart';
import 'cart_page.dart';
import 'provide_list.dart';
import 'consumer_list.dart';
import 'ref_page.dart';
import 'auto_dispose_page.dart';
import 'select_page.dart';
import 'refresh_page.dart';
import 'request_debounce_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Demo 应用'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            // 应用标题
            const Text(
              '欢迎使用 Flutter Demo',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              '请选择您要体验的功能模块',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // 功能模块卡片
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildFeatureCard(
                    context: context,
                    title: '离线存储Todo管理',
                    description: '待办事项管理\n支持增删改查',
                    icon: Icons.checklist,
                    color: Colors.blue,
                    onTap: () => _navigateToPage(context, const TodoHomePage()),
                  ),
                  _buildFeatureCard(
                    context: context,
                    title: '随机笑话',
                    description: '随机笑话生成',
                    icon: Icons.checklist,
                    color: Colors.blue,
                    onTap: () => _navigateToPage(context, const JockerPage()),
                  ),
                  _buildFeatureCard(
                    context: context,
                    title: '用户管理',
                    description: '用户信息管理\n支持用户增删',
                    icon: Icons.people,
                    color: Colors.green,
                    onTap: () => _navigateToPage(context, const UserPage()),
                  ),
                  _buildFeatureCard(
                    context: context,
                    title: '购物车',
                    description: '商品购物车\n支持增删改查',
                    icon: Icons.shopping_cart,
                    color: Colors.red,
                    onTap: () => _navigateToPage(context, const CartPage()),
                  ),
                  _buildFeatureCard(
                    context: context,
                    title: '数据存储',
                    description: 'SQLite 持久化\n数据本地存储',
                    icon: Icons.storage,
                    color: Colors.orange,
                    onTap: () => _showStorageInfo(context),
                  ),
                  _buildFeatureCard(
                    context: context,
                    title: '提供者示例',
                    description: 'Riverpod 提供者\n各种类型示例',
                    icon: Icons.code,
                    color: Colors.teal,
                    onTap: () =>
                        _navigateToPage(context, const ProviderExamplePage()),
                  ),
                  _buildFeatureCard(
                    context: context,
                    title: 'Consumer 示例',
                    description: 'Consumer 组件\n使用方式示例',
                    icon: Icons.widgets,
                    color: Colors.indigo,
                    onTap: () =>
                        _navigateToPage(context, const ConsumerExamplePage()),
                  ),
                  _buildFeatureCard(
                    context: context,
                    title: 'Ref API 示例',
                    description: 'Ref 方法演示\nwatch/read/listen',
                    icon: Icons.api,
                    color: Colors.deepPurple,
                    onTap: () =>
                        _navigateToPage(context, const RiverpodExamplesPage()),
                  ),
                  _buildFeatureCard(
                    context: context,
                    title: 'AutoDispose',
                    description: '自动销毁示例\n页面关闭时自动重置',
                    icon: Icons.autorenew,
                    color: Colors.brown,
                    onTap: () =>
                        _navigateToPage(context, const AutoDisPosePage()),
                  ),
                  _buildFeatureCard(
                    context: context,
                    title: 'family 使用',
                    description: '电商商品展示\n商品信息管理',
                    icon: Icons.shopping_bag,
                    color: Colors.cyan,
                    onTap: () =>
                        _navigateToPage(context, const FamilyDemoPage()),
                  ),
                  _buildFeatureCard(
                    context: context,
                    title: 'Select 优化',
                    description: '性能优化示例\n选择性监听属性',
                    icon: Icons.tune,
                    color: Colors.lime,
                    onTap: () => _navigateToPage(context, const UserProfile()),
                  ),
                  _buildFeatureCard(
                    context: context,
                    title: '下拉刷新',
                    description: 'Pull to Refresh\n本地数据模拟',
                    icon: Icons.refresh,
                    color: Colors.amber,
                    onTap: () => _navigateToPage(context, ActivityView()),
                  ),
                  _buildFeatureCard(
                    context: context,
                    title: '防抖请求',
                    description: 'Debounced Request\n真实网络请求',
                    icon: Icons.network_check,
                    color: Colors.deepOrange,
                    onTap: () =>
                        _navigateToPage(context, DebouncedActivityView()),
                  ),
                  _buildFeatureCard(
                    context: context,
                    title: '状态管理',
                    description: 'Riverpod 状态管理\n响应式数据流',
                    icon: Icons.settings,
                    color: Colors.purple,
                    onTap: () => _showStateInfo(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            // 底部信息
            const Text(
              '基于 Flutter + Riverpod + SQLite 构建',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  void _showStorageInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('数据存储信息'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• 使用 SQLite 数据库存储'),
            Text('• 数据持久化到本地'),
            Text('• 支持离线访问'),
            Text('• 自动数据同步'),
            SizedBox(height: 8),
            Text('数据库位置：应用文档目录/riverpod.db'),
            Text('存储格式：JSON 序列化'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('了解'),
          ),
        ],
      ),
    );
  }

  void _showStateInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('状态管理信息'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• 使用 Riverpod 状态管理'),
            Text('• 响应式数据流'),
            Text('• 自动依赖注入'),
            Text('• 类型安全的状态管理'),
            SizedBox(height: 8),
            Text('Provider 类型：'),
            Text('  - AsyncNotifierProvider'),
            Text('  - FutureProvider'),
            Text('  - StateNotifierProvider'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('了解'),
          ),
        ],
      ),
    );
  }
}
