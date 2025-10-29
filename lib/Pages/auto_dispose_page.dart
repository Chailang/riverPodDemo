import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provieder/auto_dispose.dart';

class AutoDisPosePage extends StatelessWidget {
  const AutoDisPosePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AutoDispose 示例')),
      body: ListView(
        children: [
          _buildSectionHeader('基础用法'),
          _buildListTile(
            context,
            '1. 自动销毁的计数器',
            '当页面关闭时自动重置计数器状态',
            const CounterPage(),
          ),
          _buildListTile(
            context,
            '2. 产品过滤器',
            '离开页面时自动重置过滤条件',
            const ProductFilterPage(),
          ),
          _buildListTile(
            context,
            '3. 表单验证',
            '关闭表单时自动清除验证状态',
            const FormValidationPage(),
          ),
          _buildSectionHeader('高级用法'),

          _buildListTile(
            context,
            '4. KeepAlive 示例',
            '使用 keepAlive 手动控制 provider 生命周期',
            const KeepAliveExamplePage(),
          ),
          _buildListTile(
            context,
            '5. 结合 Family 使用',
            'autoDispose 与 family 修饰符的组合',
            const FamilyExamplePage(),
          ),
          _buildListTile(
            context,
            '6. 依赖关系示例',
            'autoDispose provider 之间的依赖关系',
            const DependencyExamplePage(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  ListTile _buildListTile(
    BuildContext context,
    String title,
    String subtitle,
    Widget page,
  ) {
    return ListTile(
      leading: const Icon(Icons.arrow_forward_ios),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }
}

// 示例1: 计数器页面
class CounterPage extends ConsumerWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('自动销毁计数器')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('当前计数:', style: TextStyle(fontSize: 20)),
            Text(
              '$counter',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              '提示：退出此页面再返回，计数会自动重置为0',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(counterProvider.notifier).state++;
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// 示例2: 产品过滤页面
class ProductFilterPage extends ConsumerWidget {
  const ProductFilterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('产品过滤器')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: '过滤产品',
                hintText: '输入关键词...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                ref.read(filterProvider.notifier).state = value;
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '提示：输入过滤条件后退出页面，再返回时会自动清空过滤条件',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('错误: $error')),
              data: (products) {
                if (products.isEmpty) {
                  return const Center(child: Text('没有找到相关产品'));
                }
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.shopping_bag),
                      title: Text(products[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 示例3: 表单验证页面
class FormValidationPage extends ConsumerWidget {
  const FormValidationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailError = ref.watch(emailErrorProvider);
    final email = ref.watch(emailProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('表单验证')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: '邮箱地址',
                hintText: '请输入邮箱',
                border: const OutlineInputBorder(),
                errorText: emailError,
              ),
              onChanged: (value) {
                ref.read(emailProvider.notifier).state = value;
              },
            ),
            const SizedBox(height: 20),
            if (email.isNotEmpty && emailError == null)
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.green[50],
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    Text(
                      '邮箱格式正确: $email',
                      style: TextStyle(color: Colors.green[700]),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              '提示：输入邮箱后退出页面，再返回时会自动清空所有表单状态',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== 高级用法示例页面 ==========

class KeepAliveExamplePage extends ConsumerWidget {
  const KeepAliveExamplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(longRunningTaskProvider);
    final progress = ref.watch(taskProgressProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('KeepAlive 示例')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '长时间运行任务示例',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              '这个任务需要5秒完成，使用 keepAlive 确保在任务完成前 provider 不会被销毁。',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.schedule),
                        SizedBox(width: 8),
                        Text(
                          '任务进度',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: progress / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress == 100 ? Colors.green : Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('${progress}% 完成'),
                    const SizedBox(height: 20),

                    taskAsync.when(
                      loading: () => const Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('任务执行中...'),
                        ],
                      ),
                      error: (error, stack) => Column(
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Text('错误: $error'),
                        ],
                      ),
                      data: (result) => Column(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            result,
                            style: const TextStyle(fontFamily: 'Monospace'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
            const Card(
              color: Colors.amber,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.amber),
                        SizedBox(width: 8),
                        Text(
                          'KeepAlive 工作原理',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• 调用 ref.keepAlive() 获取 KeepAliveLink\n'
                      '• 在任务完成前，provider 会保持存活状态\n'
                      '• 任务完成后调用 link.close()，允许 provider 在不再被监听时销毁\n'
                      '• 如果不调用 close()，provider 将一直保持存活',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 手动刷新任务
          ref.invalidate(longRunningTaskProvider);
          ref.read(taskProgressProvider.notifier).state = 0;
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class FamilyExamplePage extends ConsumerWidget {
  const FamilyExamplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Family 示例')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'autoDispose 与 Family 结合使用',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              '使用 family 参数根据用户ID获取不同的用户资料，每个provider实例都会自动管理其生命周期。',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),
            Expanded(
              child: ListView(
                children: [1, 2, 3].map((userId) {
                  return UserProfileCard(userId: userId);
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),
            const Card(
              color: Colors.purple,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.code, color: Colors.purple),
                        SizedBox(width: 8),
                        Text(
                          '代码示例',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'final userProfileProvider = FutureProvider.autoDispose'
                      '.family<UserProfile, int>((ref, userId) async { ... });',
                      style: TextStyle(fontFamily: 'Monospace', fontSize: 12),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '注意：autoDispose 必须在 family 之前调用',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserProfileCard extends ConsumerWidget {
  final int userId;

  const UserProfileCard({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider(userId));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Text('$userId'),
                ),
                const SizedBox(width: 12),
                const Text(
                  '用户资料',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Chip(
                  label: Text('ID: $userId'),
                  backgroundColor: Colors.blue[50],
                ),
              ],
            ),
            const SizedBox(height: 16),

            userAsync.when(
              loading: () => const Row(
                children: [
                  CircularProgressIndicator(value: 16),
                  SizedBox(width: 12),
                  Text('加载中...'),
                ],
              ),
              error: (error, stack) =>
                  Text('错误: $error', style: const TextStyle(color: Colors.red)),
              data: (user) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '姓名: ${user.name}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text('邮箱: ${user.email}'),
                  Text('年龄: ${user.age}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DependencyExamplePage extends ConsumerWidget {
  const DependencyExamplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final valueA = ref.watch(providerA);
    final valueB = ref.watch(providerB);
    final dataAsync = ref.watch(dataProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('依赖关系示例')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Provider 依赖关系',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              '展示 autoDispose provider 之间的依赖关系，当父provider被监听时，依赖的provider也会保持存活。',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '简单依赖示例',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    InfoRow(label: 'Provider B 的值:', value: valueB),
                    InfoRow(label: 'Provider A 的值:', value: valueA),
                    const SizedBox(height: 16),
                    const Text(
                      '说明: Provider A 依赖于 Provider B，所以当 A 被监听时，B 也会保持存活状态。',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '复杂依赖链示例',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    dataAsync.when(
                      loading: () => const Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('加载数据中...'),
                        ],
                      ),
                      error: (error, stack) => Text(
                        '错误: $error',
                        style: const TextStyle(color: Colors.red),
                      ),
                      data: (data) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('获取到的数据:'),
                          const SizedBox(height: 8),
                          ...data.map(
                            (item) => Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Text('• $item'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
            Card(
              color: Colors.green.shade50,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.account_tree, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          '依赖关系说明',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '在 autoDispose provider 的依赖链中：\n'
                      '• 只要至少有一个监听器在监听依赖链中的任何一个provider，整个依赖链都会保持存活\n'
                      '• 只有当整个依赖链都没有监听器时，所有相关的provider才会被销毁\n'
                      '• 这种机制确保了依赖关系的一致性',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
