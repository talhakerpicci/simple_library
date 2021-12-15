import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:get/get.dart';

import '../values/values.dart';
import '../utils/utils.dart';
import '../enums/viewstate.dart';
import '../model/models.dart' as mdl;

class DbModel extends ChangeNotifier {
  Map<String, mdl.BookReminderData> reminders = {};
  ViewState getRemindersViewState = ViewState.Busy;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Box box;
  String localTimeZone;
  String utcTimeZone;

  Future<void> init() async {
    try {
      if (!Hive.isAdapterRegistered(mdl.BookReminderDataAdapter().typeId)) {
        Hive.registerAdapter(mdl.BookReminderDataAdapter());
      }
      if (!Hive.isAdapterRegistered(mdl.ReminderAdapter().typeId)) {
        Hive.registerAdapter(mdl.ReminderAdapter());
      }
      if (!Hive.isAdapterRegistered(mdl.RepetitionAdapter().typeId)) {
        Hive.registerAdapter(mdl.RepetitionAdapter());
      }

      getNotifications();
      getRemindersViewState = ViewState.Ready;
    } catch (e) {
      getRemindersViewState = ViewState.Error;
    }
    notifyListeners();
  }

  Future getNotifications() async {
    box = await Hive.openBox('reminders');
    box.keys.forEach((key) {
      mdl.BookReminderData data = box.get(key);
      reminders.addAll({data.bookId: data});
    });
  }

  Future<bool> createReminder({mdl.Book bookData, mdl.Reminder reminder}) async {
    bool success = true;

    try {
      if (reminders[bookData.id] == null) {
        mdl.BookReminderData data = mdl.BookReminderData(
          bookId: bookData.id,
          reminders: [
            reminder,
          ],
        );
        // Saving to hive
        await box.put(bookData.id, data);

        // Adding to map
        reminders[bookData.id] = data;
      } else {
        mdl.BookReminderData data = box.get(bookData.id);
        data.reminders.add(reminder);
        await data.save();

        reminders[bookData.id] = data;
      }

      // Creating notification
      await createNotification(bookData: bookData, reminder: reminder);
    } catch (e) {
      success = false;
    }

    notifyListeners();

    return success;
  }

  Future<bool> updateReminder({mdl.Book bookData, mdl.Reminder reminder, List<int> oldDays}) async {
    bool success = true;

    try {
      await cancelNotification(notifId: reminder.id, days: oldDays);

      mdl.BookReminderData data = box.get(bookData.id);
      int index = data.reminders.indexWhere((rmndr) => rmndr.id == reminder.id);
      data.reminders[index] = reminder;
      await data.save();

      await createNotification(bookData: bookData, reminder: reminder);
    } catch (e) {
      success = false;
    }

    notifyListeners();

    return success;
  }

  Future<bool> deleteReminder({mdl.Reminder reminder, String bookId}) async {
    bool success = true;

    try {
      await cancelNotification(notifId: reminder.id, days: reminder.days);
      reminders[bookId].reminders.removeWhere((notif) => notif.id == reminder.id);
      await reminders[bookId].save();

      if (reminders[bookId].reminders.isEmpty) {
        await reminders[bookId].delete();
        reminders.remove(bookId);
      }
    } catch (e) {
      success = false;
    }

    notifyListeners();

    return success;
  }

  Future<bool> deleteAllReminders() async {
    bool success = true;

    try {
      await box.deleteFromDisk();
      reminders.clear();
      getRemindersViewState = ViewState.Busy;
    } catch (e) {
      success = false;
    }

    notifyListeners();

    return success;
  }

  Future<bool> createNotification({mdl.Book bookData, mdl.Reminder reminder}) async {
    bool success = true;

    try {
      if (reminder.repetition == mdl.Repetition.Once || reminder.repetition == mdl.Repetition.Daily) {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          reminder.id.hashCode,
          StringConst.readingReminder.tr,
          reminder.customMessage != '' ? reminder.customMessage : StringConst.customTranslation(key: StringConst.readingReminderFor, data: bookData.title),
          Utils.nextInstanceOfHour(
            hour: int.parse(reminder.timeOfDay.split(':')[0]),
            minute: int.parse(reminder.timeOfDay.split(':')[1]),
          ),
          NotificationDetails(android: Utils.androidNotificationDetails),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: reminder.repetition == mdl.Repetition.Daily ? DateTimeComponents.time : null,
        );
      } else {
        reminder.days.forEach((int day) async {
          await flutterLocalNotificationsPlugin.zonedSchedule(
            (reminder.id + '$day').hashCode,
            StringConst.readingReminder.tr,
            reminder.customMessage != '' ? reminder.customMessage : StringConst.customTranslation(key: StringConst.readingReminderFor, data: bookData.title),
            Utils.nextInstanceOfDayWithHour(
              day: day,
              hour: int.parse(reminder.timeOfDay.split(':')[0]),
              minute: int.parse(reminder.timeOfDay.split(':')[1]),
            ),
            NotificationDetails(android: Utils.androidNotificationDetails),
            androidAllowWhileIdle: true,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          );
        });
      }
    } catch (e) {
      success = false;
    }

    return success;
  }

  Future<bool> cancelNotification({String notifId, List<int> days}) async {
    bool success = true;

    try {
      if (days.length == 0) {
        await flutterLocalNotificationsPlugin.cancel(notifId.hashCode);
      } else {
        days.forEach((day) async {
          await flutterLocalNotificationsPlugin.cancel((notifId + '$day').hashCode);
        });
      }
    } catch (e) {
      success = false;
    }

    notifyListeners();

    return success;
  }

  Future<bool> canceAllNotificationsForBook({String bookId}) async {
    bool success = true;

    try {
      reminders[bookId].reminders.forEach((reminder) async {
        if (reminder.days.length == 0) {
          await flutterLocalNotificationsPlugin.cancel(reminder.id.hashCode);
        } else {
          reminder.days.forEach((day) async {
            await flutterLocalNotificationsPlugin.cancel((reminder.id + '$day').hashCode);
          });
        }
      });
      await reminders[bookId].delete();
      reminders.remove(bookId);
    } catch (e) {
      success = false;
    }

    notifyListeners();

    return success;
  }

  Future<bool> canceAllNotifications() async {
    bool success = true;

    try {
      await flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      success = false;
    }

    notifyListeners();

    return success;
  }

  List<mdl.BookReminderData> getAllReminders() {
    return reminders.values.toList();
  }

  mdl.BookReminderData getBookNotificationData({String id}) {
    return reminders[id];
  }
}
