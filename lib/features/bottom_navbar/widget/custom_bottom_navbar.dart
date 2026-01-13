import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_haven/core/assets/app_colors.dart';

import 'package:home_haven/features/cart/controller/cart_controller.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CustomNavbar extends StatelessWidget {
  const CustomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: Offset(0, -5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: CurvedNavigationBar(
        key: GlobalKey<CurvedNavigationBarState>(),
        index: currentIndex,
        height: 65,
        items: _buildNavItems(),
        color: Colors.white,
        buttonBackgroundColor: AppColors.primary,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOutCubic,
        animationDuration: Duration(milliseconds: 600),
        onTap: (index) {
          onTap(index);
          // Add haptic feedback
          _addHapticFeedback();
        },
        letIndexChange: (index) => true,
      ).animate().fadeIn(duration: 800.ms, curve: Curves.easeOut).slideY(
          begin: 1, end: 0, duration: 600.ms, curve: Curves.easeOutBack),
    );
  }

  List<Widget> _buildNavItems() {
    final items = [
      _buildNavIcon(Icons.home_rounded, 0),
      _buildNavIcon(Icons.shopping_bag_rounded, 1),
      _buildNavIcon(Icons.person_rounded, 2),
    ];

    return items;
  }

  Widget _buildNavIcon(IconData icon, int index) {
    final isSelected = index == currentIndex;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOutBack,
          padding: EdgeInsets.all(isSelected ? 8 : 6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(isSelected ? 16 : 12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.6),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            size: isSelected ? 26 : 22,
            color: isSelected ? AppColors.primary : Colors.grey[600],
          )
              .animate(target: isSelected ? 1 : 0)
              .scale(
                begin: Offset(0.9, 0.9),
                end: Offset(1.1, 1.1),
                duration: 300.ms,
                curve: Curves.elasticOut,
              )
              .shimmer(
                delay: 100.ms,
                duration: 600.ms,
                color: Colors.white.withValues(alpha: 0.4),
              ),
        ),
        // Enhanced cart badge
        if (index == 1) _buildEnhancedCartBadge(),
      ],
    );
  }

  void _addHapticFeedback() {
    // Add subtle haptic feedback for better UX
    try {
      // Using light impact for gentle feedback
      // HapticFeedback.lightImpact();
    } catch (e) {
      // Haptic feedback not available, continue silently
    }
  }

  Widget _buildEnhancedCartBadge() {
    return Obx(() {
      final cartController = Get.find<CartController>();
      final itemCount = cartController.itemCount;

      if (itemCount == 0) return SizedBox.shrink();

      return Positioned(
        right: -8,
        top: -8,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.red.shade400,
                Colors.red.shade600,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: .4),
                blurRadius: 8,
                offset: Offset(0, 3),
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          constraints: BoxConstraints(
            minWidth: 22,
            minHeight: 22,
          ),
          child: Text(
            itemCount > 99 ? '99+' : itemCount.toString(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        )
            .animate()
            .scale(
              begin: Offset(0.5, 0.5),
              duration: 400.ms,
              curve: Curves.elasticOut,
            )
            .fadeIn(duration: 200.ms)
            .shimmer(
              delay: 500.ms,
              duration: 1000.ms,
              color: Colors.white.withValues(alpha: 0.6),
            ),
      );
    });
  }
}
