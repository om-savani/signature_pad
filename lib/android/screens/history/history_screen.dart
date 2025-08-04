import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:signature_maker/utils/sizedbox_extension.dart';

import '../../../controller/signature_controller.dart';

class HistoryScreen extends StatelessWidget {
  final SignatureStateController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    controller.loadSavedSignatures();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Saved Signatures"),
        centerTitle: true,
        leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: Obx(() {
        final files = controller.savedSignatures;

        if (files.isEmpty) {
          return const Center(child: Text("No saved signatures found."));
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: files.length,
            separatorBuilder: (BuildContext context, index) => 10.sh,
            itemBuilder: (BuildContext context, index) {
              final file = files[index];
              return SignatureTile(
                file: file,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.file(file),
                            Text(file.path.split("/").last),
                            TextButton(
                              child: const Text("Close"),
                              onPressed: () => Navigator.of(context).pop(),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
                onDelete: () => controller.deleteSignature(file),
                onShare: () => Share.shareFiles([file.path]),
              );
            },
          ),
        );
      }),
    );
  }
}

class SignatureTile extends StatelessWidget {
  final File file;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final VoidCallback onTap;

  const SignatureTile({
    Key? key,
    required this.file,
    required this.onDelete,
    required this.onShare,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filename = file.path.split("/").last;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(file, width: 50, height: 50, fit: BoxFit.cover),
          ),
          title: Text(
            filename,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          subtitle: const Text("Tap to preview"),
          trailing: Wrap(
            spacing: 8,
            children: [
              IconButton(
                icon: const Icon(Icons.share, size: 20),
                onPressed: onShare,
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
