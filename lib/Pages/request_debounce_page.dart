import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

class DebouncedActivityView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activity = ref.watch(debouncedActivityProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('防抖请求演示')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(debouncedActivityProvider.future),
        child: ListView(
          children: [
            // 说明卡片
            Card(
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text(
                          '防抖请求演示',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• 下拉刷新会发起真实的网络请求\n• 500ms 防抖延迟，避免频繁请求\n• 根据 API 返回的用户数据生成个性化活动\n• 网络失败时自动使用备用数据\n• 查看控制台日志了解请求详情',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            switch (activity) {
              AsyncValue<Activity>(:final value?) => Card(
                margin: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value.activity,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            _getTypeIcon(value.type),
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '类型: ${value.type}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.people, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '参与人数: ${value.participants}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '价格: \$${value.price.toStringAsFixed(1)}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              AsyncValue(:final error?) => Card(
                margin: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error: $error',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
              _ => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            },
          ],
        ),
      ),
    );
  }

  // 根据活动类型返回相应的图标
  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'education':
        return Icons.school;
      case 'recreational':
        return Icons.sports_basketball;
      case 'social':
        return Icons.people;
      case 'relaxation':
        return Icons.spa;
      default:
        return Icons.star;
    }
  }
}

class Activity {
  Activity({
    required this.activity,
    required this.type,
    required this.participants,
    required this.price,
  });

  factory Activity.fromJson(Map<Object?, Object?> json) {
    return Activity(
      activity: json['activity']! as String,
      type: json['type']! as String,
      participants: json['participants']! as int,
      price: json['price']! as double,
    );
  }

  final String activity;
  final String type;
  final int participants;
  final double price;
}

extension DebounceAndCancelExtension on Ref {
  /// Wait for [duration] (defaults to 500ms), and then return a [Dio] instance
  /// which can be used to make a request.
  ///
  /// That Dio instance will automatically be closed when the provider is disposed.
  Future<Dio> getDebouncedDio([Duration? duration]) async {
    // First, we handle debouncing.
    var didDispose = false;
    onDispose(() => didDispose = true);

    // We delay the request by 500ms, to wait for the user to stop refreshing.
    await Future<void>.delayed(duration ?? const Duration(milliseconds: 500));

    // If the provider was disposed during the delay, it means that the user
    // refreshed again. We throw an exception to cancel the request.
    // It is safe to use an exception here, as it will be caught by Riverpod.
    if (didDispose) {
      throw Exception('Cancelled');
    }

    // We now create the Dio instance and close it when the provider is disposed.
    final dio = Dio();
    onDispose(() => dio.close());

    // Finally, we return the Dio instance to allow our provider to make the request.
    return dio;
  }
}

final debouncedActivityProvider = FutureProvider.autoDispose<Activity>((
  ref,
) async {
  // We obtain a Dio instance using the extension we created earlier.
  final dio = await ref.getDebouncedDio();

  // 添加日志拦截器
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        print('🌐 [REQUEST] ${options.method} ${options.uri}');
        print('📋 [HEADERS] ${options.headers}');
        if (options.data != null) {
          print('📦 [DATA] ${options.data}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ [RESPONSE] ${response.statusCode} ${response.statusMessage}');
        print('📄 [BODY] ${response.data}');
        return handler.next(response);
      },
      onError: (error, handler) {
        print('❌ [ERROR] ${error.message}');
        print('🔍 [ERROR TYPE] ${error.type}');
        if (error.response != null) {
          print('📊 [ERROR RESPONSE] ${error.response?.statusCode}');
          print('📄 [ERROR BODY] ${error.response?.data}');
        }
        return handler.next(error);
      },
    ),
  );

  try {
    print('🚀 [START] 开始请求用户数据...');

    // 随机选择一个用户 ID (1-10)
    final randomUserId = Random().nextInt(10) + 1;
    print('👤 [USER ID] 随机选择用户 ID: $randomUserId');

    // 发起真实的网络请求
    final response = await dio.get(
      'https://jsonplaceholder.typicode.com/users/$randomUserId',
    );

    print('🎉 [SUCCESS] 网络请求成功！');

    // 解析用户数据
    final userData = response.data as Map<String, dynamic>;
    final userName = userData['name'] as String;
    final userEmail = userData['email'] as String;
    final userCompany = userData['company']['name'] as String;

    print('👤 [USER INFO] 用户名: $userName, 邮箱: $userEmail, 公司: $userCompany');

    // 根据用户信息生成活动
    final activities = [
      {
        'activity': '和 $userName 一起学习 Flutter 开发',
        'type': 'education',
        'participants': Random().nextInt(5) + 1,
        'price': Random().nextDouble() * 50,
      },
      {
        'activity': '与 $userCompany 团队进行技术交流',
        'type': 'social',
        'participants': Random().nextInt(10) + 2,
        'price': Random().nextDouble() * 100,
      },
      {
        'activity': '给 $userName 发送邮件: $userEmail',
        'type': 'social',
        'participants': 1,
        'price': 0.0,
      },
      {
        'activity': '参观 $userCompany 公司总部',
        'type': 'recreational',
        'participants': Random().nextInt(8) + 1,
        'price': Random().nextDouble() * 30,
      },
      {
        'activity': '与 $userName 进行在线编程挑战',
        'type': 'education',
        'participants': 2,
        'price': 0.0,
      },
    ];

    // 随机选择一个活动
    final randomActivity = activities[Random().nextInt(activities.length)];
    print('🎯 [ACTIVITY] 生成活动: ${randomActivity['activity']}');

    return Activity.fromJson(randomActivity);
  } catch (e) {
    print('💥 [FALLBACK] 网络请求失败，使用本地数据: $e');

    // 网络请求失败时的备用数据
    final fallbackActivities = [
      {
        'activity': '学习 Flutter 开发',
        'type': 'education',
        'participants': 1,
        'price': 0.0,
      },
      {
        'activity': '和朋友一起打篮球',
        'type': 'recreational',
        'participants': 5,
        'price': 0.0,
      },
      {
        'activity': '去电影院看电影',
        'type': 'social',
        'participants': 2,
        'price': 15.0,
      },
      {
        'activity': '在家做瑜伽',
        'type': 'relaxation',
        'participants': 1,
        'price': 0.0,
      },
    ];

    final randomActivity =
        fallbackActivities[Random().nextInt(fallbackActivities.length)];
    print('🔄 [FALLBACK ACTIVITY] 使用备用活动: ${randomActivity['activity']}');

    return Activity.fromJson(randomActivity);
  }
});
