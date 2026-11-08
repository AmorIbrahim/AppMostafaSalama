import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/app_language_provider.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/storage_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/theme_provider.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../auth/change_password_dialog.dart';

/// Driver Profile and Settings Screen
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final ordersProv = context.watch<OrdersProvider>();
    final langProv = context.watch<AppLanguageProvider>();
    final themeProv = context.watch<ThemeProvider>();
    final storage = context.read<StorageService>();
    final apiClient = context.read<ApiClient>();

    final driver = auth.driver;
    final stats = ordersProv.stats;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('profile')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // 1. Driver Profile Hero Card
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
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFBF33), AppColors.primary, Color(0xFFC78400)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                    ),
                    child: Center(
                      child: Text(
                        driver?.name.isNotEmpty == true
                            ? driver!.name.characters.first.toUpperCase()
                            : 'D',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Name
                  Text(
                    driver?.name ?? 'سائق مصطفى سلامة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Email
                  Text(
                    driver?.email ?? 'driver@mostafasalama.com',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Account Status & Role Badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.success.withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.success,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              driver?.isActive == true ? loc.translate('active') : loc.translate('inactive'),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                        ),
                        child: Text(
                          loc.translate('driverPortal'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Phone if available
                  if (driver?.phone != null && driver!.phone!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.phone_rounded, size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          driver.phone!,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Operational Metrics Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildMetric(
                      context,
                      label: loc.translate('activeOrders'),
                      value: (stats?.activeOrders ?? 0).toString(),
                      color: const Color(0xFFFF7A00),
                      isDark: isDark,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                  ),
                  Expanded(
                    child: _buildMetric(
                      context,
                      label: loc.translate('completedToday'),
                      value: (stats?.completedToday ?? 0).toString(),
                      color: AppColors.success,
                      isDark: isDark,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                  ),
                  Expanded(
                    child: _buildMetric(
                      context,
                      label: loc.translate('totalCompleted'),
                      value: (stats?.totalCompleted ?? 0).toString(),
                      color: AppColors.primary,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Settings & Preferences Group
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  // Change Password
                  ListTile(
                    leading: const Icon(Icons.lock_reset_rounded, color: AppColors.primary),
                    title: Text(
                      loc.translate('changePassword'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () => ChangePasswordDialog.show(context),
                  ),
                  const Divider(height: 1),

                  // Language Switch
                  ListTile(
                    leading: const Icon(Icons.language_rounded, color: AppColors.primary),
                    title: Text(
                      loc.translate('language'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                      ),
                    ),
                    subtitle: Text(
                      langProv.isArabic ? loc.translate('arabic') : loc.translate('english'),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                      ),
                    ),
                    trailing: Switch(
                      value: langProv.isArabic,
                      activeThumbColor: AppColors.primary,
                      onChanged: (_) => langProv.toggleLanguage(),
                    ),
                  ),
                  const Divider(height: 1),

                  // Dark / Light Mode Switch
                  ListTile(
                    leading: Icon(
                      themeProv.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      loc.translate('appearance'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                      ),
                    ),
                    subtitle: Text(
                      themeProv.isDarkMode ? loc.translate('themeDark') : loc.translate('themeLight'),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                      ),
                    ),
                    trailing: Switch(
                      value: themeProv.isDarkMode,
                      activeThumbColor: AppColors.primary,
                      onChanged: (_) => themeProv.toggleTheme(),
                    ),
                  ),
                  const Divider(height: 1),

                  // Server Environment Switcher (Production vs Local Testing)
                  ListTile(
                    leading: const Icon(Icons.dns_rounded, color: AppColors.primary),
                    title: Text(
                      loc.translate('serverEnvironment'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                      ),
                    ),
                    subtitle: Text(
                      storage.getBaseUrl(),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      onPressed: () => _showServerDialog(context, storage, apiClient),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. Logout Button
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                title: Text(
                  loc.translate('logout'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
                onTap: () async {
                  final confirmed = await ConfirmDialog.show(
                    context,
                    title: loc.translate('logoutConfirmTitle'),
                    message: loc.translate('logoutConfirmMsg'),
                    confirmText: loc.translate('logout'),
                    confirmColor: AppColors.error,
                    icon: Icons.logout_rounded,
                  );

                  if (confirmed == true && context.mounted) {
                    Navigator.of(context).pop(); // Close profile
                    await auth.logout();
                  }
                },
              ),
            ),
            const SizedBox(height: 24),

            // Version info
            Text(
              '${loc.translate('appName')} • v1.0.0+1',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  void _showServerDialog(
    BuildContext context,
    StorageService storage,
    ApiClient apiClient,
  ) {
    final controller = TextEditingController(text: storage.getBaseUrl());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Backend URL', style: TextStyle(fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Base URL',
                hintText: 'https://mostafasalama.com',
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: const Text('Production', style: TextStyle(fontSize: 11)),
                  onPressed: () => controller.text = ApiConstants.defaultProductionUrl,
                ),
                ActionChip(
                  label: const Text('Android Emulator', style: TextStyle(fontSize: 11)),
                  onPressed: () => controller.text = ApiConstants.androidEmulatorUrl,
                ),
                ActionChip(
                  label: const Text('Localhost', style: TextStyle(fontSize: 11)),
                  onPressed: () => controller.text = ApiConstants.localHostUrl,
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newUrl = controller.text.trim();
              if (newUrl.isNotEmpty) {
                await storage.setBaseUrl(newUrl);
                apiClient.updateBaseUrl(newUrl);
                if (ctx.mounted) Navigator.of(ctx).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
