import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScanResultDialog extends StatelessWidget {
  final String scannedData;
  final VoidCallback onScanAgain;
  final VoidCallback onCopyToClipboard;
  final VoidCallback onOpenUrl;

  const ScanResultDialog({
    super.key,
    required this.scannedData,
    required this.onScanAgain,
    required this.onCopyToClipboard,
    required this.onOpenUrl,
  });

  bool _isUrl(String data) {
    return data.startsWith('http://') ||
        data.startsWith('https://') ||
        data.startsWith('www.');
  }

  String _getDataType(String data) {
    if (_isUrl(data)) return 'URL';
    if (data.contains('@') && data.contains('.')) return 'Email';
    if (RegExp(r'^\+?[\d\s-()]+$').hasMatch(data)) return 'Phone';
    return 'Text';
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'URL':
        return Icons.link;
      case 'Email':
        return Icons.email;
      case 'Phone':
        return Icons.phone;
      default:
        return Icons.text_fields;
    }
  }

  Color _getColorForType(String type, ColorScheme colorScheme) {
    switch (type) {
      case 'URL':
        return Colors.blue;
      case 'Email':
        return Colors.green;
      case 'Phone':
        return Colors.orange;
      default:
        return colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataType = _getDataType(scannedData);
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _getColorForType(dataType, colorScheme).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: 40,
                color: _getColorForType(dataType, colorScheme),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'QR Code Scanned!',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // Connection status indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.wifi,
                    size: 16,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Sent to Dashboard',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            // Data Type Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getColorForType(dataType, colorScheme).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getIconForType(dataType),
                    size: 16,
                    color: _getColorForType(dataType, colorScheme),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dataType,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getColorForType(dataType, colorScheme),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Scanned Data
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: SelectableText(
                scannedData,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Column(
              children: [
                if (_isUrl(scannedData))
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onOpenUrl();
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Open URL'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                if (_isUrl(scannedData)) const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onCopyToClipboard();
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy to Clipboard'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onScanAgain,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Scan Again'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: colorScheme.primary),
                      foregroundColor: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
