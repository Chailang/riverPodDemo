import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
////////////////////////////////////////////////
// 定义一些数据类
import '../provieder/usersProvider.dart';

class Config {
  final String appName = 'My App';
  final String version = '1.0.0';
}

// 提供者定义
final configProvider = Provider<Config>((ref) => Config());

// 使用示例
class ConfigWidget extends ConsumerWidget {
  const ConfigWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider);
    return Text(
      '${config.appName} v${config.version}',
      style: const TextStyle(fontSize: 16),
    );
  }
}
////////////////////////////////////////////////

class UserRepository {
  Future<User> getUser() async {
    await Future.delayed(const Duration(seconds: 1));
    return User(id: 1, name: 'John Doe');
  }
}

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(),
);

// 异步提供者示例
final userProvider = FutureProvider<User>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUser();
});

// 用户信息示例
class UserInfoWidget extends ConsumerWidget {
  const UserInfoWidget({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return userAsync.when(
      data: (user) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.person, size: 48),
              const SizedBox(height: 8),
              Text(
                '用户: ${user.name}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('ID: ${user.id}'),
            ],
          ),
        ),
      ),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('错误: $error'),
    );
  }
}

////////////////////////////////////////////////

// 状态提供者示例
final counterProvider = NotifierProvider<CounterNotifier, int>(
  CounterNotifier.new,
);

class CounterNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void increment() => state++;
  void decrement() => state--;
}

// 计算提供者示例
final doubleCounterProvider = Provider<int>((ref) {
  final count = ref.watch(counterProvider);
  return count * 2;
});

// 计数器示例
class CounterWidget extends ConsumerWidget {
  const CounterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    final doubleCount = ref.watch(doubleCounterProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('计数: $count', style: const TextStyle(fontSize: 24)),
        Text(
          '双倍计数: $doubleCount',
          style: const TextStyle(fontSize: 18, color: Colors.grey),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => ref.read(counterProvider.notifier).decrement(),
              child: const Text('-'),
            ),
            ElevatedButton(
              onPressed: () => ref.read(counterProvider.notifier).increment(),
              child: const Text('+'),
            ),
          ],
        ),
      ],
    );
  }
}

//////////////////////////////////////////////////////////
// 模拟实时数据流
Stream<int> countStream() async* {
  int count = 0;
  while (true) {
    await Future.delayed(const Duration(seconds: 1));
    yield count++;
  }
}

// 提供者定义
final countStreamProvider = StreamProvider<int>((ref) => countStream());

// 使用示例
class StreamCounterWidget extends ConsumerWidget {
  const StreamCounterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(countStreamProvider);
    return countAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stackTrace) => Text('Error: $error'),
      data: (count) => Text(
        'Real-time count: $count',
        style: const TextStyle(fontSize: 20, color: Colors.blue),
      ),
    );
  }
}

//////////////////////////////////////////////////////////
// 提供者示例页面
class ProviderExamplePage extends ConsumerWidget {
  const ProviderExamplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riverpod 提供者示例'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 应用配置示例
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Provider 示例',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('简单的配置提供者'),
                    const SizedBox(height: 16),
                    const ConfigWidget(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 计数器示例
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NotifierProvider 示例',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('状态管理和计算属性'),
                    const SizedBox(height: 16),
                    const CounterWidget(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 异步数据示例
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FutureProvider 示例',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('异步数据获取'),
                    const SizedBox(height: 16),
                    const UserInfoWidget(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'StreamProvider 示例',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const StreamCounterWidget(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 说明文字
            Card(
              color: Colors.blue.withOpacity(0.1),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Riverpod 提供者类型说明',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('• Provider: 简单的只读数据'),
                    Text('• NotifierProvider: 可变状态管理'),
                    Text('• FutureProvider: 异步数据获取'),
                    Text('• AsyncNotifierProvider: 复杂的异步状态'),
                    Text('• StateNotifierProvider: 已弃用，使用 NotifierProvider'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
