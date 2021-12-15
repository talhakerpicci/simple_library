import 'package:flutter/material.dart';

import 'custom_scroll_picker.dart';

void showMaterialScrollPicker({
  BuildContext context,
  String title,
  List<String> items,
  String selectedItem,
  Color headerColor,
  Color headerTextColor,
  Color backgroundColor,
  Color buttonTextColor,
  String confirmText,
  String cancelText,
  double maxLongSide,
  double maxShortSide,
  bool showDivider: true,
  ValueChanged<String> onChanged,
  ValueChanged<String> onConfirmed,
  VoidCallback onCancelled,
}) {
  showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return ScrollPickerDialog(
        items: items,
        title: title,
        initialItem: selectedItem,
        headerColor: headerColor,
        headerTextColor: headerTextColor,
        backgroundColor: backgroundColor,
        buttonTextColor: buttonTextColor,
        confirmText: confirmText,
        cancelText: cancelText,
        maxLongSide: maxLongSide,
        maxShortSide: maxLongSide,
        showDivider: showDivider,
      );
    },
  ).then((selection) {
    if (onChanged != null && selection != null) onChanged(selection);
    if (onCancelled != null && selection == null) onCancelled();
    if (onConfirmed != null && selection != null) onConfirmed(selection);
  });
}
