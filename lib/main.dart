import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'Pages/home_page.dart';
import 'Pages/provide_list.dart';

void main() {
  runApp(
    ProviderScope(
      observers: [Logger()],
      overrides: [
        // 可以在这里添加其他 Provider 的覆盖
        // 方法2：覆盖 Provider
        // counterProvider.overrideWith(() => CustomCounterNotifier())
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// A basic logger, which logs any state changes.
final class Logger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    print('''
{
  "provider": "${context.provider}",
  "newValue": "$newValue",
  "mutation": "${context.mutation}"
}''');
  }
}



// 方法1：创建自定义 Notifier
class CustomCounterNotifier extends Notifier<int> {
  @override
  int build() => 100; // 自定义初始值
}

