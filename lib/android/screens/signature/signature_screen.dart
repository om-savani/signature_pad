import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signature/signature.dart';
import 'package:signature_maker/controller/signature_controller.dart';
import 'package:signature_maker/utils/sizedbox_extension.dart';

class SignatureScreen extends StatefulWidget {
  @override
  _SignatureScreenState createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  final SignatureStateController signatureController =
      Get.put(SignatureStateController());

  final SignatureController controller = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  final TextEditingController fileNameController = TextEditingController();
  bool isSaving = false;

  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      final sdkInt = info.version.sdkInt;
      if (sdkInt >= 33) {
        return (await Permission.photos.request()).isGranted;
      } else {
        return (await Permission.storage.request()).isGranted;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Signature Pad'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () => Get.toNamed('/history'),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 2,
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
                    10.sh,
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
                        10.sw,
                        Expanded(
                          child: Obx(() => ElevatedButton.icon(
                                onPressed: signatureController.isSaving.value
                                    ? null
                                    : () =>
                                        signatureController.handleSignatureSave(
                                          controller: controller,
                                          fileNameController:
                                              fileNameController,
                                          context: context,
                                        ),
                                icon: const Icon(Icons.save),
                                label: signatureController.isSaving.value
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white),
                                      )
                                    : const Text("Save"),
                              )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
