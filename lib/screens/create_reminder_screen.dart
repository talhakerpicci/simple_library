import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../model/models.dart' as mdl;
import '../viewmodels/db_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_book_property_tile.dart';
import '../dialogs/custom_yes_no_dialog.dart';
import '../values/values.dart';
import '../widgets/spaces.dart';
import '../utils/utils.dart';

class CreateReminderScreen extends StatefulWidget {
  final mdl.Book book;
  final mdl.Reminder reminder;
  CreateReminderScreen({
    this.book,
    this.reminder,
  });
  @override
  _CreateReminderScreenState createState() => _CreateReminderScreenState();
}

class _CreateReminderScreenState extends State<CreateReminderScreen> {
  mdl.Reminder reminder = mdl.Reminder();

  final TextEditingController _controllerCustomMessage = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.reminder != null) {
      reminder = mdl.Reminder.fromJson(json: widget.reminder.toJson());
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          reminder = mdl.Reminder(
            customMessage: '',
            repetition: mdl.Repetition.Once,
            timeOfDay: TimeOfDay.now().format(context),
          );
        });
      });
    }

    _controllerCustomMessage.value = TextEditingValue(text: reminder.customMessage, selection: _controllerCustomMessage.selection);
  }

  void setDays() {
    switch (reminder.repetition) {
      case mdl.Repetition.Once:
        reminder.days = [];
        break;
      case mdl.Repetition.Daily:
        reminder.days = [1, 2, 3, 4, 5, 6, 7];
        break;
      case mdl.Repetition.MonToFri:
        reminder.days = [1, 2, 3, 4, 5];
        break;
      case mdl.Repetition.Weekends:
        reminder.days = [6, 7];
        break;
      default:
        break;
    }
  }

  Future<Map> showCustomDayPicker() async {
    Map<String, bool> days;

    if (widget.reminder != null) {
      days = {
        StringConst.monday.tr: reminder.repetition == mdl.Repetition.Once || reminder.repetition == mdl.Repetition.Daily ? true : reminder.days.contains(1),
        StringConst.tuesday.tr: reminder.repetition == mdl.Repetition.Once || reminder.repetition == mdl.Repetition.Daily ? true : reminder.days.contains(2),
        StringConst.wednesday.tr: reminder.repetition == mdl.Repetition.Once || reminder.repetition == mdl.Repetition.Daily ? true : reminder.days.contains(3),
        StringConst.thursday.tr: reminder.repetition == mdl.Repetition.Once || reminder.repetition == mdl.Repetition.Daily ? true : reminder.days.contains(4),
        StringConst.friday.tr: reminder.repetition == mdl.Repetition.Once || reminder.repetition == mdl.Repetition.Daily ? true : reminder.days.contains(5),
        StringConst.saturday.tr: reminder.repetition == mdl.Repetition.Once || reminder.repetition == mdl.Repetition.Daily ? true : reminder.days.contains(6),
        StringConst.sunday.tr: reminder.repetition == mdl.Repetition.Once || reminder.repetition == mdl.Repetition.Daily ? true : reminder.days.contains(7),
      };
    } else {
      days = {
        StringConst.monday.tr: true,
        StringConst.tuesday.tr: true,
        StringConst.wednesday.tr: true,
        StringConst.thursday.tr: true,
        StringConst.friday.tr: true,
        StringConst.saturday.tr: true,
        StringConst.sunday.tr: true,
      };
    }

    return await showCupertinoModalPopup<Map>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <Widget>[
          for (var day in days.keys)
            StatefulBuilder(
              builder: (context, setState) => CupertinoActionSheetAction(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.symmetric(horizontal: 22),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          day,
                          style: TextStyle(
                            fontFamily: '.SF UI Text',
                            inherit: false,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w400,
                            textBaseline: TextBaseline.alphabetic,
                            color: CupertinoTheme.of(context).primaryColor,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.nord1),
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: days[day]
                                ? Icon(
                                    Icons.check,
                                    size: 18,
                                    color: Colors.white,
                                  )
                                : Icon(
                                    Icons.circle,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    days[day] = !days[day];
                  });
                },
              ),
            ),
          CupertinoActionSheetAction(
            child: Material(
              color: Colors.transparent,
              child: Container(
                color: Colors.transparent,
                padding: EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      child: Text(
                        StringConst.cancel.tr,
                        style: TextStyle(
                          fontFamily: '.SF UI Text',
                          inherit: false,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w400,
                          textBaseline: TextBaseline.alphabetic,
                          color: CupertinoTheme.of(context).primaryColor,
                        ),
                      ),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                    TextButton(
                      child: Text(
                        StringConst.okay.tr,
                        style: TextStyle(
                          fontFamily: '.SF UI Text',
                          inherit: false,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w400,
                          textBaseline: TextBaseline.alphabetic,
                          color: CupertinoTheme.of(context).primaryColor,
                        ),
                      ),
                      onPressed: () {
                        if (days.containsValue(true)) {
                          Get.back(result: days);
                        } else {
                          Get.back();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    var model = Provider.of<DbModel>(context, listen: false);

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.reminder != null ? StringConst.updateReminder.tr : StringConst.newReminder.tr,
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              if (reminder.customMessage.trim() == '') {
                reminder.customMessage = '';
              }

              setDays();

              if (widget.reminder != null) {
                var result = await model.updateReminder(
                  bookData: widget.book,
                  reminder: reminder,
                  oldDays: widget.reminder.days,
                );
                Get.back(result: {
                  'mode': 'update',
                  'result': result,
                });
              } else {
                reminder.id = UniqueKey().toString();

                var result = await model.createReminder(
                  bookData: widget.book,
                  reminder: reminder,
                );
                Get.back(result: {
                  'mode': 'insert',
                  'result': result,
                });
              }
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          Utils.unFocus();
        },
        child: Container(
          height: height,
          width: width,
          child: LayoutBuilder(
            builder: (context, constraint) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraint.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      SpaceH16(),
                      Container(
                        width: width - 32,
                        child: TextField(
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.2,
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          autocorrect: false,
                          maxLength: 140,
                          controller: _controllerCustomMessage,
                          maxLines: null,
                          decoration: InputDecoration(
                            labelText: StringConst.customNotifMessage.tr,
                            border: const OutlineInputBorder(
                              borderSide: const BorderSide(color: AppColors.grey2, width: 2.0),
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(5),
                              ),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: const BorderSide(color: AppColors.grey2, width: 2.0),
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(5),
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: const BorderSide(color: AppColors.nord4, width: 2.0),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(5),
                              ),
                            ),
                          ),
                          cursorColor: AppColors.nord0,
                          onChanged: (String value) {
                            setState(() {
                              reminder.customMessage = value;
                            });
                          },
                        ),
                      ),
                      SpaceH16(),
                      Container(
                        height: 20,
                        color: Colors.grey[300],
                      ),
                      CustomBookPropertyTile(
                        titleTextStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        title: StringConst.reminderTime.tr,
                        value: reminder.timeOfDay != '' ? '${reminder.timeOfDay.split(':')[0].length == 1 ? "0${reminder.timeOfDay.split(':')[0]}" : reminder.timeOfDay.split(':')[0]}:${reminder.timeOfDay.split(':')[1].length == 1 ? "0${reminder.timeOfDay.split(':')[1]}" : reminder.timeOfDay.split(':')[1]}' : '',
                        trailingIcon: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey[700],
                          size: 20,
                        ),
                        showTrailingIcon: true,
                        showBottomBorder: false,
                        bottomBorderColor: Colors.grey[500],
                        topPadding: 6,
                        bottomPadding: 6,
                        onPressed: () async {
                          TimeOfDay result = await showTimePicker(
                            initialTime: TimeOfDay.now(),
                            context: context,
                            builder: (BuildContext context, Widget child) {
                              return MediaQuery(
                                data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                child: child,
                              );
                            },
                          );

                          if (result != null) {
                            setState(() {
                              reminder.timeOfDay = '${result.hour}:${result.minute}';
                            });
                          }

                          Utils.unFocus();
                        },
                      ),
                      CustomBookPropertyTile(
                        titleTextStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        title: StringConst.repeat.tr,
                        value: reminder.repetition == mdl.Repetition.Custom ? Utils.numbersToDays(reminder.days) : Utils.repetitionOptionsMap[reminder.repetition],
                        trailingIcon: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey[700],
                          size: 20,
                        ),
                        showTrailingIcon: true,
                        showBottomBorder: false,
                        bottomBorderColor: Colors.grey[500],
                        topPadding: 6,
                        bottomPadding: 6,
                        onPressed: () async {
                          var result = await showCupertinoModalPopup<mdl.Repetition>(
                            context: context,
                            builder: (BuildContext context) => CupertinoActionSheet(
                              actions: <CupertinoActionSheetAction>[
                                for (var i = 0; i < Utils.repetitionOptionsMap.length - 1; i++)
                                  CupertinoActionSheetAction(
                                    child: Text(Utils.repetitionOptionsMap.values.elementAt(i)),
                                    onPressed: () {
                                      Get.back(result: mdl.Repetition.values[i]);
                                    },
                                  ),
                                CupertinoActionSheetAction(
                                  child: Text(StringConst.custom.tr),
                                  onPressed: () async {
                                    Map days = await showCustomDayPicker();

                                    if (days != null) {
                                      reminder.days = [];
                                      days.forEach((key, value) {
                                        if (value) {
                                          reminder.days.add(Utils.dayToNumMap[key]);
                                        }
                                      });

                                      if (reminder.days.length == 7) {
                                        Get.back(result: mdl.Repetition.Daily);
                                      } else if (reminder.days.length == 5 && reminder.days.contains(1) && reminder.days.contains(2) && reminder.days.contains(3) && reminder.days.contains(4) && reminder.days.contains(5)) {
                                        Get.back(result: mdl.Repetition.MonToFri);
                                      } else if (reminder.days.length == 2 && reminder.days.contains(6) && reminder.days.contains(7)) {
                                        Get.back(result: mdl.Repetition.Weekends);
                                      } else {
                                        Get.back(result: mdl.Repetition.Custom);
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          );

                          if (result != null) {
                            setState(() {
                              reminder.repetition = result;
                            });
                          }

                          Utils.unFocus();
                        },
                      ),
                      Container(
                        height: 20,
                        color: Colors.grey[300],
                      ),
                      widget.reminder != null
                          ? InkWell(
                              child: Container(
                                height: 50,
                                alignment: Alignment.center,
                                child: Text(
                                  StringConst.deleteReminder.tr,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontFamily: StringConst.trtRegular,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              onTap: () async {
                                Utils.unFocus();

                                var result = await showDialog(
                                  builder: (context) => CustomYesNoDialog(
                                    buttonTitleLeft: StringConst.yes.tr,
                                    buttonTitleRight: StringConst.no.tr,
                                    message: StringConst.areYouSureToDeleteReminder.tr,
                                  ),
                                  context: context,
                                );
                                if (result != null && result) {
                                  var result = await model.deleteReminder(
                                    reminder: reminder,
                                    bookId: widget.book.id,
                                  );
                                  Get.back(result: {
                                    'mode': 'delete',
                                    'result': result,
                                  });
                                }
                              },
                            )
                          : Container(),
                      widget.reminder != null
                          ? Container(
                              height: 40,
                              color: Colors.grey[300],
                            )
                          : Container(),
                      Expanded(
                        child: Container(
                          color: Colors.grey[300],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
