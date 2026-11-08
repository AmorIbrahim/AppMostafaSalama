import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';

/// Horizontal Filter Bar for switching order categories
class StatusFilterBar extends StatelessWidget {
  final String selectedFilter;
  final void Function(String) onFilterChanged;

  const StatusFilterBar({
    Key? key,
    required this.selectedFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filters = [
      {'key': 'all', 'label': loc.translate('filterAll'), 'icon': Icons.all_inbox_rounded},
      {'key': 'pending', 'label': loc.translate('filterPending'), 'icon': Icons.hourglass_top_rounded},
      {'key': 'preparing', 'label': loc.translate('filterPreparing'), 'icon': Icons.kitchen_rounded},
      {'key': 'out_for_delivery', 'label': loc.translate('filterOutForDelivery'), 'icon': Icons.delivery_dining_rounded},
      {'key': 'delivered', 'label': loc.translate('filterDelivered'), 'icon': Icons.check_circle_rounded},
    ];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = filters[index];
          final key = item['key'] as String;
          final label = item['label'] as String;
          final icon = item['icon'] as IconData;
          final isSelected = selectedFilter == key;

          return InkWell(
            onTap: () => onFilterChanged(key),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.darkCard : AppColors.lightCard),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 15,
                    color: isSelected
                        ? Colors.black
                        : (isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? Colors.black
                          : (isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
