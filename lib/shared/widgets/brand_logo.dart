import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Authentic Mostafa Salama Restaurant Official Brand Logo
class BrandLogo extends StatelessWidget {
  final double size;
  final bool showSubtitle;
  final bool isLight;

  const BrandLogo({
    Key? key,
    this.size = 110,
    this.showSubtitle = true,
    this.isLight = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Official Restaurant Logo Image
        Image.asset(
          'assets/images/logo.png',
          width: size * 1.6,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: size,
              height: size,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
              child: const Icon(
                Icons.restaurant_menu_rounded,
                size: 44,
                color: Colors.black,
              ),
            );
          },
        ),
        if (showSubtitle) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 14, height: 1.5, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'تطبيق مناديب التوصيل • DRIVER PORTAL',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Container(width: 14, height: 1.5, color: AppColors.primary),
            ],
          ),
        ],
      ],
    );
  }
}
