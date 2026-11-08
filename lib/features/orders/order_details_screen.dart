import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/network/api_client.dart';
import '../../models/order_model.dart';
import '../../providers/orders_provider.dart';
import '../../providers/order_details_provider.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/app_button.dart';
import 'widgets/order_status_timeline.dart';
import 'widgets/customer_info_card.dart';
import 'widgets/order_items_list.dart';
import 'widgets/order_summary_card.dart';
import '../qr_scanner/qr_scanner_screen.dart';

/// Full Order Details Page with Action Progression
class OrderDetailsScreen extends StatelessWidget {
  final int orderId;
  final OrderModel? initialOrder;

  const OrderDetailsScreen({
    Key? key,
    required this.orderId,
    this.initialOrder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final apiClient = context.read<ApiClient>();

    return ChangeNotifierProvider<OrderDetailsProvider>(
      create: (_) => OrderDetailsProvider(
        apiClient: apiClient,
        orderId: orderId,
        initialOrder: initialOrder,
      )..fetchOrderDetails(),
      child: const _OrderDetailsView(),
    );
  }
}

class _OrderDetailsView extends StatelessWidget {
  const _OrderDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final detailsProv = context.watch<OrderDetailsProvider>();
    final order = detailsProv.order;

    return Scaffold(
      appBar: AppBar(
        title: Text(order?.orderNumber ?? '${loc.translate('orderNumber')} #$detailsProv.orderId'),
        actions: [
          if (order != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Center(child: StatusBadge(status: order.status)),
            ),
        ],
      ),
      body: detailsProv.isLoading && order == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : order == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 40),
                      const SizedBox(height: 12),
                      Text(
                        detailsProv.errorMessage ?? loc.translate('noOrdersFound'),
                        style: const TextStyle(color: AppColors.error),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => detailsProv.fetchOrderDetails(),
                        child: Text(loc.translate('refresh')),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Order Status Timeline
                      OrderStatusTimeline(order: order),
                      const SizedBox(height: 14),

                      // 2. Customer Information Card
                      CustomerInfoCard(customer: order.customer),
                      const SizedBox(height: 14),

                      // 3. Order Items Breakdown
                      OrderItemsList(items: order.items),
                      const SizedBox(height: 14),

                      // 4. Financial Summary & Delivery Notes
                      OrderSummaryCard(order: order),
                    ],
                  ),
                ),
      bottomSheet: order == null ? null : _buildBottomSheet(context, order, detailsProv),
    );
  }

  Widget _buildBottomSheet(
    BuildContext context,
    OrderModel order,
    OrderDetailsProvider detailsProv,
  ) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = order.status.toLowerCase();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: _buildActionForStatus(context, order, detailsProv, status, loc),
      ),
    );
  }

  Widget _buildActionForStatus(
    BuildContext context,
    OrderModel order,
    OrderDetailsProvider detailsProv,
    String status,
    AppLocalizations loc,
  ) {
    if (status == 'pending' || status == 'confirmed') {
      return AppButton(
        text: loc.translate('actionAcceptOrder'),
        icon: Icons.check_circle_rounded,
        backgroundColor: AppColors.purple,
        textColor: Colors.white,
        isLoading: detailsProv.isActionLoading,
        onPressed: () async {
          final ok = await detailsProv.acceptOrder();
          if (ok && context.mounted) {
            context.read<OrdersProvider>().fetchOrders();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(loc.translate('tripStarted')),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
      );
    }

    if (status == 'preparing') {
      return AppButton(
        text: loc.translate('actionStartDelivery'),
        icon: Icons.two_wheeler_rounded,
        backgroundColor: const Color(0xFFFF7A00),
        textColor: Colors.white,
        isLoading: detailsProv.isActionLoading,
        onPressed: () async {
          final ok = await detailsProv.startDelivery();
          if (ok && context.mounted) {
            context.read<OrdersProvider>().fetchOrders();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(loc.translate('tripStarted')),
                backgroundColor: const Color(0xFFFF7A00),
              ),
            );
          }
        },
      );
    }

    if (status == 'out_for_delivery') {
      return AppButton(
        text: loc.translate('scanDeliveryQr'),
        icon: Icons.qr_code_scanner_rounded,
        backgroundColor: AppColors.primary,
        textColor: Colors.black,
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => QrScannerScreen(orderId: order.id),
            ),
          );
          if (result == true && context.mounted) {
            detailsProv.fetchOrderDetails();
            context.read<OrdersProvider>().fetchOrders();
          }
        },
      );
    }

    if (status == 'delivered') {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.success.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified_rounded, color: AppColors.success, size: 20),
            const SizedBox(width: 8),
            Text(
              loc.translate('status_delivered'),
              style: const TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    // Cancelled or other
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          loc.orderStatusText(status),
          style: const TextStyle(
            color: AppColors.error,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
