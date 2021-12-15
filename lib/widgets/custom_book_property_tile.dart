import 'package:flutter/material.dart';

import '../widgets/spaces.dart';

class CustomBookPropertyTile extends StatelessWidget {
  final String title;
  final String value;
  final TextStyle valueTextStyle;
  final TextStyle titleTextStyle;
  final Color bottomBorderColor;
  final Color backroundColor;
  final Color topBorderColor;
  final double bottomPadding;
  final double topPadding;
  final Icon leadingIcon;
  final Widget trailingIcon;
  final bool showTopBorder;
  final bool showBottomBorder;
  final bool showTrailingIcon;
  final Function onPressed;
  final Function onTrailingIconTap;
  final Widget paddingBetweenIconAndText;

  CustomBookPropertyTile({
    this.title,
    this.value = '',
    this.valueTextStyle,
    this.titleTextStyle,
    this.bottomBorderColor,
    this.backroundColor,
    this.onPressed,
    this.bottomPadding,
    this.topPadding,
    this.showBottomBorder = true,
    this.showTopBorder = false,
    this.showTrailingIcon = true,
    this.topBorderColor,
    this.leadingIcon,
    this.trailingIcon,
    this.onTrailingIconTap,
    this.paddingBetweenIconAndText,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backroundColor == null ? Colors.transparent : backroundColor,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.only(bottom: bottomPadding, top: topPadding),
          decoration: BoxDecoration(
            border: Border(
              top: showTopBorder ? BorderSide(color: topBorderColor == null ? Colors.grey[300] : topBorderColor) : BorderSide(color: Colors.transparent),
              bottom: showBottomBorder ? BorderSide(color: bottomBorderColor == null ? Colors.grey[300] : bottomBorderColor) : BorderSide(color: Colors.transparent),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                leadingIcon != null ? leadingIcon : Container(),
                paddingBetweenIconAndText != null ? paddingBetweenIconAndText : Container(),
                Text(
                  title,
                  style: titleTextStyle,
                ),
                SpaceW12(),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(top: 3),
                    alignment: Alignment.centerRight,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        value == null ? '' : value,
                        style: valueTextStyle == null
                            ? TextStyle(
                                color: Colors.grey[600],
                              )
                            : valueTextStyle,
                      ),
                    ),
                  ),
                ),
                SpaceW12(),
                trailingIcon != null && showTrailingIcon
                    ? SizedBox(
                        width: 22,
                        height: 20,
                        child: IconButton(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          padding: const EdgeInsets.all(0),
                          icon: trailingIcon,
                          onPressed: onTrailingIconTap,
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
