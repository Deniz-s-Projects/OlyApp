import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/qr_service.dart';

class QrScannerPage extends StatefulWidget {
  final QrService? service;
  const QrScannerPage({super.key, this.service});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  bool _handled = false;

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handled) return;
    final code = capture.barcodes.first.rawValue;
    if (code == null || !code.startsWith('event:')) return;
    final id = int.tryParse(code.substring(6));
    if (id == null) return;
    _handled = true;
    try {
      await (widget.service ?? QrService()).checkIn(id);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Check-in failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: MobileScanner(onDetect: _onDetect),
    );
  }
}
