import 'package:riverpod/riverpod.dart';

class User {
  final int id;
  final String name;

  User({required this.id, required this.name});
}

// 模拟网络请求
Future<List<User>> fetchUsers() async {
  await Future.delayed(Duration(seconds: 2));
  return [User(id: 1, name: 'Alice'), User(id: 2, name: 'Bob')];
}

final usersProvider = AsyncNotifierProvider<UsersNotifier, List<User>>(() {
  return UsersNotifier();
});

class UsersNotifier extends AsyncNotifier<List<User>> {
  @override
  Future<List<User>> build() async {
    // 这里可以是从网络或数据库获取数据
    return fetchUsers();
  }

  Future<void> addUser(User user) async {
    // 当前状态
    final currentState = state;
    // 如果当前有数据，则在现有数据基础上添加新用户
    if (currentState is AsyncData) {
      final currentUsers = currentState.value;
      state = AsyncData([...?currentUsers, user]);
    } else {
      // 如果没有数据，则创建一个只包含新用户的列表
      state = AsyncData([user]);
    }
    // 这里可以同时将新用户保存到服务器
  }

  Future<void> removeUser(int id) async {
    final currentState = state;
    if (currentState is AsyncData) {
      final currentUsers = currentState.value;
      if (currentUsers != null) {
        state = AsyncData(currentUsers.where((user) => user.id != id).toList());
        // 同时从服务器删除
      }
    }
  }

  Future<void> refresh() async {
    // 重新加载数据
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => fetchUsers());
  }
}
