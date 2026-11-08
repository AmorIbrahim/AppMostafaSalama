import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/orders_provider.dart';
import '../../models/order_model.dart';
import 'widgets/stat_card.dart';
import 'widgets/status_filter_bar.dart';
import 'widgets/order_card.dart';
import 'widgets/empty_orders_view.dart';
import '../orders/order_details_screen.dart';
import '../qr_scanner/qr_scanner_screen.dart';
import '../profile/profile_screen.dart';

/// Driver Dashboard Screen - Main delivery command center
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().fetchOrders();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToOrder(OrderModel order) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrderDetailsScreen(orderId: order.id, initialOrder: order),
      ),
    );
  }

  void _openQrScanner({int? orderId}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QrScannerScreen(orderId: orderId),
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final ordersProv = context.watch<OrdersProvider>();
    final driver = auth.driver;
    final stats = ordersProv.stats;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
          onRefresh: () => ordersProv.fetchOrders(isRefresh: true),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Top Driver Header & Branding App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      // Driver Avatar
                      InkWell(
                        onTap: _navigateToProfile,
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFBF33), AppColors.primary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              driver?.name.isNotEmpty == true
                                  ? driver!.name.characters.first.toUpperCase()
                                  : 'D',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Driver Name & Status
                      Expanded(
                        child: InkWell(
                          onTap: _navigateToProfile,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                driver?.name ?? 'سائق مصطفى سلامة',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.success,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    loc.translate('active'),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.success,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '• ' + loc.translate('driverPortal'),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Restaurant Brand Logo
                      Image.asset(
                        'assets/images/logo.png',
                        height: 36,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 8),

                      // Profile Shortcut Button
                      IconButton(
                        onPressed: _navigateToProfile,
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : AppColors.lightCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            ),
                          ),
                          child: Icon(
                            Icons.settings_outlined,
                            size: 20,
                            color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Prominent Primary Action: Scan Delivery QR Code
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFB81C), AppColors.primary, Color(0xFFD88900)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _openQrScanner(),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.qr_code_scanner_rounded,
                                  size: 32,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      loc.translate('scanDeliveryQr'),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      loc.translate('scanQrPrompt'),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black.withOpacity(0.75),
                                        height: 1.2,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 18,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Operational Stats Grid
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: loc.translate('activeOrders'),
                          value: (stats?.activeOrders ?? 0).toString(),
                          icon: Icons.two_wheeler_rounded,
                          color: const Color(0xFFFF7A00),
                          onTap: () => ordersProv.setFilter('out_for_delivery'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatCard(
                          title: loc.translate('completedToday'),
                          value: (stats?.completedToday ?? 0).toString(),
                          icon: Icons.check_circle_outline_rounded,
                          color: AppColors.success,
                          onTap: () => ordersProv.setFilter('delivered'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatCard(
                          title: loc.translate('pendingOrders'),
                          value: (stats?.pendingOrders ?? 0).toString(),
                          icon: Icons.hourglass_top_rounded,
                          color: AppColors.info,
                          onTap: () => ordersProv.setFilter('pending'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 18)),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => ordersProv.setSearchQuery(val),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: loc.isArabic
                          ? 'بحث برقم الطلب، اسم العميل، الهاتف...'
                          : 'Search by order #, customer, phone...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                      ),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.primary),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                ordersProv.setSearchQuery('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 14)),

              // Filter Chips Bar
              SliverToBoxAdapter(
                child: StatusFilterBar(
                  selectedFilter: ordersProv.selectedFilter,
                  onFilterChanged: (filter) => ordersProv.setFilter(filter),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 14)),

              // Orders List Section
              if (ordersProv.isLoading && !ordersProv.isRefreshing)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (ordersProv.errorMessage != null && ordersProv.rawOrders.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.error),
                          const SizedBox(height: 14),
                          Text(
                            ordersProv.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14, color: AppColors.error),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => ordersProv.fetchOrders(),
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: Text(loc.translate('refresh')),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (ordersProv.orders.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyOrdersView(
                    onRefresh: () => ordersProv.fetchOrders(),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (itemCtx, index) {
                        final order = ordersProv.orders[index];
                        return OrderCard(
                          order: order,
                          onTap: () => _navigateToOrder(order),
                          onAccept: () async {
                            final ok = await ordersProv.acceptOrder(order.id);
                            if (ok && mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content: Text(loc.translate('tripStarted')),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          },
                          onStartDelivery: () async {
                            final ok = await ordersProv.startDelivery(order.id);
                            if (ok && mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content: Text(loc.translate('tripStarted')),
                                  backgroundColor: const Color(0xFFFF7A00),
                                ),
                              );
                            }
                          },
                          onScanQr: () => _openQrScanner(orderId: order.id),
                        );
                      },
                      childCount: ordersProv.orders.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openQrScanner(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        elevation: 4,
        icon: const Icon(Icons.qr_code_scanner_rounded, size: 22),
        label: Text(
          loc.translate('actionScanQr'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }
}
