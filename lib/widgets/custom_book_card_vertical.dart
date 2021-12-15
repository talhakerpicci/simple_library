import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../values/values.dart';
import '../model/models.dart';
import '../screens/book_detail_screen.dart';
import '../utils/utils.dart';

import 'custom_cached_network_image.dart';
import 'custom_empty_book_card.dart';

class CustomBookCardVertical extends StatefulWidget {
  final Book book;
  final bool showSmallIcon;
  final bool shrinkBottom;
  final double borderRadius;

  final Function customOnTap;

  CustomBookCardVertical({
    this.book,
    this.showSmallIcon = false,
    this.shrinkBottom = false,
    this.borderRadius = 12,
    this.customOnTap,
  });

  @override
  _CustomBookCardVerticalState createState() => _CustomBookCardVerticalState();
}

class _CustomBookCardVerticalState extends State<CustomBookCardVertical> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
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
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: GestureDetector(
          onTap: () async {
            if (widget.customOnTap != null) {
              widget.customOnTap();
              return;
            }

            var data = await Get.to(
              () => BookDetailScreen(
                book: widget.book,
              ),
            );
            if (data != null && data['result']) {
              if (data['action'] == 'update') {
                Utils.showCustomInfoToast(
                  context,
                  StringConst.customTranslation(
                    key: StringConst.bookUpdate,
                    data: data['book'],
                  ),
                );
              } else if (data['action'] == 'delete') {
                Utils.showCustomInfoToast(
                  context,
                  StringConst.customTranslation(
                    key: StringConst.bookDelete,
                    data: data['book'],
                  ),
                );
              }
            } else if (data != null && !data['result']) {
              Utils.showCustomErrorToast(context, StringConst.anErrorOccured.tr);
            }
          },
          child: widget.book.imgUrl != ''
              ? Container(
                  child: Hero(
                    tag: widget.book.id,
                    child: CustomCachedNetworkImage(
                      url: widget.book.imgUrl,
                      boxFit: BoxFit.fill,
                    ),
                  ),
                )
              : CustomEmptyBookCard(
                  bookTitle: widget.book.title,
                  showTitle: true,
                  showSmallIcon: widget.showSmallIcon,
                  shrinkBottom: widget.shrinkBottom,
                ),
        ),
      ),
    );
  }
}
