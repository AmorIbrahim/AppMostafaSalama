import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/app_formatters.dart';
import '../../../models/order_model.dart';

/// Visual timeline of order lifecycle states
class OrderStatusTimeline extends StatelessWidget {
  final OrderModel order;

  const OrderStatusTimeline({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = loc.isArabic;

    final steps = [
      {
        'title': loc.translate('createdTime'),
        'time': order.createdAt,
        'isDone': true,
      },
      {
        'title': loc.translate('assignedTime'),
        'time': order.assignedAt,
        'isDone': order.assignedAt != null ||
            order.status == 'preparing' ||
            order.status == 'out_for_delivery' ||
            order.status == 'delivered',
      },
      {
        'title': loc.translate('acceptedTime'),
        'time': order.driverAcceptedAt,
        'isDone': order.driverAcceptedAt != null ||
            order.status == 'out_for_delivery' ||
            order.status == 'delivered',
      },
      {
        'title': loc.translate('deliveredTime'),
        'time': order.deliveredAt,
        'isDone': order.status == 'delivered',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timeline_rounded, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                loc.translate('orderTimeline'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: List.generate(steps.length, (index) {
              final step = steps[index];
              final isDone = step['isDone'] as bool;
              final time = step['time'] as DateTime?;
              final isLast = index == steps.length - 1;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dot and connector line
                    Column(
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDone ? AppColors.primary : Colors.transparent,
                            border: Border.all(
                              color: isDone
                                  ? AppColors.primary
                                  : (isDark ? AppColors.darkDivider : AppColors.lightBorder),
                              width: 2,
                            ),
                          ),
                          child: isDone
                              ? const Icon(Icons.check, size: 11, color: Colors.black)
                              : null,
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: isDone
                                  ? AppColors.primary.withOpacity(0.5)
                                  : (isDark ? AppColors.darkDivider : AppColors.lightBorder),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),

                    // Label and timestamp
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              step['title'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                                color: isDone
                                    ? (isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary)
                                    : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                              ),
                            ),
                            if (time != null)
                              Text(
                                AppFormatters.formatTimeOnly(time, isArabic: isAr),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

