import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signature/signature.dart';

class SignatureScreeniOS extends StatefulWidget {
  @override
  _SignatureScreeniOSState createState() => _SignatureScreeniOSState();
}

class _SignatureScreeniOSState extends State<SignatureScreeniOS> {
  final SignatureController controller = SignatureController(
    penStrokeWidth: 2,
    penColor: CupertinoColors.black,
    exportBackgroundColor: CupertinoColors.white,
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
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted;
    }
    return true;
  }

  Future<void> saveSignature() async {
    if (controller.isEmpty) return;

    final hasPermission = await requestPermission();
    if (!hasPermission) {
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text("Permission Denied"),
          content:
              const Text("❌ Storage permission is required to save signature."),
          actions: [
            CupertinoDialogAction(
              child: const Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
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

      final Directory baseDir = Platform.isAndroid
          ? Directory('/storage/emulated/0/Download/Signatures')
          : await getApplicationDocumentsDirectory();

      if (!await baseDir.exists()) await baseDir.create(recursive: true);

      String fileName = fileNameController.text.trim();
      if (fileName.isEmpty) {
        fileName = 'signature_${DateTime.now().millisecondsSinceEpoch}';
      }
      if (!fileName.endsWith('.jpg')) {
        fileName = '$fileName.jpg';
      }

      final filePath = '${baseDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(compressed);

      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text("✅ Saved"),
          content: Text("Saved to:\n$filePath"),
          actions: [
            CupertinoDialogAction(
              child: const Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
      );

      fileNameController.clear();
      controller.clear();
    } catch (e) {
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text("Error"),
          content: Text("❌ Error: $e"),
          actions: [
            CupertinoDialogAction(
              child: const Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('✍️ Signature Pad'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: CupertinoColors.systemGrey4,
                child: Signature(
                  controller: controller,
                  backgroundColor: CupertinoColors.systemGrey4,
                ),
              ),
            ),
            CupertinoScrollbar(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    CupertinoTextField(
                      controller: fileNameController,
                      placeholder: "Enter file name (optional)",
                      prefix: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(CupertinoIcons.pencil),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: CupertinoButton.filled(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            onPressed: controller.clear,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(CupertinoIcons.clear),
                                SizedBox(width: 5),
                                Text("Clear"),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CupertinoButton.filled(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            onPressed: isSaving ? null : saveSignature,
                            child: isSaving
                                ? const CupertinoActivityIndicator()
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(CupertinoIcons.floppy_disk),
                                      SizedBox(width: 5),
                                      Text("Save"),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
