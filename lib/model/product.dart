//电商商品详情页 Demo
//
//基于商品 ID 获取商品信息和评论的场景，我来写一个完整的 Demo。
//
//1. 数据模型

// models/product.dart

// 自定义日期范围类
class DateTimeRange {
  final DateTime start;
  final DateTime end;

  const DateTimeRange({required this.start, required this.end});
}

//评论
class Comment {
  final String id;
  final String productId;
  final String userName;
  final double rating;
  final String content;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.productId,
    required this.userName,
    required this.rating,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      productId: json['productId'],
      userName: json['userName'],
      rating: json['rating'].toDouble(),
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

// models/product.dart
class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final double rating;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.rating,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class ProductDetail {
  final String id;
  final String description;
  final List<String> imageUrls;
  final Map<String, String> specifications;

  const ProductDetail({
    required this.id,
    required this.description,
    required this.imageUrls,
    required this.specifications,
  });
}

class PriceHistory {
  final String productId;
  final List<PricePoint> history;

  const PriceHistory({required this.productId, required this.history});
}

class PricePoint {
  final DateTime date;
  final double price;

  const PricePoint({required this.date, required this.price});
}

// 评论排序方式
enum CommentSort {
  newest, // 最新
  highest, // 评分最高
  lowest, // 评分最低
}

// 参数类
// models/comment_params.dart
class CommentParams {
  final String productId;
  final CommentSort sortBy;

  const CommentParams({required this.productId, required this.sortBy});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommentParams &&
        other.productId == productId &&
        other.sortBy == sortBy;
  }

  @override
  int get hashCode => Object.hash(productId, sortBy);
}

// models/params.dart

// 价格历史查询参数
class PriceHistoryParams {
  final String productId;
  final DateTimeRange dateRange;

  const PriceHistoryParams({required this.productId, required this.dateRange});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PriceHistoryParams &&
          runtimeType == other.runtimeType &&
          productId == other.productId &&
          dateRange.start == other.dateRange.start &&
          dateRange.end == other.dateRange.end;

  @override
  int get hashCode => Object.hash(productId, dateRange.start, dateRange.end);
}

// 商品推荐参数
class RecommendationParams {
  final String currentProductId;
  final int limit;
  final List<String> excludeCategories;

  const RecommendationParams({
    required this.currentProductId,
    this.limit = 5,
    this.excludeCategories = const [],
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecommendationParams &&
          runtimeType == other.runtimeType &&
          currentProductId == other.currentProductId &&
          limit == other.limit &&
          _listEquals(excludeCategories, other.excludeCategories);

  @override
  int get hashCode =>
      Object.hash(currentProductId, limit, Object.hashAll(excludeCategories));

  static bool _listEquals(List<String> list1, List<String> list2) {
    if (identical(list1, list2)) return true;
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }
}

// 商品搜索参数
class SearchParams {
  final String query;
  final String? category;
  final double? minPrice;
  final double? maxPrice;
  final SortBy sortBy;

  const SearchParams({
    required this.query,
    this.category,
    this.minPrice,
    this.maxPrice,
    this.sortBy = SortBy.relevance,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchParams &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          category == other.category &&
          minPrice == other.minPrice &&
          maxPrice == other.maxPrice &&
          sortBy == other.sortBy;

  @override
  int get hashCode => Object.hash(query, category, minPrice, maxPrice, sortBy);
}

enum SortBy { relevance, priceLowToHigh, priceHighToLow, rating }
