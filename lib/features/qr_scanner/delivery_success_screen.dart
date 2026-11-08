import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/app_formatters.dart';
import '../../models/order_model.dart';
import '../../shared/widgets/app_button.dart';

/// Screen celebrating successful delivery confirmation
class DeliverySuccessScreen extends StatelessWidget {
  final OrderModel? order;
  final Map<String, dynamic>? confirmationData;

  const DeliverySuccessScreen({
    Key? key,
    this.order,
    this.confirmationData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = loc.isArabic;

    // Delivery time parsing
    DateTime confirmedAt = DateTime.now();
    if (confirmationData?['confirmed_at'] != null) {
      confirmedAt = DateTime.tryParse(confirmationData!['confirmed_at'].toString()) ?? confirmedAt;
    } else if (order?.deliveredAt != null) {
      confirmedAt = order!.deliveredAt!;
    }

    final driverName = confirmationData?['driver_name']?.toString() ?? 'سائق مصطفى سلامة';
    final orderNum = order?.orderNumber ?? 'ORD-${order?.id ?? ""}';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          Navigator.of(context).pop(true);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),

                // Animated Success Circle
                Center(
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF34D399), AppColors.success, Color(0xFF059669)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withOpacity(0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_rounded,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Success Message in Arabic & English
                Text(
                  'تم تسليم الأوردر بنجاح! 🎉',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Order delivered successfully!',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Confirmation Receipt Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Order Number
                      _buildReceiptRow(
                        context,
                        label: loc.translate('orderNumber'),
                        value: orderNum,
                        valueColor: AppColors.primary,
                        isBold: true,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),

                      // Delivery Time
                      _buildReceiptRow(
                        context,
                        label: loc.translate('deliveryConfirmedAt'),
                        value: AppFormatters.formatDateTime(confirmedAt, isArabic: isAr),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),

                      // Driver Name
                      _buildReceiptRow(
                        context,
                        label: loc.translate('deliveredBy'),
                        value: driverName,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Return to Dashboard Button
                AppButton(
                  text: loc.translate('backToDashboard'),
                  icon: Icons.dashboard_rounded,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(
    BuildContext context, {
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? (isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary),
          ),
        ),
      ],
    );
  }
}
