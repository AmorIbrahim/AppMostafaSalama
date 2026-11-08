import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/app_formatters.dart';
import '../../../models/order_model.dart';

/// Customer Information & Direct Actions (Call, Google Maps)
class CustomerInfoCard extends StatelessWidget {
  final CustomerModel customer;

  const CustomerInfoCard({Key? key, required this.customer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              const Icon(Icons.person_pin_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                loc.translate('customerInfo'),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Name
          Text(
            customer.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
            ),
          ),
          const SizedBox(height: 6),

          // Address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFFEF4444)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  customer.address,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action Buttons: Call & Maps
          Row(
            children: [
              // Phone Call
              if (customer.phone.isNotEmpty)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => AppFormatters.makePhoneCall(customer.phone),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
                    label: Text(
                      loc.translate('callCustomer'),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              if (customer.phone.isNotEmpty) const SizedBox(width: 10),

              // Open in Maps
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => AppFormatters.openGoogleMaps(customer.address),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    foregroundColor: isDark ? AppColors.primary : AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.directions_rounded, size: 16),
                  label: Text(
                    loc.translate('openInMaps'),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
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

