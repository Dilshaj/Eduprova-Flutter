// import 'package:eduprova/theme.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';

// class MyCartScreen extends StatelessWidget {
//   const MyCartScreen({super.key});

//   Widget _buildCartItem(
//     BuildContext context,
//     dynamic item,
//     // CoursesProvider provider,
//     AppDesignExtension themeExt,
//     ColorScheme colorScheme,
//   ) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: themeExt.cardColor,
//         border: Border(bottom: BorderSide(color: themeExt.borderColor)),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Image
//           ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: Container(
//               width: 80,
//               height: 80,
//               color: themeExt.skeletonBase,
//               child: Image.network(item['image'], fit: BoxFit.cover),
//             ),
//           ),

//           // Content
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.only(left: 12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         item['title'],
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                           height: 1.2,
//                           color: colorScheme.onSurface,
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         'By ${item['instructor']}',
//                         style: TextStyle(
//                           fontSize: 11,
//                           color: themeExt.secondaryText,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.baseline,
//                         textBaseline: TextBaseline.alphabetic,
//                         children: [
//                           Text(
//                             '₹${item['price']}',
//                             style: TextStyle(
//                               fontSize: 15,
//                               fontWeight: FontWeight.bold,
//                               color: colorScheme.onSurface,
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             '₹${item['originalPrice']}',
//                             style: TextStyle(
//                               fontSize: 11,
//                               decoration: TextDecoration.lineThrough,
//                               color: themeExt.secondaryText,
//                             ),
//                           ),
//                         ],
//                       ),
//                       InkWell(
//                         onTap: () {},
//                         child: Text(
//                           'Remove',
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
//                             color: colorScheme.primary,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
//     final colorScheme = Theme.of(context).colorScheme;

//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: Theme.of(context).brightness == Brightness.dark
//           ? SystemUiOverlayStyle.light
//           : SystemUiOverlayStyle.dark,
//       child: Scaffold(
//         backgroundColor: themeExt.scaffoldBackgroundColor,
//         body: SafeArea(
//           child: Column(
//             children: [
//               // Header
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 16,
//                 ),
//                 decoration: BoxDecoration(
//                   border: Border(
//                     bottom: BorderSide(color: themeExt.borderColor),
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     InkWell(
//                       onTap: () => Navigator.pop(context),
//                       borderRadius: BorderRadius.circular(20),
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Icon(
//                           Icons.close,
//                           size: 24,
//                           color: colorScheme.onSurface,
//                         ),
//                       ),
//                     ),
//                     Text(
//                       'Shopping Cart',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: colorScheme.onSurface,
//                       ),
//                     ),
//                     const SizedBox(
//                       width: 40,
//                     ), // Placeholder to balance back button
//                   ],
//                 ),
//               ),

//               Expanded(
//                 child: Consumer<CoursesProvider>(
//                   builder: (context, provider, child) {
//                     final cart = provider.cart;

//                     if (cart.isEmpty) {
//                       return Padding(
//                         padding: const EdgeInsets.all(20),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Container(
//                               width: 96,
//                               height: 96,
//                               decoration: BoxDecoration(
//                                 color: themeExt.skeletonBase,
//                                 shape: BoxShape.circle,
//                               ),
//                               alignment: Alignment.center,
//                               margin: const EdgeInsets.only(bottom: 16),
//                               child: Icon(
//                                 Icons.shopping_cart_outlined,
//                                 size: 48,
//                                 color: themeExt.borderColor,
//                               ),
//                             ),
//                             Text(
//                               'Your cart is empty',
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                                 color: colorScheme.onSurface,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             SizedBox(
//                               width: 250,
//                               child: Text(
//                                 'Looks like you haven\'t added any courses to your cart yet.',
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: themeExt.secondaryText,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 32),
//                             InkWell(
//                               onTap: () => Navigator.pop(context),
//                               borderRadius: BorderRadius.circular(12),
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 32,
//                                   vertical: 12,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: colorScheme.primary,
//                                   borderRadius: BorderRadius.circular(12),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: colorScheme.primary.withValues(
//                                         alpha: 0.3,
//                                       ),
//                                       blurRadius: 10,
//                                       offset: const Offset(0, 4),
//                                     ),
//                                   ],
//                                 ),
//                                 child: const Text(
//                                   'Keep Shopping',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     }

//                     num totalPrice = cart.fold(
//                       0,
//                       (sum, item) => sum + item['price'],
//                     );
//                     num totalOriginalPrice = cart.fold(
//                       0,
//                       (sum, item) => sum + item['originalPrice'],
//                     );
//                     num totalSavings = totalOriginalPrice - totalPrice;

//                     return Stack(
//                       children: [
//                         SingleChildScrollView(
//                           physics: const BouncingScrollPhysics(),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 20,
//                                   vertical: 8,
//                                 ),
//                                 child: Text(
//                                   '${cart.length} Courses in Cart',
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w600,
//                                     color: themeExt.secondaryText,
//                                   ),
//                                 ),
//                               ),

//                               ...cart.map(
//                                 (item) => _buildCartItem(
//                                   context,
//                                   item,
//                                   // provider,
//                                   themeExt,
//                                   colorScheme,
//                                 ),
//                               ),

//                               // Order Summary
//                               Container(
//                                 margin: const EdgeInsets.all(20),
//                                 padding: const EdgeInsets.all(20),
//                                 decoration: BoxDecoration(
//                                   color: themeExt.cardColor,
//                                   borderRadius: BorderRadius.circular(16),
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       'Order Summary',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                         color: colorScheme.onSurface,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 16),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text(
//                                           'Original Price',
//                                           style: TextStyle(
//                                             fontSize: 14,
//                                             color: themeExt.secondaryText,
//                                           ),
//                                         ),
//                                         Text(
//                                           '₹$totalOriginalPrice',
//                                           style: TextStyle(
//                                             fontSize: 14,
//                                             color: themeExt.secondaryText,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text(
//                                           'Discounts',
//                                           style: TextStyle(
//                                             fontSize: 14,
//                                             color: themeExt.successColor,
//                                           ),
//                                         ),
//                                         Text(
//                                           '- ₹$totalSavings',
//                                           style: TextStyle(
//                                             fontSize: 14,
//                                             color: themeExt.successColor,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     Container(
//                                       height: 1,
//                                       margin: const EdgeInsets.symmetric(
//                                         vertical: 8,
//                                       ),
//                                       color:
//                                           Theme.of(context).brightness ==
//                                               Brightness.dark
//                                           ? themeExt.borderColor.withValues(
//                                               alpha: 0.5,
//                                             )
//                                           : themeExt.borderColor,
//                                     ),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text(
//                                           'Total',
//                                           style: TextStyle(
//                                             fontSize: 18,
//                                             fontWeight: FontWeight.bold,
//                                             color: colorScheme.onSurface,
//                                           ),
//                                         ),
//                                         Text(
//                                           '₹$totalPrice',
//                                           style: TextStyle(
//                                             fontSize: 18,
//                                             fontWeight: FontWeight.bold,
//                                             color: colorScheme.onSurface,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               const SizedBox(
//                                 height: 128,
//                               ), // Spacing for bottom bar
//                             ],
//                           ),
//                         ),

//                         // Bottom Checkout Bar
//                         Positioned(
//                           bottom: 0,
//                           left: 0,
//                           right: 0,
//                           child: Container(
//                             padding: const EdgeInsets.all(20),
//                             decoration: BoxDecoration(
//                               color: themeExt.scaffoldBackgroundColor,
//                               border: Border(
//                                 top: BorderSide(color: themeExt.borderColor),
//                               ),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: themeExt.shadowColor,
//                                   blurRadius: 10,
//                                   offset: const Offset(0, -5),
//                                 ),
//                               ],
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       'TOTAL',
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.bold,
//                                         letterSpacing: 1,
//                                         color: themeExt.secondaryText,
//                                       ),
//                                     ),
//                                     Text(
//                                       '₹$totalPrice',
//                                       style: TextStyle(
//                                         fontSize: 24,
//                                         fontWeight: FontWeight.bold,
//                                         color: colorScheme.onSurface,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 InkWell(
//                                   onTap: () {
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(
//                                         content: Text(
//                                           'Proceeding to Checkout...',
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                   borderRadius: BorderRadius.circular(12),
//                                   child: Container(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 32,
//                                       vertical: 14,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: themeExt.iconColor,
//                                       borderRadius: BorderRadius.circular(12),
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: themeExt.iconColor.withValues(
//                                             alpha: 0.3,
//                                           ),
//                                           blurRadius: 10,
//                                           offset: const Offset(0, 4),
//                                         ),
//                                       ],
//                                     ),
//                                     child: const Text(
//                                       'Checkout',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
