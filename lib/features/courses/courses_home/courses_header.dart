import 'package:hugeicons/hugeicons.dart';
import 'package:eduprova/features/home/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'courses_menu_modal.dart';
import '../../../core/navigation/app_routes.dart';
import 'package:go_router/go_router.dart';

class CoursesHeader extends StatelessWidget {
  const CoursesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              mainScaffoldKey.currentState?.openDrawer();
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedMenu02,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Courses',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Icon(
                    LucideIcons.search,
                    size: 22,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  context.push(AppRoutes.myCart);
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Icon(
                    // Icons.shopping_cart_outlined,
                    LucideIcons.shoppingCart,
                    size: 22,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  showGeneralDialog(
                    context: context,
                    barrierDismissible: true,
                    barrierLabel: MaterialLocalizations.of(
                      context,
                    ).modalBarrierDismissLabel,
                    barrierColor: Colors.transparent,
                    transitionDuration: const Duration(milliseconds: 150),
                    pageBuilder: (buildContext, animation, secondaryAnimation) {
                      return CoursesMenuModal(
                        visible: true,
                        onClose: () {
                          context.pop();
                        },
                      );
                    },
                    transitionBuilder:
                        (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Icon(
                    // Icons.more_vert,
                    LucideIcons.ellipsisVertical,
                    // size: 24,
                    size: 22,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
