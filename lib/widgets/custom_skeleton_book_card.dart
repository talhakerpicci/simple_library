import 'package:flutter/material.dart';

import '../model/models.dart';
import '../values/values.dart';

import 'skeleton.dart';

class CustomSkeletonBookCardVertical extends StatefulWidget {
  final Book book;
  final bool showSmallIcon;
  final bool shrinkBottom;
  final Function customOnTap;

  CustomSkeletonBookCardVertical({
    this.book,
    this.showSmallIcon = false,
    this.shrinkBottom = false,
    this.customOnTap,
  });

  @override
  _CustomSkeletonBookCardVerticalState createState() => _CustomSkeletonBookCardVerticalState();
}

class _CustomSkeletonBookCardVerticalState extends State<CustomSkeletonBookCardVertical> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.7),
            blurRadius: 1.0,
            spreadRadius: 2.5,
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
    );
  }
}
