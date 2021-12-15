import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';

import '../model/models.dart';
import '../screens/add_book_screen.dart';
import '../widgets/spaces.dart';
import 'custom_cached_network_image.dart';
import 'custom_empty_book_card.dart';

class GoogleBookCard extends StatelessWidget {
  final GoogleBook book;
  const GoogleBookCard({this.book});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        var result = await Get.to(() => AddBookScreen(
              googleBook: book,
            ));

        if (result != null) {
          Get.back(result: result);
        }
      },
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
        color: Colors.white,
        child: Container(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SpaceW10(),
              Container(
                height: 120,
                width: 70,
                padding: EdgeInsets.symmetric(vertical: 10),
                child: book.thumbnail == ''
                    ? CustomEmptyBookCard(
                        showTitle: false,
                        showSmallIcon: true,
                      )
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
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
                          borderRadius: BorderRadius.circular(10),
                          child: CustomCachedNetworkImage(
                            url: book.thumbnail,
                            boxFit: BoxFit.fill,
                          ),
                        ),
                      ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SpaceH12(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.topLeft,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          book.title,
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.left,
                          maxLines: 5,
                        ),
                      ),
                    ),
                    SpaceH6(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.centerLeft,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          book.authors,
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
                        rating: 0,
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
    );
  }
}
