import 'package:riverpod/riverpod.dart';

// 数据模型
class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });

  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      name: name,
      price: price,
      quantity: quantity ?? this.quantity,
    );
  }
}

// 购物车状态管理
final cartProvider = AsyncNotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

class CartNotifier extends AsyncNotifier<List<CartItem>> {
  @override
  Future<List<CartItem>> build() async {
    // 从本地存储或服务器恢复购物车
    return await _loadCartFromStorage();
  }

  // 添加商品到购物车
  Future<void> addItem(CartItem newItem) async {
    state = await AsyncValue.guard(() async {
      final currentCart = await future;
      final existingIndex = currentCart.indexWhere(
        (item) => item.id == newItem.id,
      );

      if (existingIndex >= 0) {
        // 商品已存在，增加数量
        final updatedCart = [...currentCart];
        final existingItem = updatedCart[existingIndex];
        updatedCart[existingIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + newItem.quantity,
        );
        return updatedCart;
      } else {
        // 新商品
        return [...currentCart, newItem];
      }
    });

    // 保存到本地存储
    if (state.hasValue) {
      await _saveCartToStorage(state.value!);
    }
  }

  // 更新商品数量
  Future<void> updateQuantity(String itemId, int newQuantity) async {
    state = await AsyncValue.guard(() async {
      final currentCart = await future;
      if (newQuantity <= 0) {
        // 数量为0或负数，移除商品
        return currentCart.where((item) => item.id != itemId).toList();
      }

      return currentCart.map((item) {
        if (item.id == itemId) {
          return item.copyWith(quantity: newQuantity);
        }
        return item;
      }).toList();
    });

    if (state.hasValue) {
      await _saveCartToStorage(state.value!);
    }
  }

  // 清空购物车
  Future<void> clearCart() async {
    state = const AsyncData([]);
    await _clearCartStorage();
  }

  // 计算总价
  double get totalPrice {
    return state.when(
      data: (cart) =>
          cart.fold(0, (sum, item) => sum + (item.price * item.quantity)),
      loading: () => 0,
      error: (_, __) => 0,
    );
  }

  // 私有方法 - 本地存储操作
  Future<List<CartItem>> _loadCartFromStorage() async {
    // 实现从本地存储加载购物车的逻辑
    await Future.delayed(const Duration(milliseconds: 500)); // 模拟延迟

    // 返回一些示例商品数据用于演示
    return [
      CartItem(id: '1', name: 'iPhone 15 Pro', price: 7999.0, quantity: 1),
      CartItem(id: '2', name: 'MacBook Pro', price: 12999.0, quantity: 1),
      CartItem(id: '3', name: 'AirPods Pro', price: 1999.0, quantity: 2),
    ];
  }

  Future<void> _saveCartToStorage(List<CartItem> cart) async {
    // 实现保存购物车到本地存储的逻辑
  }

  Future<void> _clearCartStorage() async {
    // 实现清空本地存储的逻辑
  }
}
