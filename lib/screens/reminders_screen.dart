import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../values/values.dart';
import '../utils/utils.dart';
import '../viewmodels/user_model.dart';
import '../enums/viewstate.dart';
import '../viewmodels/db_model.dart';
import '../widgets/custom_progress_indicator.dart';
import '../widgets/custom_notification_card.dart';
import '../widgets/custom_app_bar.dart';
import '../model/models.dart' as mdl;

import 'create_reminder_screen.dart';
import 'empty_screen.dart';
import 'error_screen.dart';

class RemindersScreen extends StatefulWidget {
  final mdl.Book book;
  final bool showAll;
  RemindersScreen({
    this.book,
    this.showAll = false,
  });
  @override
  _RemindersScreenState createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget buildBody() {
    Widget screen;
    var dbModel = Provider.of<DbModel>(context, listen: true);
    var userModel = Provider.of<UserModel>(context, listen: true);

    if (dbModel.getRemindersViewState == ViewState.Busy || userModel.user.getBooksViewState == ViewState.Busy) {
      screen = Center(
        child: CustomProgressIndicator(),
      );
    } else if (dbModel.getRemindersViewState == ViewState.Ready && userModel.user.getBooksViewState == ViewState.Ready) {
      if (widget.showAll) {
        List<mdl.BookReminderData> datas = dbModel.getAllReminders();

        if (datas == null || datas.length == 0) {
          screen = EmptyScreen(
            icon: Icons.notifications,
            description: StringConst.yourReadingRemindersWillAppearHere.tr,
          );
        } else {
          screen = Container(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 20),
              children: [
                for (var i = 0; i < datas.length; i++)
                  for (var j = 0; j < datas[i].reminders.length; j++)
                    Column(
                      children: [
                        CustomNotificationCard(
                          book: userModel.findBookById(datas[i].bookId),
                          reminder: datas[i].reminders[j],
                          onTap: () async {
                            var result = await Get.to(() => CreateReminderScreen(
                                  book: userModel.findBookById(datas[i].bookId),
                                  reminder: datas[i].reminders[j],
                                ));

                            if (result != null) {
                              switch (result['mode']) {
                                case 'update':
                                  if (result['result']) {
                                    Utils.showCustomInfoToast(_scaffoldKey.currentContext, StringConst.reminderUpdateSuccess.tr);
                                  } else {
                                    Utils.showCustomErrorToast(_scaffoldKey.currentContext, StringConst.reminderUpdateFail.tr);
                                  }
                                  break;
                                case 'delete':
                                  if (result['result']) {
                                    Utils.showCustomInfoToast(_scaffoldKey.currentContext, StringConst.reminderDeleteSuccess.tr);
                                  } else {
                                    Utils.showCustomErrorToast(_scaffoldKey.currentContext, StringConst.reminderDeleteFail.tr);
                                  }
                                  break;
                                default:
                              }
                            }
                          },
                        ),
                        if (j == datas[i].reminders.length - 1 && i != datas.length - 1)
                          const Divider(
                            height: 16,
                            thickness: 1,
                          ),
                      ],
                    ),
              ],
            ),
          );
        }
      } else {
        mdl.BookReminderData data = dbModel.getBookNotificationData(id: widget.book.id);

        if (data == null || data.reminders.length == 0) {
          screen = EmptyScreen(
            icon: Icons.notifications,
            description: StringConst.yourRemindersWillAppearHere.tr,
          );
        } else {
          screen = Container(
            child: ListView.separated(
              itemCount: data.reminders.length,
              separatorBuilder: (BuildContext context, int index) => const Divider(
                height: 16,
                thickness: 1,
              ),
              padding: EdgeInsets.only(bottom: 20),
              itemBuilder: (BuildContext context, int index) {
                return CustomNotificationCard(
                  book: widget.book,
                  reminder: data.reminders[index],
                  onTap: () async {
                    var result = await Get.to(() => CreateReminderScreen(
                          book: widget.book,
                          reminder: data.reminders[index],
                        ));

                    if (result != null) {
                      switch (result['mode']) {
                        case 'update':
                          if (result['result']) {
                            Utils.showCustomInfoToast(_scaffoldKey.currentContext, StringConst.reminderUpdateSuccess.tr);
                          } else {
                            Utils.showCustomErrorToast(_scaffoldKey.currentContext, StringConst.reminderUpdateFail.tr);
                          }
                          break;
                        case 'delete':
                          if (result['result']) {
                            Utils.showCustomInfoToast(_scaffoldKey.currentContext, StringConst.reminderDeleteSuccess.tr);
                          } else {
                            Utils.showCustomErrorToast(_scaffoldKey.currentContext, StringConst.reminderDeleteFail.tr);
                          }
                          break;
                        default:
                      }
                    }
                  },
                );
              },
            ),
          );
        }
      }
    } else if (dbModel.getRemindersViewState == ViewState.Error || userModel.user.getBooksViewState == ViewState.Error) {
      if (userModel.user.getBooksViewState == ViewState.Error) {
        screen = ErrorScreen(
          function: userModel.getBookList,
        );
      } else if (dbModel.getRemindersViewState == ViewState.Error) {
        screen = ErrorScreen(
          function: dbModel.init,
        );
      }
    }

    return screen;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: StringConst.readingReminders.tr,
        actions: [
          !widget.showAll
              ? IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () async {
                    var result = await Get.to(() => CreateReminderScreen(
                          book: widget.book,
                        ));

                    if (result != null) {
                      if (result['result']) {
                        Utils.showCustomInfoToast(_scaffoldKey.currentContext, StringConst.reminderCreateSuccess.tr);
                      } else {
                        Utils.showCustomErrorToast(_scaffoldKey.currentContext, StringConst.reminderCreateFail.tr);
                      }
                    }
                  },
                )
              : Container(),
        ],
      ),
      body: buildBody(),
    );
  }
}
