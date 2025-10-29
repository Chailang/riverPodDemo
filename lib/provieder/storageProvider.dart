import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod/experimental/persist.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_sqflite/riverpod_sqflite.dart';

// 一个展示不使用代码生成的 JsonSqFliteStorage 的示例
final storageProvider = FutureProvider<JsonSqFliteStorage>((ref) async {
  // 初始化 SQFlite。我们应该在提供者之间共享存储实例。
  return JsonSqFliteStorage.open(join(await getDatabasesPath(), 'riverpod.db'));
});

Future<String> getDatabasesPath() async {
  // 获取应用程序的文档目录
  final directory = await getApplicationDocumentsDirectory();
  final path = directory.path;

  // 打印路径信息
  print('📁 应用文档目录: $path');
  print('🗄️ 数据库文件路径: ${join(path, 'riverpod.db')}');

  return path;
}

/// 一个可序列化的 Todo 类。
class Todo {
  const Todo({
    required this.id,
    required this.description,
    required this.completed,
  });

  Todo.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int,
      description = json['description'] as String,
      completed = json['completed'] as bool;

  final int id;
  final String description;
  final bool completed;

  Map<String, dynamic> toJson() {
    return {'id': id, 'description': description, 'completed': completed};
  }
}

final todosProvider = AsyncNotifierProvider<TodosNotifier, List<Todo>>(
  TodosNotifier.new,
);

class TodosNotifier extends AsyncNotifier<List<Todo>> {
  @override
  FutureOr<List<Todo>> build() async {
    // 我们在 'build' 方法的开始调用 persist。
    // 这将：
    // - 读取数据库并在第一次执行此方法时用持久化的值更新状态。
    // - 监听此提供者的更改并将这些更改写入数据库。
    persist(
      // 我们传递 JsonSqFliteStorage 实例。不需要 "await" Future。
      // Riverpod 会处理这个。
      ref.watch(storageProvider.future),
      // 此状态的唯一键。
      // 没有其他提供者应该使用相同的键。
      key: 'todos',
      // 默认情况下，状态仅在离线时缓存 2 天。
      // 我们可以选择取消注释以下行来更改缓存持续时间。
      // options: const StorageOptions(cacheTime: StorageCacheTime.unsafe_forever),
      encode: jsonEncode,
      decode: (json) {
        final decoded = jsonDecode(json) as List;
        return decoded
            .map((e) => Todo.fromJson(e as Map<String, Object?>))
            .toList();
      },
    );

    // 我们异步从服务器获取待办事项。
    // 在等待期间，持久化的待办事项列表将可用。
    // 网络请求完成后，服务器状态将优先于持久化状态。
    final todos = await fetchTodos();
    return todos;
  }

  Future<void> add(Todo todo) async {
    // 修改状态时，不需要任何额外的逻辑来持久化更改。
    // Riverpod 会自动缓存新状态并将其写入数据库。
    state = AsyncData([...await future, todo]);
  }

  Future<List<Todo>> fetchTodos() async {
    // 模拟从服务器获取待办事项
    // 在实际应用中，这里应该是真实的网络请求
    await Future.delayed(const Duration(seconds: 1));
    return [
      const Todo(id: 1, description: '学习 Flutter', completed: false),
      const Todo(id: 2, description: '完成项目', completed: true),
      const Todo(id: 3, description: '写文档', completed: false),
    ];
  }

  Future<void> toggleTodo(Todo todo) async {
    final currentTodos = await future;
    final updatedTodos = currentTodos.map((t) {
      if (t.id == todo.id) {
        return todo;
      }
      return t;
    }).toList();
    state = AsyncData(updatedTodos);
  }

  Future<void> removeTodo(int id) async {
    final currentTodos = await future;
    final updatedTodos = currentTodos.where((t) => t.id != id).toList();
    state = AsyncData(updatedTodos);
  }
}

// 过滤相关的提供者
enum Filter { all, active, completed }

final filterProvider = NotifierProvider<FilterNotifier, Filter>(
  FilterNotifier.new,
);

class FilterNotifier extends Notifier<Filter> {
  @override
  Filter build() => Filter.all;

  void setFilter(Filter filter) => state = filter;
}

final filteredTodosProvider = Provider<AsyncValue<List<Todo>>>((ref) {
  final filter = ref.watch(filterProvider);
  final todosAsync = ref.watch(todosProvider);

  return todosAsync.when(
    data: (todos) {
      List<Todo> filteredTodos;
      switch (filter) {
        case Filter.all:
          filteredTodos = todos;
          break;
        case Filter.active:
          filteredTodos = todos.where((todo) => !todo.completed).toList();
          break;
        case Filter.completed:
          filteredTodos = todos.where((todo) => todo.completed).toList();
          break;
      }
      return AsyncData(filteredTodos);
    },
    loading: () => const AsyncLoading(),
    error: (error, stack) => AsyncError(error, stack),
  );
});

///-===========================
///
///
///
// 一个展示不使用代码生成的 JsonSqFliteStorage 的示例
final cStorageProvider = FutureProvider<JsonSqFliteStorage>((ref) async {
  // 初始化 SQFlite。我们应该在提供者之间共享存储实例。
  return JsonSqFliteStorage.open(join(await getDatabasesPath(), 'riverpod.db'));
});

class CwdTodoNotifier extends AsyncNotifier<List<Todo>> {
  @override
  Future<List<Todo>> build() async {
    persist(
      ref.watch(cStorageProvider.future),
      key: "todo",
      encode: jsonEncode,
      decode: (json) {
        final dec = jsonDecode(json) as List;
        return dec
            .map((e) => Todo.fromJson(e as Map<String, Object?>))
            .toList();
      },
    );
    final todos = await fetchTodos();
    return todos;
  }

  Future<List<Todo>> fetchTodos() async {
    // 模拟从服务器获取待办事项
    // 在实际应用中，这里应该是真实的网络请求
    await Future.delayed(const Duration(seconds: 1));
    return [
      const Todo(id: 1, description: '学习 Flutter', completed: false),
      const Todo(id: 2, description: '完成项目', completed: true),
      const Todo(id: 3, description: '写文档', completed: false),
    ];
  }

  Future<void> toggleTodoTodo(Todo todo) async {
    final cuToDos = await future;
    final updatedTodos = cuToDos.map((t) {
      if (t.id == todo.id) {
        return todo;
      }
      return t;
    }).toList();

    state = AsyncData(updatedTodos);
  }

  Future<void> toggleTodo(Todo todo) async {
    final currentTodos = await future;
    final updatedTodos = currentTodos.map((t) {
      if (t.id == todo.id) {
        return todo;
      }
      return t;
    }).toList();
    state = AsyncData(updatedTodos);
  }

  Future<void> removeTodo(int id) async {
    final currentTodos = await future;
    final updatedTodos = currentTodos.where((t) => t.id != id).toList();
    state = AsyncData(updatedTodos);
  }
}
