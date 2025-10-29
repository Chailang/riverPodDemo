import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provieder/randomJokeProvider.dart';

class JockerPage extends ConsumerWidget {
  const JockerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('随机笑话生成器'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(randomJokeProvider);
            },
            tooltip: '刷新笑话',
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, _) {
          final randomJoke = ref.watch(randomJokeProvider);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 顶部进度指示器
                if (randomJoke.isRefreshing) const LinearProgressIndicator(),

                const SizedBox(height: 20),

                // 笑话内容区域
                Expanded(
                  child: Center(
                    child: randomJoke.when(
                      data: (joke) => Card(
                        elevation: 8,
                        margin: const EdgeInsets.all(16),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 笑话类型标签
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  joke.type.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // 笑话内容
                              SelectableText(
                                joke.setup,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // 分隔线
                              Container(
                                height: 1,
                                color: Colors.grey.withOpacity(0.3),
                                margin: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),

                              // 笑点
                              SelectableText(
                                joke.punchline,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // 笑话ID
                              Text(
                                'ID: ${joke.id}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      loading: () => const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            '正在获取笑话...',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                      error: (error, stackTrace) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            '获取笑话失败',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '错误: $error',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => ref.invalidate(randomJokeProvider),
                            icon: const Icon(Icons.refresh),
                            label: const Text('重试'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 底部按钮
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => ref.invalidate(randomJokeProvider),
                      icon: const Icon(Icons.shuffle),
                      label: const Text(
                        '获取另一个笑话',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
