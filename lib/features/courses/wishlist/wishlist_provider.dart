import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'wishlist_repository.dart';
import 'dart:developer';

class WishlistState {
  final bool isLoading;
  final Set<String> ids;
  final String? error;

  WishlistState({this.isLoading = false, this.ids = const {}, this.error});

  WishlistState copyWith({
    bool? isLoading,
    Set<String>? ids,
    String? error,
    bool clearError = false,
  }) {
    return WishlistState(
      isLoading: isLoading ?? this.isLoading,
      ids: ids ?? this.ids,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class WishlistNotifier extends Notifier<WishlistState> {
  final _repository = WishlistRepository.instance;

  @override
  WishlistState build() {
    Future.microtask(() => fetchWishlist());
    return .new();
  }

  Future<void> fetchWishlist() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _repository.getWishlist();
      state = state.copyWith(isLoading: false, ids: items.toSet());
    } on DioException catch (e) {
      log('Fetch Wishlist Error: ${e.response?.data}');
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data?['message'] ?? 'Failed to load wishlist',
      );
    } catch (e) {
      log('Fetch Wishlist Exception: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addToWishlist(String courseId) async {
    // Optimistic Update
    final oldItems = state.ids;
    state = state.copyWith(ids: {...state.ids, courseId});
    try {
      final items = await _repository.addToWishlist(courseId);
      state = state.copyWith(ids: items.toSet());
    } on DioException catch (e) {
      state = state.copyWith(
        ids: oldItems,
        error: e.response?.data?['message'] ?? 'Failed to add to wishlist',
      );
    } catch (e) {
      state = state.copyWith(ids: oldItems, error: e.toString());
    }
  }

  Future<void> removeFromWishlist(String courseId) async {
    // Optimistic update
    final oldItems = state.ids;
    final updated = Set<String>.from(state.ids)..remove(courseId);
    state = state.copyWith(ids: updated);
    try {
      await _repository.removeFromWishlist(courseId);
    } on DioException catch (e) {
      log('Remove Exception: ${e.response?.data}');
      state = state.copyWith(
        ids: oldItems,
        error: 'Failed to remove from wishlist',
      );
    } catch (e) {
      state = state.copyWith(ids: oldItems, error: e.toString());
    }
  }

  Future<void> toggleWishlist(String courseId) async {
    if (state.ids.contains(courseId)) {
      await removeFromWishlist(courseId);
    } else {
      await addToWishlist(courseId);
    }
  }

  Future<void> clearWishlist() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.clearWishlist();
      state = state.copyWith(isLoading: false, ids: {});
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data?['message'] ?? 'Failed to clear wishlist',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final wishlistProvider = NotifierProvider<WishlistNotifier, WishlistState>(
  WishlistNotifier.new,
);
