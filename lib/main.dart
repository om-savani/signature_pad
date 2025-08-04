import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:signature_maker/ios/screen/history/history_screen_ios.dart';
import 'package:signature_maker/ios/screen/signature/sognature_screen_ios.dart';

import 'android/screens/history/history_screen.dart';
import 'android/screens/signature/signature_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return GetCupertinoApp(
        debugShowCheckedModeBanner: false,
        home: SignatureScreeniOS(),
      );
    } else {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true),
        home: SignatureScreen(),
        getPages: [
          GetPage(name: '/signature', page: () => SignatureScreen()),
          GetPage(name: '/history', page: () => HistoryScreen()),
        ],
      );
    }
    // return GetCupertinoApp(
    //   debugShowCheckedModeBanner: false,
    //   home: SignatureScreeniOS(),
    //   getPages: [
    //     GetPage(name: '/signatureIos', page: () => SignatureScreeniOS()),
    //     GetPage(name: '/historyIos', page: () => HistoryScreenIos()),
    //   ],
    // );
  }
}
