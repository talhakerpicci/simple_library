import 'package:flutter/material.dart';

import '../utils/utils.dart';
import '../values/values.dart';
import '../widgets/spaces.dart';
import '../model/models.dart' as mdl;

import 'custom_cached_network_image.dart';
import 'custom_empty_book_card.dart';

class CustomNotificationCard extends StatelessWidget {
  final mdl.Book book;
  final mdl.Reminder reminder;
  final VoidCallback onTap;
  CustomNotificationCard({
    this.book,
    this.reminder,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 130,
        margin: EdgeInsets.symmetric(
          vertical: 10,
        ),
        child: Row(
          children: [
            SpaceW10(),
            book.imgUrl == ''
                ? CustomEmptyBookCard(
                    width: 90,
                    height: 130,
                    showTitle: false,
                    showSmallIcon: true,
                    borderRadius: 16,
                  )
                : CustomCachedNetworkImage(
                    width: 90,
                    height: 130,
                    url: book.imgUrl,
                    borderRadius: 16,
                  ),
            SpaceW10(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SpaceH10(),
                  Text(
                    book.title,
                    style: TextStyle(
                      fontFamily: StringConst.trtRegular,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  SpaceH10(),
                  Text(
                    book.author,
                    style: TextStyle(
                      fontFamily: StringConst.trtRegular,
                    ),
                  ),
                  Spacer(),
                  Row(
                    children: [
                      Icon(
                        Icons.notifications_none_outlined,
                      ),
                      Text(
                        '${reminder.timeOfDay.split(':')[0].length == 1 ? "0${reminder.timeOfDay.split(':')[0]}" : reminder.timeOfDay.split(':')[0]}:${reminder.timeOfDay.split(':')[1].length == 1 ? "0${reminder.timeOfDay.split(':')[1]}" : reminder.timeOfDay.split(':')[1]}',
                        style: TextStyle(
                          fontFamily: StringConst.trtRegular,
                        ),
                      ),
                      Spacer(),
                      Text(
                        reminder.repetition == mdl.Repetition.Custom ? Utils.numbersToDays(reminder.days) : Utils.repetitionOptionsMap[reminder.repetition],
                        style: TextStyle(
                          fontFamily: StringConst.trtRegular,
                        ),
                      ),
                      SpaceW20(),
                    ],
                  ),
                  SpaceH4(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
