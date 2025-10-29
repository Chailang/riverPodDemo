import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActivityView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activity = ref.watch(activityProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pull to refresh')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(activityProvider.future),
        child: ListView(
          children: [
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
                          Icon(
                            Icons.people,
                            size: 16,
                            color: Colors.grey[600],
                          ),
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

final activityProvider = FutureProvider.autoDispose<Activity>((ref) async {
  // 模拟网络请求延迟
  await Future.delayed(Duration(milliseconds: 500 + Random().nextInt(1000)));

  // 本地测试数据
  final activities = [
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
    {
      'activity': '学习新的编程语言',
      'type': 'education',
      'participants': 1,
      'price': 0.0,
    },
    {
      'activity': '和朋友聚餐',
      'type': 'social',
      'participants': 4,
      'price': 25.0,
    },
    {
      'activity': '去公园散步',
      'type': 'relaxation',
      'participants': 1,
      'price': 0.0,
    },
    {
      'activity': '参加编程比赛',
      'type': 'education',
      'participants': 1,
      'price': 0.0,
    },
  ];

  // 随机选择一个活动
  final randomActivity = activities[Random().nextInt(activities.length)];
  return Activity.fromJson(randomActivity);
});

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