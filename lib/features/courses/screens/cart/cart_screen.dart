import 'package:eduprova/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/cart_provider.dart';
import '../../models/cart_item_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MyCartScreen extends ConsumerWidget {
  const MyCartScreen({super.key});

  Widget _buildCartItem(
    BuildContext context,
    CartItemModel item,
    WidgetRef ref,
    AppDesignExtension themeExt,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeExt.cardColor,
        border: Border(bottom: BorderSide(color: themeExt.borderColor)),
      ),
      child: Row(
        crossAxisAlignment: .start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 80,
              height: 80,
              color: themeExt.skeletonBase,
              child: item.thumbnail != null
                  ? CachedNetworkImage(
                      imageUrl: item.thumbnail!,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.image_not_supported),
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Column(
                crossAxisAlignment: .start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Course',
                        style: TextStyle(
                          fontSize: 11,
                          color: themeExt.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '₹${item.price}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          ref
                              .read(cartProvider.notifier)
                              .removeFromCart(item.courseId);
                        },
                        child: Text(
                          'Remove',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final cartState = ref.watch(cartProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: themeExt.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: themeExt.borderColor),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => context.pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.close,
                          size: 24,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      'Shopping Cart',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(
                      width: 40,
                    ), // Placeholder to balance back button
                  ],
                ),
              ),

              Expanded(
                child: Builder(
                  builder: (context) {
                    final cart = cartState.items;

                    if (cartState.isLoading && cart.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (cart.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                color: themeExt.skeletonBase,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Icon(
                                Icons.shopping_cart_outlined,
                                size: 48,
                                color: themeExt.borderColor,
                              ),
                            ),
                            Text(
                              'Your cart is empty',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 250,
                              child: Text(
                                'Looks like you haven\'t added any courses to your cart yet.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: themeExt.secondaryText,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            InkWell(
                              onTap: () => context.pop(),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.primary.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'Keep Shopping',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    num totalPrice = cart.fold(
                      0,
                      (sum, item) => sum + item.price,
                    );
                    num totalOriginalPrice =
                        totalPrice; // Modify if model adds it
                    num totalSavings = totalOriginalPrice - totalPrice;

                    return Stack(
                      children: [
                        SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: .start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                child: Text(
                                  '${cart.length} Courses in Cart',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: themeExt.secondaryText,
                                  ),
                                ),
                              ),

                              ...cart.map(
                                (item) => _buildCartItem(
                                  context,
                                  item,
                                  ref,
                                  themeExt,
                                  colorScheme,
                                ),
                              ),

                              // Order Summary
                              Container(
                                margin: const EdgeInsets.all(20),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: themeExt.cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: .start,
                                  children: [
                                    Text(
                                      'Order Summary',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Original Price',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: themeExt.secondaryText,
                                          ),
                                        ),
                                        Text(
                                          '₹$totalOriginalPrice',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: themeExt.secondaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (totalSavings > 0)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Discounts',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: themeExt.successColor,
                                            ),
                                          ),
                                          Text(
                                            '- ₹$totalSavings',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: themeExt.successColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    Container(
                                      height: 1,
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? themeExt.borderColor.withValues(
                                              alpha: 0.5,
                                            )
                                          : themeExt.borderColor,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Total',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                        Text(
                                          '₹$totalPrice',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 128,
                              ), // Spacing for bottom bar
                            ],
                          ),
                        ),

                        // Bottom Checkout Bar
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: themeExt.scaffoldBackgroundColor,
                              border: Border(
                                top: BorderSide(color: themeExt.borderColor),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: themeExt.shadowColor,
                                  blurRadius: 10,
                                  offset: const Offset(0, -5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: .start,
                                  children: [
                                    Text(
                                      'TOTAL',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                        color: themeExt.secondaryText,
                                      ),
                                    ),
                                    Text(
                                      '₹$totalPrice',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                                InkWell(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Proceeding to Checkout...',
                                        ),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: themeExt.iconColor,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: themeExt.iconColor.withValues(
                                            alpha: 0.3,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      'Checkout',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
