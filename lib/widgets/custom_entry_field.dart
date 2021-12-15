import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../values/values.dart';

class EntryField extends StatelessWidget {
  final bool isPassword;
  final Function onChanged;
  final String hintText;
  final bool showSuffixIcon;
  final bool readOnly;
  final bool digitsOnly;
  final Function onTap;
  final Function onSuffixIconTap;
  final Function onSubmit;
  final String textEditingValue;
  final TextInputType inputType;
  final FocusNode focusNode;
  final TextInputAction textInputAction;
  final Icon icon;
  final TextCapitalization textCapitalization;
  final TextEditingController controller;
  final TextAlign textAlign;
  final TextStyle textStyle;
  final double borderRadius;
  final Function validator;

  EntryField({
    this.isPassword = false,
    this.onChanged,
    this.hintText,
    this.showSuffixIcon = false,
    this.readOnly = false,
    this.digitsOnly = false,
    this.onTap,
    this.onSuffixIconTap,
    this.onSubmit,
    this.textEditingValue,
    this.inputType = TextInputType.text,
    this.focusNode,
    this.textInputAction = TextInputAction.done,
    this.textCapitalization = TextCapitalization.none,
    this.icon,
    this.controller,
    this.textAlign = TextAlign.start,
    this.textStyle,
    this.borderRadius = 8,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FormField(
        validator: validator,
        builder: (state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: TextField(
                  onSubmitted: onSubmit,
                  textAlign: textAlign,
                  textInputAction: textInputAction,
                  focusNode: focusNode,
                  inputFormatters: <TextInputFormatter>[
                    digitsOnly ? FilteringTextInputFormatter.digitsOnly : TextInputFormatter.withFunction((oldValue, newValue) => newValue),
                  ],
                  textCapitalization: textCapitalization,
                  keyboardType: inputType,
                  autocorrect: false,
                  style: textStyle,
                  controller: controller != null
                      ? controller
                      : TextEditingController.fromValue(
                          TextEditingValue(
                            text: textEditingValue.toString(),
                            selection: TextSelection.collapsed(
                              offset: textEditingValue.length,
                            ),
                          ),
                        ),
                  onTap: onTap,
                  obscureText: isPassword,
                  cursorColor: AppColors.nord0,
                  readOnly: readOnly,
                  decoration: InputDecoration(
                    prefixIcon: icon,
                    border: InputBorder.none,
                    fillColor: AppColors.grey4,
                    filled: true,
                    labelText: hintText,
                    suffixIcon: showSuffixIcon
                        ? IconButton(
                            onPressed: onSuffixIconTap,
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                  ),
                  onChanged: onChanged,
                ),
              ),
              state.errorText != null
                  ? Container(
                      padding: const EdgeInsets.only(left: 10, top: 5),
                      child: Text(
                        state.errorText,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    )
                  : Container(),
            ],
          );
        },
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final int maxLength;
  final int maxLines;
  final String labelText;
  final TextStyle labelStyle;
  final TextStyle textFieldTextStyle;
  final Function onChanged;
  final Function onSubmit;
  final TextEditingController controller;
  final TextInputAction textInputAction;
  final TextInputType keyboardType;
  final bool digitsOnly;
  final Widget markdown;
  final FocusNode focusNode;
  final TextAlign textAlign;
  final Function validator;
  final EdgeInsets margin;

  CustomTextField({
    this.maxLength,
    this.maxLines = 1,
    this.labelText,
    this.labelStyle,
    this.textFieldTextStyle,
    this.onChanged,
    this.onSubmit,
    this.controller,
    this.textInputAction,
    this.keyboardType = TextInputType.text,
    this.digitsOnly = false,
    this.markdown,
    this.focusNode,
    this.textAlign = TextAlign.left,
    this.validator,
    this.margin = const EdgeInsets.symmetric(horizontal: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: TextFormField(
        style: textFieldTextStyle,
        textCapitalization: TextCapitalization.sentences,
        keyboardType: digitsOnly ? TextInputType.number : keyboardType,
        focusNode: focusNode,
        autocorrect: false,
        maxLength: maxLength,
        maxLines: maxLines,
        controller: controller,
        inputFormatters: <TextInputFormatter>[
          digitsOnly ? FilteringTextInputFormatter.digitsOnly : TextInputFormatter.withFunction((oldValue, newValue) => newValue),
        ],
        textAlign: textAlign,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: labelStyle,
          border: Borders.border,
          enabledBorder: Borders.enabledBorder,
          focusedBorder: Borders.focusedBorder,
          prefixIcon: markdown,
        ),
        cursorColor: AppColors.nord0,
        onChanged: onChanged,
        textInputAction: textInputAction,
        onFieldSubmitted: onSubmit,
        validator: validator,
      ),
    );
  }
}
