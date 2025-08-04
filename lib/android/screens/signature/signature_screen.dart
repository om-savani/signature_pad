import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

class SignatureScreen extends StatefulWidget {
  @override
  _SignatureScreenState createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  SignatureController controller = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  final TextEditingController fileNameController = TextEditingController();
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      final sdkInt = info.version.sdkInt;

      if (sdkInt >= 33) {
        final status = await Permission.photos.request();
        return status.isGranted;
      } else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    return true;
  }

  Future<void> saveSignature() async {
    if (controller.isEmpty) return;

    final hasPermission = await requestPermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Storage permission denied")),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final ui.Image? rawImage = await controller.toImage();
      final byteData =
          await rawImage?.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List rawBytes = byteData!.buffer.asUint8List();

      final decoded = img.decodeImage(rawBytes);
      final compressed = img.encodeJpg(decoded!, quality: 30);

      final Directory dir =
          Directory('/storage/emulated/0/Download/Signatures');
      if (!await dir.exists()) await dir.create(recursive: true);

      String fileName = fileNameController.text.trim();
      if (fileName.isEmpty) {
        fileName = 'signature_${DateTime.now().millisecondsSinceEpoch}';
      }
      if (!fileName.endsWith('.jpg')) {
        fileName = '$fileName.jpg';
      }

      final filePath = '${dir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(compressed);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Saved to:\n$filePath')),
      );

      fileNameController.clear();
      controller.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('✍️ Signature Pad')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.grey[300],
                child: Signature(
                  controller: controller,
                  backgroundColor: Colors.grey[300]!,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  TextField(
                    controller: fileNameController,
                    decoration: const InputDecoration(
                      labelText: "Enter file name (optional)",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.edit),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: controller.clear,
                          icon: const Icon(Icons.clear),
                          label: const Text("Clear"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isSaving ? null : saveSignature,
                          icon: const Icon(Icons.save),
                          label: isSaving
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Text("Save"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
