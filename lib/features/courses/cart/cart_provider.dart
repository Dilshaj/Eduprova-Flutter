import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cart_item_model.dart';
import 'cart_repository.dart';
import 'dart:developer';

class CartState {
  final bool isLoading;
  final List<CartItemModel> items;
  final String? error;

  CartState({this.isLoading = false, this.items = const [], this.error});

  CartState copyWith({
    bool? isLoading,
    List<CartItemModel>? items,
    String? error,
    bool clearError = false,
  }) {
    return CartState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class CartNotifier extends Notifier<CartState> {
  final _repository = CartRepository.instance;

  @override
  CartState build() {
    Future.microtask(() => fetchCart());
    return .new();
  }

  Future<void> fetchCart() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _repository.getCart();
      state = state.copyWith(isLoading: false, items: items);
    } on DioException catch (e) {
      log('Fetch Cart Error: ${e.response?.data}');
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data?['message'] ?? 'Failed to load cart',
      );
    } catch (e) {
      log('Fetch Cart Exception: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addToCart(String courseId, {num? price, String? title}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _repository.addToCart(
        courseId: courseId,
        price: price,
        title: title,
      );
      state = state.copyWith(isLoading: false, items: items);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data?['message'] ?? 'Failed to add to cart',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> removeFromCart(String courseId) async {
    // Optimistic UI update
    final oldItems = state.items;
    state = state.copyWith(
      items: [
        for (final item in state.items)
          if (item.courseId != courseId) item,
      ],
    );
    try {
      await _repository.removeFromCart(courseId);
    } on DioException catch (e) {
      log('Remove Exception: ${e.response?.data}');
      // Rollback
      state = state.copyWith(
        items: oldItems,
        error: 'Failed to remove from cart',
      );
    } catch (e) {
      state = state.copyWith(items: oldItems, error: e.toString());
    }
  }

  Future<void> clearCart() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.clearCart();
      state = state.copyWith(isLoading: false, items: []);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data?['message'] ?? 'Failed to clear cart',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(
  CartNotifier.new,
);
