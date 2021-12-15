import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';

import '../widgets/spaces.dart';
import '../values/values.dart';
import '../model/models.dart';
import '../screens/book_detail_screen.dart';
import '../utils/utils.dart';

import 'custom_cached_network_image.dart';
import 'custom_empty_book_card.dart';

class CustomBookCardHorizontal extends StatefulWidget {
  final Book book;
  final double borderRadius;
  final Function customOnTap;

  CustomBookCardHorizontal({
    this.book,
    this.borderRadius = 12,
    this.customOnTap,
  });

  @override
  _CustomBookCardHorizontalState createState() => _CustomBookCardHorizontalState();
}

class _CustomBookCardHorizontalState extends State<CustomBookCardHorizontal> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      height: 130,
      child: GestureDetector(
        onTap: () async {
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
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(.4),
                blurRadius: 2.0,
                spreadRadius: 0.2,
                offset: const Offset(
                  0.0,
                  0.1,
                ),
              )
            ],
          ),
          child: Card(
            elevation: 8,
            margin: const EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.white,
            child: Container(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SpaceW10(),
                  Container(
                    height: 100,
                    width: 70,
                    child: widget.book.imgUrl == ''
                        ? CustomEmptyBookCard(
                            showTitle: false,
                            showSmallIcon: true,
                          )
                        : Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(widget.borderRadius),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(.7),
                                  blurRadius: 1.0,
                                  spreadRadius: 1.5,
                                  offset: const Offset(
                                    0.0,
                                    0.0,
                                  ),
                                )
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(widget.borderRadius),
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
                                      showSmallIcon: true,
                                      shrinkBottom: true,
                                    ),
                            ),
                          ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SpaceH14(),
                        Container(
                          padding: const EdgeInsets.only(left: 14, right: 10),
                          alignment: Alignment.topLeft,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              widget.book.title,
                              style: const TextStyle(fontSize: 14),
                              textAlign: TextAlign.left,
                              maxLines: 5,
                            ),
                          ),
                        ),
                        SpaceH6(),
                        Container(
                          padding: const EdgeInsets.only(left: 14, right: 10),
                          alignment: Alignment.centerLeft,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              widget.book.author,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.normal,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.left,
                              maxLines: 5,
                            ),
                          ),
                        ),
                        SpaceH12(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          alignment: Alignment.centerLeft,
                          child: RatingBarIndicator(
                            unratedColor: Colors.grey[300],
                            rating: widget.book.rating,
                            itemCount: 5,
                            itemSize: 18,
                            itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                        SpaceH12(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
