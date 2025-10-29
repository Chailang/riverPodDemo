import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';

// 1. 计数器示例的 Provider
final counterProvider = StateProvider.autoDispose<int>((ref) => 0);

// 2. 产品过滤示例的 Provider
final filterProvider = StateProvider.autoDispose<String>((ref) => '');
final productsProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final filter = ref.watch(filterProvider);
  // 模拟网络请求
  await Future.delayed(const Duration(milliseconds: 500));

  final allProducts = ['苹果手机', '三星电视', '小米手环', '华为笔记本', '索尼耳机'];
  if (filter.isEmpty) return allProducts;

  return allProducts.where((product) => product.contains(filter)).toList();
});

// 3. 表单验证示例的 Provider
final emailProvider = StateProvider.autoDispose<String>((ref) => '');
final emailErrorProvider = Provider.autoDispose<String?>((ref) {
  final email = ref.watch(emailProvider);
  if (email.isEmpty) return '请输入邮箱';
  if (!email.contains('@')) return '邮箱格式不正确';
  return null;
});

// ========== 高级用法示例 ==========

// 4. 使用 keepAlive 的示例 - 模拟长时间运行的任务
final longRunningTaskProvider = FutureProvider.autoDispose<String>((ref) async {
  // 调用 keepAlive 来在任务期间保持 provider 存活
  final link = ref.keepAlive();

  // 模拟长时间运行的任务（5秒）
  String result = '';
  for (int i = 1; i <= 5; i++) {
    await Future.delayed(const Duration(seconds: 1));
    result += '步骤 $i 完成\n';

    // 更新进度
    ref.read(taskProgressProvider.notifier).state = i * 20;
  }

  // 任务完成后，可以选择关闭链接，让 provider 在不再被监听时自动销毁
  // 如果注释掉下面这行，provider 将一直保持存活状态
  link.close();

  return '任务完成！\n$result';
});

final taskProgressProvider = StateProvider.autoDispose<int>((ref) => 0);

// 5. autoDispose 与 family 结合使用的示例
final userProfileProvider = FutureProvider.autoDispose.family<UserProfile, int>(
  (ref, userId) async {
    // 模拟根据用户ID获取用户信息
    await Future.delayed(const Duration(seconds: 1));

    // 模拟用户数据
    final users = {
      1: UserProfile('张三', 'zhangsan@example.com', 28),
      2: UserProfile('李四', 'lisi@example.com', 32),
      3: UserProfile('王五', 'wangwu@example.com', 25),
    };

    return users[userId] ?? UserProfile('未知用户', '', 0);
  },
);

class UserProfile {
  final String name;
  final String email;
  final int age;

  UserProfile(this.name, this.email, this.age);
}

// 6. 依赖关系示例 - providerA 依赖 providerB
final providerB = Provider.autoDispose<String>((ref) => '来自 B 的问候');
final providerA = Provider.autoDispose<String>((ref) {
  final valueFromB = ref.watch(providerB);
  return 'A 说: $valueFromB';
});

// 更复杂的依赖示例
final configProvider = Provider.autoDispose<String>((ref) => '基础配置');
final apiClientProvider = Provider.autoDispose<String>((ref) {
  final config = ref.watch(configProvider);
  return 'API客户端使用: $config';
});
final dataProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  await Future.delayed(const Duration(milliseconds: 800));
  return ['数据1 ($apiClient)', '数据2 ($apiClient)', '数据3 ($apiClient)'];
});
