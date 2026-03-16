import '../../../core/network/api_client.dart';
import 'cart_item_model.dart';

class CartRepository {
  static final CartRepository instance = CartRepository._();
  CartRepository._();

  final _dio = ApiClient.instance;

  Future<List<CartItemModel>> getCart() async {
    final response = await _dio.get('/cart');
    final List data = response.data;
    return [for (var json in data) CartItemModel.fromJson(json)];
  }

  Future<List<CartItemModel>> addToCart({
    required String courseId,
    num? price,
    String? title,
  }) async {
    final response = await _dio.post(
      '/cart',
      data: {'courseId': courseId, 'price': ?price, 'title': ?title},
    );
    final List data = response.data;
    return [for (var json in data) CartItemModel.fromJson(json)];
  }

  Future<void> removeFromCart(String courseId) async {
    await _dio.delete('/cart/$courseId');
  }

  Future<void> clearCart() async {
    await _dio.delete('/cart/clear');
  }

  Future<List<CartItemModel>> syncCart(List<CartItemModel> items) async {
    final response = await _dio.post(
      '/cart/sync',
      data: {
        'items': [for (var item in items) item.toJson()],
      },
    );
    final List data = response.data;
    return [for (var json in data) CartItemModel.fromJson(json)];
  }
}
