import '../../../core/network/api_client.dart';

class WishlistRepository {
  static final WishlistRepository instance = WishlistRepository._();
  WishlistRepository._();

  final _dio = ApiClient.instance;

  Future<List<String>> getWishlist() async {
    final response = await _dio.get('/wishlist');
    final List data = response.data;
    return [for (var item in data) item.toString()];
  }

  Future<List<String>> addToWishlist(String courseId) async {
    final response = await _dio.post('/wishlist', data: {'courseId': courseId});
    final List data = response.data;
    return [for (var item in data) item.toString()];
  }

  Future<void> removeFromWishlist(String courseId) async {
    await _dio.delete('/wishlist/$courseId');
  }

  Future<void> clearWishlist() async {
    await _dio.delete('/wishlist/clear');
  }

  Future<List<String>> syncWishlist(List<String> ids) async {
    final response = await _dio.post('/wishlist/sync', data: {'ids': ids});
    final List data = response.data;
    return [for (var item in data) item.toString()];
  }
}
