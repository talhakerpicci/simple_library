import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';

import '../enums/default_view.dart';
import '../screens/reminders_screen.dart';
import '../values/values.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_form_field.dart';
import '../enums/viewstate.dart';
import '../utils/utils.dart';
import '../viewmodels/user_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/spaces.dart';

import 'buy_premium_screen.dart';
import 'feedback_screen.dart';
import 'genres_screen.dart';
import 'info_screen.dart';
import 'language_screen.dart';
import 'support_us_screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _form = GlobalKey<FormState>();

  bool lockInBackground = true;
  bool notificationsEnabled = true;
  bool isLoading = false;
  String version = '';

  Widget whatsNewTile(title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(
            Icons.check,
            color: Colors.green,
          ),
          SpaceW20(),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: StringConst.trtRegular,
                fontWeight: FontWeight.w400,
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        version = packageInfo.version;
      });
    });
  }

  String getReadingSpeed(UserModel model) {
    if (model.user.getUserDataViewState == ViewState.Busy || model.user.getUserDataViewState == ViewState.Error) {
      return '';
    }
    return '${model.user.readingSpeed.split('-')[0]} ${StringConst.pageS.tr} = ${model.user.readingSpeed.split('-')[1]} ${StringConst.minute.tr}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: StringConst.settingsAppBarTitle.tr),
      body: buildSettingsList(),
    );
  }

  Widget buildSettingsList() {
    var width = MediaQuery.of(context).size.width;
    var model = Provider.of<UserModel>(context, listen: true);

    return LoadingOverlay(
      isLoading: isLoading,
      color: Colors.white,
      opacity: 0.65,
      progressIndicator: const SpinKitCircle(
        color: AppColors.nord1,
        size: 60,
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        children: [
          !model.user.isPremium
              ? GestureDetector(
                  onTap: () {
                    Get.to(() => BuyPremiumScreen(
                          userId: model.user.id,
                        ));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                      top: 5,
                      bottom: 20,
                    ),
                    child: Card(
                      color: AppColors.nord3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: FittedBox(
                                      fit: BoxFit.fitWidth,
                                      child: Text(
                                        StringConst.spPremium,
                                        style: const TextStyle(
                                          fontFamily: StringConst.trtRegular,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SpaceH12(),
                                  Container(
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minWidth: 300.0,
                                        maxWidth: 300.0,
                                        minHeight: 30.0,
                                        maxHeight: 100.0,
                                      ),
                                      child: AutoSizeText(
                                        StringConst.unlockAllTheFeatures.tr,
                                        style: const TextStyle(
                                          fontFamily: StringConst.trtRegular,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 5),
                            child: Column(
                              children: [
                                Container(
                                  child: Icon(
                                    Icons.emoji_events,
                                    size: 60,
                                    color: Colors.yellow[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Container(),
          SettingsSection(
            title: StringConst.account.tr,
            tiles: [
              SettingsTile(
                title: model.user.email,
                leading: const Icon(
                  Icons.person_outline,
                  color: Colors.deepOrange,
                ),
                onPressed: (_) {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: <Widget>[
                          Container(
                            height: 200,
                            width: 400,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.white),
                            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                            child: Column(
                              children: [
                                Text(
                                  model.user.nameSurname,
                                  style: const TextStyle(fontSize: 18),
                                  textAlign: TextAlign.center,
                                ),
                                SpaceH8(),
                                Text(
                                  model.user.email,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SpaceH12(),
                                Text(
                                  StringConst.customTranslation(
                                    key: StringConst.memberSince,
                                    data: Utils.formatter.format(model.user.dateRegistered),
                                  ),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: -25,
                            child: ClipOval(
                              child: Container(
                                height: 70,
                                width: 70,
                                color: Colors.white,
                                child: Utils.getAvatarImage(
                                  model.user.getUserDataViewState != ViewState.Ready ? '' : model.user.image,
                                  Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            child: TextButton(
                              child: Text(
                                StringConst.close.tr,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14.0,
                                ),
                              ),
                              onPressed: () {
                                Get.back();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          SpaceH12(),
          SettingsSection(
            title: StringConst.common.tr,
            tiles: [
              SettingsTile(
                title: StringConst.language.tr,
                subtitle: Utils.selectedLocale != ''
                    ? Utils.availableLanguages[Utils.selectedLocale]
                    : Utils.availableLanguages[Utils.defaultLocale] == null
                        ? StringConst.english.tr
                        : Utils.availableLanguages[Utils.defaultLocale],
                leading: Icon(
                  Icons.language,
                  color: Colors.blue[400],
                ),
                onPressed: (context) async {
                  await Get.to(() => LanguagesScreen());
                  setState(() {});
                },
              ),
              SettingsTile(
                title: StringConst.readingSpeed.tr,
                subtitle: getReadingSpeed(model),
                leading: Icon(
                  Icons.speed,
                  color: Colors.amber[400],
                ),
                onPressed: (context) async {
                  int pages = int.parse(model.user.readingSpeed.split('-')[0]);
                  int minutes = int.parse(model.user.readingSpeed.split('-')[1]);
                  var result = await showDialog(
                    context: context,
                    builder: (BuildContext context) => Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0.0,
                      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
                      backgroundColor: Colors.transparent,
                      child: GestureDetector(
                        onTap: () {
                          Utils.unFocus();
                        },
                        child: Container(
                          height: 210,
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: <Widget>[
                              Container(
                                height: 210,
                                width: width,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.white),
                                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                                child: Column(
                                  children: [
                                    Text(
                                      StringConst.yourReadingSpeed.tr,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: AppColors.nord0,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SpaceH40(),
                                    Form(
                                      key: _form,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Column(
                                            children: [
                                              CustomTextFormField(
                                                textAlign: TextAlign.center,
                                                width: 100,
                                                contentPadding: const EdgeInsets.only(bottom: 5),
                                                keyboardType: TextInputType.number,
                                                digitsOnly: true,
                                                initialValue: pages.toString(),
                                                textStyle: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 30,
                                                ),
                                                hintStyle: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 30,
                                                ),
                                                textCapitalization: TextCapitalization.none,
                                                onChanged: (value) {
                                                  if (value == '') {
                                                    setState(() {
                                                      pages = 0;
                                                    });
                                                  } else {
                                                    setState(() {
                                                      pages = int.parse(value);
                                                    });
                                                  }
                                                },
                                                validator: (value) {
                                                  if (value.toString().isEmpty) {
                                                    return StringConst.enterAValue.tr;
                                                  }
                                                  if (double.parse(value) <= 0) {
                                                    return StringConst.enterAValue.tr;
                                                  }

                                                  return null;
                                                },
                                              ),
                                              SpaceH8(),
                                              Container(
                                                child: Text(
                                                  StringConst.pageS.tr,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SpaceW12(),
                                          Container(
                                            child: Text(
                                              '=',
                                              style: const TextStyle(
                                                fontSize: 30,
                                              ),
                                            ),
                                          ),
                                          SpaceW12(),
                                          Column(
                                            children: [
                                              CustomTextFormField(
                                                textAlign: TextAlign.center,
                                                width: 100,
                                                contentPadding: const EdgeInsets.only(bottom: 5),
                                                keyboardType: TextInputType.number,
                                                digitsOnly: true,
                                                initialValue: minutes.toString(),
                                                textStyle: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 30,
                                                ),
                                                hintStyle: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 30,
                                                ),
                                                textCapitalization: TextCapitalization.none,
                                                onChanged: (value) {
                                                  if (value == '') {
                                                    setState(() {
                                                      minutes = 0;
                                                    });
                                                  } else {
                                                    setState(() {
                                                      minutes = int.parse(value);
                                                    });
                                                  }
                                                },
                                                validator: (value) {
                                                  if (value.toString().isEmpty) {
                                                    return StringConst.enterAValue.tr;
                                                  }
                                                  if (double.parse(value) <= 0) {
                                                    return StringConst.enterAValue.tr;
                                                  }

                                                  return null;
                                                },
                                              ),
                                              SpaceH8(),
                                              Container(
                                                child: Text(
                                                  StringConst.minuteS.tr,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                right: 10,
                                bottom: 4,
                                child: Row(
                                  children: [
                                    TextButton(
                                      child: Text(
                                        StringConst.cancel.tr,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                      onPressed: () {
                                        Get.back();
                                      },
                                    ),
                                    TextButton(
                                      child: Text(
                                        StringConst.done.tr,
                                        style: const TextStyle(
                                          color: AppColors.nord1,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                      onPressed: () {
                                        final isValid = _form.currentState.validate();
                                        if (!isValid) {
                                          return;
                                        }
                                        Utils.unFocus();
                                        Get.back(result: {
                                          'pages': pages,
                                          'minutes': minutes,
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );

                  if (result != null && double.parse(model.user.readingSpeed.split('-')[0]) != pages || double.parse(model.user.readingSpeed.split('-')[1]) != minutes) {
                    setState(() {
                      isLoading = true;
                    });

                    if (!(await Utils.isOnline())) {
                      Utils.showFlushError(
                        context,
                        StringConst.makeSureYouAreOnline.tr,
                      );
                      setState(() {
                        isLoading = false;
                      });
                      return;
                    }

                    var result = await model.updateReadingSpeed(
                      pages: pages,
                      minutes: minutes,
                    );

                    if (result) {
                      Utils.showCustomInfoToast(context, StringConst.successfulyUpdated.tr);
                    } else {
                      Utils.showCustomErrorToast(context, StringConst.anErrorOccured.tr);
                    }

                    setState(() {
                      isLoading = false;
                    });
                  }
                },
              ),
              SettingsTile(
                title: StringConst.defaultView.tr,
                subtitle: model.user.defaultView == DefaultView.GRID ? StringConst.gridView.tr : StringConst.listView.tr,
                leading: Icon(
                  Icons.view_agenda_outlined,
                  color: Colors.purple[400],
                ),
                onPressed: (context) async {
                  var result = await showModalBottomSheet<DefaultView>(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        height: 130,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                leading: const Icon(Icons.grid_view),
                                trailing: model.user.defaultView == DefaultView.GRID ? Icon(Icons.check, color: Colors.green) : null,
                                title: Text(
                                  StringConst.gridView.tr,
                                  style: const TextStyle(
                                    fontFamily: StringConst.trtRegular,
                                  ),
                                ),
                                onTap: () {
                                  Get.back(result: DefaultView.GRID);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.list),
                                trailing: model.user.defaultView == DefaultView.LIST ? Icon(Icons.check, color: Colors.green) : null,
                                title: Text(
                                  StringConst.listView.tr,
                                  style: const TextStyle(
                                    fontFamily: StringConst.trtRegular,
                                  ),
                                ),
                                onTap: () {
                                  Get.back(result: DefaultView.LIST);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );

                  if (result != null) {
                    await model.setDefaultViewSetting(result);
                  }
                },
              ),
              SettingsTile(
                title: StringConst.genres.tr,
                leading: Icon(
                  Icons.category_outlined,
                  color: Colors.deepOrange,
                ),
                onPressed: (context) {
                  Get.to(() => GenresScreen());
                },
              ),
              SettingsTile(
                title: StringConst.readingReminders.tr,
                leading: Icon(
                  Icons.notifications_none,
                  color: Colors.green[400],
                ),
                onPressed: (context) {
                  Get.to(() => RemindersScreen(showAll: true));
                },
              ),
            ],
          ),
          SpaceH12(),
          SettingsSection(
            title: StringConst.other.tr,
            tiles: [
              SettingsTile(
                title: StringConst.about.tr,
                leading: Icon(
                  Icons.info_outline,
                  color: Colors.red[400],
                ),
                onPressed: (context) {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: <Widget>[
                          Container(
                            height: 250,
                            width: 400,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.white),
                            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                            child: Column(
                              children: [
                                SpaceH50(),
                                Container(
                                  child: Text(
                                    StringConst.appName,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SpaceH8(),
                                Container(
                                  padding: const EdgeInsets.only(left: 10, right: 10),
                                  child: Text(
                                    StringConst.developedBy.tr,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: StringConst.trtRegular,
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                                SpaceH12(),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 20,
                            child: Container(
                              height: 70,
                              width: 70,
                              child: Image.asset(
                                StringConst.iconPath,
                                width: width,
                                height: 100,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: CustomButton(
                                height: 30,
                                width: 200,
                                title: StringConst.visitMyWebsite.tr,
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: StringConst.trtRegular,
                                  color: Colors.white,
                                ),
                                borderRadius: 30,
                                onPressed: () {
                                  launch(StringConst.myWebsite);
                                },
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: GestureDetector(
                              child: const Icon(
                                Icons.close,
                                color: Colors.black,
                                size: 20,
                              ),
                              onTap: () {
                                Get.back();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SettingsTile(
                title: StringConst.shareApp.tr,
                leading: Icon(
                  Icons.share,
                  color: Colors.blue[400],
                ),
                onPressed: (context) {
                  Share.share(StringConst.appLink);
                },
              ),
              SettingsTile(
                title: StringConst.rateUs.tr,
                leading: Icon(
                  Icons.star_border,
                  color: Colors.yellow[700],
                ),
                onPressed: (context) async {
                  await launch(StringConst.appLink);
                },
              ),
              SettingsTile(
                title: StringConst.supportUs.tr,
                leading: Icon(
                  Icons.monetization_on_outlined,
                  color: Colors.green[400],
                ),
                onPressed: (context) {
                  Get.to(() => SupportUsScreen());
                },
              ),
              SettingsTile(
                title: StringConst.faqs.tr,
                leading: Icon(
                  Icons.help_outline,
                  color: Colors.cyan[400],
                ),
                onPressed: (context) {
                  Get.to(() => InfoScreen());
                },
              ),
              SettingsTile(
                title: StringConst.feedback.tr,
                leading: Icon(
                  Icons.email_outlined,
                  color: Colors.purple[400],
                ),
                onPressed: (context) {
                  Get.to(() => FeedbackScreen());
                },
              ),
              SettingsTile(
                title: StringConst.customTranslation(
                  key: StringConst.whatsNewInVersion,
                  data: version,
                ),
                leading: Icon(
                  Icons.new_releases_outlined,
                  color: Colors.red[400],
                ),
                onPressed: (context) {
                  Utils.showWhatsNew(context, version: version);
                },
              ),
            ],
          ),
          CustomSection(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 22, bottom: 8),
                  child: Image.asset(
                    StringConst.iconPath,
                    height: 50,
                    width: 50,
                  ),
                ),
                Text(
                  '${StringConst.version.tr}: $version',
                  style: const TextStyle(
                    color: Color(0xFF777777),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
