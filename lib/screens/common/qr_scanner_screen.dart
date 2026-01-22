// TODO Implement this library.
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  // Controller to handle switching cameras
  final MobileScannerController _controller = MobileScannerController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR Code"),
        actions: [
          // SWITCH CAMERA BUTTON (Essential for Web/Laptops)
          IconButton(
            icon: const Icon(Icons.cameraswitch_rounded),
            onPressed: () => _controller.switchCamera(),
          ),
          // TOGGLE FLASHLIGHT (Phones only)
          IconButton(
            icon: const Icon(Icons.flash_on_rounded),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. The Camera View
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                final String code = barcodes.first.rawValue!;
                // Stop scanning and return the code
                _controller.stop(); 
                if (mounted) {
                  Navigator.pop(context, code); 
                }
              }
            },
          ),

          // 2. Overlay Guide (Visual Box)
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.greenAccent, width: 4),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          
          // 3. Instruction Text
          const Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Text(
              "Point camera at the Volunteer's QR Code",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white, 
                fontSize: 16, 
                backgroundColor: Colors.black54
              ),
            ),
          )
        ],
      ),
    );
  }
}