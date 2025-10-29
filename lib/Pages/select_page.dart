import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 用户模型
class User {
  final String name;
  final int age;
  final String email;

  const User({required this.name, required this.age, required this.email});

  User copyWith({String? name, int? age, String? email}) {
    return User(
      name: name ?? this.name,
      age: age ?? this.age,
      email: email ?? this.email,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.name == name &&
        other.age == age &&
        other.email == email;
  }

  @override
  int get hashCode => Object.hash(name, age, email);

  @override
  String toString() {
    return 'User(name: $name, age: $age, email: $email)';
  }
}

// 用户状态管理
class UserNotifier extends Notifier<User> {
  @override
  User build() {
    return const User(name: 'John', age: 25, email: 'john@example.com');
  }

  void updateName(String newName) {
    if (state.name != newName) {
      state = state.copyWith(name: newName);
      print('🔄 Name updated to: $newName');
    }
  }

  void updateAge(int newAge) {
    if (state.age != newAge) {
      state = state.copyWith(age: newAge);
      print('🔄 Age updated to: $newAge');
    }
  }

  void updateEmail(String newEmail) {
    if (state.email != newEmail) {
      state = state.copyWith(email: newEmail);
      print('🔄 Email updated to: $newEmail');
    }
  }
}

// Provider
final userProvider = NotifierProvider<UserNotifier, User>(UserNotifier.new);

// 分别监听不同属性的 Provider
final userNameProvider = Provider<String>((ref) {
  return ref.watch(userProvider).name;
});

final userAgeProvider = Provider<int>((ref) {
  return ref.watch(userProvider).age;
});

final userEmailProvider = Provider<String>((ref) {
  return ref.watch(userProvider).email;
});

// 使用 select 只监听特定属性
class UserProfile extends ConsumerStatefulWidget {
  const UserProfile({super.key});

  @override
  ConsumerState<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends ConsumerState<UserProfile> {
  bool _showFullUserInfo = false;

  @override
  Widget build(BuildContext context) {
    // 不再需要在这里监听，因为各个组件会独立监听

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          Switch(
            value: _showFullUserInfo,
            onChanged: (value) {
              setState(() {
                _showFullUserInfo = value;
              });
            },
          ),
          const SizedBox(width: 8),
          const Text('Show Full Info'),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 只有当 name 改变时才会重建
            _NameCard(),

            const SizedBox(height: 16),

            // 只有当 age 改变时才会重建
            _AgeCard(),

            const SizedBox(height: 16),

            // 只有当 email 改变时才会重建
            _EmailCard(),

            const SizedBox(height: 16),

            // 监听整个 user 对象（任何改变都会重建）
            if (_showFullUserInfo) _FullUserInfo(ref: ref),

            const SizedBox(height: 16),

            Card(
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '💡 Select 优化说明:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('• Name、Age、Email 卡片使用独立 Provider，只有对应属性改变时才重建'),
                    const Text('• 打开 "Show Full Info" 可以看到对比效果'),
                    const Text('• 观察控制台日志，了解哪些组件在重建'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            ref.read(userProvider.notifier).updateName('Alice');
                          },
                          child: const Text('Set Name to Alice'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(userProvider.notifier).updateAge(30);
                          },
                          child: const Text('Set Age to 30'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            ref
                                .read(userProvider.notifier)
                                .updateEmail('alice@example.com');
                          },
                          child: const Text('Set Email'),
                        ),
                      ],
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

// 独立的 Name 组件
class _NameCard extends ConsumerStatefulWidget {
  const _NameCard();

  @override
  ConsumerState<_NameCard> createState() => _NameCardState();
}

class _NameCardState extends ConsumerState<_NameCard> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userName = ref.watch(userNameProvider);
    _controller.text = userName;

    print('🔄 Rebuilding: Name'); // 只有 Name 改变时才会打印

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Text('Name: ', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: (newValue) {
                  ref.read(userProvider.notifier).updateName(newValue);
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 独立的 Age 组件
class _AgeCard extends ConsumerStatefulWidget {
  const _AgeCard();

  @override
  ConsumerState<_AgeCard> createState() => _AgeCardState();
}

class _AgeCardState extends ConsumerState<_AgeCard> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAge = ref.watch(userAgeProvider);
    _controller.text = userAge.toString();

    print('🔄 Rebuilding: Age'); // 只有 Age 改变时才会打印

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Text('Age: ', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: (newValue) {
                  final age = int.tryParse(newValue);
                  if (age != null) {
                    ref.read(userProvider.notifier).updateAge(age);
                  }
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 独立的 Email 组件
class _EmailCard extends ConsumerStatefulWidget {
  const _EmailCard();

  @override
  ConsumerState<_EmailCard> createState() => _EmailCardState();
}

class _EmailCardState extends ConsumerState<_EmailCard> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = ref.watch(userEmailProvider);
    _controller.text = userEmail;

    print('🔄 Rebuilding: Email'); // 只有 Email 改变时才会打印

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Text(
              'Email: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: (newValue) {
                  ref.read(userProvider.notifier).updateEmail(newValue);
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 监听整个对象的组件
class _FullUserInfo extends ConsumerWidget {
  final WidgetRef ref;

  const _FullUserInfo({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    print(
      '🔴 Rebuilding FULL user info (any change triggers this)',
    ); // 任何属性改变都会打印

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Full User Info (rebuilds on any change):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Name: ${user.name}'),
            Text('Age: ${user.age}'),
            Text('Email: ${user.email}'),
          ],
        ),
      ),
    );
  }
}
