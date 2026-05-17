import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../providers/qr_providers.dart';
import '../services/qr_service.dart';

class QrScannerPage extends ConsumerStatefulWidget {
  final QrService? service;
  const QrScannerPage({super.key, this.service});

  @override
  ConsumerState<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends ConsumerState<QrScannerPage> {
  bool _handled = false;

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handled) return;
    final code = capture.barcodes.first.rawValue;
    if (code == null || !code.startsWith('event:')) return;
    final id = int.tryParse(code.substring(6));
    if (id == null) return;
    _handled = true;
    final QrService service = widget.service ?? ref.read(qrServiceProvider);
    try {
      await service.checkIn(id);
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
