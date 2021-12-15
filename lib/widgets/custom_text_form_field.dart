import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatelessWidget {
  final String initialValue;
  final TextCapitalization textCapitalization;
  final int maxLength;
  final Function onChanged;
  final Function validator;
  final EdgeInsetsGeometry contentPadding;
  final double width;
  final double height;
  final TextAlign textAlign;
  final String hintText;
  final String labelText;
  final TextInputType keyboardType;
  final TextStyle textStyle;
  final TextStyle hintStyle;
  final TextStyle labelStyle;
  final bool digitsOnly;
  final List inputFormatters;
  final TextInputAction textInputAction;
  final FocusNode focusNode;
  final Function onFieldSubmitted;
  final TextEditingController controller;

  CustomTextFormField({
    this.initialValue,
    this.textCapitalization,
    this.maxLength,
    this.onChanged,
    this.validator,
    this.contentPadding,
    this.height,
    this.width,
    this.textAlign,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.textStyle = const TextStyle(
      color: Colors.black,
    ),
    this.hintStyle,
    this.digitsOnly = false,
    this.inputFormatters,
    this.labelStyle,
    this.labelText,
    this.textInputAction,
    this.focusNode,
    this.onFieldSubmitted,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: TextFormField(
        controller: controller,
        textCapitalization: textCapitalization,
        initialValue: initialValue,
        textInputAction: textInputAction,
        textAlign: textAlign,
        focusNode: focusNode,
        keyboardType: keyboardType,
        onFieldSubmitted: onFieldSubmitted,
        cursorColor: Colors.grey,
        maxLength: maxLength,
        style: textStyle,
        inputFormatters: inputFormatters != null
            ? inputFormatters
            : <TextInputFormatter>[
                digitsOnly ? FilteringTextInputFormatter.digitsOnly : TextInputFormatter.withFunction((oldValue, newValue) => newValue),
              ],
        decoration: InputDecoration(
          labelStyle: const TextStyle(color: Colors.grey),
          contentPadding: contentPadding,
          isDense: true,
          focusColor: Colors.grey,
          fillColor: Colors.grey,
          hoverColor: Colors.grey,
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey,
              style: BorderStyle.solid,
            ),
          ),
          errorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.red,
              style: BorderStyle.solid,
            ),
          ),
          errorStyle: const TextStyle(color: Colors.red, fontSize: 10),
          hintText: hintText,
          hintStyle: hintStyle,
          labelText: labelText,
        ),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}
