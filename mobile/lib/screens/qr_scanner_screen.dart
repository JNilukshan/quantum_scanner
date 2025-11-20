import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/scan_result_dialog.dart';
import '../widgets/scan_overlay.dart';
import '../services/backend_service.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? scannedData;
  bool isFlashOn = false;
  bool isScanning = true;
  final BackendService _backendService = BackendService.instance;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
    _initializeBackendService();
  }

  Future<void> _initializeBackendService() async {
    try {
      await _backendService.initialize();
    } catch (e) {
      print('Failed to initialize backend service: $e');
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isDenied) {
      _showPermissionDeniedDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission Required'),
        content: const Text(
          'This app needs camera permission to scan QR codes. Please grant camera permission in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (isScanning && mounted) {
        setState(() {
          scannedData = scanData.code;
          isScanning = false;
        });
        _showScanResult(scanData.code ?? '');
      }
    });
  }

  void _showScanResult(String data) {
    HapticFeedback.mediumImpact();

    // Send scan data to backend
    _sendScanToBackend(data);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ScanResultDialog(
        scannedData: data,
        onScanAgain: _scanAgain,
        onCopyToClipboard: () => _copyToClipboard(data),
        onOpenUrl: () => _openUrl(data),
      ),
    );
  }

  Future<void> _sendScanToBackend(String qrData) async {
    try {
      final result = await _backendService.sendScanData(qrData);
      if (result.success) {
        print('✅ Scan data sent to web dashboard successfully');

        // Show a subtle notification that data was sent
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.wifi, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text('Data sent to dashboard'),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        print('❌ Failed to send scan data: ${result.error}');
      }
    } catch (e) {
      print('❌ Error sending scan data: $e');

      // Show error notification
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.wifi_off, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text('Failed to send to dashboard'),
              ],
            ),
            backgroundColor: Colors.orange.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _scanAgain() {
    setState(() {
      isScanning = true;
      scannedData = null;
    });
    Navigator.of(context).pop();
  }

  void _copyToClipboard(String data) {
    Clipboard.setData(ClipboardData(text: data));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Cannot open this URL'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _toggleFlash() async {
    if (controller != null) {
      await controller!.toggleFlash();
      setState(() {
        isFlashOn = !isFlashOn;
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // QR Scanner View
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Theme.of(context).colorScheme.primary,
              borderRadius: 20,
              borderLength: 30,
              borderWidth: 8,
              cutOutSize: MediaQuery.of(context).size.width * 0.7,
            ),
          ),

          // Custom Overlay
          const ScanOverlay(),

          // Top Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Title
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Quantum Scanner',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Flash Toggle
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: IconButton(
                      onPressed: _toggleFlash,
                      icon: Icon(
                        isFlashOn ? Icons.flash_off : Icons.flash_on,
                        color: isFlashOn ? Colors.amber : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Instructions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Colors.white.withOpacity(0.8),
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Point camera at QR code',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Align QR code within the frame to scan',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
