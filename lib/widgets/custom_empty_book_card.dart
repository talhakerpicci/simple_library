import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../values/values.dart';

class CustomEmptyBookCard extends StatelessWidget {
  final double width;
  final double height;
  final Widget stackWidget;
  final String bookTitle;
  final bool showTitle;
  final bool showSmallIcon;
  final bool shrinkBottom;
  final double borderRadius;

  CustomEmptyBookCard({
    this.width,
    this.height,
    this.stackWidget,
    this.bookTitle,
    this.showTitle = false,
    this.showSmallIcon = false,
    this.shrinkBottom = false,
    this.borderRadius = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(borderRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.7),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Center(
            child: FaIcon(
              FontAwesomeIcons.book,
              size: showSmallIcon ? 25 : 40,
            ),
          ),
          stackWidget == null ? Container() : stackWidget,
          showTitle
              ? Positioned(
                  child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: Container(
                      height: shrinkBottom ? 25 : 40,
                      color: Colors.grey.withOpacity(0.3),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            bookTitle,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.nord0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
