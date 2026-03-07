import '../../../core/network/api_client.dart';

class CartItemModel {
  final String courseId;
  final num price;
  final String title;
  final String? thumbnail;

  CartItemModel({
    required this.courseId,
    required this.price,
    required this.title,
    this.thumbnail,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    String? thumb = json['thumbnail'];
    if (thumb != null &&
        thumb.isNotEmpty &&
        !thumb.startsWith('http') &&
        !thumb.startsWith('data:')) {
      thumb = '${ApiClient.baseUrl}$thumb';
    }

    return CartItemModel(
      courseId: json['courseId'] ?? '',
      price: json['price'] ?? 0,
      title: json['title'] ?? '',
      thumbnail: thumb,
    );
  }

  Map<String, dynamic> toJson() {
    return {'courseId': courseId, 'price': price, 'title': title};
  }
}
