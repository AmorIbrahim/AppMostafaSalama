import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Authentic Mostafa Salama Restaurant Brand Logo & Crest
class BrandLogo extends StatelessWidget {
  final double size;
  final bool showSubtitle;
  final bool isLight;

  const BrandLogo({
    Key? key,
    this.size = 80,
    this.showSubtitle = true,
    this.isLight = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Brand Crest / Icon Badge
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFFFBF33), AppColors.primary, Color(0xFFC78400)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
          ),
          child: Center(
            child: Icon(
              Icons.restaurant_menu_rounded,
              size: size * 0.52,
              color: Colors.black,
            ),
          ),
        ),
        if (showSubtitle) ...[
          const SizedBox(height: 14),
          // Restaurant Name in Arabic
          Text(
            'مصطفى سلامة',
            style: TextStyle(
              fontSize: size * 0.32,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isLight ? AppColors.textLightPrimary : AppColors.textDarkPrimary,
            ),
          ),
          const SizedBox(height: 2),
          // Tagline / English Subtitle
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 1.5,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              const Text(
                'MOSTAFA SALAMA DELIVERY',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 14,
                height: 1.5,
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ],
    );
  }
}
