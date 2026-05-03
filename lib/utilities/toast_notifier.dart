import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../themes/colors.dart';


class ToastNotifier {
  static final ToastNotifier _instance = ToastNotifier._();

  factory ToastNotifier() {
    return _instance;
  }

  final Toastification _toastification = Toastification();

  ToastNotifier._();

  void showSuccess(String message) {
    _toastification.show(
      title: Text(message),
      type: ToastificationType.success,
      alignment: AlignmentDirectional.topCenter,
      style: ToastificationStyle.flat,
      backgroundColor: DarkColors.tileBackgroundColor,
      foregroundColor: DarkColors.writingColor,
      borderSide: BorderSide(color: Colors.green, width: 2),
      autoCloseDuration: const Duration(seconds: 3),
    );
  }

  void showInfo(String message) {
    _toastification.show(
      title: Text(message),
      type: ToastificationType.info,
      alignment: AlignmentDirectional.topCenter,
      style: ToastificationStyle.flat,
      backgroundColor: DarkColors.tileBackgroundColor,
      foregroundColor: DarkColors.writingColor,
      borderSide: BorderSide(color: Colors.blue, width: 2),
      autoCloseDuration: const Duration(seconds: 4),
    );
  }

  void showWarning(String message) {
    _toastification.show(
      title: Text(message),
      type: ToastificationType.warning,
      alignment: AlignmentDirectional.topCenter,
      style: ToastificationStyle.flat,backgroundColor: DarkColors.tileBackgroundColor,
      foregroundColor: DarkColors.writingColor,
      borderSide: BorderSide(color: Colors.orange, width: 2),
      autoCloseDuration: const Duration(seconds: 4),
    );
  }

  void showError(String message) {
    _toastification.show(
      title: Text(message),
      type: ToastificationType.error,
      alignment: AlignmentDirectional.topCenter,
      style: ToastificationStyle.flat,backgroundColor: DarkColors.tileBackgroundColor,
      foregroundColor: DarkColors.writingColor,
      borderSide: BorderSide(color: Colors.red, width: 2),
      autoCloseDuration: const Duration(seconds: 5),
    );
  }
}