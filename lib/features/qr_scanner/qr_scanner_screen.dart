import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/network/api_client.dart';
import '../../providers/orders_provider.dart';
import '../../providers/qr_scanner_provider.dart';
import 'widgets/scanner_overlay_painter.dart';
import 'delivery_success_screen.dart';

/// QR Code Scanner Screen for Delivery Confirmation
class QrScannerScreen extends StatefulWidget {
  final int? orderId;

  const QrScannerScreen({Key? key, this.orderId}) : super(key: key);

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  late final MobileScannerController _scannerController;
  late final AnimationController _animationController;
  bool _isTorchOn = false;
  bool _isHandlingCode = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      autoStart: true,
      detectionSpeed: DetectionSpeed.normal,
      detectionTimeoutMs: 200,
      facing: CameraFacing.back,
      formats: const [BarcodeFormat.qrCode],
      returnImage: false,
      torchEnabled: false,
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleBarcodeDetected(
    BarcodeCapture capture,
    QrScannerProvider qrProv,
  ) async {
    if (_isHandlingCode || qrProv.isProcessing || qrProv.isDelivered) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.trim().isEmpty) return;

    _isHandlingCode = true;

    try {
      final success = await qrProv.processBarcode(
        rawValue,
        expectedOrderId: widget.orderId,
      );

      if (!mounted) return;

      if (success) {
        // Pause scanner
        await _scannerController.stop();

        if (!mounted) return;

        // Notify OrdersProvider of delivery event
        final deliveredOrder = qrProv.confirmedOrder;
        final confData = qrProv.confirmationDetails;
        final ordersProvider = context.read<OrdersProvider>();

        if (deliveredOrder != null) {
          ordersProvider.onOrderDelivered(
            deliveredOrder.id,
            deliveredOrder.deliveredAt ?? DateTime.now(),
          );
        } else if (widget.orderId != null) {
          ordersProvider.onOrderDelivered(
            widget.orderId!,
            DateTime.now(),
          );
        }

        // Navigate to Celebration Screen
        if (mounted) {
          await Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => DeliverySuccessScreen(
                order: deliveredOrder,
                confirmationData: confData,
              ),
            ),
          );
        }
      } else {
        // Allow re-scanning after brief delay if token was invalid
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            setState(() {
              _isHandlingCode = false;
            });
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isHandlingCode = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final apiClient = context.read<ApiClient>();

    return ChangeNotifierProvider<QrScannerProvider>(
      create: (_) => QrScannerProvider(apiClient: apiClient),
      child: Consumer<QrScannerProvider>(
        builder: (context, qrProv, _) {
          final size = MediaQuery.of(context).size;
          final double scanBoxSize = size.width * 0.72;
          final Rect scanWindow = Rect.fromCenter(
            center: Offset(size.width / 2, size.height * 0.45),
            width: scanBoxSize,
            height: scanBoxSize,
          );

          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              title: Text(loc.translate('scanDeliveryQr')),
              centerTitle: true,
              actions: [
                // Torch / Flash toggle
                IconButton(
                  icon: Icon(
                    _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                    color: _isTorchOn ? AppColors.primary : Colors.white70,
                  ),
                  onPressed: () async {
                    await _scannerController.toggleTorch();
                    setState(() => _isTorchOn = !_isTorchOn);
                  },
                ),
                // Camera switch front/back
                IconButton(
                  icon: const Icon(Icons.cameraswitch_rounded, color: Colors.white70),
                  onPressed: () => _scannerController.switchCamera(),
                ),
              ],
            ),
            body: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Mobile Camera Scanner
                MobileScanner(
                  controller: _scannerController,
                  onDetect: (capture) => _handleBarcodeDetected(capture, qrProv),
                  errorBuilder: (context, error, child) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.videocam_off_rounded, size: 54, color: AppColors.error),
                            const SizedBox(height: 16),
                            Text(
                              loc.translate('cameraPermissionTitle'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              loc.translate('cameraPermissionDesc'),
                              style: const TextStyle(fontSize: 13, color: Colors.white70),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // 2. Custom Laser Overlay Mask
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: ScannerOverlayPainter(
                        scanWindow: scanWindow,
                        scanAnimationValue: _animationController.value,
                      ),
                    );
                  },
                ),

                // 3. Top Instructional Prompt
                Positioned(
                  top: 24,
                  left: 24,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            loc.translate('scanQrPrompt'),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 4. Processing Overlay Banner
                if (qrProv.isProcessing)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.75),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                          decoration: BoxDecoration(
                            color: AppColors.darkCard,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.primary, width: 1.5),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(color: AppColors.primary),
                              const SizedBox(height: 18),
                              Text(
                                loc.translate('processingScan'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // 5. Error Bottom Banner
                if (qrProv.errorMessage != null && !qrProv.isProcessing)
                  Positioned(
                    bottom: 30,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Colors.white, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              qrProv.errorMessage!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                            onPressed: () => qrProv.resetScanner(),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
