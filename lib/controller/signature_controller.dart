import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:signature/signature.dart';
import 'package:flutter/material.dart';

class SignatureStateController extends GetxController {
  var savedSignatures = <File>[].obs;
  var isSaving = false.obs;

  final String androidPath = '/storage/emulated/0/Download/Signatures';

  Future<void> loadSavedSignatures() async {
    final dir = Directory(androidPath);
    if (await dir.exists()) {
      final files = dir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith(".jpg"))
          .toList();
      files
          .sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      savedSignatures.assignAll(files);
    }
  }

  Future<void> deleteSignature(File file) async {
    if (await file.exists()) {
      await file.delete();
      savedSignatures.remove(file);
    }
  }

  Future<void> saveImageFile(String fileName, List<int> bytes) async {
    final dir = Directory(androidPath);
    if (!await dir.exists()) await dir.create(recursive: true);
    final file = File('$androidPath/$fileName');
    await file.writeAsBytes(bytes);
    loadSavedSignatures();
  }

  Future<String?> saveSignatureFromUI({
    required Uint8List rawBytes,
    required String rawFileName,
  }) async {
    try {
      final decoded = img.decodeImage(rawBytes);
      final compressed = img.encodeJpg(decoded!, quality: 30);

      String fileName = rawFileName.trim();
      if (fileName.isEmpty) {
        fileName = 'signature_${DateTime.now().millisecondsSinceEpoch}.jpg';
      } else if (!fileName.endsWith('.jpg')) {
        fileName += '.jpg';
      }

      await saveImageFile(fileName, compressed);
      return fileName;
    } catch (e) {
      return null;
    }
  }

  Future<void> handleSignatureSave({
    required SignatureController controller,
    required TextEditingController fileNameController,
    required BuildContext context,
  }) async {
    if (controller.isEmpty) return;
    final info = await DeviceInfoPlugin().androidInfo;
    final sdkInt = info.version.sdkInt;
    final hasPermission = sdkInt >= 33
        ? (await Permission.photos.request()).isGranted
        : (await Permission.storage.request()).isGranted;

    if (!hasPermission) {
      Get.snackbar('Permission Denied', '❌ Storage permission denied');
      return;
    }

    isSaving.value = true;

    try {
      final ui.Image? rawImage = await controller.toImage();
      final byteData =
          await rawImage?.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List rawBytes = byteData!.buffer.asUint8List();

      final fileName = fileNameController.text.trim();
      final savedFileName = await saveSignatureFromUI(
        rawBytes: rawBytes,
        rawFileName: fileName,
      );

      if (savedFileName != null) {
        fileNameController.clear();
        controller.clear();
        Get.snackbar('✅ Success', 'Saved as $savedFileName');
      } else {
        Get.snackbar('❌ Error', 'Failed to save signature');
      }
    } catch (e) {
      Get.snackbar('❌ Exception', '$e');
    } finally {
      isSaving.value = false;
    }
  }
}
