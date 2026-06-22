import 'package:flutter/material.dart';

extension ScaffoldMessengerX on ScaffoldMessengerState {
  void showUniqueSnackBar(SnackBar snackBar) {
    clearSnackBars();
    showSnackBar(snackBar);
  }
}
