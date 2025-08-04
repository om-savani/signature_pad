import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:signature_maker/controller/signature_controller.dart';
import 'package:signature_maker/utils/sizedbox_extension.dart';

class HistoryScreenIos extends StatelessWidget {
  const HistoryScreenIos({super.key});

  @override
  Widget build(BuildContext context) {
    final SignatureStateController controller = Get.find();
    controller.loadSavedSignatures();

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: const CupertinoNavigationBar(
        previousPageTitle: "Back",
        backgroundColor: CupertinoColors.white,
        middle: Text(
          "Saved Signatures",
          style: TextStyle(color: CupertinoColors.black),
        ),
      ),
      child: SafeArea(
        child: Obx(() {
          final files = controller.savedSignatures;

          if (files.isEmpty) {
            return const Center(child: Text("No saved signatures found."));
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: files.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final file = files[index];

                return GestureDetector(
                  onTap: () => _showPreviewDialog(context, file),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: CupertinoColors.white,
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                                image: FileImage(file), fit: BoxFit.cover),
                          ),
                        ),
                        10.sw,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                file.path.split("/").last,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: CupertinoColors.black,
                                ),
                              ),
                              5.sh,
                              const Text(
                                "Tap to preview",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              child: const Icon(
                                CupertinoIcons.share,
                                size: 20,
                              ),
                              onPressed: () => Share.shareFiles([file.path]),
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              child: const Icon(
                                CupertinoIcons.delete,
                                color: CupertinoColors.systemRed,
                                size: 20,
                              ),
                              onPressed: () => controller.deleteSignature(file),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }

  void _showPreviewDialog(BuildContext context, File file) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Signature Preview"),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            children: [
              Image.file(file),
              10.sh,
              Text(file.path.split("/").last),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text("Close"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
