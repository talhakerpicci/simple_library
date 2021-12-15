import 'package:flutter/material.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:get/get.dart';

import '../model/models.dart';
import '../values/values.dart';

import 'spaces.dart';

class CustomCollectionCard extends StatelessWidget {
  final Collection collection;
  final Function onEdit;
  final Function onOpen;
  final Function onDelete;

  CustomCollectionCard({
    this.collection,
    this.onEdit,
    this.onOpen,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 12,
        right: 12,
        top: 15,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.6),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ExpansionTileCard(
          borderRadius: BorderRadius.circular(10),
          leading: CircleAvatar(
            child: Image.asset(
              StringConst.bookCollection,
              color: Colors.white,
              width: 28,
              height: 28,
            ),
          ),
          title: Text(
            collection.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          subtitle: Text(
            StringConst.customTranslation(
              key: StringConst.containsXBooks,
              data: '${collection.books.length}',
            ),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          children: <Widget>[
            const Divider(
              thickness: 1.0,
              height: 1.0,
            ),
            SpaceH8(),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Text(
                  collection.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.spaceAround,
              buttonHeight: 52.0,
              buttonMinWidth: 90.0,
              children: <Widget>[
                TextButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                    ),
                  ),
                  onPressed: onEdit,
                  child: Column(
                    children: <Widget>[
                      const Icon(
                        Icons.edit,
                        color: AppColors.nord3,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                      ),
                      Text(
                        StringConst.edit.tr,
                        style: const TextStyle(
                          color: AppColors.nord3,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                    ),
                  ),
                  onPressed: onOpen,
                  child: Column(
                    children: <Widget>[
                      const Icon(
                        Icons.open_in_browser,
                        color: AppColors.nord3,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                      ),
                      Text(
                        StringConst.open.tr,
                        style: const TextStyle(
                          color: AppColors.nord3,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                    ),
                  ),
                  onPressed: onDelete,
                  child: Column(
                    children: <Widget>[
                      const Icon(
                        Icons.delete,
                        color: AppColors.nord3,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                      ),
                      Text(
                        StringConst.delete.tr,
                        style: const TextStyle(
                          color: AppColors.nord3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
