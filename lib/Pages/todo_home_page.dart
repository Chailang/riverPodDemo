import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../provieder/storageProvider.dart';

class TodoHomePage extends ConsumerWidget {
  const TodoHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredTodosAsync = ref.watch(filteredTodosProvider);
    final currentFilter = ref.watch(filterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // 过滤按钮
          PopupMenuButton<Filter>(
            icon: const Icon(Icons.filter_list),
            tooltip: '过滤选项',
            onSelected: (Filter filter) {
              ref.read(filterProvider.notifier).setFilter(filter);
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<Filter>(
                value: Filter.all,
                child: Row(
                  children: [
                    Icon(Icons.list, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('全部'),
                  ],
                ),
              ),
              const PopupMenuItem<Filter>(
                value: Filter.active,
                child: Row(
                  children: [
                    Icon(Icons.radio_button_unchecked, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('进行中'),
                  ],
                ),
              ),
              const PopupMenuItem<Filter>(
                value: Filter.completed,
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('已完成'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              // 刷新数据
              ref.invalidate(todosProvider);
              // 可选：显示刷新提示
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('正在刷新数据...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            tooltip: '刷新数据',
          ),
        ],
      ),
      body: Column(
        children: [
          // 过滤状态显示
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Row(
              children: [
                Icon(
                  _getFilterIcon(currentFilter),
                  color: _getFilterColor(currentFilter),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '当前过滤: ${_getFilterText(currentFilter)}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    ref.read(filterProvider.notifier).setFilter(Filter.all);
                  },
                  child: const Text('清除过滤'),
                ),
              ],
            ),
          ),
          // Todo 列表
          Expanded(
            child: filteredTodosAsync.when(
              data: (todos) => TodoList(todos: todos),
              loading: () => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('正在加载数据...'),
                  ],
                ),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('加载失败: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(todosProvider);
                      },
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoDialog(context, ref),
        tooltip: '添加 Todo',
        child: const Icon(Icons.add),
      ),
    );
  }

  // 获取过滤选项的图标
  IconData _getFilterIcon(Filter filter) {
    switch (filter) {
      case Filter.all:
        return Icons.list;
      case Filter.active:
        return Icons.radio_button_unchecked;
      case Filter.completed:
        return Icons.check_circle;
    }
  }

  // 获取过滤选项的颜色
  Color _getFilterColor(Filter filter) {
    switch (filter) {
      case Filter.all:
        return Colors.blue;
      case Filter.active:
        return Colors.orange;
      case Filter.completed:
        return Colors.green;
    }
  }

  // 获取过滤选项的文本
  String _getFilterText(Filter filter) {
    switch (filter) {
      case Filter.all:
        return '全部';
      case Filter.active:
        return '进行中';
      case Filter.completed:
        return '已完成';
    }
  }

  void _showAddTodoDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加新的 Todo'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '请输入 Todo 内容',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final todo = Todo(
                  id: DateTime.now().millisecondsSinceEpoch,
                  description: controller.text.trim(),
                  completed: false,
                );
                ref.read(todosProvider.notifier).add(todo);
                Navigator.of(context).pop();
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }
}

class TodoList extends ConsumerWidget {
  final List<Todo> todos;

  const TodoList({super.key, required this.todos});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (todos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.checklist, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '还没有 Todo 项目',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text('点击右下角的 + 按钮添加新的 Todo', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Checkbox(
              value: todo.completed,
              onChanged: (value) {
                // 切换完成状态
                final updatedTodo = Todo(
                  id: todo.id,
                  description: todo.description,
                  completed: value ?? false,
                );
                ref.read(todosProvider.notifier).toggleTodo(updatedTodo);
              },
            ),
            title: Text(
              todo.description,
              style: TextStyle(
                decoration: todo.completed
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: todo.completed ? Colors.grey : null,
              ),
            ),
            subtitle: Text(
              'ID: ${todo.id}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _showDeleteDialog(context, ref, todo);
              },
              tooltip: '删除',
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Todo todo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除 "${todo.description}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(todosProvider.notifier).removeTodo(todo.id);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
