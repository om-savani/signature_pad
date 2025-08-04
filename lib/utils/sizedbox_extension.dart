import 'package:flutter/material.dart';

extension SizedBoxExtension on num {
  Widget get sh => SizedBox(height: toDouble());
  Widget get sw => SizedBox(width: toDouble());
}
