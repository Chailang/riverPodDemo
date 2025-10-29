import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ========== 1. 基础 Provider ==========

// 计数器 Provider - 全局状态，不会自动清理
final counterProvider = NotifierProvider<CounterNotifier, int>(
  CounterNotifier.new,
);

class CounterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
  void decrement() => state--;
  void reset() => state = 0;
}

// 本地计数器 Provider - 使用普通的 NotifierProvider
// 注意：在 Riverpod 3.x 中，autoDispose 需要不同的配置
// 这里先使用普通 Provider，但添加清理说明
final localCounterProvider = NotifierProvider<LocalCounterNotifier, int>(
  LocalCounterNotifier.new,
);

class LocalCounterNotifier extends Notifier<int> {
  @override
  int build() {
    print('本地计数器初始化 - ${DateTime.now()}');

    // 注册清理函数
    ref.onDispose(() {
      print('本地计数器被清理 - ${DateTime.now()}');
    });

    return 0;
  }

  void increment() => state++;
  void decrement() => state--;
  void reset() => state = 0;
}

// 主题 Provider
final themeProvider = NotifierProvider<ThemeNotifier, String>(
  ThemeNotifier.new,
);

class ThemeNotifier extends Notifier<String> {
  @override
  String build() => 'light';

  void toggle() => state = state == 'light' ? 'dark' : 'light';
}

// ========== 2. 监听和计算 ==========

// 使用 ref.watch 自动计算双倍值
final doubledCounterProvider = Provider<int>((ref) {
  final count = ref.watch(counterProvider);
  return count * 2;
});

// ========== 3. 副作用监听 ==========

final themeLoggerProvider = NotifierProvider<ThemeLoggerNotifier, void>(
  ThemeLoggerNotifier.new,
);

class ThemeLoggerNotifier extends Notifier<void> {
  @override
  void build() {
    // 使用 ref.listen 监听主题变化
    ref.listen<String>(themeProvider, (previous, next) {
      if (previous != next) {
        print('主题从 $previous 变为 $next');
        // 这里可以添加其他副作用，如保存到本地存储
      }
    });
  }
}

// ========== 4. 异步操作 ==========

final userDataProvider = FutureProvider<String>((ref) async {
  // 模拟异步数据获取
  await Future.delayed(const Duration(seconds: 1));
  return '用户数据 - ${DateTime.now()}';
});

// ========== 5. 保持存活的 Provider ==========

final persistentDataProvider = NotifierProvider<PersistentDataNotifier, String>(
  PersistentDataNotifier.new,
);

class PersistentDataNotifier extends Notifier<String> {
  @override
  String build() {
    // 模拟昂贵的初始化
    print('PersistentData 初始化 - ${DateTime.now()}');

    // 注册清理函数 - 会在以下情况执行：
    // 1. 当 no longer watched by any widget
    // 2. 当 Provider 被 invalidate 时
    // 3. 当应用退出时
    ref.onDispose(() {
      print('PersistentData 被清理 - ${DateTime.now()}');
    });

    // 如果不使用 keepAlive()，Provider 会在没有监听者时自动销毁
    // 注释掉这行可以看到 onDispose 的执行
    // ref.keepAlive();

    return '持久化数据 ${DateTime.now()}';
  }

  // 可以添加一个方法来强制刷新，触发 onDispose
  void forceRefresh() {
    // 这将导致 Notifier 重新构建，旧的实例会被销毁，触发 onDispose
    ref.invalidateSelf();
  }
}

// ========== 6. 定时器和资源管理 ==========

// 使用 NotifierProvider.autoDispose 确保响应式更新和自动销毁
final timerServiceProvider =
    NotifierProvider.autoDispose<TimerServiceNotifier, int>(
      TimerServiceNotifier.new,
    );

class TimerServiceNotifier extends Notifier<int> {
  Timer? _timer;
  int _seconds = 0;

  @override
  int build() {
    // 注册清理函数
    ref.onDispose(() {
      print('🔄 TimerService 正在销毁，清理定时器...');
      _timer?.cancel();
      _timer = null;
      state = 0;
      print('✅ TimerService 已完全清理');
    });

    // 启动定时器
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds++;
      state = _seconds;
      print('⏰ Timer 计数: $_seconds');
    });

    print('✅ TimerService 已启动，ID: ${hashCode}');
    return 0;
  }

  void reset() {
    _seconds = 0;
    state = 0;
    print('🔄 Timer 已重置');
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    print('⏹️ Timer 已停止');
  }

  void start() {
    if (_timer == null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _seconds++;
        state = _seconds;
      });
      print('▶️ Timer 已重新启动');
    }
  }
}

// ========== 7. 操作和业务逻辑 ==========

final counterOperationsProvider =
    NotifierProvider<CounterOperationsNotifier, void>(
      CounterOperationsNotifier.new,
    );

class CounterOperationsNotifier extends Notifier<void> {
  @override
  void build() {
    // 这个 Provider 主要用于组织操作逻辑
  }

  void increment() {
    ref.read(counterProvider.notifier).state++;
  }

  void decrement() {
    ref.read(counterProvider.notifier).state--;
  }

  void reset() {
    ref.read(counterProvider.notifier).state = 0;
  }
}

// ========== 8. 条件 Provider ==========

final isPremiumProvider = Provider<bool>((ref) {
  // 模拟检查用户是否是高级用户
  final count = ref.watch(counterProvider);
  return count > 5;
});

final premiumFeatureProvider = Provider<String>((ref) {
  // 检查是否是高级用户
  final isPremium = ref.watch(isPremiumProvider);
  if (isPremium) {
    return '高级功能已解锁！';
  } else {
    return '需要成为高级用户';
  }
});

// ========== 9. 刷新和无效化 ==========

final dataManagerProvider = NotifierProvider<DataManagerNotifier, void>(
  DataManagerNotifier.new,
);

class DataManagerNotifier extends Notifier<void> {
  @override
  void build() {
    // 初始化逻辑
  }

  void refreshUserData() {
    ref.invalidate(userDataProvider);
  }

  void refreshAll() {
    ref.invalidate(counterProvider);
    ref.invalidate(timerServiceProvider);
    ref.invalidate(persistentDataProvider);
  }
}

// ========== 主页面 ==========

class RiverpodExamplesPage extends ConsumerStatefulWidget {
  const RiverpodExamplesPage({super.key});

  @override
  ConsumerState<RiverpodExamplesPage> createState() =>
      _RiverpodExamplesPageState();
}

class _RiverpodExamplesPageState extends ConsumerState<RiverpodExamplesPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    print('页面初始化 - ${DateTime.now()}');
  }

  @override
  void dispose() {
    // 页面销毁时，清理本地计数器
    ref.invalidate(localCounterProvider);
    WidgetsBinding.instance.removeObserver(this);
    print('页面销毁，本地计数器已清理 - ${DateTime.now()}');
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 监听应用生命周期
    if (state == AppLifecycleState.paused) {
      print('应用进入后台');
    } else if (state == AppLifecycleState.resumed) {
      print('应用回到前台');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeProvider);
    final currentCounter = ref.watch(counterProvider);
    final doubled = ref.watch(doubledCounterProvider);
    final timerValue = ref.watch(timerServiceProvider);
    final persistentData = ref.watch(persistentDataProvider);
    final isPremiumUser = ref.watch(isPremiumProvider);
    final premiumFeatureText = ref.watch(premiumFeatureProvider);
    final userDataAsync = ref.watch(userDataProvider);
    final localCounter = ref.watch(localCounterProvider);

    // 初始化主题监听器
    ref.watch(themeLoggerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riverpod 3.0+ Ref API 示例'),
        backgroundColor: currentTheme == 'dark' ? Colors.white : null,
      ),
      backgroundColor: currentTheme == 'dark' ? Colors.white : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 主题切换
            _buildSection('主题控制', [
              Row(
                children: [
                  Text(
                    '当前主题: $currentTheme',
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(themeProvider.notifier).toggle();
                    },
                    child: const Text('切换主题'),
                  ),
                ],
              ),
            ]),

            const SizedBox(height: 24),

            // 2. 计数器示例 - 全局状态
            _buildSection('全局计数器 (不会自动清理)', [
              Text(
                '当前计数: $currentCounter',
                style: const TextStyle(fontSize: 18, color: Colors.black),
              ),
              Text(
                '双倍计数: $doubled',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 8),
              const Text(
                '⚠️ 这是全局状态，即使离开页面也会保留',
                style: TextStyle(color: Colors.orange, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => ref
                        .read(counterOperationsProvider.notifier)
                        .increment(),
                    child: const Text('增加'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => ref
                        .read(counterOperationsProvider.notifier)
                        .decrement(),
                    child: const Text('减少'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(counterOperationsProvider.notifier).reset(),
                    child: const Text('重置'),
                  ),
                ],
              ),
            ]),

            const SizedBox(height: 24),

            // 2.1 本地计数器示例 - 带清理日志
            _buildSection('本地计数器 (与页面生命周期绑定，离开时自动清理)', [
              Text(
                '当前本地计数: $localCounter',
                style: const TextStyle(fontSize: 18, color: Colors.black),
              ),
              const SizedBox(height: 8),
              const Text(
                '✅ 这个计数器与页面生命周期绑定，离开页面时会自动清理并重置',
                style: TextStyle(color: Colors.green, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(localCounterProvider.notifier).increment(),
                    child: const Text('增加'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(localCounterProvider.notifier).decrement(),
                    child: const Text('减少'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(localCounterProvider.notifier).reset(),
                    child: const Text('重置'),
                  ),
                ],
              ),
            ]),

            const SizedBox(height: 24),

            // 3. 定时器示例
            _buildSection('定时器和资源管理', [
              Text(
                '定时器运行了 $timerValue 秒',
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () =>
                    ref.read(timerServiceProvider.notifier).reset(),
                child: const Text('重置定时器'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  // 手动销毁 Provider 来测试
                  ref.invalidate(timerServiceProvider);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('手动销毁 Timer'),
              ),
            ]),

            const SizedBox(height: 24),

            // 4. 持久化数据
            _buildSection('持久化数据 (演示 onDispose)', [
              Text(persistentData, style: const TextStyle(color: Colors.black)),
              const SizedBox(height: 8),
              Text(
                '点击下面的按钮会触发 onDispose 执行，查看控制台输出',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  // 这会触发 onDispose
                  ref.invalidate(persistentDataProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Provider 已刷新，查看控制台输出 onDispose'),
                    ),
                  );
                },
                child: const Text('刷新数据 (触发 onDispose)'),
              ),
              const SizedBox(height: 8),
              const Text(
                '注意：如果没有使用 keepAlive()，当离开页面时也会触发 onDispose',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ]),

            const SizedBox(height: 24),

            // 5. 异步数据
            _buildSection('异步数据', [
              userDataAsync.when(
                data: (data) =>
                    Text(data, style: const TextStyle(color: Colors.black)),
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text(
                  '错误: $error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () =>
                    ref.read(dataManagerProvider.notifier).refreshUserData(),
                child: const Text('刷新用户数据'),
              ),
            ]),

            const SizedBox(height: 24),

            // 6. 条件功能
            _buildSection('条件功能', [
              Text(
                '高级用户: ${isPremiumUser ? "是" : "否"}',
                style: TextStyle(
                  color: isPremiumUser ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                premiumFeatureText,
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 8),
              const Text(
                '提示：当计数器大于5时，自动成为高级用户',
                style: TextStyle(color: Colors.black54),
              ),
            ]),

            const SizedBox(height: 24),

            // 7. 全局操作
            _buildSection('全局操作', [
              ElevatedButton(
                onPressed: () =>
                    ref.read(dataManagerProvider.notifier).refreshAll(),
                child: const Text('刷新所有数据'),
              ),
            ]),

            const SizedBox(height: 24),

            // 8. ref 方法说明
            _buildSection('Ref 方法说明', [
              const Text(
                '• ref.watch() - 监听并自动更新',
                style: TextStyle(color: Colors.black),
              ),
              const Text(
                '• ref.read() - 一次性读取',
                style: TextStyle(color: Colors.black),
              ),
              const Text(
                '• ref.listen() - 监听副作用',
                style: TextStyle(color: Colors.black),
              ),
              const Text(
                '• ref.invalidate() - 刷新数据',
                style: TextStyle(color: Colors.black),
              ),
              const Text(
                '• ref.keepAlive() - 保持存活',
                style: TextStyle(color: Colors.black),
              ),
              const Text(
                '• ref.onDispose() - 清理资源',
                style: TextStyle(color: Colors.black),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}
