import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';
import 'package:signature_maker/controller/signature_controller.dart';
import 'package:signature_maker/utils/sizedbox_extension.dart';

class SignatureScreeniOS extends StatelessWidget {
  final SignatureController controller = SignatureController(
    penStrokeWidth: 2,
    penColor: CupertinoColors.black,
    exportBackgroundColor: CupertinoColors.white,
  );

  final TextEditingController fileNameController = TextEditingController();
  final SignatureStateController signatureController =
      Get.put(SignatureStateController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: CupertinoPageScaffold(
        backgroundColor: CupertinoColors.white,
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Signature Pad'),
          trailing: GestureDetector(
            onTap: () => Get.toNamed('/historyIos'),
            child: const Icon(CupertinoIcons.clock),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  color: CupertinoColors.systemGrey4,
                  child: Signature(
                    controller: controller,
                    backgroundColor: CupertinoColors.systemGrey4,
                  ),
                ),
              ),
              Padding(
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
                    10.sh,
                    Row(
                      children: [
                        Expanded(
                          child: CupertinoButton.filled(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            onPressed: controller.clear,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(CupertinoIcons.clear),
                                5.sw,
                                const Text("Clear"),
                              ],
                            ),
                          ),
                        ),
                        10.sw,
                        Expanded(
                          child: Obx(() => CupertinoButton.filled(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                onPressed: signatureController.isSaving.value
                                    ? null
                                    : () =>
                                        signatureController.handleSignatureSave(
                                          controller: controller,
                                          fileNameController:
                                              fileNameController,
                                          context: context,
                                        ),
                                child: signatureController.isSaving.value
                                    ? const CupertinoActivityIndicator()
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                              CupertinoIcons.floppy_disk),
                                          5.sw,
                                          const Text("Save"),
                                        ],
                                      ),
                              )),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
