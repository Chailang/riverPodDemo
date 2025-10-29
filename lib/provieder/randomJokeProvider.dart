import 'package:riverpod/riverpod.dart';
import 'package:dio/dio.dart';

final dio = Dio(
  BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ),
);

Future<Joke> fetchRandomJoke() async {
  try {
    print('开始请求笑话数据...');

    final response = await dio.get<Map<String, Object?>>(
      'https://official-joke-api.appspot.com/random_joke',
    );

    print('请求成功，状态码: ${response.statusCode}');
    print('响应数据: ${response.data}');

    if (response.data == null) {
      throw Exception('响应数据为空');
    }

    return Joke.fromJson(response.data!);
  } catch (e) {
    print('请求失败: $e');
    rethrow;
  }
}

final randomJokeProvider = FutureProvider<Joke>((ref) async {
  try {
    // 尝试从网络获取笑话
    return await fetchRandomJoke();
  } catch (e) {
    print('网络请求失败，使用本地笑话: $e');
    // 如果网络请求失败，返回本地笑话
    return _getLocalJoke();
  }
});

// 本地备用笑话数据
Joke _getLocalJoke() {
  final localJokes = [
    {
      'type': 'general',
      'setup': '为什么程序员喜欢用深色主题？',
      'punchline': '因为光明属于bug！',
      'id': 1001,
    },
    {
      'type': 'programming',
      'setup': '为什么程序员总是混淆圣诞节和万圣节？',
      'punchline': '因为 Oct 31 == Dec 25！',
      'id': 1002,
    },
    {
      'type': 'general',
      'setup': '为什么程序员不喜欢自然？',
      'punchline': '因为那里有太多的bug！',
      'id': 1003,
    },
    {
      'type': 'programming',
      'setup': '为什么程序员喜欢咖啡？',
      'punchline': '因为Java！',
      'id': 1004,
    },
    {
      'type': 'general',
      'setup': '为什么程序员总是带着伞？',
      'punchline': '因为他们在云端工作！',
      'id': 1005,
    },
  ];

  // 随机选择一个本地笑话
  final randomIndex = DateTime.now().millisecondsSinceEpoch % localJokes.length;
  final jokeData = localJokes[randomIndex];

  return Joke(
    type: jokeData['type'] as String,
    setup: jokeData['setup'] as String,
    punchline: jokeData['punchline'] as String,
    id: jokeData['id'] as int,
  );
}

class Joke {
  Joke({
    required this.type,
    required this.setup,
    required this.punchline,
    required this.id,
  });

  factory Joke.fromJson(Map<String, Object?> json) {
    return Joke(
      type: json['type']! as String,
      setup: json['setup']! as String,
      punchline: json['punchline']! as String,
      id: json['id']! as int,
    );
  }

  final String type;
  final String setup;
  final String punchline;
  final int id;
}
