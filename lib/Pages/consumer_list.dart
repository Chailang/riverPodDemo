// We subclass StatelessWidget as usual
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final myProvider = Provider<String>((ref) => 'Hello from Provider!');

class MyConsumerWidget extends StatelessWidget {
  const MyConsumerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // A FutureBuilder-like widget
    return Consumer(
      // The "builder" callback gives us a "ref" parameter
      builder: (context, ref, _) {
        // We can use that "ref" to listen to providers
        final value = ref.watch(myProvider);
        return Text(value);
      },
    );
  }
}

// 我们继承 ConsumerWidget 而不是 StatelessWidget
class MyConsumerWidget1 extends ConsumerWidget {
  const MyConsumerWidget1({super.key});

  // "build" 方法接收一个额外的参数
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 我们可以使用那个 "ref" 来监听提供者
    final value = ref.watch(myProvider);
    return Text(value);
  }
}

// 我们继承 ConsumerStatefulWidget 而不是 StatefulWidget
class MyConsumerWidget2 extends ConsumerStatefulWidget {
  const MyConsumerWidget2({super.key});

  @override
  ConsumerState<MyConsumerWidget2> createState() => _MyWidgetState();
}

// 我们继承 ConsumerState 而不是 State
class _MyWidgetState extends ConsumerState<MyConsumerWidget2> {
  // 有一个可用的 "this.ref" 属性
  @override
  Widget build(BuildContext context) {
    // 我们可以使用那个 "ref" 来监听提供者
    final value = ref.watch(myProvider);
    return Text(value);
  }
}
///////////////////////////////////////
// Consumer 示例页面
class ConsumerExamplePage extends ConsumerWidget {
  const ConsumerExamplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consumer 组件示例'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Consumer 示例
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Consumer 组件示例',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('在 StatelessWidget 中使用 Consumer'),
                    const SizedBox(height: 16),
                    const MyConsumerWidget(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ConsumerWidget 示例
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ConsumerWidget 示例',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('直接继承 ConsumerWidget'),
                    const SizedBox(height: 16),
                    const MyConsumerWidget1(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ConsumerStatefulWidget 示例
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ConsumerStatefulWidget 示例',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('在有状态组件中使用 Riverpod'),
                    const SizedBox(height: 16),
                    const MyConsumerWidget2(),
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
                      'Consumer 组件类型说明',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('• Consumer: 在 StatelessWidget 中使用'),
                    Text('• ConsumerWidget: 直接继承，简化代码'),
                    Text('• ConsumerStatefulWidget: 在有状态组件中使用'),
                    Text('• ConsumerState: 配合 ConsumerStatefulWidget 使用'),
                    SizedBox(height: 8),
                    Text(
                      '所有 Consumer 组件都可以通过 ref 参数访问 Riverpod 提供者',
                      style: TextStyle(fontStyle: FontStyle.italic),
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
