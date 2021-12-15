import 'package:flutter/material.dart';

import '../model/models.dart';
import '../values/values.dart';

import 'skeleton.dart';

class CustomSkeletonBookCardHorizontal extends StatefulWidget {
  final Book book;
  final bool showSmallIcon;
  final bool shrinkBottom;
  final Function customOnTap;

  CustomSkeletonBookCardHorizontal({
    this.book,
    this.showSmallIcon = false,
    this.shrinkBottom = false,
    this.customOnTap,
  });

  @override
  _CustomSkeletonBookCardHorizontalState createState() => _CustomSkeletonBookCardHorizontalState();
}

class _CustomSkeletonBookCardHorizontalState extends State<CustomSkeletonBookCardHorizontal> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      height: 130,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(0),
        color: Colors.white,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(.7),
                blurRadius: 1.0,
                spreadRadius: 1,
                offset: const Offset(
                  0.0,
                  0.0,
                ),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Skeleton(
              color: Colors.grey[300],
              shimmerColor: AppColors.nord0,
            ),
          ),
        ),
      ),
    );
  }
}
