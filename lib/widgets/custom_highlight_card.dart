import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';

import '../model/models.dart';
import '../utils/utils.dart';
import '../values/values.dart';

import 'spaces.dart';

class HighlightCard extends StatelessWidget {
  final Highlight highlight;
  final Function onTap;

  HighlightCard({
    this.highlight,
    this.onTap,
  });

  WrapAlignment getAlignment() {
    WrapAlignment textAlignment;
    switch (highlight.textAlign) {
      case 'left':
        textAlignment = WrapAlignment.start;
        break;
      case 'center':
        textAlignment = WrapAlignment.center;
        break;
      case 'right':
        textAlignment = WrapAlignment.end;
        break;
      default:
        textAlignment = WrapAlignment.start;
        break;
    }

    return textAlignment;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            highlight.chapter != ''
                ? Text(
                    highlight.chapter,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                : Container(),
            highlight.chapter != '' ? SpaceH16() : Container(),
            Container(
              child: Markdown(
                padding: const EdgeInsets.all(0),
                data: highlight.highlight,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                styleSheet: MarkdownStyleSheet(
                  textAlign: getAlignment(),
                  blockSpacing: 12,
                  p: const TextStyle(
                    fontSize: 14,
                    fontFamily: StringConst.trtRegular,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                  code: TextStyle(
                    color: AppColors.nord0,
                    backgroundColor: Colors.grey[200],
                  ),
                  blockquoteDecoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                  blockquote: TextStyle(
                    color: AppColors.nord0,
                    backgroundColor: Colors.grey[200],
                    fontFamily: StringConst.trtRegular,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            SpaceH24(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                highlight.pageNo != ''
                    ? Container(
                        child: Text(
                          '${StringConst.pageNo.tr} ${highlight.pageNo}',
                          style: const TextStyle(
                            fontFamily: StringConst.trtRegular,
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Container(),
                Container(
                  child: Text(
                    Utils.timeAgo(highlight.dateCreated),
                    style: const TextStyle(
                      fontFamily: StringConst.trtRegular,
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
